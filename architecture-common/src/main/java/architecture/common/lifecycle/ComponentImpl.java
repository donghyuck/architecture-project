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
package architecture.common.lifecycle;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import architecture.common.event.api.EventPublisher;
import architecture.common.event.api.EventSource;
import architecture.common.exception.ComponentDisabledException;
import architecture.common.exception.ConfigurationError;
import architecture.common.exception.ConfigurationWarning;
import architecture.common.exception.RuntimeError;
import architecture.common.exception.RuntimeWarning;


public class ComponentImpl implements Component, EventSource {
    
    protected String name;
    
    protected volatile State state;
            
    private EventPublisher eventPublisher = null;
    
    protected Log log = LogFactory.getLog(getClass());
    
    
    public ComponentImpl() {
    	state = State.NONE;
    	setName(getClass().getSimpleName());
	}

	public String getName()
    {
        return name;
    }

	public void setName(String name)
    {
        this.name = name;
    }

    public State getState()
    {
        return state;
    }

    public String getStateString()
    {
        return state.toString();
    }
    
    public void destroy() {
    	setState(State.DESTROYING);
    	destoryInternal();
    	setState(State.DESTROYED);
    }

    public void initialize() throws ComponentDisabledException, ConfigurationWarning, ConfigurationError {
    	setState(State.INITIALIZING);
    	initializeInternal();
    	setState(State.INITIALIZED);
    }

    public void start() throws RuntimeError, RuntimeWarning {
    	if(state == State.INITIALIZED){
	    	setState(State.STARTING);	    	
	    	startInternal();
	    	setState(State.STARTED);
    	}
    }

    public void stop() {  
    	if(state == State.STARTED || state == State.RUNNING ){
	    	setState(State.STOPING); 
	    	stopInternal();
	    	setState(State.STOPED);
    	}
    }

    protected void setState(State newState) throws RuntimeError, RuntimeWarning, ConfigurationError, ConfigurationWarning
    {	
    	State oldValue = getState();
        state = newState;
        fireStateChangeEvent(oldValue, state);  
    }
    
    protected  void startInternal(){}
    
    protected  void stopInternal(){}
    
    protected  void destoryInternal(){}
    
    protected  void initializeInternal(){}
    
    protected void fireStateChangeEvent(State oldValue, State state){
    	//log.debug("%%%%%%%%%%%%" + eventPublisher);
       if(eventPublisher != null){
    	   //log.debug("fire state event!!");
           eventPublisher.publish(new StateChangeEvent(this, oldValue, state));    	
       }
    }
    
    protected EventPublisher getEventPublisher(){
    	return eventPublisher;
    }
    
    /**
     * method from EventSource interface!
     */
	public void setEventPublisher(EventPublisher eventPublisher) {
		this.eventPublisher = eventPublisher;		
	}

	public void removeStateChangeListener(Object listener){
		if(eventPublisher != null)
			eventPublisher.unregister(listener);
	}
	
	public void addStateChangeListener(Object listener){
		if(eventPublisher != null)
			eventPublisher.register(listener);
	}

	@Override
	public String toString() {
		return String.format("Component:%s", getName());
	}
	
}