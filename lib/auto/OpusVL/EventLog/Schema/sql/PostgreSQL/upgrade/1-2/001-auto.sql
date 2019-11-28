-- Convert schema '/opt/local/fb11/fb11/lib/auto/OpusVL/EventLog/Schema/sql/_source/deploy/1/001-auto.yml' to '/opt/local/fb11/fb11/lib/auto/OpusVL/EventLog/Schema/sql/_source/deploy/2/001-auto.yml':;

;
BEGIN;

;
ALTER TABLE event_log ADD COLUMN message text NOT NULL;

;

COMMIT;

