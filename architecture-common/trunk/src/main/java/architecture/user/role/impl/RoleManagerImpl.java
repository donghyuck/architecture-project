package architecture.user.role.impl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import net.sf.ehcache.Cache;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import architecture.common.event.api.EventPublisher;
import architecture.common.event.api.EventSource;
import architecture.common.user.UserTemplate;
import architecture.user.Group;
import architecture.user.GroupManager;
import architecture.user.role.ExtendedRoleManager;
import architecture.user.role.Role;
import architecture.user.role.dao.RoleDao;

/**
 * @author  donghyuck
 */
public class RoleManagerImpl implements ExtendedRoleManager, EventSource {

	private Log log = LogFactory.getLog(getClass());
	
	/**
	 */
	private GroupManager groupManager;
	/**
	 */
	private RoleDao roleDao;
	/**
	 */
	private EventPublisher eventPublisher;
	
	private Cache roleCache;
	private Cache userRoleCache;
		
	
	public RoleManagerImpl() {
		//this.roleCache = AdminHelper.getCache("roleCache");
		//this.userRoleCache = AdminHelper.getCache("userRoleCache");
	}

		
	/**
	 * @param roleCache
	 */
	public void setRoleCache(Cache roleCache) {
		this.roleCache = roleCache;
	}

	/**
	 * @param userRoleCache
	 */
	public void setUserRoleCache(Cache userRoleCache) {
		this.userRoleCache = userRoleCache;
	}

	/**
	 * @param groupManager
	 */
	public void setGroupManager(GroupManager groupManager) {
		this.groupManager = groupManager;
	}
	/**
	 * @param roleDao
	 */
	public void setRoleDao(RoleDao roleDao) {
		this.roleDao = roleDao;
	}
	/**
	 * @param eventPublisher
	 */
	public void setEventPublisher(EventPublisher eventPublisher) {
		this.eventPublisher = eventPublisher;
	}
		
	public List<Role> getFinalUserRoles(long userId) {
		
		List<Role> roles = new ArrayList<Role>();
		
		List<Long> userRoleIds = roleDao.getUserRoleIds(userId);
		for(long roleId : userRoleIds ){
			Role role = getRoleFromCacheById(roleId);
			if( role == null){
				role = roleDao.getRoleById(roleId);
			}
			roles.add(role);
		}
        
		List<Group> groups = Collections.EMPTY_LIST; //groupManager.getUserGroups(new UserTemplate(userId));
		for(Group group : groups ){			
			List<Long> groupRoleIds = roleDao.getGroupRoleIds(group.getGroupId());
			for(long roleId : groupRoleIds ){
				Role role = getRoleFromCacheById(roleId);
				if( role == null){
					role = roleDao.getRoleById(roleId);
				}
				roles.add(role);
			}
		}		
		return roles;
	}
	public List<Role> getFinalGroupRoles(long groupId) {
		List<Role> roles = new ArrayList<Role>();	
		List<Long> groupRoleIds = roleDao.getGroupRoleIds(groupId);
		for(long roleId : groupRoleIds ){
			Role role = getRoleFromCacheById(roleId);
			if( role == null){
				role = roleDao.getRoleById(roleId);
			}
			roles.add(role);
		}
		return roles;
	}
	
	
	 private Role getRoleFromCacheById(long id){
		 if(roleCache.isKeyInCache(id))
	            return (Role)roleCache.get(id).getValue();
	        else
	            return null;
	 }


	public List<Role> getAllRoles() {
		List<Role> roles = new ArrayList<Role>();		
		List<Long> roleIds = roleDao.getAllRoleIds();
		for(long roleId : roleIds ){
			Role role = getRoleFromCacheById(roleId);
			if( role == null){
				role = roleDao.getRoleById(roleId);
			}
			roles.add(role);
		}
		return roles;
	}
	
	
}
