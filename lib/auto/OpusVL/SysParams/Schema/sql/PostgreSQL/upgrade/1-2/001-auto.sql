-- Convert schema '/opt/local/fb11/OpusVL-FB11/lib/auto/OpusVL/SysParams/Schema/sql/_source/deploy/1/001-auto.yml' to '/opt/local/fb11/OpusVL-FB11/lib/auto/OpusVL/SysParams/Schema/sql/_source/deploy/2/001-auto.yml':;

-- We don't delete the old sys_info table here, but we have removed the creation
-- of it from the previous migration.

-- The goal of this is that if you deploy a sysparams you only get the sysparams
-- table, but if you upgrade from the old version you don't lose the old table.

-- To support the old table you will need to include
-- OpusVL::FB11X::SysParams::Legacy in your application, which provides the
-- original schema, result class, and Catalyst model.
;
BEGIN;

;
CREATE TABLE "sysparams" (
  "name" text NOT NULL,
  "label" text NOT NULL,
  "value" text NOT NULL,
  "comment" text,
  "data_type" character varying DEFAULT '{"value":"text"}' NOT NULL,
  PRIMARY KEY ("name")
);

;

COMMIT;

