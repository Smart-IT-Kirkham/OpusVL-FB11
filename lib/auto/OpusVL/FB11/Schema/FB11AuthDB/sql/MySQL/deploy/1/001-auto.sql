-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Thu Aug 10 11:15:23 2017
-- 
;
SET foreign_key_checks=0;
--
-- Table: `aclfeature`
--
CREATE TABLE `aclfeature` (
  `id` integer NOT NULL auto_increment,
  `feature` text NOT NULL,
  `feature_description` text NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `aclfeature_role`
--
CREATE TABLE `aclfeature_role` (
  `aclfeature_id` integer NOT NULL,
  `role_id` integer NOT NULL,
  INDEX `aclfeature_role_idx_aclfeature_id` (`aclfeature_id`),
  INDEX `aclfeature_role_idx_role_id` (`role_id`),
  PRIMARY KEY (`aclfeature_id`, `role_id`),
  CONSTRAINT `aclfeature_role_fk_aclfeature_id` FOREIGN KEY (`aclfeature_id`) REFERENCES `aclfeature` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aclfeature_role_fk_role_id` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `aclrule`
--
CREATE TABLE `aclrule` (
  `id` integer NOT NULL auto_increment,
  `actionpath` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `parameter`
--
CREATE TABLE `parameter` (
  `id` integer NOT NULL auto_increment,
  `data_type` text NOT NULL,
  `parameter` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `role`
--
CREATE TABLE `role` (
  `id` integer NOT NULL auto_increment,
  `role` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;
--
-- Table: `role_admin`
--
CREATE TABLE `role_admin` (
  `role_id` integer NOT NULL auto_increment,
  INDEX (`role_id`),
  PRIMARY KEY (`role_id`),
  CONSTRAINT `role_admin_fk_role_id` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `roles_allowed`
--
CREATE TABLE `roles_allowed` (
  `role` integer NOT NULL,
  `role_allowed` integer NOT NULL,
  INDEX `roles_allowed_idx_role` (`role`),
  INDEX `roles_allowed_idx_role_allowed` (`role_allowed`),
  PRIMARY KEY (`role`, `role_allowed`),
  CONSTRAINT `roles_allowed_fk_role` FOREIGN KEY (`role`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `roles_allowed_fk_role_allowed` FOREIGN KEY (`role_allowed`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `users`
--
CREATE TABLE `users` (
  `id` integer NOT NULL auto_increment,
  `username` text NOT NULL,
  `password` text NOT NULL,
  `email` text NOT NULL,
  `name` text NOT NULL,
  `tel` text NULL,
  `status` text NOT NULL DEFAULT 'active',
  `last_login` timestamp NULL,
  `last_failed_login` timestamp NULL,
  PRIMARY KEY (`id`),
  UNIQUE `users_username` (`username`)
) ENGINE=InnoDB;
--
-- Table: `parameter_defaults`
--
CREATE TABLE `parameter_defaults` (
  `id` integer NOT NULL auto_increment,
  `parameter_id` integer NOT NULL,
  `data` text NULL,
  INDEX `parameter_defaults_idx_parameter_id` (`parameter_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `parameter_defaults_fk_parameter_id` FOREIGN KEY (`parameter_id`) REFERENCES `parameter` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `user_avatar`
--
CREATE TABLE `user_avatar` (
  `id` integer NOT NULL auto_increment,
  `user_id` integer NOT NULL,
  `mime_type` text NOT NULL,
  `data` blob NOT NULL,
  INDEX `user_avatar_idx_user_id` (`user_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `user_avatar_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;
--
-- Table: `users_data`
--
CREATE TABLE `users_data` (
  `id` integer NOT NULL auto_increment,
  `users_id` integer NOT NULL,
  `key` text NOT NULL,
  `value` text NOT NULL,
  INDEX `users_data_idx_users_id` (`users_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `users_data_fk_users_id` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `users_favourites`
--
CREATE TABLE `users_favourites` (
  `id` integer NOT NULL auto_increment,
  `user_id` integer NOT NULL,
  `page` varchar(255) NOT NULL,
  `name` varchar(255) NULL,
  INDEX `users_favourites_idx_user_id` (`user_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `users_favourites_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;
--
-- Table: `aclrule_role`
--
CREATE TABLE `aclrule_role` (
  `aclrule_id` integer NOT NULL auto_increment,
  `role_id` integer NOT NULL auto_increment,
  INDEX `aclrule_role_idx_aclrule_id` (`aclrule_id`),
  INDEX `aclrule_role_idx_role_id` (`role_id`),
  PRIMARY KEY (`aclrule_id`, `role_id`),
  CONSTRAINT `aclrule_role_fk_aclrule_id` FOREIGN KEY (`aclrule_id`) REFERENCES `aclrule` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `aclrule_role_fk_role_id` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `users_parameter`
--
CREATE TABLE `users_parameter` (
  `users_id` integer NOT NULL auto_increment,
  `parameter_id` integer NOT NULL auto_increment,
  `value` text NOT NULL,
  INDEX `users_parameter_idx_parameter_id` (`parameter_id`),
  INDEX `users_parameter_idx_users_id` (`users_id`),
  PRIMARY KEY (`users_id`, `parameter_id`),
  CONSTRAINT `users_parameter_fk_parameter_id` FOREIGN KEY (`parameter_id`) REFERENCES `parameter` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `users_parameter_fk_users_id` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `users_role`
--
CREATE TABLE `users_role` (
  `users_id` integer NOT NULL auto_increment,
  `role_id` integer NOT NULL auto_increment,
  INDEX `users_role_idx_role_id` (`role_id`),
  INDEX `users_role_idx_users_id` (`users_id`),
  PRIMARY KEY (`users_id`, `role_id`),
  CONSTRAINT `users_role_fk_role_id` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `users_role_fk_users_id` FOREIGN KEY (`users_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
SET foreign_key_checks=1;
