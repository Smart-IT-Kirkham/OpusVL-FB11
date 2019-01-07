BEGIN;

UPDATE users SET status = 'enabled' WHERE status = 'active';

COMMIT;
