-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Jul  3 11:33:19 2019
-- 

;
BEGIN TRANSACTION;
--
-- Table: event_log
--
CREATE TABLE event_log (
  id INTEGER PRIMARY KEY NOT NULL,
  object_identifier jsonb NOT NULL,
  payload jsonb NOT NULL,
  tags jsonb,
  type text,
  timestamp timestamptz NOT NULL DEFAULT NOW()
);
COMMIT;
