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
package architecture.ee.jdbc.sqlquery.factory;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import architecture.common.jdbc.TypeAliasRegistry;
import architecture.common.util.L10NUtils;
import architecture.common.util.StringUtils;
import architecture.ee.jdbc.sqlquery.SqlNotFoundException;
import architecture.ee.jdbc.sqlquery.builder.SqlBuilderAssistant;
import architecture.ee.jdbc.sqlquery.builder.xml.XmlMapperBuilder;
import architecture.ee.jdbc.sqlquery.builder.xml.XmlStatementBuilder;
import architecture.ee.jdbc.sqlquery.mapping.MapperSource;
import architecture.ee.jdbc.sqlquery.mapping.MappedStatement;
import architecture.ee.jdbc.sqlquery.parser.XNode;

/**
 * @author donghyuck
 */
public class Configuration {

    protected TypeAliasRegistry DEAFULT_TYPE_ALIAS_REGISTRY = new TypeAliasRegistry();

    protected Integer defaultStatementTimeout;

    protected Properties variables = new Properties();

    protected final Set<String> loadedResources = new HashSet<String>();

    /**
     * 파싱되어 매핑된 스테이트 객체들이 저장되는 위치. 다중키는 아파치 commons-collections 패키지에서 제공하는
     * MultiKey (namespace + id) 을 사용하여 구현함. 다중키를 스트링 조합으로 변경함.
     * 
     */
    protected final Map<String, MappedStatement> mappedStatements = new HashMap<String, MappedStatement>();
    
    protected final Map<String, MapperSource> mappers = new HashMap<String, MapperSource>();
    
    protected final Map<String, String> uriNamespace = new HashMap<String, String>();

    public TypeAliasRegistry getTypeAliasRegistry() {
	return DEAFULT_TYPE_ALIAS_REGISTRY;
    }

    public String getUriNamespace(String uri) {
	return uriNamespace.get(uri);
    }

    public void addUriNamespace(String uri, String namespace) {
	uriNamespace.put(uri, namespace);
    }

    public void removeUriNamespace(String uri, boolean forceRemove) {
	if (uriNamespace.containsKey(uri)) {
	    String namespace = getUriNamespace(uri);
	    if (forceRemove) {
		Set<String> keys = mappedStatements.keySet();
		for (String key : keys) {
		    if (StringUtils.startsWith(key, namespace))
			mappedStatements.remove(key);
		}

		if (statementNodesToParse.containsKey(namespace))
		    statementNodesToParse.remove(namespace);
	    }
	    uriNamespace.remove(namespace);
	}
    }

    /** A map holds statement nodes for a namespace. */
    protected final ConcurrentMap<String, List<XNode>> statementNodesToParse = new ConcurrentHashMap<String, List<XNode>>();
    
    protected final ConcurrentMap<String, List<XNode>> mapperNodesToParse = new ConcurrentHashMap<String, List<XNode>>();
    
    public void addMapperNodes(String namespace, List<XNode> nodes) {
	mapperNodesToParse.put(namespace, nodes);
    }
    
    public void addStatementNodes(String namespace, List<XNode> nodes) {
	statementNodesToParse.put(namespace, nodes);
    }

    public void addLoadedResource(String resource) {
	String stringToUse = resource.trim();
	loadedResources.add(stringToUse);
    }

    public boolean isResourceLoaded(String resource) {
	String stringToUse = resource.trim();
	return loadedResources.contains(stringToUse);
    }

    public void removeLoadedResource(String resource) {
	loadedResources.remove(resource);
    }

    /**
     * @return
     */
    public Properties getVariables() {
	return variables;
    }

    /**
     * @param variables
     */
    public void setVariables(Properties variables) {
	this.variables = variables;
    }

    /**
     * Extracts namespace from fully qualified statement id.
     * 
     * @param statementId
     * @return namespace or null when id does not contain period.
     */
    protected String extractNamespace(String statementId) {
	int lastPeriod = statementId.lastIndexOf('.');
	return lastPeriod > 0 ? statementId.substring(0, lastPeriod) : null;
    }

    /**
     * @param defaultStatementTimeout
     */
    public void setDefaultStatementTimeout(Integer defaultStatementTimeout) {
	this.defaultStatementTimeout = defaultStatementTimeout;
    }

