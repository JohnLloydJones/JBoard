CREATE TABLE `jboard`.`board`
(
   id BIGINT PRIMARY KEY not null,
   created DATETIME,
   created_by VARCHAR(32) not null,
   description VARCHAR(128),
   locked BIT,
   state VARCHAR(64),
   title VARCHAR(32) not null
);
CREATE TABLE `jboard`.`board_category`
(
   BOARD_ID BIGINT,
   MCATEGORIES_ID BIGINT
);
CREATE TABLE `jboard`.`board_mProperties`
(
   BOARD_ID BIGINT,
   KEY0 VARCHAR(255),
   value VARCHAR(255)
);
CREATE TABLE `jboard`.`category`
(
   id BIGINT PRIMARY KEY not null,
   created DATETIME,
   created_by VARCHAR(32) not null,
   description VARCHAR(128),
   locked BIT,
   state VARCHAR(64),
   title VARCHAR(32)
);
CREATE TABLE `jboard`.`category_forum`
(
   CATEGORY_ID BIGINT,
   MFORUMS_ID BIGINT
);
CREATE TABLE `jboard`.`category_mProperties`
(
   CATEGORY_ID BIGINT,
   KEY0 VARCHAR(255),
   value VARCHAR(255)
);
CREATE TABLE `jboard`.`category_post`
(
   CATEGORY_ID BIGINT,
   MDELETEDPOSTS_ID BIGINT,
   MPENDINGPOSTS_ID BIGINT
);
CREATE TABLE `jboard`.`event`
(
   id BIGINT PRIMARY KEY not null,
   created DATETIME,
   created_by VARCHAR(32) not null,
   description VARCHAR(128),
   locked BIT,
   state VARCHAR(64),
   title VARCHAR(32),
   for_user VARCHAR(32) not null,
   object_id BIGINT,
   text VARCHAR(128),
   type VARCHAR(16) not null
);
CREATE TABLE `jboard`.`event_mProperties`
(
   EVENT_ID BIGINT,
   KEY0 VARCHAR(255),
   value VARCHAR(255)
);
CREATE TABLE `jboard`.`forum`
(
   id BIGINT PRIMARY KEY not null,
   created DATETIME,
   created_by VARCHAR(32) not null,
   description VARCHAR(128),
   locked BIT,
   state VARCHAR(64),
   title VARCHAR(32),
   mLastTopicUpdated BIGINT
);
CREATE TABLE `jboard`.`forum_mProperties`
(
   FORUM_ID BIGINT,
   KEY0 VARCHAR(255),
   value VARCHAR(255)
);
CREATE TABLE `jboard`.`forum_topic`
(
   FORUM_ID BIGINT,
   MTOPICS_ID BIGINT
);
CREATE TABLE `jboard`.`member`
(
   id BIGINT PRIMARY KEY not null,
   created DATETIME,
   created_by VARCHAR(32) not null,
   description VARCHAR(128),
   locked BIT,
   state VARCHAR(64),
   title VARCHAR(32),
   avatar VARCHAR(128),
   email VARCHAR(256) not null,
   first_name VARCHAR(32),
   usr_grp VARCHAR(128),
   last_name VARCHAR(32),
   middle_name VARCHAR(32),
   login_name VARCHAR(32) not null,
   passwrd VARCHAR(64) not null,
   photo VARCHAR(128),
   reg_code VARCHAR(64),
   sig VARCHAR(256),
   tzone VARCHAR(64)
);
CREATE TABLE `jboard`.`member_member`
(
   MEMBER_ID BIGINT,
   MFRIENDS_ID BIGINT
);
CREATE TABLE `jboard`.`member_mProperties`
(
   MEMBER_ID BIGINT,
   KEY0 VARCHAR(255),
   value VARCHAR(255)
);
CREATE TABLE `jboard`.`message`
(
   id BIGINT PRIMARY KEY not null,
   body TEXT not null,
   created DATETIME,
   created_by VARCHAR(32) not null
);
CREATE TABLE `jboard`.`meta_data`
(
   id BIGINT PRIMARY KEY not null,
   description VARCHAR(128),
   data_key VARCHAR(32) not null,
   data_type VARCHAR(16) not null,
   data_value VARCHAR(256)
);
CREATE TABLE `jboard`.`post`
(
   id BIGINT PRIMARY KEY not null,
   created DATETIME,
   created_by VARCHAR(32) not null,
   description VARCHAR(128),
   locked BIT,
   state VARCHAR(64),
   title VARCHAR(32),
   body_id BIGINT,
   previous_id BIGINT,
   version BIGINT
);
CREATE TABLE `jboard`.`post_mProperties`
(
   POST_ID BIGINT,
   KEY0 VARCHAR(255),
   value VARCHAR(255)
);

CREATE TABLE `jboard`.`sequence`
(
   id INT PRIMARY KEY not null,
   name VARCHAR(30) not null,
   VALUE0 BIGINT
);

CREATE TABLE `jboard`.`topic`
(
   id BIGINT PRIMARY KEY not null,
   created DATETIME,
   created_by VARCHAR(32) not null,
   description VARCHAR(128),
   locked BIT,
   state VARCHAR(64),
   title VARCHAR(32),
   mLastPostAuthor VARCHAR(255),
   mLastPostDate DATETIME,
   mLastPostId BIGINT,
   mNumReplies INT
);
CREATE TABLE `jboard`.`topic_mProperties`
(
   TOPIC_ID BIGINT,
   KEY0 VARCHAR(255),
   value VARCHAR(255)
);
CREATE TABLE `jboard`.`topic_post`
(
   TOPIC_ID BIGINT,
   MPOSTS_ID BIGINT
);
CREATE TABLE `jboard`.`category_mModerators`
(
   CATEGORY_ID BIGINT,
   element VARCHAR(255)
);
CREATE UNIQUE INDEX UNQ_title ON board(title);
CREATE UNIQUE INDEX UNQ_email ON member(email);
CREATE UNIQUE INDEX UNQ_login_name ON member(login_name);
CREATE UNIQUE INDEX UNQ_typekey ON meta_data
(
  data_type,
  data_key
);
