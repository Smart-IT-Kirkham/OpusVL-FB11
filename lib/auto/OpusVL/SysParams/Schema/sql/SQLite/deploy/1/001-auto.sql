-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Jun 13 09:36:48 2018
-- 

;
BEGIN TRANSACTION;
--
-- Table: sys_info
--
CREATE TABLE sys_info (
  name text NOT NULL,
  label text,
  value text,
  comment text,
  data_type enum,
  PRIMARY KEY (name)
);
COMMIT;
