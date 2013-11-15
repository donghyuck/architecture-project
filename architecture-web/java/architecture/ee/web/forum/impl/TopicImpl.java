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
package architecture.ee.web.forum.impl;

import java.io.Serializable;

import architecture.common.model.ModelObjectType;
import architecture.common.model.support.DateModelObjectSupport;
import architecture.ee.web.forum.Topic;

public class TopicImpl extends DateModelObjectSupport  implements Topic {
	
	private Long ForumId;
	
	private Long topidId;
	
	private Long userId ;
		
	private int totalReplies = 0 ;

	private String  subject  ;
	
	public Serializable getPrimaryKeyObject() {
		return topidId;
	}

	public ModelObjectType getModelObjectType() {
		return ModelObjectType.FORUM_TOPIC;
	}

	public int getCachedSize() {
		return 0;
	}

	
}
