/*
 * Copyright 2012 Donghyuck, Son
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
   
package architecture.ee.web.util;

import java.net.InetAddress;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.UnknownHostException;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import architecture.ee.util.OutputFormat;

public class ServletUtils {
	
	private static Log log = LogFactory.getLog(ServletUtils.class);
	
	public static final String CONTEXT_ROOT_PATH = "";
	
    public static Map getModelMap(HttpServletRequest request, HttpServletResponse response) {
		ModelMap modelMap = (ModelMap) request.getAttribute(WebApplicatioinConstants.MODEL_ATTRIBUTE);
		if (modelMap == null) {
			modelMap = new ModelMap();
		}
		return modelMap;
	}    
    
    
    public static  InetAddress getLocalHost(){
    	try {
			return InetAddress.getLocalHost();
		} catch (UnknownHostException e) {
			return null ;
		}
    }
    
    public static  String  getLocalHostAddr(){
    	InetAddress addr = getLocalHost();
    	if( addr == null )
    		return null;
    	return addr.getHostAddress();
    }
    
    public static String getDomainName(HttpServletRequest request, boolean opt){    	
    	String url = request.getHeader("Referer");
    	
    	return getDomainName( url , opt);
    }
    
    public static String getDomainName(String url, boolean opt){
    	
    	if( StringUtils.isNotEmpty(url)){
    		try {
				URI uri = new URI(url);
				String domain = uri.getHost();
				if( opt )
					return domain.startsWith("www.") ? domain.substring(4) : domain;				
				return domain;	
			} catch (URISyntaxException e) {
			}
    	}
    	return null;
    }    
    
    public static String getContextPath(HttpServletRequest request){    	
    	
    	if( StringUtils.isEmpty(request.getContextPath())){
    		return CONTEXT_ROOT_PATH ;
    	}else if ( StringUtils.equals( "/",  request.getContextPath().trim() ) ){
    		return CONTEXT_ROOT_PATH ;    		
    	}else{
    		return request.getContextPath();
    	}
    }
    
        
	public static String getServletPath(HttpServletRequest request) {
		String thisPath = request.getServletPath();
		if (thisPath == null) {
			String requestURI = request.getRequestURI();
			if (request.getPathInfo() != null)
				thisPath = requestURI.substring(0,
						requestURI.indexOf(request.getPathInfo()));
			else
				thisPath = requestURI;
		} else if (thisPath.equals("") && request.getPathInfo() != null)
			thisPath = request.getPathInfo();
		return thisPath;
	}
	
	
	
	
	public static OutputFormat getOutputFormat(HttpServletRequest httpservletrequest, HttpServletResponse httpservletresponse){
    	String formatString = ParamUtils.getParameter(httpservletrequest, "output", "html");
    	if( StringUtils.isNotEmpty(ParamUtils.getAttribute(httpservletrequest, "output"))){
    		formatString = ParamUtils.getAttribute(httpservletrequest, "output");
    	}    	
    	OutputFormat format = OutputFormat.stingToOutputFormat(formatString);  
    	return format;
	}
	
	public static UAgentInfo getUserAgentInfo(HttpServletRequest httpservletrequest){		
		return new UAgentInfo(httpservletrequest);
		
	}

}
