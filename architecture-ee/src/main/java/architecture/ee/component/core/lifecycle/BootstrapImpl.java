package architecture.ee.component.core.lifecycle;

import java.lang.ref.WeakReference;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.ReentrantLock;

import javax.servlet.ServletContext;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.access.BeanFactoryReference;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.access.ContextSingletonBeanFactoryLocator;

import architecture.common.exception.ComponentNotFoundException;
import architecture.common.lifecycle.Repository;
import architecture.common.lifecycle.State;
import architecture.common.lifecycle.bootstrap.Bootstrap;
import architecture.common.lifecycle.service.AdminService;
import architecture.common.util.L10NUtils;
import architecture.ee.spring.lifecycle.SpringAdminService;
import architecture.ee.util.ApplicationConstants;

/**
 * @author   donghyuck
 */
public class BootstrapImpl implements Bootstrap.Implementation {
	
	private Log log = LogFactory.getLog(getClass());
	
	private static final String BOOTSTRAP_CONTEXT_KEY = "default-services-context";

	private Map<Class<?>, WeakReference<?>> references = Collections.synchronizedMap(new HashMap<Class<?>, WeakReference<?>>()) ;

	private RepositoryImpl repository = new RepositoryImpl();
	
	private final ReentrantLock lock = new ReentrantLock();
	
	private final AtomicBoolean initialized = new AtomicBoolean(false); 	
	
	private String bootstrapFactoryKey ;
	
	
	public ConfigurableApplicationContext getBootstrapApplicationContext(){	
		
		try {
			
			// 리파지토리가 준비되어 있고 아직 컨텍스트가 초기화 되지 않았다면 ..		
			if( repository.getState() == State.INITIALIZED && !initialized.getAndSet(true) ){
				boolean setupComplete = repository.getSetupApplicationProperties().getBooleanProperty(ApplicationConstants.SETUP_COMPLETE_PROP_NAME, false);
				bootstrapFactoryKey = repository.getSetupApplicationProperties().getStringProperty(ApplicationConstants.BOOTSTRAP_CONTEXT_PROP_NAME, BOOTSTRAP_CONTEXT_KEY);				
				log.info(L10NUtils.format("003008", setupComplete ));
				log.info(L10NUtils.format("003009", bootstrapFactoryKey ));				
			}
			
			BeanFactoryReference parentContextRef = ContextSingletonBeanFactoryLocator.getInstance().useBeanFactory(bootstrapFactoryKey);			
			ConfigurableApplicationContext context = (ConfigurableApplicationContext) parentContextRef.getFactory();			
			return context;
			
		} catch (Throwable e) {
			log.error( L10NUtils.getMessage("002402") , e );
			return null;
		}	
	}		
	
	@SuppressWarnings("unchecked")
	public <T> T getBootstrapComponent(Class<T> requiredType) throws ComponentNotFoundException {

		if (requiredType == null) {
			throw new ComponentNotFoundException();
		}
		if( requiredType == Repository.class ){			
			lock.lock();
			try{
			if( repository.getState() != State.INITIALIZED ){				
				repository.initialize();
			}	
			}catch(Exception e){
				
			}finally{
				lock.unlock();
			}
			return (T)repository;
		}
		
		
		if( references.get(requiredType) == null){			
			try {
				
				if ( getBootstrapApplicationContext() == null) {
					throw new IllegalStateException(L10NUtils.getMessage("003051"));
				}
				references.put(requiredType, new WeakReference<T>( getBootstrapApplicationContext().getBean(requiredType) ));
			} catch (BeansException e) {
				throw new ComponentNotFoundException(L10NUtils.format("003052", requiredType.getName()), e);
			}			
		}
		return (T)references.get(requiredType).get();
	}
		
	public void boot(ServletContext servletContext){		
		lock.lock();
		try{
			if( repository.getState() != State.INITIALIZED ){
				((RepositoryImpl)repository).setServletContext(servletContext);
			}						
			// 1. admin service 가 존재하는 경우 : DOTO
						
			AdminService adminService = getBootstrapComponent(AdminService.class);	
			if(adminService instanceof SpringAdminService ){
				((SpringAdminService)adminService).setServletContext(servletContext);
			}
			adminService.start();
		} catch (BeansException e) {
			
		} catch (ComponentNotFoundException e) { 
			// 2. admin service 가 존재하지 않는 경우 : DOTO
			
		}finally{
			lock.unlock();
		}		
	}	
		
	public void shutdown(ServletContext servletContext){
		lock.lock();
		try{
			// 1. admin service 가 존재하는 경우 :
			AdminService adminService = getBootstrapComponent(AdminService.class);
			adminService.stop();
			adminService.destroy();
		} catch (ComponentNotFoundException e) { 
			// 2. admin service 가 존재하지 않는 경우 :
			
		}finally{
			lock.unlock();
		}
	}

	public boolean isAvailable(Class serviceClass){
		try{
			getBootstrapComponent(AdminService.class);
		} catch (ComponentNotFoundException e) {
			return false;
		} catch (Exception e){
			return false;
		}
		return true;
	}
	
	public State getState() {
		if(isAvailable(AdminService.class)){
			AdminService adminService = getBootstrapComponent(AdminService.class);	
			return adminService.getState();
		}else{
			return repository.getState();
		}
	}
	
	
}