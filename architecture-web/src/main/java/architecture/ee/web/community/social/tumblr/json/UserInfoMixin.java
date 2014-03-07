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
package architecture.ee.web.community.social.tumblr.json;

import java.util.List;

import architecture.ee.web.community.social.tumblr.BlogInfo;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown=true)
public class UserInfoMixin {

	@JsonCreator
	public UserInfoMixin(
			@JsonProperty("following") int following, 
			@JsonProperty("default_post_format") String defaultPostFormat, 
			@JsonProperty("name") String name, 
			@JsonProperty("likes") int likes,
			@JsonProperty("blogs") List<BlogInfo> blogInfos ){}
			
	@JsonProperty("default_post_format")
	private String defaultPostFormat;

	@JsonProperty("blogs")
	private List<BlogInfo> blogInfos;
	
	@JsonProperty("following")
	private int following;
	
	@JsonProperty("likes")
	private int likes;
	
	@JsonProperty("name")
	private String name;
	
}