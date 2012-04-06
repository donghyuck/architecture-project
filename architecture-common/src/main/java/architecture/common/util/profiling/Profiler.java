package architecture.common.util.profiling;

import java.util.HashMap;
import java.util.Stack;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author  donghyuck
 */
public class Profiler {

    
    class ProfileInstance
    {

        String name;
        String displayName;
        long start;

        public ProfileInstance(String name, String displayName, long start)
        {
            this.name = name;
            this.displayName = displayName;
            this.start = start;
        }
    }
    
    /**
	 * @author  donghyuck
	 */
    public static class ProfileStat
    {
    	/**
		 * @uml.property  name="count"
		 */
    	int count;
        /**
		 * @uml.property  name="average"
		 */
        double average;
        /**
		 * @uml.property  name="max"
		 */
        long max;
        /**
		 * @uml.property  name="parent"
		 * @uml.associationEnd  
		 */
        ProfileStat parent;

        public ProfileStat()
        {
        }

        public ProfileStat(ProfileStat parent)
        {
            this.parent = parent;
        }
        
        public void addTime(long time)
        {
            count++;
            average = (average * (double)(count - 1) + (double)time) / (double)count;
            if(max < time)
                max = time;
        }

        /**
		 * @return
		 * @uml.property  name="count"
		 */
        public int getCount()
        {
            return count;
        }

        /**
		 * @return
		 * @uml.property  name="average"
		 */
        public double getAverage()
        {
            return average;
        }

        /**
		 * @return
		 * @uml.property  name="max"
		 */
        public long getMax()
        {
            return max;
        }

        public int getPercentOfParent()
        {
            if(parent == null)
            {
                return 100;
            } else
            {
                double parentAvg = parent.getAverage();
                return (int)((average / parentAvg) * 100D);
            }
        }        
    }
    
    private Log log = LogFactory.getLog(Profiler.class);
    private Stack<ProfileInstance> stack;
    /**
	 * @uml.property  name="stats"
	 */
    private HashMap<String, ProfileStat> stats = new HashMap<String, ProfileStat>();
    private boolean enabled = false;
    
    public Profiler()
    {
        stack = new Stack<ProfileInstance>();
    }
    
    public boolean isProfilingEnabled()
    {
        return enabled;
    }

    public void setProfilingEnabled(boolean enabled)
    {
        this.enabled = enabled;
    }   
    
    public void start(String name)
    {
        String displayName = name;
        ProfileInstance prev = null;
        if(!stack.isEmpty())
            prev = (ProfileInstance)stack.peek();
        if(prev != null)
            displayName = (new StringBuilder()).append(prev.displayName).append(".").append(name).toString();
        
        ProfileStat ps = getProfileStat(displayName);
        
        stack.push(new ProfileInstance(name, displayName, System.currentTimeMillis()));
    }

    public void stop(String name)
    {
        if(stack.isEmpty())
            return;
        ProfileInstance pi = (ProfileInstance)stack.peek();
        if(pi.name.equals(name))
        {
            long end = System.currentTimeMillis();
            stack.pop();
            long time = end - pi.start;
            ProfileStat ps = getProfileStat(pi.displayName);
            ps.addTime(time);
        } else
        {
            stack.clear();
            log.warn((new StringBuilder()).append("Profiling not being used correctly: got ").append(pi.name).append(", expected ").append(name).toString());
        }
    }
    
    private ProfileStat getProfileStat(String key)
    {
        ProfileStat ps = (ProfileStat)stats.get(key);
        if(ps == null)
        {
            int dot = key.lastIndexOf(".");
            if(dot != -1)
            {
                String parentKey = key.substring(0, dot);
                ProfileStat parentStat = (ProfileStat)stats.get(parentKey);
                ps = new ProfileStat(parentStat);
            }
            if(ps == null)
                ps = new ProfileStat();
            stats.put(key, ps);
        }
        return ps;
    }
    
    public void resetStatistics()
    {
        stats = new HashMap<String, ProfileStat>();
    }
    
    /**
	 * @return
	 * @uml.property  name="stats"
	 */
    public HashMap<String, ProfileStat> getStats()
    {
        return stats;
    }
}
