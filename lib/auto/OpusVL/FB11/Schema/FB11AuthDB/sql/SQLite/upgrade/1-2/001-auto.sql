-- Convert schema '/opt/local/fb11/OpusVL-FB11/lib/auto/OpusVL/FB11/Schema/FB11AuthDB/sql/_source/deploy/1/001-auto.yml' to '/opt/local/fb11/OpusVL-FB11/lib/auto/OpusVL/FB11/Schema/FB11AuthDB/sql/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
DROP INDEX user_avatar_fk_user_id;

;

;
CREATE TEMPORARY TABLE users_temp_alter (
  id INTEGER PRIMARY KEY NOT NULL,
  username text NOT NULL,
  password text NOT NULL,
  email text NOT NULL,
  name text NOT NULL,
  tel text,
  status text NOT NULL DEFAULT 'enabled',
  last_login timestamp,
  last_failed_login timestamp
);

;
INSERT INTO users_temp_alter( id, username, password, email, name, tel, status, last_login, last_failed_login) SELECT id, username, password, email, name, tel, status, last_login, last_failed_login FROM users;

;
DROP TABLE users;

;
CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  username text NOT NULL,
  password text NOT NULL,
  email text NOT NULL,
  name text NOT NULL,
  tel text,
  status text NOT NULL DEFAULT 'enabled',
  last_login timestamp,
  last_failed_login timestamp
);

;
CREATE UNIQUE INDEX users_username03 ON users (username);

;
INSERT INTO users SELECT id, username, password, email, name, tel, status, last_login, last_failed_login FROM users_temp_alter;

;
DROP TABLE users_temp_alter;

;

COMMIT;

