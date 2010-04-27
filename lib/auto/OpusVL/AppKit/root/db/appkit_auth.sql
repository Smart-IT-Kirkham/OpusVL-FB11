
-- This is some example SQL, that currently builds a basic structure for user and Auth.

PRAGMA foreign_keys = ON;
CREATE TABLE user (
        id                  INTEGER PRIMARY KEY,
        username            TEXT,
        password            TEXT,
        email               TEXT,
        name                TEXT,
        tel                 TEXT,
        status              INTEGER
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
        data_type           TEXT,
        parameter           TEXT
);
CREATE TABLE user_data (
        id                  INTEGER PRIMARY KEY,
        user_id             INTEGER REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
        key                 TEXT,
        value               TEXT
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

INSERT INTO user VALUES (1, 'appkitadmin',  '$2$08$pJiwUlPDkRd9Pg3OLT2h2O5EbboOKtKi9r/Yu94Tw4ocP4py8RWh.', 'appkit@opusvl.com',    'Applications', '07720061678',  'enabled');
INSERT INTO user VALUES (2, 'william',      '$2$08$pJiwUlPDkRd9Pg3OLT2h2O5EbboOKtKi9r/Yu94Tw4ocP4py8RWh.', 'will@opusvl.com',      'William',      '07720061678',  'enabled');
INSERT INTO user VALUES (3, 'paterick',     '$2$08$pJiwUlPDkRd9Pg3OLT2h2O5EbboOKtKi9r/Yu94Tw4ocP4py8RWh.', 'pat@opusvl.com',       'Paterick',     '07720061678',  'enabled');

INSERT INTO aclrule VALUES (1, 'index');
INSERT INTO aclrule VALUES (3, 'appkit/admin');
INSERT INTO aclrule VALUES (4, 'appkit/admin/access');
INSERT INTO aclrule VALUES (5, 'appkit/admin/access/addrole');
INSERT INTO aclrule VALUES (6, 'appkit/admin/access/role_specific');
INSERT INTO aclrule VALUES (7, 'appkit/admin/access/delete_role');
INSERT INTO aclrule VALUES (8, 'appkit/admin/access/show_role');
INSERT INTO aclrule VALUES (9, 'appkit/admin/access/user_add_to_role');
INSERT INTO aclrule VALUES (10, 'appkit/admin/access/user_for_role');
INSERT INTO aclrule VALUES (11, 'appkit/admin/access/user_delete_from_role');


INSERT INTO aclrule VALUES (12, 'test/access_admin');
INSERT INTO aclrule VALUES (13, 'test/access_user_or_admin');
INSERT INTO aclrule VALUES (14, 'test/access_user');

INSERT INTO aclrule VALUES (15, 'extensiona/expansionaa/startchain');
INSERT INTO aclrule VALUES (16, 'extensiona/expansionaa/midchain');
INSERT INTO aclrule VALUES (17, 'extensiona/expansionaa/endchain');

INSERT INTO aclrule VALUES (18, 'extensionb/formpage');

INSERT INTO aclrule VALUES (19, 'test/portlet_test');
INSERT INTO aclrule VALUES (20, 'appkit/change_password');

INSERT INTO role VALUES (1, 'administrator');
INSERT INTO role VALUES (2, 'normal user');

INSERT INTO parameter VALUES (1,'integer','client_id' );
INSERT INTO parameter VALUES (2,'boolean','Login Validation via SMS' );

INSERT INTO user_role VALUES (1, 1);
INSERT INTO user_role VALUES (1, 2);
INSERT INTO user_role VALUES (2, 2);
INSERT INTO user_role VALUES (3, 2);

INSERT INTO user_parameter VALUES (1, 1, '%');
INSERT INTO user_parameter VALUES (2, 1, '1');
INSERT INTO user_parameter VALUES (2, 2, '1');
INSERT INTO user_parameter VALUES (3, 3, '1');

-- ..apply the rules to the 'administrator' role...
INSERT INTO aclrule_role VALUES (1, 1);
INSERT INTO aclrule_role VALUES (2, 1);
INSERT INTO aclrule_role VALUES (3, 1);
INSERT INTO aclrule_role VALUES (4, 1);
INSERT INTO aclrule_role VALUES (5, 1);
INSERT INTO aclrule_role VALUES (6, 1);
INSERT INTO aclrule_role VALUES (7, 1);
INSERT INTO aclrule_role VALUES (8, 1);
INSERT INTO aclrule_role VALUES (9, 1);
INSERT INTO aclrule_role VALUES (10, 1);
INSERT INTO aclrule_role VALUES (11, 1);

INSERT INTO aclrule_role VALUES (12, 1);
INSERT INTO aclrule_role VALUES (13, 1);

INSERT INTO aclrule_role VALUES (15, 1);
INSERT INTO aclrule_role VALUES (16, 1);
INSERT INTO aclrule_role VALUES (17, 1);
INSERT INTO aclrule_role VALUES (18, 1);

INSERT INTO aclrule_role VALUES (19, 1);
INSERT INTO aclrule_role VALUES (20, 1);

-- ..apply the rules to the 'user' role...
INSERT INTO aclrule_role VALUES (1, 2);
INSERT INTO aclrule_role VALUES (2, 2);
INSERT INTO aclrule_role VALUES (13, 2);
INSERT INTO aclrule_role VALUES (14, 2);
INSERT INTO aclrule_role VALUES (20, 2);

