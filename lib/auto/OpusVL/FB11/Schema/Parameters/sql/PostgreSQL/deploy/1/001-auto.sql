-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Mon Apr 30 09:51:14 2018
-- 
;
--
-- Table: user_parameters
--
CREATE TABLE "user_parameters" (
  "id" integer NOT NULL,
  "prefs_json" jsonb NOT NULL,
  PRIMARY KEY ("id")
);

;
