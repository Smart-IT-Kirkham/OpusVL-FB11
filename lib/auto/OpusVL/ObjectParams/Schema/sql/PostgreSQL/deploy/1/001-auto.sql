-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Fri Jun  7 15:16:37 2019
-- 
;
--
-- Table: object_params
--
CREATE TABLE "object_params" (
  "id" serial NOT NULL,
  "object_type" text NOT NULL,
  "object_identifier" jsonb NOT NULL,
  "parameter_owner" text NOT NULL,
  "parameters" jsonb NOT NULL,
  PRIMARY KEY ("id")
);

;
