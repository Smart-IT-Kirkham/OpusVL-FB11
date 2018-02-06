-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Tue Feb  6 14:52:13 2018
-- 
;
--
-- Table: dbix_class_deploymenthandler_versions_withschemata
--
CREATE TABLE "dbix_class_deploymenthandler_versions_withschemata" (
  "id" serial NOT NULL,
  "schema" text NOT NULL,
  "version" text NOT NULL,
  "ddl" text,
  "upgrade_sql" text,
  PRIMARY KEY ("id"),
  CONSTRAINT "dbix_class_deploymenthandler_versions_withschemata_schema_version" UNIQUE ("schema", "version")
);

;
