-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Wed Jun 26 15:47:27 2019
-- 
;
SET foreign_key_checks=0;
--
-- Table: `custom_params`
--
CREATE TABLE `custom_params` (
  `type` text NOT NULL,
  `schema` jsonb NOT NULL,
  PRIMARY KEY (`type`)
);
SET foreign_key_checks=1;
