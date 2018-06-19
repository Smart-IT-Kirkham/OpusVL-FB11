-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Wed Jun 13 12:56:08 2018
-- 
;
SET foreign_key_checks=0;
--
-- Table: `evt_creator_types`
--
CREATE TABLE `evt_creator_types` (
  `id` integer NOT NULL auto_increment,
  `creator_type` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `evt_creator_types_creator_type_key` (`creator_type`)
) ENGINE=InnoDB;
--
-- Table: `evt_creators`
--
CREATE TABLE `evt_creators` (
  `id` integer NOT NULL,
  `creator_type_id` integer NOT NULL,
  INDEX `evt_creators_idx_creator_type_id` (`creator_type_id`),
  PRIMARY KEY (`id`, `creator_type_id`),
  CONSTRAINT `evt_creators_fk_creator_type_id` FOREIGN KEY (`creator_type_id`) REFERENCES `evt_creator_types` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `evt_events`
--
CREATE TABLE `evt_events` (
  `id` integer NOT NULL auto_increment,
  `type_id` integer NOT NULL,
  `creator_id` integer NOT NULL,
  `creator_type_id` integer NOT NULL,
  `event_date` timestamp NOT NULL DEFAULT current_timestamp,
  `details` text NOT NULL,
  `source` text NOT NULL,
  `event` text NOT NULL,
  `data` text NULL,
  `username` text NULL,
  `ip_addr` text NULL,
  INDEX `evt_events_idx_creator_id_creator_type_id` (`creator_id`, `creator_type_id`),
  INDEX `evt_events_idx_type_id` (`type_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `evt_events_fk_creator_id_creator_type_id` FOREIGN KEY (`creator_id`, `creator_type_id`) REFERENCES `evt_creators` (`id`, `creator_type_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `evt_events_fk_type_id` FOREIGN KEY (`type_id`) REFERENCES `evt_types` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `evt_types`
--
CREATE TABLE `evt_types` (
  `id` integer NOT NULL auto_increment,
  `event_type` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `evt_types_event_type_key` (`event_type`)
) ENGINE=InnoDB;
--
-- Table: `system_events`
--
CREATE TABLE `system_events` (
  `id` integer NOT NULL auto_increment,
  `evt_creator_type_id` integer NULL,
  INDEX `system_events_idx_id_evt_creator_type_id` (`id`, `evt_creator_type_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `system_events_fk_id_evt_creator_type_id` FOREIGN KEY (`id`, `evt_creator_type_id`) REFERENCES `evt_creators` (`id`, `creator_type_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
SET foreign_key_checks=1;
