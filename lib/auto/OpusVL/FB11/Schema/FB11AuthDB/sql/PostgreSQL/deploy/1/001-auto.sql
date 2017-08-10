-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Thu Aug 10 11:15:23 2017
-- 
;
--
-- Table: aclfeature
--
CREATE TABLE "aclfeature" (
  "id" serial NOT NULL,
  "feature" text NOT NULL,
  "feature_description" text,
  PRIMARY KEY ("id")
);

;
--
-- Table: aclfeature_role
--
CREATE TABLE "aclfeature_role" (
  "aclfeature_id" integer NOT NULL,
  "role_id" integer NOT NULL,
  PRIMARY KEY ("aclfeature_id", "role_id")
);
CREATE INDEX "aclfeature_role_idx_aclfeature_id" on "aclfeature_role" ("aclfeature_id");
CREATE INDEX "aclfeature_role_idx_role_id" on "aclfeature_role" ("role_id");

;
--
-- Table: aclrule
--
CREATE TABLE "aclrule" (
  "id" serial NOT NULL,
  "actionpath" text NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: parameter
--
CREATE TABLE "parameter" (
  "id" serial NOT NULL,
  "data_type" text NOT NULL,
  "parameter" text NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: role
--
CREATE TABLE "role" (
  "id" serial NOT NULL,
  "role" text NOT NULL,
  PRIMARY KEY ("id")
);

;
--
-- Table: role_admin
--
CREATE TABLE "role_admin" (
  "role_id" serial NOT NULL,
  PRIMARY KEY ("role_id")
);

;
--
-- Table: roles_allowed
--
CREATE TABLE "roles_allowed" (
  "role" integer NOT NULL,
  "role_allowed" integer NOT NULL,
  PRIMARY KEY ("role", "role_allowed")
);
CREATE INDEX "roles_allowed_idx_role" on "roles_allowed" ("role");
CREATE INDEX "roles_allowed_idx_role_allowed" on "roles_allowed" ("role_allowed");

;
--
-- Table: users
--
CREATE TABLE "users" (
  "id" serial NOT NULL,
  "username" text NOT NULL,
  "password" text NOT NULL,
  "email" text NOT NULL,
  "name" text NOT NULL,
  "tel" text,
  "status" text DEFAULT 'active' NOT NULL,
  "last_login" timestamp,
  "last_failed_login" timestamp,
  PRIMARY KEY ("id"),
  CONSTRAINT "users_username" UNIQUE ("username")
);

;
--
-- Table: parameter_defaults
--
CREATE TABLE "parameter_defaults" (
  "id" serial NOT NULL,
  "parameter_id" integer NOT NULL,
  "data" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "parameter_defaults_idx_parameter_id" on "parameter_defaults" ("parameter_id");

;
--
-- Table: user_avatar
--
CREATE TABLE "user_avatar" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "mime_type" text NOT NULL,
  "data" bytea NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "user_avatar_idx_user_id" on "user_avatar" ("user_id");

;
--
-- Table: users_data
--
CREATE TABLE "users_data" (
  "id" serial NOT NULL,
  "users_id" integer NOT NULL,
  "key" text NOT NULL,
  "value" text NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "users_data_idx_users_id" on "users_data" ("users_id");

;
--
-- Table: users_favourites
--
CREATE TABLE "users_favourites" (
  "id" serial NOT NULL,
  "user_id" integer NOT NULL,
  "page" character varying NOT NULL,
  "name" character varying,
  PRIMARY KEY ("id")
);
CREATE INDEX "users_favourites_idx_user_id" on "users_favourites" ("user_id");

;
--
-- Table: aclrule_role
--
CREATE TABLE "aclrule_role" (
  "aclrule_id" serial NOT NULL,
  "role_id" serial NOT NULL,
  PRIMARY KEY ("aclrule_id", "role_id")
);
CREATE INDEX "aclrule_role_idx_aclrule_id" on "aclrule_role" ("aclrule_id");
CREATE INDEX "aclrule_role_idx_role_id" on "aclrule_role" ("role_id");

;
--
-- Table: users_parameter
--
CREATE TABLE "users_parameter" (
  "users_id" serial NOT NULL,
  "parameter_id" serial NOT NULL,
  "value" text NOT NULL,
  PRIMARY KEY ("users_id", "parameter_id")
);
CREATE INDEX "users_parameter_idx_parameter_id" on "users_parameter" ("parameter_id");
CREATE INDEX "users_parameter_idx_users_id" on "users_parameter" ("users_id");

;
--
-- Table: users_role
--
CREATE TABLE "users_role" (
  "users_id" serial NOT NULL,
  "role_id" serial NOT NULL,
  PRIMARY KEY ("users_id", "role_id")
);
CREATE INDEX "users_role_idx_role_id" on "users_role" ("role_id");
CREATE INDEX "users_role_idx_users_id" on "users_role" ("users_id");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "aclfeature_role" ADD CONSTRAINT "aclfeature_role_fk_aclfeature_id" FOREIGN KEY ("aclfeature_id")
  REFERENCES "aclfeature" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "aclfeature_role" ADD CONSTRAINT "aclfeature_role_fk_role_id" FOREIGN KEY ("role_id")
  REFERENCES "role" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "role_admin" ADD CONSTRAINT "role_admin_fk_role_id" FOREIGN KEY ("role_id")
  REFERENCES "role" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "roles_allowed" ADD CONSTRAINT "roles_allowed_fk_role" FOREIGN KEY ("role")
  REFERENCES "role" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "roles_allowed" ADD CONSTRAINT "roles_allowed_fk_role_allowed" FOREIGN KEY ("role_allowed")
  REFERENCES "role" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "parameter_defaults" ADD CONSTRAINT "parameter_defaults_fk_parameter_id" FOREIGN KEY ("parameter_id")
  REFERENCES "parameter" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "user_avatar" ADD CONSTRAINT "user_avatar_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") DEFERRABLE;

;
ALTER TABLE "users_data" ADD CONSTRAINT "users_data_fk_users_id" FOREIGN KEY ("users_id")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "users_favourites" ADD CONSTRAINT "users_favourites_fk_user_id" FOREIGN KEY ("user_id")
  REFERENCES "users" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION;

;
ALTER TABLE "aclrule_role" ADD CONSTRAINT "aclrule_role_fk_aclrule_id" FOREIGN KEY ("aclrule_id")
  REFERENCES "aclrule" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "aclrule_role" ADD CONSTRAINT "aclrule_role_fk_role_id" FOREIGN KEY ("role_id")
  REFERENCES "role" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "users_parameter" ADD CONSTRAINT "users_parameter_fk_parameter_id" FOREIGN KEY ("parameter_id")
  REFERENCES "parameter" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "users_parameter" ADD CONSTRAINT "users_parameter_fk_users_id" FOREIGN KEY ("users_id")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "users_role" ADD CONSTRAINT "users_role_fk_role_id" FOREIGN KEY ("role_id")
  REFERENCES "role" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "users_role" ADD CONSTRAINT "users_role_fk_users_id" FOREIGN KEY ("users_id")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
