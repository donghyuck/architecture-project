/*
 * Copyright 2012, 2013 Donghyuck, Son
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package architecture.ee.web.site;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import architecture.common.user.Company;
import architecture.common.user.CompanyManager;
import architecture.common.user.User;
import architecture.common.user.UserManager;
import architecture.common.util.StringUtils;
import architecture.ee.web.model.DataSourceRequest.FilterDescriptor;
import architecture.ee.web.site.dao.WebSiteDao;
import architecture.ee.web.site.page.WebPage;
import architecture.ee.web.util.WebSiteUtils;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class DefaultWebSiteManager implements WebSiteManager {

    private Log log = LogFactory.getLog(getClass());

    private UserManager userManager;

    private CompanyManager companyManager;

    private WebSiteDao webSiteDao;

    private Cache webSiteCache;

    private Cache webSiteIdCache;

    private Cache webSiteUrlCache;

    private Cache webPageIdCache;

    private Cache webPageCache;

    public DefaultWebSiteManager() {

    }
    

    /**
     * @return webSiteUrlCache
     */
    public Cache getWebSiteUrlCache() {
	return webSiteUrlCache;
    }

    /**
     * @param webSiteUrlCache
     *            설정할 webSiteUrlCache
     */
    public void setWebSiteUrlCache(Cache webSiteUrlCache) {
	this.webSiteUrlCache = webSiteUrlCache;
    }

    /**
     * @return userManager
     */
    public UserManager getUserManager() {
	return userManager;
    }

    /**
     * @param userManager
     *            설정할 userManager
     */
    public void setUserManager(UserManager userManager) {
	this.userManager = userManager;
    }

    /**
     * @return companyManager
     */
    public CompanyManager getCompanyManager() {
	return companyManager;
    }

    /**
     * @param companyManager
     *            설정할 companyManager
     */
    public void setCompanyManager(CompanyManager companyManager) {
	this.companyManager = companyManager;
    }

    /**
     * @return webPageIdCache
     */
    public Cache getWebPageIdCache() {
	return webPageIdCache;
    }

    /**
     * @param webPageIdCache
     *            설정할 webPageIdCache
     */
    public void setWebPageIdCache(Cache webPageIdCache) {
	this.webPageIdCache = webPageIdCache;
    }

    /**
     * @return webPageCache
     */
    public Cache getWebPageCache() {
	return webPageCache;
    }

    /**
     * @param webPageCache
     *            설정할 webPageCache
     */
    public void setWebPageCache(Cache webPageCache) {
	this.webPageCache = webPageCache;
    }

    /**
     * @return webSiteDao
     */
    public WebSiteDao getWebSiteDao() {
	return webSiteDao;
    }

    /**
     * @param webSiteDao
     *            설정할 webSiteDao
     */
    public void setWebSiteDao(WebSiteDao webSiteDao) {
	this.webSiteDao = webSiteDao;
    }

    /**
     * @return webSiteCache
     */
    public Cache getWebSiteCache() {
	return webSiteCache;
    }

    /**
     * @param webSiteCache
     *            설정할 webSiteCache
     */
    public void setWebSiteCache(Cache webSiteCache) {
	this.webSiteCache = webSiteCache;
    }

    /**
     * @return webSiteIdCache
     */
    public Cache getWebSiteIdCache() {
	return webSiteIdCache;
    }

    /**
     * @param webSiteIdCache
     *            설정할 webSiteIdCache
     */
    public void setWebSiteIdCache(Cache webSiteIdCache) {
	this.webSiteIdCache = webSiteIdCache;
    }

    /**
     * @return webSiteUrlCache
     */
    public Cache getWebSiteUrllCache() {
	return webSiteUrlCache;
    }

    /**
     * @param webSiteUrlCache
     *            설정할 webSiteUrlCache
     */
    public void setWebSiteUrllCache(Cache webSiteUrllCache) {
	this.webSiteUrlCache = webSiteUrllCache;
    }

    private WebSite getWebSiteFromCacheById(long id) {
	if (webSiteCache.get(id) != null)
	    return (WebSite) webSiteCache.get(id).getValue();
	else
	    return null;
    }

    @Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
    public void createWebSite(String name, String description, String displayName, String url,
	    boolean allowAnonymousAccess, Company company, User user) throws WebSiteAlreadyExistsExcaption {
	DefaultWebSite site = new DefaultWebSite(name, description, displayName, url, allowAnonymousAccess, true,
		company, user);
	createWebSite(site);
    }

    @Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
    public void createWebSite(WebSite webSite) throws WebSiteAlreadyExistsExcaption {

	if (StringUtils.isNotEmpty(webSite.getName()) && webSiteDao.findWebSitesByName(webSite.getName()).size() > 0) {
	    throw new WebSiteAlreadyExistsExcaption();
	}

	if (StringUtils.isNotEmpty(webSite.getUrl()) && webSiteDao.findWebSitesByUrl(webSite.getUrl()).size() > 0) {
	    throw new WebSiteAlreadyExistsExcaption();
	}

	webSiteDao.createWebSite(webSite);
    }

    @Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
    public void updateWebSite(WebSite webSite) throws WebSiteAlreadyExistsExcaption, WebSiteNotFoundException {
	WebSite old = getWebSiteById(webSite.getWebSiteId());
	if (!StringUtils.equals(old.getUrl(), webSite.getUrl())) {
	    if (webSiteDao.findWebSitesByUrl(webSite.getUrl()).size() > 0) {
		throw new WebSiteAlreadyExistsExcaption();
	    } else {
		webSiteUrlCache.remove(old.getUrl());
	    }
	}
	if (!StringUtils.equals(old.getName(), webSite.getName())) {
	    if (webSiteDao.findWebSitesByName(webSite.getName()).size() > 0) {
		throw new WebSiteAlreadyExistsExcaption();
	    } else {
		webSiteIdCache.remove(old.getName());
	    }
	}
	webSiteDao.updateWebSite(webSite);
    }

    public List<WebSite> getWebSites(Company company) {
	List<Long> ids = webSiteDao.getWebSiteIds(company.getCompanyId());
	List<WebSite> sites = new ArrayList<WebSite>(ids.size());
	for (Long id : ids) {
	    try {
		sites.add(getWebSiteById(id));
	    } catch (WebSiteNotFoundException e) {
	    }
	}
	return sites;
    }

    public int getWebCount(Company company) {
	return webSiteDao.getWebSiteCount(company.getCompanyId());
    }

    public List<WebSite> findWebSitesByName(String name) {
	List<Long> ids = webSiteDao.findWebSitesByName(name);
	List<WebSite> sites = new ArrayList<WebSite>(ids.size());
	for (Long id : ids) {
	    try {
		sites.add(getWebSiteById(id));
	    } catch (WebSiteNotFoundException e) {
	    }
	}
	return sites;
    }

    public List<WebSite> findWebSitesByUrl(String url) {
	List<Long> ids = webSiteDao.findWebSitesByUrl(url);
	List<WebSite> sites = new ArrayList<WebSite>(ids.size());
	for (Long id : ids) {
	    try {
		sites.add(getWebSiteById(id));
	    } catch (WebSiteNotFoundException e) {
	    }
	}
	return sites;
    }

    public WebSite getWebSiteByName(String name) throws WebSiteNotFoundException {
	Long webSiteId = -1L;
	if (webSiteIdCache.get(name) != null) {
	    webSiteId = (Long) webSiteIdCache.get(name).getValue();
	}
	if (webSiteId < 0) {
	    webSiteId = webSiteDao.getWebSiteByName(name).getWebSiteId();
	    webSiteIdCache.put(new Element(name, webSiteId));
	}
	return getWebSiteById(webSiteId);
    }

    public WebSite getWebSiteByUrl(String url) throws WebSiteNotFoundException {

	Long webSiteId = -1L;
	if (webSiteIdCache.get(url) != null) {
	    webSiteId = (Long) webSiteUrlCache.get(url).getValue();
	}

	if (webSiteId < 0) {
	    for (WebSiteDomainMapper mapper : webSiteDao.getWebSiteDomainMappers()) {
		if (mapper.isMatch(url)) {
		    webSiteId = mapper.getWebSiteId();
		    webSiteUrlCache.put(new Element(url, webSiteId));
		    break;
		}
	    }
	}
	
	if( webSiteId < 0)
	    throw new WebSiteNotFoundException();	
	return getWebSiteById(webSiteId);
    }

    public WebSite getWebSiteById(long webSiteId) throws WebSiteNotFoundException {
	WebSite webSite;
	if (webSiteCache.get(webSiteId) != null) {
	    webSite = (WebSite) webSiteCache.get(webSiteId).getValue();
	} else {
	    webSite = webSiteDao.getWebSiteById(webSiteId);
	    try {
		log.debug("set user " + webSite.getUser().getUserId() );		
		
		((DefaultWebSite) webSite).setUser(userManager.getUser(webSite.getUser().getUserId()));
		log.debug("set company " + webSite.getCompany().getCompanyId() );
		
		((DefaultWebSite) webSite).setCompany(companyManager.getCompany(webSite.getCompany().getCompanyId()));
		
		if (webSite.getMenu().getMenuId() > 0)
		    ((DefaultWebSite) webSite).setMenu(WebSiteUtils.getMenu(webSite.getMenu().getMenuId()));
		else
		    ((DefaultWebSite) webSite).setMenu(WebSiteUtils.getDefaultMenu());
		
	    } catch (Exception e) {
	    }
	    webSiteCache.put(new Element(webSiteId, webSite));
	}
	return webSite;
    }

    public void refreshWebSite(WebSite webSite) {
	if (webSite.getWebSiteId() > 0) {
	    webSiteCache.remove(webSite.getWebSiteId());
	}
    }

    @Override
    public WebPage getWebPageByName(WebSite website, String name) throws WebPageNotFoundException {
	String pageKey = getWebPageKey(website.getName(), name);
	Long pageId = -1L;
	if (webPageIdCache.get(pageKey) != null) {
	    pageId = (Long) webPageIdCache.get(pageKey).getValue();
	}
	if (pageId < 0) {
	    WebPage page = webSiteDao.getWebPageByName(website.getWebSiteId(), name);
	    webPageIdCache.put(new Element(pageKey, page.getWebPageId()));
	    pageId = page.getWebPageId();
	    this.webPageCache.remove(pageId);
	    this.webPageCache.put(new Element(pageId, page));

	}
	return getWebPageById(pageId);
    }

    protected String getWebPageKey(String site, String file) {
	return site.toLowerCase() + "_" + file.toLowerCase();
    }

    public WebPage getWebPageById(Long webPageId) throws WebPageNotFoundException {
	WebPage webPage;
	if (webPageCache.get(webPageId) != null) {
	    webPage = (WebPage) webPageCache.get(webPageId).getValue();
	} else {
	    webPage = webSiteDao.getWebPageById(webPageId);
	    webPageCache.put(new Element(webPageId, webPage));
	}
	return webPage;
    }

    @Override
    public void updateWebPage(WebPage page) {
	boolean isNewPage = page.getWebPageId() <= 0L;
	Date now = Calendar.getInstance().getTime();
	if (isNewPage) {
	    page.setCreationDate(now);
	    page.setModifiedDate(now);
	    webSiteDao.createWebPage(page);
	} else {
	    page.setModifiedDate(now);
	    webSiteDao.updateWebPage(page);
	}
	if (webPageCache != null) {
	    webPageCache.remove(page.getWebPageId());
	}
    }

    @Override
    public void removeWebPage(WebPage page) {
	webSiteDao.deleteWebPage(page);
	if (webPageCache != null) {
	    webPageCache.remove(page.getWebPageId());
	}
    }

    @Override
    public List<WebPage> getWebPages(WebSite website) {
	List<Long> IDs = webSiteDao.getWebPageIds(website.getWebSiteId());
	List<WebPage> list = new ArrayList<WebPage>();
	for (Long webPageId : IDs) {
	    try {
		list.add(getWebPageById(webPageId));
	    } catch (WebPageNotFoundException e) {
	    }
	}
	return list;
    }

    @Override
    public List<WebPage> getWebPages(WebSite website, int startIndex, int maxResults) {
	List<Long> IDs = webSiteDao.getWebPageIds(website.getWebSiteId(), startIndex, maxResults);
	List<WebPage> list = new ArrayList<WebPage>();
	for (Long webPageId : IDs) {
	    try {
		list.add(getWebPageById(webPageId));
	    } catch (WebPageNotFoundException e) {
	    }
	}
	return list;
    }

    
    @Override
    public int getWebPageCount(WebSite website) {
	return webSiteDao.getWebPageCount(website.getWebSiteId());
    }


    @Override
    public List<WebPage> getWebPages(WebSite website, List<FilterDescriptor> filters) {
	List<Long> IDs = webSiteDao.getWebPageIds(website.getWebSiteId(), filters );
	List<WebPage> list = new ArrayList<WebPage>();
	for (Long webPageId : IDs) {
	    try {
		list.add(getWebPageById(webPageId));
	    } catch (WebPageNotFoundException e) {
	    }
	}
	return list;
    }


    @Override
    public List<WebPage> getWebPages(WebSite website, List<FilterDescriptor> filters, int startIndex, int maxResults) {
	List<Long> IDs = webSiteDao.getWebPageIds(website.getWebSiteId(), filters,  startIndex, maxResults);
	List<WebPage> list = new ArrayList<WebPage>();
	for (Long webPageId : IDs) {
	    try {
		list.add(getWebPageById(webPageId));
	    } catch (WebPageNotFoundException e) {
	    }
	}
	return list;
    }


    @Override
    public int getWebPageCount(WebSite website, List<FilterDescriptor> filters) {
	return webSiteDao.getWebPageCount(website.getWebSiteId(), filters);
    }

}
