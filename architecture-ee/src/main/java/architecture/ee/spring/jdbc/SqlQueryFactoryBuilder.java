/*
 * Copyright 2010, 2011 INKIUM, Inc.
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
package architecture.ee.spring.jdbc;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import architecture.common.scanner.DirectoryListener;
import architecture.ee.jdbc.query.builder.xml.XmlSqlBuilder;
import architecture.ee.jdbc.query.factory.Configuration;
import architecture.ee.jdbc.query.factory.ConfigurationFactory;
import architecture.ee.jdbc.query.factory.SqlQueryFactory;
import architecture.ee.jdbc.query.factory.impl.SqlQueryFactoryImpl;

/**
 * SqlQueryFactory 객체를 생성하는 클래스.
 * 
 * @author DongHyuck, Son
 * 
 */
public class SqlQueryFactoryBuilder implements DirectoryListener {

	private Log log = LogFactory.getLog(getClass());

	private String prefix = "";
	
	private String suffix = "queryset.xml";
	
	private ResourceLoader resourceLoader;

	private DataSource defaultDataSource;

	private List<String> resourceLocations;

	public SqlQueryFactoryBuilder() {
		this.resourceLoader = new DefaultResourceLoader();
		this.defaultDataSource = null;
		this.resourceLocations = Collections.EMPTY_LIST;
	}
	

	public SqlQueryFactory createSqlQueryFactory() { 
		loadResourceLocations();
		return createSqlQueryFactory(ConfigurationFactory.getConfiguration(), defaultDataSource);
	}

	public SqlQueryFactory createSqlQueryFactory(Configuration configuration, DataSource dataSource) {
		SqlQueryFactory factory = new SqlQueryFactoryImpl(configuration);
		factory.setDefaultDataSource(dataSource);
		return factory;
	}
	
	protected void buildSqlFromInputStream(InputStream inputStream, Configuration configuration) {
		XmlSqlBuilder builder = new XmlSqlBuilder(inputStream, configuration);
		builder.build();
	}

	public ResourceLoader getResourceLoader() {
		return resourceLoader;
	}

	public List<String> getResourceLocations() {
		return resourceLocations;
	}

	protected void loadResourceLocations() {
		try {
			Configuration configuration = ConfigurationFactory.getConfiguration();
			for (String path : resourceLocations) {
				if (!configuration.isResourceLoaded(path)) {					
					Resource resource = getResourceLoader().getResource(path);
					if (resource.exists()) {
						
						URL url = resource.getURL();						
						if("file".equals(url.getProtocol()) && resource.getFile().exists()){
							//directoryScanner.addScanURL(url);
						}else{
							buildSqlFromInputStream(resource.getInputStream(), configuration);
							configuration.addLoadedResource(url.getPath());
						}						
					}
				}
			}
		} catch (Exception e) {
		}

	}

	public void setDefaultDataSource(DataSource dataSource) {
		this.defaultDataSource = dataSource;
	}

	public void setResourceLoader(ResourceLoader loader) {
		resourceLoader = loader;
	}

	public void setResourceLocations(List<String> resourceLocations) {
		this.resourceLocations = resourceLocations;
	}

	public String getPrefix() {
		return prefix;
	}
	/*
	 * Set the prefix that gets prepended to view names when building a URL.
	 */
	public void setPrefix(String prefix) {
		this.prefix = (prefix != null ? prefix : "");
	}

    public String getSuffix() {
		return suffix;
	}
    
	/**
	 * Set the suffix that gets appended to view names when building a URL.
	 */
	public void setSuffix(String suffix) {
		this.suffix = (suffix != null ? suffix : "");
	}
	
		
		private Map<URI, DeployedInfo> deployments = Collections.synchronizedMap(new HashMap<URI, DeployedInfo>());
		
		static class DeployedInfo {
			
			protected long deployedTime;
			protected String name;
			protected URI uri;
			
			public DeployedInfo( URI uri, String name, long deployedTime) {
				this.deployedTime = deployedTime;
				this.name = name;
				this.uri = uri;
			}

			public DeployedInfo( URI uri, long deployedTime) {
				this.deployedTime = deployedTime;
				this.uri = uri;
			}
		}

		public String fileCreated(File file) {
			try {			
				buildSqlFromInputStream(new FileInputStream(file), ConfigurationFactory.getConfiguration());
				DeployedInfo di = new DeployedInfo(file.toURI(), System.currentTimeMillis());
				deployments.put(di.uri, di);
			} catch (FileNotFoundException e) {
			}
			return "success";
		}

		public boolean fileDeleted(File file) {	
			Configuration configuration = ConfigurationFactory.getConfiguration();
			if (configuration.isResourceLoaded(file.toURI().toString())) {
				configuration.removeUriNamespace(file.toURI().toString(), true);
				configuration.removeLoadedResource(file.toURI().toString());
			}			
			DeployedInfo di = deployments.remove(file.toURI());
			return true;
		}

		public void fileChanged(File file) {
			try {
				buildSqlFromInputStream(new FileInputStream(file), ConfigurationFactory.getConfiguration());
				DeployedInfo di = deployments.get(file.toURI());
				di.deployedTime = System.currentTimeMillis(); 
				deployments.put(di.uri, di);
			} catch (FileNotFoundException e) {
			}
		}

		public long getDeploymentTime(File file) {
			if(isFileDeployed(file))
				return deployments.get(file.toURI()).deployedTime;
			return 0;
		}

		public boolean isFileDeployed(File file) {
			return deployments.containsKey(file.toURI());
		}
					
		/**
		 * 
		 * 파일이 유요한 형태의 파일인가를 확인하여 true/false 값을 리턴한다.
		 */
		public boolean validateFile(File file) {
			
						
			boolean readable = file.canRead();
			boolean flag1 = StringUtils.isEmpty(getSuffix()) ? true : file.getName().endsWith(getSuffix());
			boolean flag2 = StringUtils.isEmpty(getPrefix()) ? true : file.getName().startsWith(getPrefix());
			boolean valid = readable && flag1 && flag2;
		
			if (!valid) {
				//if (log.isDebugEnabled())
				//	log.info(MessageFormatter.format("011023", file.getAbsolutePath()));
			}
			
			//log.debug(file.getPath() + "validate:" + valid);
			return valid;
		}
//	}
}