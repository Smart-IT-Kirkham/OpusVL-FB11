-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed Jun 13 09:36:48 2018
-- 
;
--
-- Table: sys_info
--
CREATE TABLE "sys_info" (
  "name" text NOT NULL,
  "label" text,
  "value" text,
  "comment" text,
  "data_type" character varying,
  PRIMARY KEY ("name")
);

;
