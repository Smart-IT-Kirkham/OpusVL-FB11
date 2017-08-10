-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Thu Aug 10 09:30:49 2017
-- 

;
BEGIN TRANSACTION;
--
-- Table: aclfeature
--
CREATE TABLE aclfeature (
  id INTEGER PRIMARY KEY NOT NULL,
  feature text NOT NULL,
  feature_description text
);
--
-- Table: aclfeature_role
--
CREATE TABLE aclfeature_role (
  aclfeature_id integer NOT NULL,
  role_id integer NOT NULL,
  PRIMARY KEY (aclfeature_id, role_id),
  FOREIGN KEY (aclfeature_id) REFERENCES aclfeature(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX aclfeature_role_idx_aclfeature_id ON aclfeature_role (aclfeature_id);
CREATE INDEX aclfeature_role_idx_role_id ON aclfeature_role (role_id);
--
-- Table: aclrule
--
CREATE TABLE aclrule (
  id INTEGER PRIMARY KEY NOT NULL,
  actionpath text NOT NULL
);
--
-- Table: parameter
--
CREATE TABLE parameter (
  id INTEGER PRIMARY KEY NOT NULL,
  data_type text NOT NULL,
  parameter text NOT NULL
);
--
-- Table: role
--
CREATE TABLE role (
  id INTEGER PRIMARY KEY NOT NULL,
  role text NOT NULL
);
--
-- Table: role_admin
--
CREATE TABLE role_admin (
  role_id INTEGER PRIMARY KEY NOT NULL,
  FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE
);
--
-- Table: roles_allowed
--
CREATE TABLE roles_allowed (
  role integer NOT NULL,
  role_allowed integer NOT NULL,
  PRIMARY KEY (role, role_allowed),
  FOREIGN KEY (role) REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (role_allowed) REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX roles_allowed_idx_role ON roles_allowed (role);
CREATE INDEX roles_allowed_idx_role_allowed ON roles_allowed (role_allowed);
--
-- Table: users
--
CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  username text NOT NULL,
  password text NOT NULL,
  email text NOT NULL,
  name text NOT NULL,
  tel text,
  status text NOT NULL DEFAULT 'active',
  last_login timestamp,
  last_failed_login timestamp
);
CREATE UNIQUE INDEX user_index ON users (username);
--
-- Table: parameter_defaults
--
CREATE TABLE parameter_defaults (
  id INTEGER PRIMARY KEY NOT NULL,
  parameter_id integer NOT NULL,
  data text,
  FOREIGN KEY (parameter_id) REFERENCES parameter(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX parameter_defaults_idx_parameter_id ON parameter_defaults (parameter_id);
--
-- Table: user_avatar
--
CREATE TABLE user_avatar (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id integer NOT NULL,
  mime_type text NOT NULL,
  data blob NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
CREATE INDEX user_avatar_idx_user_id ON user_avatar (user_id);
--
-- Table: users_data
--
CREATE TABLE users_data (
  id INTEGER PRIMARY KEY NOT NULL,
  users_id integer NOT NULL,
  key text NOT NULL,
  value text NOT NULL,
  FOREIGN KEY (users_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX users_data_idx_users_id ON users_data (users_id);
--
-- Table: users_favourites
--
CREATE TABLE users_favourites (
  id INTEGER PRIMARY KEY NOT NULL,
  user_id integer NOT NULL,
  page varchar NOT NULL,
  name varchar,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
CREATE INDEX users_favourites_idx_user_id ON users_favourites (user_id);
--
-- Table: aclrule_role
--
CREATE TABLE aclrule_role (
  aclrule_id integer NOT NULL,
  role_id integer NOT NULL,
  PRIMARY KEY (aclrule_id, role_id),
  FOREIGN KEY (aclrule_id) REFERENCES aclrule(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX aclrule_role_idx_aclrule_id ON aclrule_role (aclrule_id);
CREATE INDEX aclrule_role_idx_role_id ON aclrule_role (role_id);
--
-- Table: users_parameter
--
CREATE TABLE users_parameter (
  users_id integer NOT NULL,
  parameter_id integer NOT NULL,
  value text NOT NULL,
  PRIMARY KEY (users_id, parameter_id),
  FOREIGN KEY (parameter_id) REFERENCES parameter(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (users_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX users_parameter_idx_parameter_id ON users_parameter (parameter_id);
CREATE INDEX users_parameter_idx_users_id ON users_parameter (users_id);
--
-- Table: users_role
--
CREATE TABLE users_role (
  users_id integer NOT NULL,
  role_id integer NOT NULL,
  PRIMARY KEY (users_id, role_id),
  FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (users_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX users_role_idx_role_id ON users_role (role_id);
CREATE INDEX users_role_idx_users_id ON users_role (users_id);
COMMIT;
