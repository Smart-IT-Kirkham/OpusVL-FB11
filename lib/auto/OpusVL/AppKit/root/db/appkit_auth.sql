
-- This is some example SQL, that currently builds a basic structure for users and Auth.

PRAGMA foreign_keys = ON;
CREATE TABLE users
(
        id                  INTEGER             NOT NULL,
        username            TEXT UNIQUE         NOT NULL,
        password            TEXT                NOT NULL,
        email               TEXT                NOT NULL,
        name                TEXT                NOT NULL,
        tel                 TEXT                NOT NULL,
        status              TEXT                NOT NULL DEFAULT ('active'),
    PRIMARY KEY (id)
);

CREATE TABLE aclrule (
        id                  INTEGER     NULL,
        actionpath          TEXT        NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE role (
        id                  INTEGER     NULL,
        role                TEXT        NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE parameter (
        id                  INTEGER     NULL,
        data_type           TEXT        NOT NULL,
        parameter           TEXT        NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE parameter_defaults (
        id                  INTEGER     NULL,
        parameter_id        INTEGER     REFERENCES parameter(id) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
        data                TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE users_data (
        id                  INTEGER     NULL,
        users_id            INTEGER     NOT NULL REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
        key                 TEXT        NOT NULL,
        value               TEXT        NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE users_role (
        users_id            INTEGER     NOT NULL REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
        role_id             INTEGER     NOT NULL REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (users_id, role_id)
);
CREATE TABLE users_parameter (
        users_id            INTEGER     NOT NULL REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
        parameter_id        INTEGER     NOT NULL REFERENCES parameter(id) ON DELETE CASCADE ON UPDATE CASCADE,
        value               TEXT        NOT NULL,
    PRIMARY KEY (users_id, parameter_id)
);
CREATE TABLE aclrule_role (
        aclrule_id          INTEGER     NOT NULL REFERENCES aclrule(id) ON DELETE CASCADE ON UPDATE CASCADE,
        role_id             INTEGER     NOT NULL REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (aclrule_id, role_id)
);
