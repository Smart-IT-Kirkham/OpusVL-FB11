-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Tue Jul  2 11:17:35 2019
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
  environmental_data jsonb,
  type text,
  timestamp timestamptz NOT NULL DEFAULT NOW()
);
COMMIT;
