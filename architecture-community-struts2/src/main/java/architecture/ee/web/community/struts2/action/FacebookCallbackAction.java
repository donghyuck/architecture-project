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
package architecture.ee.web.community.struts2.action;

import architecture.common.util.StringUtils;
import org.scribe.model.Token;

import architecture.common.user.User;
import architecture.ee.web.community.social.SocialNetwork;
import architecture.ee.web.community.social.SocialNetwork.Media;
import architecture.ee.web.community.social.facebook.FacebookServiceProvider;
import architecture.ee.web.community.struts2.action.support.SocialCallbackSupport;

public class FacebookCallbackAction  extends SocialCallbackSupport {
	
	private String code;
	
	/**
	 * @return code
	 */
	public String getCode() {
		return code;
	}

	/**
	 * @param code 설정할 code
	 */
	public void setCode(String code) {
		this.code = code;
	}
	
	public String execute() throws Exception {		

		if( StringUtils.isNotEmpty(code) ){
			SocialNetwork newSocialNetwork = newSocialNetwork(Media.FACEBOOK);			
			FacebookServiceProvider provider = (FacebookServiceProvider) newSocialNetwork.getSocialServiceProvider();			
			Token token = provider.getTokenWithCallbackReturns(null, code);
			newSocialNetwork.setAccessSecret(token.getSecret());
			newSocialNetwork.setAccessToken(token.getToken());
			setSocialNetwork(newSocialNetwork);		
			setOnetimeSecureObject();
		}else if ( StringUtils.isNotEmpty( getOnetime())){
			log.debug("restore secure object");
			restoreOnetimeSecureObject();
		}		
		return success();
	}

	@Override
	public User findUser() {		
		return this.findUserByMedia(Media.FACEBOOK);
	}
}
