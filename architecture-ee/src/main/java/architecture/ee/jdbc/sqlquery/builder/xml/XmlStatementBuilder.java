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
package architecture.ee.jdbc.sqlquery.builder.xml;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import architecture.common.jdbc.ParameterMapping;
import architecture.common.jdbc.ResultMapping;
import architecture.common.util.StringUtils;
import architecture.ee.jdbc.sqlquery.builder.AbstractBuilder;
import architecture.ee.jdbc.sqlquery.builder.SqlBuilderAssistant;
import architecture.ee.jdbc.sqlquery.builder.xml.dynamic.DynamicSqlNode;
import architecture.ee.jdbc.sqlquery.builder.xml.dynamic.DynamicSqlSource;
import architecture.ee.jdbc.sqlquery.builder.xml.dynamic.MixedSqlNode;
import architecture.ee.jdbc.sqlquery.builder.xml.dynamic.SqlNode;
import architecture.ee.jdbc.sqlquery.builder.xml.dynamic.TextSqlNode;
import architecture.ee.jdbc.sqlquery.factory.Configuration;
import architecture.ee.jdbc.sqlquery.mapping.StatementType;
import architecture.ee.jdbc.sqlquery.parser.XNode;
import architecture.ee.jdbc.sqlquery.sql.SqlSource;

/**
 * @author DongHyuck, Son
 */
public class XmlStatementBuilder extends AbstractBuilder {

    public static final String XML_NODE_DESCRIPTION_TAG = "description";
    public static final String XML_NODE_PARAMETER_MAPPING_TAG = "parameterMapping";
    public static final String XML_NODE_PARAMETER_MAPPINGS_TAG = "parameterMappings";

    public static final String XML_ATTR_STATEMENT_TYPE_TAG = "statementType";
    public static final String XML_ATTR_FETCH_SIZE_TAG = "fetchSize";
    public static final String XML_ATTR_TIMEOUT_TAG = "timeout";
    public static final String XML_ATTR_DYNAMIC_TAG = "dynamic";
    public static final String XML_ATTR_ID_TAG = "id";
    public static final String XML_ATTR_NAME_TAG = "name";
    public static final String XML_ATTR_CALLABLE_TAG = "callable";
    public static final String XML_ATTR_FUNCTION_TAG = "function";
    public static final String XML_ATTR_SCRIPT_TAG = "script";
    public static final String XML_ATTR_COMMENT_TAG = "comment";
    public static final String XML_ATTR_DESCRIPTION_TAG = "description";

    private Log log = LogFactory.getLog(XmlStatementBuilder.class);

    /**
     * @uml.property name="builderAssistant"
     * @uml.associationEnd
     */
    private SqlBuilderAssistant builderAssistant;

    /**
     * @uml.property name="context"
     * @uml.associationEnd
     */
    private XNode context;

    public XmlStatementBuilder(Configuration configuration, SqlBuilderAssistant builderAssistant, XNode context) {
	super(configuration);
	this.builderAssistant = builderAssistant;
	this.context = context;
    }

    public void parseStatementNode() {

	//log.debug("parse statement node ");
	
	String idToUse = context.getStringAttribute(XML_ATTR_ID_TAG);
	String nameToUse = context.getStringAttribute(XML_ATTR_NAME_TAG);
	if (StringUtils.isEmpty(idToUse))
	    idToUse = nameToUse;
	String descriptionToUse = context.getStringAttribute(XML_ATTR_DESCRIPTION_TAG);
	Integer fetchSize = context.getIntAttribute(XML_ATTR_FETCH_SIZE_TAG, 0);
	Integer timeout = context.getIntAttribute(XML_ATTR_TIMEOUT_TAG, 0);

	// bug!! 디폴트로 PREPARED !!!
	StatementType statementType = StatementType.valueOf(context.getStringAttribute(XML_ATTR_STATEMENT_TYPE_TAG, StatementType.PREPARED.toString()));
	List<ParameterMapping> parameterMappings = parseParameterMappings(context);
	List<ResultMapping> resultrMappings = parseResultMappings(context);
	// dynamic 해당하는 부분을 검색한다.
	List<SqlNode> contents = parseDynamicTags(context);
	MixedSqlNode rootSqlNode = new MixedSqlNode(contents);
	SqlSource sqlSource = new DynamicSqlSource(configuration, rootSqlNode, parameterMappings, resultrMappings);
	builderAssistant.addMappedStatement(idToUse, descriptionToUse, sqlSource, statementType, fetchSize, timeout);
    }

