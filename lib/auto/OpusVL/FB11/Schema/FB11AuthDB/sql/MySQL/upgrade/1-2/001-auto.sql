-- Convert schema '/opt/local/fb11/OpusVL-FB11/lib/auto/OpusVL/FB11/Schema/FB11AuthDB/sql/_source/deploy/1/001-auto.yml' to '/opt/local/fb11/OpusVL-FB11/lib/auto/OpusVL/FB11/Schema/FB11AuthDB/sql/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE user_avatar DROP FOREIGN KEY user_avatar_fk_user_id;

;
ALTER TABLE user_avatar ADD CONSTRAINT user_avatar_fk_user_id FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE;

;
ALTER TABLE users CHANGE COLUMN status status text NOT NULL DEFAULT 'enabled';

;

COMMIT;

