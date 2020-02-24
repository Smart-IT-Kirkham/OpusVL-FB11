-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Fri Jun  7 15:16:37 2019
-- 

;
BEGIN TRANSACTION;
--
-- Table: object_params
--
CREATE TABLE object_params (
  id INTEGER PRIMARY KEY NOT NULL,
  object_type text NOT NULL,
  object_identifier jsonb NOT NULL,
  parameter_owner text NOT NULL,
  parameters jsonb NOT NULL
);
COMMIT;
