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
package architecture.common.event.internal;


import static com.google.common.base.Preconditions.checkNotNull;

import architecture.common.event.api.AsynchronousPreferred;

/**
 * <p>Annotation based {@link AsynchronousEventResolver}. This will check whether the event is annotated with the given
 * annotation.</p>
 * <p>The default annotation used is {@link com.atlassian.event.api.AsynchronousPreferred}</p>
 * @see architecture.common.event.api.AsynchronousPreferred
 * @since 2.0
 */
final class AnnotationAsynchronousEventResolver implements AsynchronousEventResolver
{
    private final Class annotationClass;

    AnnotationAsynchronousEventResolver()
    {
        this(AsynchronousPreferred.class);
    }

    AnnotationAsynchronousEventResolver(Class annotationClass)
    {
        this.annotationClass = checkNotNull(annotationClass);
    }

    @SuppressWarnings("unchecked")
    public boolean isAsynchronousEvent(Object event)
    {
        return checkNotNull(event).getClass().getAnnotation(annotationClass) != null;
    }
}
