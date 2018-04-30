-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Mon Apr 30 09:51:14 2018
-- 
;
SET foreign_key_checks=0;
--
-- Table: `user_parameters`
--
CREATE TABLE `user_parameters` (
  `id` integer NOT NULL,
  `prefs_json` jsonb NOT NULL,
  PRIMARY KEY (`id`)
);
SET foreign_key_checks=1;
