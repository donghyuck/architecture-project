package architecture.ee.web.util;

import architecture.common.exception.ComponentNotFoundException;
import architecture.common.lifecycle.ConfigService;
import architecture.ee.util.ApplicationHelper;

public final class WebApplicationHelper 
{
	
	public static final ConfigService getConfigService(){
		return ApplicationHelper.getConfigService();
	}
	
	public static final <T> T getComponent(Class<T> requiredType) throws ComponentNotFoundException{
		return ApplicationHelper.getComponent(requiredType);
	}

	public static final void autowireComponent(Object obj){
		ApplicationHelper.autowireComponent(obj);
	}
	
}

