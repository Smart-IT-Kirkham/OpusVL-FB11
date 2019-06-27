-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed Jun 26 15:47:27 2019
-- 
;
--
-- Table: custom_params
--
CREATE TABLE "custom_params" (
  "type" text NOT NULL,
  "schema" jsonb NOT NULL,
  PRIMARY KEY ("type")
);

;
