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
package architecture.common.model.support;

import architecture.common.model.BaseModelObject;
import architecture.common.model.PropertyModel;

public abstract class BaseModelObjectSupport extends PropertyModelSupport implements BaseModelObject {
	
	private String name;

	/**
	 * @return name
	 */
	public String getName() {
		return name;
	}

	/**
	 * @param name 설정할 name
	 */
	public void setName(String name) {
		this.name = name;
	}

}
