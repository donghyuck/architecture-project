package architecture.ee.jdbc.sequencer.internal;

import java.sql.Types;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.dao.IncorrectResultSizeDataAccessException;

import architecture.ee.jdbc.sequencer.Sequencer;
import architecture.ee.spring.jdbc.support.ExtendedJdbcDaoSupport;

public class JdbcSequencer extends ExtendedJdbcDaoSupport implements Sequencer {
   
    private Log log = LogFactory.getLog(getClass());
    
    private int type;
    
    private String name;
       
    private long currentID;
    
    private long maxID;
    
    private int blockSize;
   
    public JdbcSequencer() {
		super();
	}

	public JdbcSequencer(int seqType) {
    	super();
        this.type = seqType;
        this.blockSize = 10;
        this.currentID = 0L;
        this.maxID = 0L;  
    }    
	
	public int getSequencerId(){
		return type;
	}
	

    public String getName() {
		return name;
	}

    public void setName(String name) {
		this.name = name;
	}

	public int getBlockSize() {
        return blockSize;
    }

    public void setBlockSize(int blockSize) {
        this.blockSize = blockSize;
    }

    /**
     * Returns the next available unique ID. Essentially this provides for the functionality of an
     * auto-increment database field.
     */
    public synchronized long getNext() {
        if (!(currentID < maxID)) {
            getNextBlock(3);
        }
        long id = currentID;
        currentID++;
        return id;
    }
    
    private long createNewID(int type) {
    	long newID = 1L ;    	
        getJdbcTemplate().update(getBoundSql("FRAMEWORK_V2.INSERT_SEQUENCER").getSql(), new Object[]{newID, name, type}, new int[]{Types.INTEGER, Types.VARCHAR, Types.INTEGER });    
        return newID;
    }
    
    private int getNextSequencerId(){
    	int max = getJdbcTemplate().queryForInt(getBoundSql("FRAMEWORK_V2.SELECT_SEQUENCER_MAX_ID").getSql());
    	return max + 1; 
    }
    
    /**
     *  
     *  
     *  
     *  
     * @param count 실패하였을 경우 재 시도 횟수
     */
    private void getNextBlock(int count) {
        
        boolean success = false;
        long currentID = 1;
        try {
            currentID = getExtendedJdbcTemplate().queryForLong( getBoundSql("FRAMEWORK_V2.SELECT_SEQUENCER_BY_ID").getSql(), new Object[] { this.type }, new int[] { Types.INTEGER });
        } catch (IncorrectResultSizeDataAccessException e) {
            // 해당 값이 없는 경우 생성한다.
        	this.type = getNextSequencerId();     
        	
        	//log.debug("++++++++++++++++++++++++++++++++++++>" + this.type);
        	
        	currentID = createNewID(this.type);
        }

        // Increment the id to define our block.
        long newID = currentID + blockSize;
        // The WHERE clause includes the last value of the id. This ensures
        // that an update will occur only if nobody else has performed an
        // update first.
        success = (1 == getExtendedJdbcTemplate().update( 
        		getBoundSql("FRAMEWORK_V2.UPDATE_SEQUENCER").getSql(),
                new Object[] { newID, type, currentID },
                new int[] { Types.INTEGER, Types.INTEGER, Types.INTEGER }));
        // Check to see if the row was affected. If not, some other process
        // already changed the original id that we read. Therefore, this
        // round failed and we'll have to try again.
        
        if (success) {
            this.currentID = currentID;
            this.maxID = newID;
        }
        
        if( !success ){
        	try {
				Thread.sleep(75L);
			} catch (InterruptedException e) {}
			
			getNextBlock( count - 1);
        }        
    }

	@Override
	public boolean equals(Object obj) {
		JdbcSequencer other = (JdbcSequencer)obj;
		return other.getSequencerId() == getSequencerId();
	}
    
}