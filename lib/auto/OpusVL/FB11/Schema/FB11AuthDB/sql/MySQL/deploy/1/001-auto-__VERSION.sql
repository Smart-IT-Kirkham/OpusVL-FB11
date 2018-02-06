-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Tue Feb  6 14:52:13 2018
-- 
;
SET foreign_key_checks=0;
--
-- Table: `dbix_class_deploymenthandler_versions_withschemata`
--
CREATE TABLE `dbix_class_deploymenthandler_versions_withschemata` (
  `id` integer NOT NULL auto_increment,
  `schema` text NOT NULL,
  `version` text NOT NULL,
  `ddl` text NULL,
  `upgrade_sql` text NULL,
  PRIMARY KEY (`id`),
  UNIQUE `dbix_class_deploymenthandler_versions_withschemata_sche_320ea6e8` (`schema`, `version`)
);
SET foreign_key_checks=1;
