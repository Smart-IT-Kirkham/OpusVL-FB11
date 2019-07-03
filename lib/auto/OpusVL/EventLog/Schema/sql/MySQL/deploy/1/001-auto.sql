-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Wed Jul  3 11:33:19 2019
-- 
;
SET foreign_key_checks=0;
--
-- Table: `event_log`
--
CREATE TABLE `event_log` (
  `id` integer NOT NULL auto_increment,
  `object_identifier` jsonb NOT NULL,
  `payload` jsonb NOT NULL,
  `tags` jsonb NULL,
  `type` text NULL,
  `timestamp` timestamptz NOT NULL DEFAULT NOW(),
  PRIMARY KEY (`id`)
);
SET foreign_key_checks=1;
