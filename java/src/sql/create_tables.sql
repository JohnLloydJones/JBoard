
  CREATE TABLE "JRUBYAPP"."BOARD" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"CREATED" TIMESTAMP (6), 
	"CREATED_BY" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	"DESCRIPTION" VARCHAR2(128 BYTE), 
	"LOCKED" NUMBER, 
	"STATE" VARCHAR2(64 BYTE), 
	"TITLE" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE, 
	 CONSTRAINT "UNQ_TITLE" UNIQUE ("TITLE") DEFERRABLE
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE UNIQUE INDEX "JRUBYAPP"."SYS_C004421" ON "JRUBYAPP"."BOARD" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 
  CREATE INDEX "JRUBYAPP"."UNQ_TITLE" ON "JRUBYAPP"."BOARD" ("TITLE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."BOARD_CATEGORY" 
   (	"BOARD_ID" NUMBER, 
	"MCATEGORIES_ID" NUMBER
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE INDEX "JRUBYAPP"."I_BRD_GRY_BOARD_ID" ON "JRUBYAPP"."BOARD_CATEGORY" ("BOARD_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 
  CREATE INDEX "JRUBYAPP"."I_BRD_GRY_ELEMENT" ON "JRUBYAPP"."BOARD_CATEGORY" ("MCATEGORIES_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."CATEGORY" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"CREATED" TIMESTAMP (6), 
	"CREATED_BY" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	"DESCRIPTION" VARCHAR2(128 BYTE), 
	"LOCKED" NUMBER, 
	"STATE" VARCHAR2(64 BYTE), 
	"TITLE" VARCHAR2(32 BYTE), 
	 PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."CATEGORY_FORUM" 
   (	"CATEGORY_ID" NUMBER, 
	"MFORUMS_ID" NUMBER
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE INDEX "JRUBYAPP"."I_CTGRFRM_CATEGORY_ID" ON "JRUBYAPP"."CATEGORY_FORUM" ("CATEGORY_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."FORUM" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"CREATED" TIMESTAMP (6), 
	"CREATED_BY" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	"DESCRIPTION" VARCHAR2(128 BYTE), 
	"LOCKED" NUMBER, 
	"STATE" VARCHAR2(64 BYTE), 
	"TITLE" VARCHAR2(32 BYTE), 
	"MLASTTOPICUPDATED" NUMBER, 
	 PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."FORUM_TOPIC" 
   (	"FORUM_ID" NUMBER, 
	"MTOPICS_ID" NUMBER
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."MEMBER" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"CREATED" TIMESTAMP (6), 
	"CREATED_BY" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	"DESCRIPTION" VARCHAR2(128 BYTE), 
	"LOCKED" NUMBER, 
	"STATE" VARCHAR2(64 BYTE), 
	"TITLE" VARCHAR2(32 BYTE), 
	"AVATAR" VARCHAR2(128 BYTE), 
	"EMAIL" VARCHAR2(256 BYTE) NOT NULL ENABLE, 
	"FIRST_NAME" VARCHAR2(32 BYTE), 
	"USR_GRP" VARCHAR2(128 BYTE), 
	"LAST_NAME" VARCHAR2(32 BYTE), 
	"MIDDLE_NAME" VARCHAR2(32 BYTE), 
	"LOGIN_NAME" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	"PASSWRD" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	"PHOTO" VARCHAR2(128 BYTE), 
	"SIG" VARCHAR2(256 BYTE), 
	"TZONE" VARCHAR2(64 BYTE), 
	 PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE, 
	 CONSTRAINT "UNQ_LOGIN_NAME" UNIQUE ("LOGIN_NAME") DEFERRABLE
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE, 
	 CONSTRAINT "UNQ_EMAIL" UNIQUE ("EMAIL") DEFERRABLE
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE UNIQUE INDEX "JRUBYAPP"."SYS_C004434" ON "JRUBYAPP"."MEMBER" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 
  CREATE INDEX "JRUBYAPP"."UNQ_EMAIL" ON "JRUBYAPP"."MEMBER" ("EMAIL") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 
  CREATE INDEX "JRUBYAPP"."UNQ_LOGIN_NAME" ON "JRUBYAPP"."MEMBER" ("LOGIN_NAME") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."MESSAGE" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"BODY" CLOB NOT NULL ENABLE, 
	"CREATED" TIMESTAMP (6), 
	"CREATED_BY" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	 PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" 
 LOB ("BODY") STORE AS (
  TABLESPACE "USERS" ENABLE STORAGE IN ROW CHUNK 8192 PCTVERSION 10
  NOCACHE LOGGING 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)) ;
 

  CREATE TABLE "JRUBYAPP"."META_DATA" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"DESCRIPTION" VARCHAR2(128 BYTE), 
	"KEY" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	"TYPE" VARCHAR2(16 BYTE) NOT NULL ENABLE, 
	"VALUE" VARCHAR2(256 BYTE), 
	 PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE, 
	 CONSTRAINT "UNQ_TYPEKEY" UNIQUE ("TYPE", "KEY") DEFERRABLE
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE UNIQUE INDEX "JRUBYAPP"."SYS_C004444" ON "JRUBYAPP"."META_DATA" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 
  CREATE INDEX "JRUBYAPP"."UNQ_TYPEKEY" ON "JRUBYAPP"."META_DATA" ("TYPE", "KEY") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."POST" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"CREATED" TIMESTAMP (6), 
	"CREATED_BY" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	"DESCRIPTION" VARCHAR2(128 BYTE), 
	"LOCKED" NUMBER, 
	"STATE" VARCHAR2(64 BYTE), 
	"TITLE" VARCHAR2(32 BYTE), 
	"BODY_ID" NUMBER, 
	"PREVIOUS_ID" NUMBER, 
	"VERSION" NUMBER, 
	 PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."TOPIC" 
   (	"ID" NUMBER NOT NULL ENABLE, 
	"CREATED" TIMESTAMP (6), 
	"CREATED_BY" VARCHAR2(32 BYTE) NOT NULL ENABLE, 
	"DESCRIPTION" VARCHAR2(128 BYTE), 
	"LOCKED" NUMBER, 
	"STATE" VARCHAR2(64 BYTE), 
	"TITLE" VARCHAR2(32 BYTE), 
	"MLASTPOSTAUTHOR" VARCHAR2(255 BYTE), 
	"MLASTPOSTDATE" TIMESTAMP (6), 
	"MLASTPOSTTITLE" VARCHAR2(255 BYTE), 
	 PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS"  ENABLE
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE TABLE "JRUBYAPP"."TOPIC_POST" 
   (	"TOPIC_ID" NUMBER, 
	"MPOSTS_ID" NUMBER
   ) PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "USERS" ;
 

  CREATE SEQUENCE  "JRUBYAPP"."OPENJPA_SEQUENCE"  MINVALUE 1 MAXVALUE 999999999999999999999999999 INCREMENT BY 1 START WITH 101 CACHE 100 NOORDER  NOCYCLE ;
 
