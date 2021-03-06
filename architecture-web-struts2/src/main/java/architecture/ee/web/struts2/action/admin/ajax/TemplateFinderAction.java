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
package architecture.ee.web.struts2.action.admin.ajax;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import architecture.common.util.StringUtils;
import architecture.ee.web.struts2.action.support.FinderActionSupport;
import architecture.ee.web.util.WebApplicatioinConstants;

public class TemplateFinderAction extends FinderActionSupport{

	private boolean customized	= false;
	
	private String path = null ;	
	
	private ResourceLoader resourceLoader = new DefaultResourceLoader();

	public TemplateFinderAction()  {
		
	}
	
	
	/**
	 * @return customized
	 */
	public boolean isCustomized() {
		return customized;
	}


	/**
	 * @param customized 설정할 customized
	 */
	public void setCustomized(boolean customized) {
		this.customized = customized;
	}

	
	/**
	 * @return path
	 */
	public String getPath() {
		return path;
	}


	/**
	 * @param path 설정할 path
	 */
	public void setPath(String path) {
		this.path = path;
	}

	public String getTargetFileContent(){		
		try {
			File targetFile = getTargetResource().getFile();
			if( !targetFile.isDirectory() ){
				return FileUtils.readFileToString(targetFile);				
			}
		} catch (IOException e) {			
		}
		return "";
	}

	public List<FileInfo> getTargetFiles(){
		
		Resource root = getTargetRootResource();	
		List<FileInfo> list = new ArrayList<FileInfo>();
		boolean opt = useCustomizedTemplateSource();
		try {
			File file = root.getFile();			
			if( StringUtils.isEmpty(path) ){
				for( File f : file.listFiles()){
					list.add(new FileInfo( file , f, opt));
				}			
			}else{
				File targetFile = getTargetResource().getFile();
				for( File f : targetFile.listFiles()){
					list.add(new FileInfo( file , f, opt));
				}				
			}
		} catch (IOException e) {
			log.error(e);
		}
		return list;
	}
	
	
	public Resource getTargetResource(){
		return getResourceLoader().getResource( getTemplateSrouceLocation() +  this.path);
	}
	
	public Resource getTargetRootResource(){
		return getResourceLoader().getResource(getTemplateSrouceLocation());
	}

    
    public String getCustomizedTemplateSrouceLocation(){
    	return getApplicationProperty("view.html.customize.source.location",  null );	
    }
        
    public String getTemplateSrouceLocation(){
    	if(useCustomizedTemplateSource()){
    		return getCustomizedTemplateSrouceLocation();
    	}else{    	
    		return getApplicationProperty(WebApplicatioinConstants.VIEW_FREEMARKER_SOURCE_LOCATION, null);
    	}
    }
 
    public boolean isCustomizedEnabled(){		
		return getApplicationBooleanProperty("view.html.customize.enabled", false);
	}
    
    protected boolean useCustomizedTemplateSource(){
    	if(customized && isCustomizedEnabled() ){
    		String path = getCustomizedTemplateSrouceLocation();
    		if(StringUtils.isNotBlank(path))
    			return true;
    	}
    	return false;
    }
    
    
    
}
