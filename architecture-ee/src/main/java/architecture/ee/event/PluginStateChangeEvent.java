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
package architecture.ee.event;

import architecture.common.lifecycle.event.Event;

/**
 * @author donghyuck
 */
public class PluginStateChangeEvent extends Event {

    private static final long serialVersionUID = -6725688776619308652L;

    public enum State {

	INSTALLED,

	UNINSTALLED,

	UNLOADED,

	RESTART
    };

    private State state;

    public PluginStateChangeEvent(Object source, State state) {
	super(source);
	this.state = state;
    }

    public State getState() {
	return state;
    }

}
