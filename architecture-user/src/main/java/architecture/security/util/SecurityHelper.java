package architecture.security.util;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;

import architecture.common.user.User;
import architecture.common.user.authentication.AuthToken;
import architecture.common.util.ImplFactory;

/**
 * @author  donghyuck
 */
public class SecurityHelper {

	public static interface Implementation {
		
		public boolean isAnonymous();
		
		public boolean isAnonymous(Authentication authen);
		
		public  boolean isApplicaitonUser();
		
		public  AuthToken getAuthToke();
		
		public User getUser();
		
		public Authentication getAuthentication();
	}
	
	/**
	 */
	private static Implementation impl = null;
    
    static 
    {
        impl = (Implementation)ImplFactory.loadImplFromKey(SecurityHelper.Implementation.class);
    }
	
    public static boolean isAnonymous(){
    	return impl.isAnonymous();
    }
    
    public static boolean isAnonymous(Authentication authen){
    	return impl.isAnonymous(authen);
    }
    
    public static boolean isApplicaitonUser(){
    	return impl.isApplicaitonUser();
    }
    
    public static AuthToken getAuthToke(){
    	return impl.getAuthToke();
    }
    
    public static User getUser(){
    	return impl.getUser();
    }    
    
	public static Authentication getAuthentication(){
		return impl.getAuthentication();
	}	
	
	public static List<String> getUserRoles(){		
		
		Collection< ? extends GrantedAuthority> authorities = getAuthentication().getAuthorities();
		List<String> list = new ArrayList<String>(authorities.size());		
		for( GrantedAuthority authority : authorities ){
			list.add( authority.getAuthority() );
		}
		return list;
	}
	
}
