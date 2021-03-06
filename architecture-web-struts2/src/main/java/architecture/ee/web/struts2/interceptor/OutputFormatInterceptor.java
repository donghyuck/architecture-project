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
package architecture.ee.web.struts2.interceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.struts2.StrutsStatics;

import architecture.ee.util.OutputFormat;
import architecture.ee.web.util.ServletUtils;

import com.opensymphony.xwork2.ActionContext;
import com.opensymphony.xwork2.ActionInvocation;
import com.opensymphony.xwork2.interceptor.Interceptor;

public class OutputFormatInterceptor implements Interceptor  {

	public void destroy() {
	
	}

	public void init() {
	
	}

	public String intercept(ActionInvocation invocation) throws Exception {
		
		ActionContext ac = invocation.getInvocationContext();
		
		HttpServletRequest request = (HttpServletRequest)ac.get(StrutsStatics.HTTP_REQUEST);
		HttpServletResponse response = (HttpServletResponse)ac.get(StrutsStatics.HTTP_RESPONSE);
		
		if( invocation.getAction() instanceof OutputFormatAware )
		{
			OutputFormat output = ServletUtils.getOutputFormat(request, response);
			( (OutputFormatAware) invocation.getAction() ).setOutputFormat(output);
		}
		
		return invocation.invoke();
		
	}

}
