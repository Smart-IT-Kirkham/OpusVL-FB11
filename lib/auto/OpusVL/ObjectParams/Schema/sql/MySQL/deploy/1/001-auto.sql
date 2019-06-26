-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Fri Jun  7 15:16:37 2019
-- 
;
SET foreign_key_checks=0;
--
-- Table: `object_params`
--
CREATE TABLE `object_params` (
  `id` integer NOT NULL auto_increment,
  `object_type` text NOT NULL,
  `object_identifier` jsonb NOT NULL,
  `parameter_owner` text NOT NULL,
  `parameters` jsonb NOT NULL,
  PRIMARY KEY (`id`)
);
SET foreign_key_checks=1;
