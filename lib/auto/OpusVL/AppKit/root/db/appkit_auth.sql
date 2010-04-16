
-- This is some example SQL, that currently builds a basic structure for user and Auth.

PRAGMA foreign_keys = ON;
CREATE TABLE user (
        id                  INTEGER PRIMARY KEY,
        username            TEXT,
        password            TEXT,
        email               TEXT,
        name                TEXT,
        tel                 TEXT,
        active              INTEGER
);
CREATE TABLE aclrule (
        id                  INTEGER PRIMARY KEY,
        actionpath          TEXT
);
CREATE TABLE role (
        id   INTEGER PRIMARY KEY,
        role TEXT
);
CREATE TABLE parameter (
        id                  INTEGER PRIMARY KEY,
        parameter           TEXT
);

CREATE TABLE user_role (
        user_id             INTEGER REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
        role_id             INTEGER REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
        PRIMARY KEY (user_id, role_id)
);
CREATE TABLE user_parameter (
        user_id             INTEGER REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
        parameter_id        INTEGER REFERENCES parameter(id) ON DELETE CASCADE ON UPDATE CASCADE,
        value               TEXT,
        PRIMARY KEY (user_id, parameter_id)
);
CREATE TABLE aclrule_role (
        aclrule_id          INTEGER REFERENCES aclrule(id) ON DELETE CASCADE ON UPDATE CASCADE,
        role_id             INTEGER REFERENCES role(id) ON DELETE CASCADE ON UPDATE CASCADE,
        PRIMARY KEY (aclrule_id, role_id)
);

-------------------------------------
-- Load up some initial test data  --
-------------------------------------

INSERT INTO user VALUES (1, 'appkitadmin',  '$2a$05$abcdefghijklmnopqrstuuVXLGLH0YYn303cB/t9gc8ACq9MtEwAm', 'appkit@opusvl.com',    'Applications', '07720061678',  1);
INSERT INTO user VALUES (2, 'william',      '$2a$05$abcdefghijklmnopqrstuuVXLGLH0YYn303cB/t9gc8ACq9MtEwAm', 'will@opusvl.com',      'William',      '07720061678',  1);
INSERT INTO user VALUES (3, 'paterick',     '$2a$05$abcdefghijklmnopqrstuuVXLGLH0YYn303cB/t9gc8ACq9MtEwAm', 'pat@opusvl.com',       'Paterick',     '07720061678',  0);

INSERT INTO aclrule VALUES (1, 'appkitadmin');
INSERT INTO aclrule VALUES (2, 'test/access_admin');
INSERT INTO aclrule VALUES (3, 'test/access_user');
INSERT INTO aclrule VALUES (4, 'test/access_user_or_admin');

INSERT INTO role VALUES (1, 'administrator');
INSERT INTO role VALUES (2, 'normal user');

INSERT INTO parameter VALUES (1,'client_id' );
INSERT INTO parameter VALUES (2,'Attribute 2' );

INSERT INTO user_role VALUES (1, 1);
INSERT INTO user_role VALUES (1, 2);
INSERT INTO user_role VALUES (2, 2);
INSERT INTO user_role VALUES (3, 2);

INSERT INTO user_parameter VALUES (1, 1, '%');
INSERT INTO user_parameter VALUES (1, 2, 'Admin Value 2');
INSERT INTO user_parameter VALUES (2, 1, '1');
INSERT INTO user_parameter VALUES (2, 2, 'User Value 2');

INSERT INTO aclrule_role VALUES (1, 1);
INSERT INTO aclrule_role VALUES (2, 1);
INSERT INTO aclrule_role VALUES (3, 2);
INSERT INTO aclrule_role VALUES (4, 1);
INSERT INTO aclrule_role VALUES (4, 2);

