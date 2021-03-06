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
package architecture.ee.web.community.page;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import architecture.common.event.api.EventPublisher;
import architecture.common.event.api.EventSource;
import architecture.common.user.User;
import architecture.common.user.UserManager;
import architecture.common.user.UserNotFoundException;
import architecture.ee.web.community.page.dao.PageDao;
import architecture.ee.web.community.page.dao.PageVersionDao;
import architecture.ee.web.community.page.event.PageEvent;
import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

public class DefaultPageManager implements PageManager, EventSource {

    private Log log = LogFactory.getLog(getClass());
    private UserManager userManager;
    private EventPublisher eventPublisher;

    private PageDao pageDao;

    private PageVersionDao pageVersionDao;

    private Cache pageCache;

    private Cache pageIdCache;

    private Cache pageVersionCache;

    private Cache pageVersionsCache;

    public DefaultPageManager() {

    }

    /**
     * @return pageVersionCache
     */
    public Cache getPageVersionCache() {
	return pageVersionCache;
    }

    /**
     * @param pageVersionCache
     *            설정할 pageVersionCache
     */
    public void setPageVersionCache(Cache pageVersionCache) {
	this.pageVersionCache = pageVersionCache;
    }

    /**
     * @return pageVersionDao
     */
    public PageVersionDao getPageVersionDao() {
	return pageVersionDao;
    }

    /**
     * @param pageVersionDao
     *            설정할 pageVersionDao
     */
    public void setPageVersionDao(PageVersionDao pageVersionDao) {
	this.pageVersionDao = pageVersionDao;
    }

    /**
     * @return pageVersionsCache
     */
    public Cache getPageVersionsCache() {
	return pageVersionsCache;
    }

    /**
     * @param pageVersionsCache
     *            설정할 pageVersionsCache
     */
    public void setPageVersionsCache(Cache pageVersionsCache) {
	this.pageVersionsCache = pageVersionsCache;
    }

    public Page createPage(User user, BodyType bodyType, String name, String title, String body) {
	if (bodyType == null)
	    throw new IllegalArgumentException("A page content type is required to create a page.");
	DefaultPage page = new DefaultPage();

	page.setName(name);
	page.setBodyContent(new DefaultBodyContent(-1L, -1L, bodyType, body));
	page.setTitle(title);
	page.setUser(user);
	return page;
    }

    @Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
    public void updatePage(Page page) {
	updatePage(page, false);
    }

    @Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
    public void updatePage(Page page, boolean forceNewVersion) {
	boolean isNewPage = page.getPageId() == -1L;
	boolean isNewVersionRequired = isNewVersionRequired(forceNewVersion, isNewPage);
	if (isNewPage) {
	    pageDao.create(page);
	    eventPublisher.publish(new PageEvent(page, PageEvent.Type.CREATED));
	} else {
	    pageDao.update(page, isNewVersionRequired);
	    if (page.getPageState() == PageState.DELETED) {
		eventPublisher.publish(new PageEvent(page, PageEvent.Type.DELETED));
	    } else {
		eventPublisher.publish(new PageEvent(page, PageEvent.Type.UPDATED));
	    }

	}

	if (pageCache.get(page.getPageId()) != null) {
	    pageCache.remove(page.getPageId());
	}
	String key = getVersionListCacheKey(page.getPageId());
	if (pageVersionsCache.get(key) != null) {
	    pageVersionsCache.remove(key);
	}
    }

    private boolean isNewVersionRequired(boolean forceNewVersion, boolean isNewPage) {
	boolean isNewVersionRequired = false;
	if (isNewPage)
	    isNewVersionRequired = false;
	else if (forceNewVersion)
	    isNewVersionRequired = true;
	return isNewVersionRequired;
    }

