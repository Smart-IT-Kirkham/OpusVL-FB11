-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Jul  2 11:17:35 2019
-- 
;
--
-- Table: event_log
--
CREATE TABLE "event_log" (
  "id" serial NOT NULL,
  "object_identifier" jsonb NOT NULL,
  "payload" jsonb NOT NULL,
  "environmental_data" jsonb,
  "type" text,
  "timestamp" timestamptz DEFAULT NOW() NOT NULL,
  PRIMARY KEY ("id")
);

;
