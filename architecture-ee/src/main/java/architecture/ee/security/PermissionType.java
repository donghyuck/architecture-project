package architecture.ee.security;

public enum PermissionType {
	ADDITIVE(1), NEGATIVE(2);
	
	private int id;

	private PermissionType(int id) {
		this.id = id;
	}
	
    public String toString()
    {
        return String.valueOf(id);
    }
	
    public int getId(){
    	return this.id;
    }
}
