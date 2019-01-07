-- Convert schema '/opt/local/fb11/OpusVL-FB11/lib/auto/OpusVL/FB11/Schema/FB11AuthDB/sql/_source/deploy/1/001-auto.yml' to '/opt/local/fb11/OpusVL-FB11/lib/auto/OpusVL/FB11/Schema/FB11AuthDB/sql/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE user_avatar DROP CONSTRAINT user_avatar_fk_user_id;

;
ALTER TABLE user_avatar ADD CONSTRAINT user_avatar_fk_user_id FOREIGN KEY (user_id)
  REFERENCES users (id) ON DELETE CASCADE DEFERRABLE;

;
ALTER TABLE users ALTER COLUMN status SET DEFAULT 'enabled';

;

COMMIT;

