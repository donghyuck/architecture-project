/*
 *  Copyright 2012, 2013 donghyuck, son.
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
package architecture.ee.jdbc.sqlquery.builder.xml.dynamic;

public class TextSqlNode implements SqlNode {

	private String text;

	public TextSqlNode(String text) {
		this.text = text;
	}

	public boolean apply(DynamicContext context) {
		context.appendSql(text);
		return true;
	}

	@Override
	public String toString() {
		return "text[" + text + "]";
	}

}
