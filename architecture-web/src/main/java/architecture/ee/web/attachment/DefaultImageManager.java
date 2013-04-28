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
package architecture.ee.web.attachment;

import java.io.File;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

import net.sf.ehcache.Cache;
import net.sf.ehcache.Element;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import architecture.common.event.api.EventPublisher;
import architecture.common.event.api.EventSource;
import architecture.ee.exception.NotFoundException;
import architecture.ee.exception.SystemException;
import architecture.ee.util.ApplicationHelper;
import architecture.ee.web.attachment.dao.ImageDao;
import architecture.ee.web.attachment.impl.ImageImpl;

public class DefaultImageManager implements ImageManager, EventSource {

	private Log log = LogFactory.getLog(getClass());
	
	private EventPublisher eventPublisher;
	private ImageConfig imageConfig;
	private ImageDao imageDao;
	private Cache imageCache;
	private File imageDir;	
	
	
	public EventPublisher getEventPublisher() {
		return eventPublisher;
	}

	public void setEventPublisher(EventPublisher eventPublisher) {
		this.eventPublisher = eventPublisher;
	}

	public ImageConfig getImageConfig() {
		return imageConfig;
	}

	public void setImageConfig(ImageConfig imageConfig) {
		this.imageConfig = imageConfig;
	}

	public ImageDao getImageDao() {
		return imageDao;
	}

	public void setImageDao(ImageDao imageDao) {
		this.imageDao = imageDao;
	}
	
	public boolean isImageEnabled() {
		return imageConfig.isEnabled();
	}

	public void setImageEnabled(boolean enabled) {
		imageConfig.setEnabled(enabled);
		String str = (new StringBuilder()).append("").append(enabled).toString();
		ApplicationHelper.getConfigService().setApplicationProperty("image.enabled", str);
	}

	public int getMaxImageSize() {
		return imageConfig.getMaxImageSize();
	}

	public void setMaxImageSize(int maxImageSize) {
		imageConfig.setMaxImageSize(maxImageSize);
		String str = (new StringBuilder()).append("").append(maxImageSize).toString();
		ApplicationHelper.getConfigService().setApplicationProperty("image.maxImageSize", str);	
	}

	public int getImagePreviewMaxSize() {
		return imageConfig.getImagePreviewMaxSize();
	}

	public void setImagePreviewMaxSize(int imagePreviewMaxSize) {
		imageConfig.setImagePreviewMaxSize(imagePreviewMaxSize);
		String str = (new StringBuilder()).append("").append(imagePreviewMaxSize).toString();
		ApplicationHelper.getConfigService().setApplicationProperty("image.imagePreviewMaxSize", str);		
	}

	public boolean isForceThumbnailsEnabled() {
		return imageConfig.isForceThumbnailsEnabled();
	}

	public void setFourceThumbnailsEnabled(boolean forceThumbnailsEnabled) {
		imageConfig.setForceThumbnailsEnabled(forceThumbnailsEnabled);
		String str = (new StringBuilder()).append("").append(forceThumbnailsEnabled).toString();
		ApplicationHelper.getConfigService().setApplicationProperty("image.forceThumbnailsEnabled", str);		
	}

	public int getImageMaxWidth() {
		return imageConfig.getImageMaxWidth();
	}

	public void setImageMaxWidth(int imageMaxWidth) {
		imageConfig.setImageMaxWidth(imageMaxWidth);
		String str = (new StringBuilder()).append("").append(imageMaxWidth).toString();
		ApplicationHelper.getConfigService().setApplicationProperty("image.imageMaxWidth", str);	
	}

	public int getImageMaxHeight() {
		return imageConfig.getImageMaxHeight();
	}

	public void setImageMaxHeight(int imageMaxHeight) {
		imageConfig.setImageMaxHeight(imageMaxHeight);
		String str = (new StringBuilder()).append("").append(imageMaxHeight).toString();
		ApplicationHelper.getConfigService().setApplicationProperty("image.imageMaxHeight", str);	
	}

	public boolean isValidType(String contentType) {
		boolean flag;		
		 if(isAllowAllByDefault())
             flag = !getDisallowedTypes().contains(contentType);
         else
             flag = getAllowedTypes().contains(contentType);
		 return flag;
	}

	public List<String> getDisallowedTypes(){		
		return imageConfig.getDisallowedTypes();
	}
	
	public void addDisallowedType(String contentType)
	{
		if (!imageConfig.getDisallowedTypes().contains(contentType)){			
			imageConfig.getDisallowedTypes().add(contentType);
			String str = listToString( imageConfig.getDisallowedTypes());
			ApplicationHelper.getConfigService().setApplicationProperty("image.disallowedTypes", str);	
		}	
	}
	
	public void removeDisallowedType(String contentType)
	{
		if (imageConfig.getDisallowedTypes().contains(contentType)){			
			imageConfig.getDisallowedTypes().remove(contentType);
			String str = listToString( imageConfig.getDisallowedTypes());
			ApplicationHelper.getConfigService().setApplicationProperty("image.disallowedTypes", str);	
		}			
	}
	
	public void addAllowedType(String contentType) {
		if (!imageConfig.getAllowedTypes().contains(contentType)){			
			imageConfig.getAllowedTypes().add(contentType);
			String str = listToString( imageConfig.getAllowedTypes());
			ApplicationHelper.getConfigService().setApplicationProperty("image.allowedTypes", str);	
		}		
	}

	public void removeAllowedType(String contentType) {
		if (imageConfig.getAllowedTypes().contains(contentType)){			
			imageConfig.getAllowedTypes().remove(contentType);
			String str = listToString( imageConfig.getAllowedTypes());
			ApplicationHelper.getConfigService().setApplicationProperty("image.allowedTypes", str);	
		}			
	}