    private List<ResultMapping> parseResultMappings(XNode node) {
	
	//log.debug("parse statement result mapping node ");
	
	List<ResultMapping> parameterMappings = new ArrayList<ResultMapping>();
	List<XNode> children = node.evalNodes("resultMappings/resultMapping");
	for (XNode child : children) {
	    ResultMapping.Builder builder = new ResultMapping.Builder(child.getStringAttribute(XML_ATTR_NAME_TAG));

	    builder.index(child.getIntAttribute("index", 0));
	    builder.primary(child.getBooleanAttribute("primary", false));
	    builder.encoding(child.getStringAttribute("encoding", null));
	    builder.pattern(child.getStringAttribute("pattern", null));
	    builder.cipher(child.getStringAttribute("cipher", null));
	    builder.cipherKey(child.getStringAttribute("cipherKey", null));
	    builder.cipherKeyAlg(child.getStringAttribute("cipherKeyAlg", null));
	    builder.size(child.getStringAttribute("size", "0"));

	    String javaTypeName = child.getStringAttribute("javaType", null);
	    String jdbcTypeName = child.getStringAttribute("jdbcType", null);
	    if (jdbcTypeName != null)
		builder.jdbcTypeName(jdbcTypeName);
	    if (javaTypeName != null)
		builder.javaType(getTypeAliasRegistry().resolveAlias(javaTypeName));
	    parameterMappings.add(builder.build());
	}
	return parameterMappings;
    }

    private List<ParameterMapping> parseParameterMappings(XNode node) {
	//log.debug("parse statement paramenters node ");
	
	List<ParameterMapping> parameterMappings = new ArrayList<ParameterMapping>();
	List<XNode> children = node.evalNodes("parameterMappings/parameterMapping");
	for (XNode child : children) {

	    ParameterMapping.Builder builder = new ParameterMapping.Builder(child.getStringAttribute(XML_ATTR_NAME_TAG));

	    builder.index(child.getIntAttribute("index", 0));
	    builder.mode(child.getStringAttribute("mode", "NONE"));
	    builder.primary(child.getBooleanAttribute("primary", false));
	    builder.encoding(child.getStringAttribute("encoding", null));
	    builder.pattern(child.getStringAttribute("pattern", null));
	    builder.cipher(child.getStringAttribute("cipher", null));
	    builder.cipherKey(child.getStringAttribute("cipherKey", null));
	    builder.cipherKeyAlg(child.getStringAttribute("cipherKeyAlg", null));
	    builder.digest(child.getStringAttribute("digest", null));
	    builder.size(child.getStringAttribute("size", "0"));
	    builder.column(child.getStringAttribute("column", null));	    
	    String javaTypeName = child.getStringAttribute("javaType", null);
	    String jdbcTypeName = child.getStringAttribute("jdbcType", null);	    
	    if (StringUtils.isNotEmpty(jdbcTypeName))
		builder.jdbcTypeName(jdbcTypeName);
	    if (StringUtils.isNotEmpty(javaTypeName))
		builder.javaType(getTypeAliasRegistry().resolveAlias(javaTypeName));
	    parameterMappings.add(builder.build());
	}
	return parameterMappings;
    }

    private List<SqlNode> parseDynamicTags(XNode node) {
	List<SqlNode> contents = new ArrayList<SqlNode>();
	NodeList children = node.getNode().getChildNodes();
	for (int i = 0; i < children.getLength(); i++) {
	    XNode child = node.newXNode(children.item(i));
	    String nodeName = child.getNode().getNodeName();
	    if (child.getNode().getNodeType() == Node.CDATA_SECTION_NODE || child.getNode().getNodeType() == Node.TEXT_NODE) {
		String data = child.getStringBody("");
		contents.add(new TextSqlNode(data));
	    } else {
		if ("dynamic".equals(nodeName)) {
		    String data = child.getStringBody("");
		    contents.add(new DynamicSqlNode(data));
		}
	    }
	}
	return contents;
    }
}
