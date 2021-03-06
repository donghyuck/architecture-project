package architecture.ee.web.attachment;

import java.io.IOException;
import java.io.InputStream;

import architecture.common.model.DateAware;
import architecture.common.model.PropertyAware;
import architecture.common.user.User;

public interface Attachment extends PropertyAware, DateAware {

    public long getAttachmentId();

    public void setAttachmentId(long attachementId);

    public int getObjectType();

    public void setObjectType(int objectType);

    public long getObjectId();

    public void setObjectId(long objectId);

    public String getName();

    public void setName(String name);

    public int getSize();

    public void setSize(int size);

    public String getContentType();

    public void setContentType(String contentType);

    public int getDownloadCount();

    public void setDownloadCount(int downloadCount);

    public void setInputStream(InputStream inputStream);

    public InputStream getInputStream() throws IOException;

    public abstract Integer getThumbnailSize();

    public abstract void setThumbnailSize(Integer thumbnailSize);

    public abstract void setThumbnailContentType(String contentType);

    public abstract String getThumbnailContentType();

    public abstract User getUser();

    public abstract void setUser(User user);

}
