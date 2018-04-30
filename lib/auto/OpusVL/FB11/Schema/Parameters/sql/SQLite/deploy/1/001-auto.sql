-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Mon Apr 30 09:51:14 2018
-- 

;
BEGIN TRANSACTION;
--
-- Table: user_parameters
--
CREATE TABLE user_parameters (
  id INTEGER PRIMARY KEY NOT NULL,
  prefs_json jsonb NOT NULL
);
COMMIT;