	public List<String> getAllowedTypes() {
		return imageConfig.getAllowedTypes();
	}

	public boolean isAllowAllByDefault() {
		return imageConfig.isAllowAllByDefault();
	}

	public void setAllowAllByDefault(boolean allowed) {
		imageConfig.setAllowAllByDefault(allowed);
		String str = (new StringBuilder()).append("").append(allowed).toString();
		ApplicationHelper.getConfigService().setApplicationProperty("image.allowAllByDefault", str);			
	}
	
	public void deleteImage(Image image){		
		Image imageToUse = imageDao.getImageById(image.getImageId());
		imageDao.delete(imageToUse);
		 File imageFile = new File(getImageDir(), (new StringBuilder()).append(imageToUse.getImageId()).append(".bin").toString());
         if(imageFile.exists())
             imageFile.delete();
	}
	

	public Image createImage(int objectType, long objectId, String name, String contentType, InputStream inputStream) {
		ImageImpl image = new ImageImpl();
		image.setObjectType(objectType);
		image.setObjectId(objectId);
		image.setContentType(contentType);
		image.setName(name);
		image.setImageId(-1L);
		image.setInputStream(inputStream);		
		return image;
	}

	public void saveOrUpdate(Image image) {
		try {
			if( image.getImageId() < 0 ){
				imageDao.create(image);
				imageDao.saveImageInputStream(image, image.getInputStream());
			}else{
				imageDao.update(image);
				imageDao.saveImageInputStream(image, image.getInputStream());
			}					
			Image imageToUse = getImage(image.getImageId());			
			imageCache.remove(imageToUse.getImageId());
		} catch (Exception e) {
			throw new SystemException(e);
		}
	}
	
	public Image saveImage(Image image){
		try {
			if( image.getImageId() < 0 ){
				imageDao.create(image);
				imageDao.saveImageInputStream(image, image.getInputStream());
			}else{
				imageDao.update(image);
				imageDao.saveImageInputStream(image, image.getInputStream());
			}					
			Image imageToUse = getImage(image.getImageId());			
			imageCache.remove(imageToUse.getImageId());
			return imageToUse;
		} catch (Exception e) {
			throw new SystemException(e);
		}
	}
		
	public Image getImage(long imageId) throws NotFoundException {
		Image image = null  ;
		if( imageCache.get(imageId) != null)
			image =  (Image) imageCache.get( imageId ).getValue();
		
		if( image == null ){
			try {
				image = getImageById(imageId);
				imageCache.put(new Element(imageId, image));
			} catch (Exception e) {
				 String msg = (new StringBuilder()).append("Unable to find image ").append(imageId).toString();
	             throw new NotFoundException(msg, e);
			}
		}
		return image;
	}

	private Image getImageById(long imageId) throws NotFoundException {
		try {
			return imageDao.getImageById(imageId);
		} catch (Exception e) {
			 String msg = (new StringBuilder()).append("Unable to find image ").append(imageId).toString();
             throw new NotFoundException(msg, e);
		}
	}
		
	public Cache getImageCache() {
		return imageCache;
	}

	public void setImageCache(Cache imageCache) {
		this.imageCache = imageCache;
	}

	protected synchronized File getImageDir() {
		if(imageDir == null)
        {
			imageDir = ApplicationHelper.getRepository().getFile("images");
			if(!imageDir.exists())
            {
                boolean result = imageDir.mkdir();
                if(!result)
                    log.error((new StringBuilder()).append("Unable to create image directory: '").append(imageDir).append("'").toString());
            }
        }
        return imageDir;
	}
	
	public void destroy(){
	
	}
		
	public void  initialize() {		
		
		ImageConfig imageConfigToUse = new ImageConfig();
		imageConfigToUse.setEnabled( ApplicationHelper.getApplicationBooleanProperty("image.enabled", true) );
		imageConfigToUse.setAllowAllByDefault( ApplicationHelper.getApplicationBooleanProperty("image.allowAllByDefault", true) );
		imageConfigToUse.setForceThumbnailsEnabled( ApplicationHelper.getApplicationBooleanProperty("image.forceThumbnailsEnabled", true) );
		imageConfigToUse.setMaxImageSize( ApplicationHelper.getApplicationIntProperty("", 2048) );
		imageConfigToUse.setImagePreviewMaxSize(ApplicationHelper.getApplicationIntProperty("image.imagePreviewMaxSize", 250));
		imageConfigToUse.setImageMaxWidth(ApplicationHelper.getApplicationIntProperty("image.imageMaxWidth", 450));
		imageConfigToUse.setImageMaxHeight(ApplicationHelper.getApplicationIntProperty("image.imageMaxHeight", 600));
		imageConfigToUse.setMaxImagesPerObject(ApplicationHelper.getApplicationIntProperty("image.maxImagesPerObject", 50));
		imageConfigToUse.setAllowedTypes( stringToList(ApplicationHelper.getApplicationProperty("image.allowedTypes", ""))  );
		imageConfigToUse.setDisallowedTypes( stringToList( ApplicationHelper.getApplicationProperty("image.disallowedTypes", "")));
		this.imageConfig = imageConfigToUse;
		getImageDir();		
	}	
	
	private static String listToString(List<String> list)
    {
        StringBuilder sb = new StringBuilder();
        for( String element :  list ){
        	 sb.append(element).append(",");
        }
        return sb.toString();
    }

    private static List<String> stringToList(String string)
    {
        List<String> list = new ArrayList<String>();
        if(string != null)
        {
            for(StringTokenizer tokens = new StringTokenizer(string, ","); tokens.hasMoreTokens(); list.add(tokens.nextToken()));
        }
        return list;
    }
}