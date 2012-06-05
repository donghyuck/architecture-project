package architecture.ee.model.impl;

import java.io.Serializable;

import architecture.common.model.impl.BaseModelObject;
import architecture.ee.model.ModelConstants;
import architecture.ee.model.PermissionMaskModel;
import architecture.ee.security.permission.PermissionMask;

/**
 * @author  donghyuck
 */
public class PermissionMaskModelImpl  extends BaseModelObject<PermissionMask> implements PermissionMaskModel {
	
	/**
	 */
	private String name;
	
    /**
	 */
    private int mask;
    
	/**
	 * @return
	 */
	public String getName() {
		return name;
	}
	/**
	 * @param name
	 */
	public void setName(String name) {
		this.name = name;
	}
	/**
	 * @return
	 */
	public int getMask() {
		return mask;
	}
	/**
	 * @param mask
	 */
	public void setMask(int mask) {
		this.mask = mask;
	}

	@Override
	public Object clone() {
		return null;
	}

	public int compareTo(PermissionMask o) {
		return 0;
	}
	public Serializable getPrimaryKeyObject() {
		return null;
	}
	public void setPrimaryKeyObject(Serializable primaryKeyObj) {

	}
	public int getObjectType() {
		return ModelConstants.PERMISSION_MASK;
	}
	public int getCachedSize() {
		// TODO Auto-generated method stub
		return 0;
	}
}
