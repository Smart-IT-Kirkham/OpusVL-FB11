-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Wed Jun 13 09:36:48 2018
-- 
;
SET foreign_key_checks=0;
--
-- Table: `sys_info`
--
CREATE TABLE `sys_info` (
  `name` text NOT NULL,
  `label` text NULL,
  `value` text NULL,
  `comment` text NULL,
  `data_type` enum('text', 'textarea', 'object', 'array', 'bool') NULL,
  PRIMARY KEY (`name`)
);
SET foreign_key_checks=1;
