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
package architecture.ee.web.logo.dao;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import architecture.ee.web.logo.LogoImage;
import architecture.ee.web.logo.LogoImageNotFoundException;

public interface LogoImageDao {

    public void addLogoImage(LogoImage logoImage, File file);

    public void addLogoImage(LogoImage logoImage, InputStream is);

    public void updateLogoImage(LogoImage logoImage, File file);

    public void updateLogoImage(LogoImage logoImage, InputStream is);

    public void removeLogoImage(LogoImage logoImage);

    public InputStream getInputStream(LogoImage logoImage) throws IOException;

    public Long getPrimaryLogoImageId(int objectType, long objectId) throws LogoImageNotFoundException;

    public LogoImage getLogoImageById(long logoId) throws LogoImageNotFoundException;

    public List<Long> getLogoImageIds(int objectType, long objectId);

    public int getLogoImageCount(int objectType, long objectId);

}