    public Page getPage(long pageId) throws PageNotFoundException {
	if (pageId < 1)
	    throw new PageNotFoundException();

	Page page = null;
	if (pageCache.get(pageId) != null) {
	    page = (Page) pageCache.get(pageId).getValue();
	}

	if (page == null) {
	    try {
		page = pageDao.getPageById(pageId);
		if (page == null)
		    throw new PageNotFoundException();
		setUserInPage(page);

		if (PageState.PUBLISHED == page.getPageState())
		    pageCache.put(new Element(pageId, page));
		pageIdCache.put(new Element(page.getName(), pageId));
	    } catch (Exception e) {
		throw new PageNotFoundException(e);
	    }
	}
	return page;
    }

    public Page getPage(long pageId, int versionId) throws PageNotFoundException {
	if (pageId < 1)
	    throw new PageNotFoundException();
	Page page = findInLocalCache(pageId, versionId);
	if (page == null) {
	    try {
		page = pageDao.getPageById(pageId, versionId);
		if (page == null)
		    throw new PageNotFoundException();

		setUserInPage(page);
		PageVersion pageVersion = PageVersionHelper.getPublishedPageVersion(pageId);
		if (pageVersion != null && pageVersion.getVersionNumber() == versionId) {
		    if (PageState.PUBLISHED == page.getPageState())
			pageCache.put(new Element(pageId, page));
		    pageIdCache.put(new Element(page.getName(), pageId));
		}
	    } catch (Exception e) {
		throw new PageNotFoundException(e);
	    }
	}
	return page;
    }

    protected void setUserInPage(Page page) {
	long userId = page.getUser().getUserId();
	try {
	    page.setUser(userManager.getUser(userId));
	} catch (UserNotFoundException e) {
	}
    }

    public Page findInLocalCache(long pageId, int versionNumber) {

	if (pageCache.get(pageId) != null) {
	    Page page = (Page) pageCache.get(pageId).getValue();
	    if (page.getVersionId() == versionNumber)
		return page;
	}
	return null;
    }

    public Page getPage(String name) throws PageNotFoundException {
	Page pageToUse = null;
	if (pageIdCache.get(name) != null) {
	    Long pageId = (Long) pageIdCache.get(name).getValue();
	    log.debug("using cached pageId : " + pageId);
	    pageToUse = getPage(pageId);
	}
	if (pageToUse == null) {
	    try {
		pageToUse = pageDao.getPageByName(name);
		if (pageToUse == null)
		    throw new PageNotFoundException();
		setUserInPage(pageToUse);
		if (PageState.PUBLISHED == pageToUse.getPageState())
		    pageCache.put(new Element(pageToUse.getPageId(), pageToUse));
		pageIdCache.put(new Element(pageToUse.getName(), pageToUse.getPageId()));
	    } catch (Exception e) {
		throw new PageNotFoundException(e);
	    }
	}
	return pageToUse;
    }

    public Page getPage(String name, int versionId) throws PageNotFoundException {
	// TODO 자동 생성된 메소드 스텁
	return null;
    }

    public List<Page> getPages(int objectType) {
	// TODO 자동 생성된 메소드 스텁
	return null;
    }

    public List<Page> getPages(int objectType, long objectId) {
	List<Long> ids = pageDao.getPageIds(objectType, objectId);
	ArrayList<Page> list = new ArrayList<Page>(ids.size());
	for (Long pageId : ids) {
	    try {
		list.add(getPage(pageId));
	    } catch (PageNotFoundException e) {
	    }
	}
	return list;
    }

    public List<Page> getPages(int objectType, long objectId, int startIndex, int maxResults) {
	List<Long> ids = pageDao.getPageIds(objectType, objectId, startIndex, maxResults);
	ArrayList<Page> list = new ArrayList<Page>(ids.size());
	for (Long pageId : ids) {
	    try {
		list.add(getPage(pageId));
	    } catch (PageNotFoundException e) {
	    }
	}
	return list;
    }

    public int getPageCount(int objectType) {
	return 0;
    }

