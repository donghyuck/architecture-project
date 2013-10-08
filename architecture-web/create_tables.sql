		-- =================================================  
		--  CONTENT 	
		-- =================================================		
		CREATE TABLE V2_CONTENT (
			
			OBJECT_TYPE							INTEGER NOT NULL,
			OBJECT_ID								INTEGER NOT NULL,	 			
			CONTENT_ID							INTEGER NOT NULL,
			CONTENT_TYPE						VARCHAR2(255) NOT NULL,
			TITLE										VARCHAR2(255) NOT NULL,
			LOCATION								VARCHAR2(255) NOT NULL,
			CREATOR								INTEGER,
			LASTMODIFIER						INTEGER,
			CREATION_DATE						DATE DEFAULT  SYSDATE NOT NULL,
			MODIFIED_DATE						DATE DEFAULT  SYSDATE NOT NULL,		
			CONSTRAINT V2_CONTENT_PK PRIMARY KEY (CONTENT_ID)
		);
		
		CREATE INDEX V2_CONTENT_TITLE_IDX ON V2_CONTENT (TITLE);
		
		CREATE INDEX V2_CONTENT_IDX2 ON V2_CONTENT( OBJECT_TYPE , OBJECT_ID) ;	
		
		CREATE TABLE V2_CONTENT_BODY (			
			BODY_CONTENT_ID					INTEGER NOT NULL,	 			
			BODY									CLOB,
			CONSTRAINT V2_CONTENT_BODY_PK PRIMARY KEY (BODY_CONTENT_ID)
		);		
		
		CREATE TABLE V2_CONTENT_PROPERTY (
		  CONTENT_ID                     INTEGER NOT NULL,
		  PROPERTY_NAME          VARCHAR2(100)   NOT NULL,
		  PROPERTY_VALUE         VARCHAR2(1024)  NOT NULL,
		  CONSTRAINT V2_CONTENT_PROPERTY_PK PRIMARY KEY (CONTENT_ID, PROPERTY_NAME)
		);	
		
		-- =================================================  
		--  SOCIAL 	
		-- =================================================		
		CREATE TABLE V2_SOCIAL_PROVIDER (
			PROVIDER_ID				INTEGER NOT NULL,
			PROVIDER_NAME			VARCHAR2(255) NOT NULL,
			API_KEY						VARCHAR2(255) NOT NULL,
			API_SECRET					VARCHAR2(255) NOT NULL,
			CREATION_DATE			DATE DEFAULT  SYSDATE NOT NULL,
			MODIFIED_DATE			DATE DEFAULT  SYSDATE NOT NULL,			
			CONSTRAINT V2_SOCIAL_PROVIDER_PK PRIMARY KEY (PROVIDER_ID)
	    );
		CREATE UNIQUE INDEX V2_SOCIAL_PROVIDER_IDX ON V2_USER (PROVIDER_NAME);
		
		CREATE TABLE V2_SOCIAL_ACCOUNT (
			ACCOUNT_ID							INTEGER NOT NULL,
			OBJECT_TYPE							INTEGER NOT NULL,
			OBJECT_ID								INTEGER NOT NULL,	 
			SOCIAL_PROVIDER					VARCHAR2(255) NOT NULL,
			
			--SOCIAL_ACCOUNT_ID					VARCHAR2(255) NOT NULL,
			--SOCIAL_ACCOUNT_NAME			VARCHAR2(255) ,   
			--SOCIAL_ACCOUNT_USERNAME 	VARCHAR2(255) ,
			--SOCIAL_ACCOUNT_URL				VARCHAR2(255) ,			
			
			ACCESS_TOKEN						VARCHAR2(255) NOT NULL,
			ACCESS_SECRET						VARCHAR2(255) NOT NULL,					
			SIGNED									NUMBER(1, 0)  DEFAULT 0, 
			CREATION_DATE						DATE DEFAULT  SYSDATE NOT NULL,
			MODIFIED_DATE						DATE DEFAULT  SYSDATE NOT NULL,		
			CONSTRAINT V2_SOCIAL_ACCOUNT_PK PRIMARY KEY (ACCOUNT_ID)
	    );	    
	    CREATE INDEX V2_SOCIAL_ACCOUNT_IDX ON V2_SOCIAL_ACCOUNT( OBJECT_TYPE ) ;	
	    CREATE INDEX V2_SOCIAL_ACCOUNT_IDX2 ON V2_SOCIAL_ACCOUNT( OBJECT_TYPE , OBJECT_ID) ;	
	    --CREATE INDEX V2_SOCIAL_ACCOUNT_IDX3 ON V2_SOCIAL_ACCOUNT( OBJECT_TYPE, SOCIAL_ACCOUNT_ID ) ;	
	    
	    COMMENT ON TABLE      "V2_SOCIAL_ACCOUNT"  IS '쇼셜 계정 정보 테이블';
	    COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."ACCOUNT_ID" IS '쇼셜계정정보 아이디'; 
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."OBJECT_TYPE" IS '관련 데이터 유형'; 
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."OBJECT_ID" IS '관련 데이터 ID'; 
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."SOCIAL_PROVIDER" IS '서비스 제공자 명'; 
		--COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."SOCIAL_ACCOUNT_ID" IS '계정 ID'; 
		--COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."SOCIAL_ACCOUNT_NAME" IS '계정 NAMe'; 
		--COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."SOCIAL_ACCOUNT_USERNAME" IS '계정 USERNAME'; 
		--COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."SOCIAL_ACCOUNT_URL" IS '계정 URL'; 
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."ACCESS_TOKEN" IS '인증된 TOKEN 값'; 
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."ACCESS_SECRET" IS '인증된 SECRET 값'; 
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."CREATION_DATE" IS '생성일'; 
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT"."MODIFIED_DATE" IS '수정일'; 		
		
		CREATE TABLE V2_SOCIAL_ACCOUNT_PROPERTY (
		  ACCOUNT_ID                     INTEGER NOT NULL,
		  PROPERTY_NAME          VARCHAR2(100)   NOT NULL,
		  PROPERTY_VALUE         VARCHAR2(1024)  NOT NULL,
		  CONSTRAINT V2_SOCIAL_ACCOUNT_PROPERTY_PK PRIMARY KEY (ACCOUNT_ID, PROPERTY_NAME)
		);	
		COMMENT ON TABLE      "V2_SOCIAL_ACCOUNT_PROPERTY"  IS '쇼셜 계정 정보 프로퍼티 테이블';
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT_PROPERTY"."ACCOUNT_ID" IS '쇼셜계정정보  ID'; 
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT_PROPERTY"."PROPERTY_NAME" IS '프로퍼티 이름'; 
		COMMENT ON COLUMN "V2_SOCIAL_ACCOUNT_PROPERTY"."PROPERTY_VALUE" IS '프로퍼티 값'; 				
		-- =================================================  
		--  MENU	
		-- =================================================		
		CREATE TABLE V2_MENU (
	    	MENU_ID			          INTEGER NOT NULL,
	   		--COMPANY_ID               INTEGER NOT NULL,
		   	NAME                         VARCHAR2(255) NOT NULL,
		   	TITLE                           VARCHAR2(255) NOT NULL,
		   	LOCATION                   VARCHAR2(255),
		    MENU_ENABLED           NUMBER(1, 0)  DEFAULT 1,
			CREATION_DATE            DATE DEFAULT  SYSDATE NOT NULL,
			MODIFIED_DATE            DATE DEFAULT  SYSDATE NOT NULL,	
	    	CONSTRAINT V2_MENU_PK PRIMARY KEY (MENU_ID)	    
	    );		
		COMMENT ON TABLE      "V2_MENU"  IS '메뉴 테이블';
		COMMENT ON COLUMN "V2_MENU"."MENU_ID" IS '메뉴 ID'; 
		--COMMENT ON COLUMN "V2_MENU"."COMPANY_ID" IS '회사 아이디'; 
		COMMENT ON COLUMN "V2_MENU"."NAME" IS '이름'; 		
		COMMENT ON COLUMN "V2_MENU"."TITLE" IS '타이틀 명'; 
		COMMENT ON COLUMN "V2_MENU"."LOCATION" IS 'LOCATION 값'; 				
		COMMENT ON COLUMN "V2_MENU"."MENU_ENABLED" IS '사용여부'; 
		COMMENT ON COLUMN "V2_MENU"."CREATION_DATE" IS '생성을'; 		
		COMMENT ON COLUMN "V2_MENU"."MODIFIED_DATE" IS '수정일'; 
		
		CREATE TABLE V2_MENU_PROPERTY (
		  MENU_ID                     INTEGER NOT NULL,
		  PROPERTY_NAME          VARCHAR2(100)   NOT NULL,
		  PROPERTY_VALUE         VARCHAR2(1024)  NOT NULL,
		  CONSTRAINT V2_MENU_PROPERTY_PK PRIMARY KEY (MENU_ID, PROPERTY_NAME)
		);	
		COMMENT ON TABLE      "V2_MENU_PROPERTY"  IS '메뉴 프로퍼티 테이블';
		COMMENT ON COLUMN "V2_MENU_PROPERTY"."MENU_ID" IS '메뉴 ID'; 
		COMMENT ON COLUMN "V2_MENU_PROPERTY"."PROPERTY_NAME" IS '프로퍼티 이름'; 
		COMMENT ON COLUMN "V2_MENU_PROPERTY"."PROPERTY_VALUE" IS '프로퍼티 값'; 		

		CREATE TABLE V2_MENU_XML (
			  MENU_ID                    INTEGER NOT NULL,
			  MENU_DATA               CLOB,
			  CONSTRAINT V2_MENU_XML_PK PRIMARY KEY (MENU_ID)
		);
		
		CREATE TABLE V2_MENU_DATA (
			  MENU_ID                    INTEGER NOT NULL,
			  MENU_DATA               BLOB,
			  CONSTRAINT V2_MENU_DATA_PK PRIMARY KEY (MENU_ID)
		);
		
		-- =================================================  
		--  ATTACHEMENT 	
		-- =================================================		
		CREATE TABLE V2_ATTACHMENT (
	    		ATTACHMENT_ID			  INTEGER NOT NULL,
			  	OBJECT_TYPE                INTEGER NOT NULL,
			  	OBJECT_ID                   INTEGER NOT NULL,	    		
			   	CONTENT_TYPE             VARCHAR2(50)  NOT NULL,			  
			   	FILE_NAME                   VARCHAR2(255)   NOT NULL,
			   	FILE_SIZE                      INTEGER   NOT NULL,
			   	CREATION_DATE            DATE DEFAULT  SYSDATE NOT NULL,
			   	MODIFIED_DATE            DATE DEFAULT  SYSDATE NOT NULL,	
	    	   CONSTRAINT V2_ATTACHMENT_PK PRIMARY KEY (ATTACHMENT_ID)	    
	    );
	    
	    CREATE INDEX V2_ATTACHMENT_OBJ_IDX ON V2_ATTACHMENT( OBJECT_TYPE, OBJECT_ID ) ;	
		COMMENT ON TABLE "V2_ATTACHMENT"  IS '첨부파일 테이블';
		COMMENT ON COLUMN "V2_ATTACHMENT"."ATTACHMENT_ID" IS 'ID'; 
		COMMENT ON COLUMN "V2_ATTACHMENT"."OBJECT_TYPE" IS '첨부파일과 연관된 모델 유형'; 
        COMMENT ON COLUMN "V2_ATTACHMENT"."OBJECT_ID" IS '첨부파일과 연관된 모델 ID';
		COMMENT ON COLUMN "V2_ATTACHMENT"."FILE_NAME" IS '첨부파일 이름'; 
        COMMENT ON COLUMN "V2_ATTACHMENT"."FILE_SIZE" IS '첨부파일 크기';        
		COMMENT ON COLUMN "V2_ATTACHMENT"."CONTENT_TYPE" IS 'CONTENT TYPE 값'; 
		COMMENT ON COLUMN "V2_ATTACHMENT"."CREATION_DATE" IS '생성일'; 
        COMMENT ON COLUMN "V2_ATTACHMENT"."MODIFIED_DATE" IS '수정일';

        CREATE TABLE V2_ATTACHMENT_PROPERTY (
		  ATTACHMENT_ID               INTEGER NOT NULL,
		  PROPERTY_NAME          VARCHAR2(100)   NOT NULL,
		  PROPERTY_VALUE         VARCHAR2(1024)  NOT NULL,
		  CONSTRAINT V2_ATTACHMENT_PROPERTY_PK PRIMARY KEY (ATTACHMENT_ID, PROPERTY_NAME)
		);	
		COMMENT ON TABLE      "V2_ATTACHMENT_PROPERTY"  IS '첨부파일 프로퍼티 테이블';
		COMMENT ON COLUMN "V2_ATTACHMENT_PROPERTY"."ATTACHMENT_ID" IS '첨부파일 ID'; 
		COMMENT ON COLUMN "V2_ATTACHMENT_PROPERTY"."PROPERTY_NAME" IS '프로퍼티 이름'; 
		COMMENT ON COLUMN "V2_ATTACHMENT_PROPERTY"."PROPERTY_VALUE" IS '프로퍼티 값'; 		

		CREATE TABLE V2_ATTACHMENT_DATA (
			  ATTACHMENT_ID                    INTEGER NOT NULL,
			  ATTACHMENT_DATA               BLOB,
			  CONSTRAINT V2_ATTACHMENT_DATA_PK PRIMARY KEY (ATTACHMENT_ID)
		);		        
		
		COMMENT ON TABLE "V2_ATTACHMENT_DATA"  IS '첨부파일 데이터 테이블';
		COMMENT ON COLUMN "V2_ATTACHMENT_DATA"."ATTACHMENT_ID" IS 'ID'; 
		COMMENT ON COLUMN "V2_ATTACHMENT_DATA"."ATTACHMENT_DATA" IS '첨부파일 데이터'; 		
		
	    -- =================================================  
		--  IMAGE	
		-- =================================================		
		CREATE TABLE V2_IMAGE (
			  IMAGE_ID                    INTEGER NOT NULL,
			  OBJECT_TYPE                INTEGER NOT NULL,
			  OBJECT_ID                   INTEGER NOT NULL,
			  FILE_NAME                   VARCHAR2(255)   NOT NULL,
			  FILE_SIZE                      INTEGER   NOT NULL,
			  CONTENT_TYPE             VARCHAR2(50)  NOT NULL,			  
			  CREATION_DATE            DATE DEFAULT  SYSDATE NOT NULL,
			  MODIFIED_DATE            DATE DEFAULT  SYSDATE NOT NULL,	
			  CONSTRAINT V2_IMAGE_PK PRIMARY KEY (IMAGE_ID)
		);		        
		
		
		CREATE INDEX V2_IMAGE_OBJ_IDX ON V2_IMAGE( OBJECT_TYPE, OBJECT_ID ) ;	
		COMMENT ON TABLE "V2_IMAGE"  IS '이미지 테이블';
		COMMENT ON COLUMN "V2_IMAGE"."IMAGE_ID" IS 'ID'; 
		COMMENT ON COLUMN "V2_IMAGE"."OBJECT_TYPE" IS '이미지와 연관된 모델 유형'; 
        COMMENT ON COLUMN "V2_IMAGE"."OBJECT_ID" IS '이미지와 연관된 모델 ID';
		COMMENT ON COLUMN "V2_IMAGE"."FILE_NAME" IS '이미지 파일 이름'; 
        COMMENT ON COLUMN "V2_IMAGE"."FILE_SIZE" IS '이미지 파일 크기';        
		COMMENT ON COLUMN "V2_IMAGE"."CONTENT_TYPE" IS 'CONTENT TYPE 값'; 
		COMMENT ON COLUMN "V2_IMAGE"."CREATION_DATE" IS '생성일'; 
        COMMENT ON COLUMN "V2_IMAGE"."MODIFIED_DATE" IS '수정일';
        
        CREATE TABLE V2_IMAGE_DATA (
			  IMAGE_ID                    INTEGER NOT NULL,
			  IMAGE_DATA               BLOB,
			  CONSTRAINT V2_IMAGE_DATA_PK PRIMARY KEY (IMAGE_ID)
		);		        
		
		COMMENT ON TABLE "V2_IMAGE_DATA"  IS '이미지 데이터 테이블';
		COMMENT ON COLUMN "V2_IMAGE_DATA"."IMAGE_ID" IS 'ID'; 
		COMMENT ON COLUMN "V2_IMAGE_DATA"."IMAGE_DATA" IS '이미지 데이터'; 		
		