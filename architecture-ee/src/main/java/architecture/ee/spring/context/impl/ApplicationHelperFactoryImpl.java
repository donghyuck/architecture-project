package architecture.ee.spring.context.impl;

import architecture.common.lifecycle.ApplicationHelper;
import architecture.common.lifecycle.ApplicationHelperFactory.Implementation;

import architecture.ee.bootstrap.Bootstrap;

public class ApplicationHelperFactoryImpl implements Implementation {

	private ApplicationHelper helper = null;
	
	public ApplicationHelper getApplicationHelper() {	
		// 이부분은 숨여야할 필요성이 있다.
		if(helper == null){
			this.helper = new ApplicationHelperImpl(Bootstrap.getBootstrapApplicationContext());
		}		
		return helper;
	}

}
