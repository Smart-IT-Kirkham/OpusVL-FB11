-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Wed Jun 13 12:56:09 2018
-- 
;
--
-- Table: evt_creator_types
--
CREATE TABLE "evt_creator_types" (
  "id" serial NOT NULL,
  "creator_type" text NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "evt_creator_types_creator_type_key" UNIQUE ("creator_type")
);

;
--
-- Table: evt_creators
--
CREATE TABLE "evt_creators" (
  "id" integer NOT NULL,
  "creator_type_id" integer NOT NULL,
  PRIMARY KEY ("id", "creator_type_id")
);
CREATE INDEX "evt_creators_idx_creator_type_id" on "evt_creators" ("creator_type_id");

;
--
-- Table: evt_events
--
CREATE TABLE "evt_events" (
  "id" serial NOT NULL,
  "type_id" integer NOT NULL,
  "creator_id" integer NOT NULL,
  "creator_type_id" integer NOT NULL,
  "event_date" timestamp DEFAULT current_timestamp NOT NULL,
  "details" text NOT NULL,
  "source" text NOT NULL,
  "event" text NOT NULL,
  "data" text,
  "username" text,
  "ip_addr" text,
  PRIMARY KEY ("id")
);
CREATE INDEX "evt_events_idx_creator_id_creator_type_id" on "evt_events" ("creator_id", "creator_type_id");
CREATE INDEX "evt_events_idx_type_id" on "evt_events" ("type_id");

;
--
-- Table: evt_types
--
CREATE TABLE "evt_types" (
  "id" serial NOT NULL,
  "event_type" text NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "evt_types_event_type_key" UNIQUE ("event_type")
);

;
--
-- Table: system_events
--
CREATE TABLE "system_events" (
  "id" serial NOT NULL,
  "evt_creator_type_id" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "system_events_idx_id_evt_creator_type_id" on "system_events" ("id", "evt_creator_type_id");

;
--
-- Foreign Key Definitions
--

;
ALTER TABLE "evt_creators" ADD CONSTRAINT "evt_creators_fk_creator_type_id" FOREIGN KEY ("creator_type_id")
  REFERENCES "evt_creator_types" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "evt_events" ADD CONSTRAINT "evt_events_fk_creator_id_creator_type_id" FOREIGN KEY ("creator_id", "creator_type_id")
  REFERENCES "evt_creators" ("id", "creator_type_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "evt_events" ADD CONSTRAINT "evt_events_fk_type_id" FOREIGN KEY ("type_id")
  REFERENCES "evt_types" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
ALTER TABLE "system_events" ADD CONSTRAINT "system_events_fk_id_evt_creator_type_id" FOREIGN KEY ("id", "evt_creator_type_id")
  REFERENCES "evt_creators" ("id", "creator_type_id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

;