    /**
     * Parses all the unprocessed statement nodes in the cache. It is
     * recommended to call this method once all the mappers are added as it
     * provides fail-fast statement validation.
     */
    public void buildAllStatements() {
	if (!statementNodesToParse.isEmpty()) {
	    Set<String> keySet = statementNodesToParse.keySet();
	    for (String namespace : keySet) {
		buildStatementsForNamespace(namespace);
	    }
	}
    }
    
    public void buildAllMappers() {
	if (!this.mapperNodesToParse.isEmpty()) {
	    Set<String> keySet = mapperNodesToParse.keySet();
	    for (String namespace : keySet) {
		buildMappersForNamespace(namespace);
	    }
	}
    }

    public void addMapper(MapperSource factory) {
	mappers.put(factory.getID(), factory);
    }

    public void addMappedStatement(MappedStatement ms) {
	mappedStatements.put(ms.getID(), ms);
    }
    
    
    protected void buildMappersForNamespace(String namespace) {
	if (namespace != null) {
	    final List<XNode> list = mapperNodesToParse.get(namespace);
	    if (list != null) {
		final SqlBuilderAssistant builderAssistant = new SqlBuilderAssistant(this, null);
		builderAssistant.setCurrentNamespace(namespace);
		parseMapperNodes(builderAssistant, list);
		// Remove the processed nodes and resource from the cache.
		mapperNodesToParse.remove(namespace);
	    }
	}
    }
    
   
    protected void parseMapperNodes(final SqlBuilderAssistant builderAssistant, final List<XNode> list) {
	for (XNode context : list) {
	    final XmlMapperBuilder mapperParser = new XmlMapperBuilder(this, builderAssistant, context);
	    mapperParser.parseRowMapperFactoryNode();
	}
    }
    
    
    /**
     * Parses cached statement nodes for the specified namespace and stores the
     * generated mapped statements.
     * 
     * @param namespace
     */
    protected void buildStatementsForNamespace(String namespace) {
	if (namespace != null) {
	    final List<XNode> list = statementNodesToParse.get(namespace);
	    if (list != null) {
		final SqlBuilderAssistant builderAssistant = new SqlBuilderAssistant(this, null);
		builderAssistant.setCurrentNamespace(namespace);
		parseStatementNodes(builderAssistant, list);
		// Remove the processed nodes and resource from the cache.
		statementNodesToParse.remove(namespace);
	    }
	}
    }

    protected void parseStatementNodes(final SqlBuilderAssistant builderAssistant, final List<XNode> list) {
	for (XNode context : list) {
	    final XmlStatementBuilder statementParser = new XmlStatementBuilder(this, builderAssistant, context);
	    statementParser.parseStatementNode();
	}
    }

    /**
     * @return
     */
    public Integer getDefaultStatementTimeout() {
	return defaultStatementTimeout;
    }

    public Collection<String> getMappedStatementNames() {
	buildAllStatements();
	return mappedStatements.keySet();
    }

    
    public Collection<String> getMapperNames() {
	buildAllMappers();
	return mappers.keySet();
    }
    
    
    /**
     * @return
     */
    public Collection<MappedStatement> getMappedStatements() {
	buildAllStatements();
	return mappedStatements.values();
    }

    public MappedStatement getMappedStatement(String id) {
	if (!mappedStatements.containsKey(id)) {
	    buildStatementsFromId(id);
	}
	if (!mappedStatements.containsKey(id))
	    throw new SqlNotFoundException(L10NUtils.format("003281", id));
	return mappedStatements.get(id);
    }
    
    public MapperSource getMapper(String id) {
	if (!this.mappers.containsKey(id)) {
	    buildMappersFromId(id);
	}
	if (!mappers.containsKey(id))
	    throw new SqlNotFoundException(L10NUtils.format("003281", id));
	return mappers.get(id);
    }
    

    protected void buildStatementsFromId(String id) {
	final String namespace = extractNamespace(id);
	buildStatementsForNamespace(namespace);
    }
    
    protected void buildMappersFromId(String id) {
	final String namespace = extractNamespace(id);
	buildMappersForNamespace(namespace);
    }
}