    public int getPageCount(int objectType, long objectId) {
	return pageDao.getPageCount(objectType, objectId);
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
     * @return pageDao
     */
    public PageDao getPageDao() {
	return pageDao;
    }

    /**
     * @param pageDao
     *            설정할 pageDao
     */
    public void setPageDao(PageDao pageDao) {
	this.pageDao = pageDao;
    }

    /**
     * @return pageCache
     */
    public Cache getPageCache() {
	return pageCache;
    }

    /**
     * @param pageCache
     *            설정할 pageCache
     */
    public void setPageCache(Cache pageCache) {
	this.pageCache = pageCache;
    }

    /**
     * @return pageIdCache
     */
    public Cache getPageIdCache() {
	return pageIdCache;
    }

    /**
     * @param pageIdCache
     *            설정할 pageIdCache
     */
    public void setPageIdCache(Cache pageIdCache) {
	this.pageIdCache = pageIdCache;
    }

    public List<PageVersion> getPageVersions(long pageId) {
	String key = getVersionListCacheKey(pageId);
	List<Integer> versions;
	if (pageVersionsCache.get(key) != null) {
	    versions = (List<Integer>) pageVersionsCache.get(key).getValue();
	} else {
	    versions = this.pageVersionDao.getPageVersionIds(pageId);
	    pageVersionsCache.put(new Element(key, versions));
	}
	List<PageVersion> list = new ArrayList<PageVersion>(versions.size());
	for (Integer version : versions) {
	    list.add(getPageVersion(pageId, version));
	}
	return list;
    }

    private String getVersionCacheKey(long pageId, int versionId) {
	return (new StringBuilder()).append("version-").append(pageId).append("-").append(versionId).toString();
    }

    private String getVersionListCacheKey(long pageId) {
	return (new StringBuilder()).append("versions-").append(pageId).toString();
    }

    protected PageVersion getPageVersion(long pageId, int versionNumber) {
	String key = getVersionCacheKey(pageId, versionNumber);
	PageVersion pv;
	if (pageVersionCache.get(key) != null) {
	    pv = (PageVersion) pageVersionCache.get(key).getObjectValue();
	} else {
	    pv = pageVersionDao.getPageVersion(pageId, versionNumber);
	    pageVersionCache.put(new Element(key, pv));
	}
	return pv;
    }

    @Override
    public List<Page> getPages(int objectType, PageState state) {
	List<Long> ids = pageDao.getPageIds(objectType, state);
	ArrayList<Page> list = new ArrayList<Page>(ids.size());
	for (Long pageId : ids) {
	    try {
		list.add(getPage(pageId));
	    } catch (PageNotFoundException e) {
	    }
	}
	return list;
    }

    @Override
    public List<Page> getPages(int objectType, PageState state, int startIndex, int maxResults) {
	List<Long> ids = pageDao.getPageIds(objectType, state, startIndex, maxResults);
	ArrayList<Page> list = new ArrayList<Page>(ids.size());
	for (Long pageId : ids) {
	    try {
		list.add(getPage(pageId));
	    } catch (PageNotFoundException e) {
	    }
	}
	return list;
    }

    @Override
    public int getPageCount(int objectType, PageState state) {
	return pageDao.getPageCount(objectType, state);
    }

    @Override
    public int getPageCount(int objectType, long objectId, PageState state) {
	return pageDao.getPageCount(objectType, objectId, state);
    }

    @Override
    public List<Page> getPages(int objectType, long objectId, PageState state) {
	List<Long> ids = pageDao.getPageIds(objectType, objectId, state);
	ArrayList<Page> list = new ArrayList<Page>(ids.size());
	for (Long pageId : ids) {
	    try {
		list.add(getPage(pageId));
	    } catch (PageNotFoundException e) {
	    }
	}
	return list;
    }

    @Override
    public List<Page> getPages(int objectType, long objectId, PageState state, int startIndex, int maxResults) {
	List<Long> ids = pageDao.getPageIds(objectType, objectId, state, startIndex, maxResults);
	ArrayList<Page> list = new ArrayList<Page>(ids.size());
	for (Long pageId : ids) {
	    try {
		list.add(getPage(pageId));
	    } catch (PageNotFoundException e) {
	    }
	}
	return list;
    }

    @Override
    public void setEventPublisher(EventPublisher eventPublisher) {
	this.eventPublisher = eventPublisher;
    }
}
