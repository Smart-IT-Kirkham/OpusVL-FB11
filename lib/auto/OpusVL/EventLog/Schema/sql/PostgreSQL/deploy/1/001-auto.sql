-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed Jul  3 11:33:19 2019
-- 
;
--
-- Table: event_log
--
CREATE TABLE "event_log" (
  "id" serial NOT NULL,
  "object_identifier" jsonb NOT NULL,
  "payload" jsonb NOT NULL,
  "tags" jsonb,
  "type" text,
  "timestamp" timestamptz DEFAULT NOW() NOT NULL,
  PRIMARY KEY ("id")
);

;
