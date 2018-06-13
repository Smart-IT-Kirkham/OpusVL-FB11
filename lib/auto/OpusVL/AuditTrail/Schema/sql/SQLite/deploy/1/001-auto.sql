-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Wed Jun 13 12:56:09 2018
-- 

;
BEGIN TRANSACTION;
--
-- Table: evt_creator_types
--
CREATE TABLE evt_creator_types (
  id INTEGER PRIMARY KEY NOT NULL,
  creator_type text NOT NULL
);
CREATE UNIQUE INDEX evt_creator_types_creator_type_key ON evt_creator_types (creator_type);
--
-- Table: evt_creators
--
CREATE TABLE evt_creators (
  id integer NOT NULL,
  creator_type_id integer NOT NULL,
  PRIMARY KEY (id, creator_type_id),
  FOREIGN KEY (creator_type_id) REFERENCES evt_creator_types(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX evt_creators_idx_creator_type_id ON evt_creators (creator_type_id);
--
-- Table: evt_events
--
CREATE TABLE evt_events (
  id INTEGER PRIMARY KEY NOT NULL,
  type_id integer NOT NULL,
  creator_id integer NOT NULL,
  creator_type_id integer NOT NULL,
  event_date timestamp NOT NULL DEFAULT current_timestamp,
  details text NOT NULL,
  source text NOT NULL,
  event text NOT NULL,
  data text,
  username text,
  ip_addr text,
  FOREIGN KEY (creator_id, creator_type_id) REFERENCES evt_creators(id, creator_type_id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (type_id) REFERENCES evt_types(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX evt_events_idx_creator_id_creator_type_id ON evt_events (creator_id, creator_type_id);
CREATE INDEX evt_events_idx_type_id ON evt_events (type_id);
--
-- Table: evt_types
--
CREATE TABLE evt_types (
  id INTEGER PRIMARY KEY NOT NULL,
  event_type text NOT NULL
);
CREATE UNIQUE INDEX evt_types_event_type_key ON evt_types (event_type);
--
-- Table: system_events
--
CREATE TABLE system_events (
  id INTEGER PRIMARY KEY NOT NULL,
  evt_creator_type_id integer,
  FOREIGN KEY (id, evt_creator_type_id) REFERENCES evt_creators(id, creator_type_id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE INDEX system_events_idx_id_evt_creator_type_id ON system_events (id, evt_creator_type_id);
COMMIT;
