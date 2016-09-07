/*
 * Copyright 2016 donghyuck
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

package architecture.common;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.BeforeClass;
import org.junit.Test;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import architecture.common.event.api.EventPublisher;


public class EventTest {

    private static Log log = LogFactory.getLog(EventTest.class);
    private static ClassPathXmlApplicationContext context = null;

    @BeforeClass
    public static void setup() {
	log.debug("setup context..");
	context = new ClassPathXmlApplicationContext("eventSubsystemContext.xml");
    }

    public EventTest() {
    }

    

    @Test
    public void testEventPublish() {
	
	EventPublisher publisher = context.getBean( "eventPublisher", EventPublisher.class );
	LoginEvent evt = new LoginEvent("hello");
	evt.setUsername("a");
	evt.setSessionId("1233");
	
	publisher.publish(evt);
	
	try {
	    System.out.println("-----------------------------");
	    Thread.currentThread().sleep(5000L);
	} catch (InterruptedException e) {
	    e.printStackTrace();
	}
    }

}
