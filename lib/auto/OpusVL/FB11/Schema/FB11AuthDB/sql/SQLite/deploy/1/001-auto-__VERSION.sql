-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Tue Feb  6 14:52:13 2018
-- 

;
BEGIN TRANSACTION;
--
-- Table: dbix_class_deploymenthandler_versions_withschemata
--
CREATE TABLE dbix_class_deploymenthandler_versions_withschemata (
  id INTEGER PRIMARY KEY NOT NULL,
  schema text NOT NULL,
  version text NOT NULL,
  ddl text,
  upgrade_sql text
);
CREATE UNIQUE INDEX dbix_class_deploymenthandler_versions_withschemata_schema_version ON dbix_class_deploymenthandler_versions_withschemata (schema, version);
COMMIT;
