
-- This is some example SQL, that currently builds a basic structure for users and Auth.

PRAGMA foreign_keys = ON;
CREATE TABLE users
(
        id                  SERIAL              ,
        username            TEXT UNIQUE         NOT NULL,
        password            TEXT                NOT NULL,
        email               TEXT                NOT NULL,
        name                TEXT                NOT NULL,
        tel                 TEXT                NOT NULL,
        status              TEXT                NOT NULL,
    PRIMARY KEY (id)
);


CREATE TABLE aclrule (
        id                  SERIAL              ,
        actionpath          TEXT        NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE role (
        id                  SERIAL              ,
        role                TEXT        NOT NULL,
    PRIMARY KEY (id)
);
CREATE TABLE parameter (
        id                  SERIAL              ,
        data_type           TEXT        NOT NULL,
        parameter           TEXT        NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE parameter_defaults (
        id                  SERIAL              ,
        parameter_id        INTEGER REFERENCES parameter(id) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
        data                TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE users_data (
        id                  SERIAL              ,
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

---------------------------------------
---- Add some initial test data  --
---------------------------------------
--
--INSERT INTO users VALUES (1, 'appkitadmin',  '$2$08$pJiwUlPDkRd9Pg3OLT2h2O5EbboOKtKi9r/Yu94Tw4ocP4py8RWh.', 'appkit@opusvl.com',    'Applications', '07720061678',  'enabled');
--INSERT INTO users VALUES (2, 'william',      '$2$08$pJiwUlPDkRd9Pg3OLT2h2O5EbboOKtKi9r/Yu94Tw4ocP4py8RWh.', 'will@opusvl.com',      'William',      '07720061678',  'enabled');
--
--INSERT INTO aclrule VALUES (1, 'index');
--INSERT INTO aclrule VALUES (3, 'appkit/admin');
--INSERT INTO aclrule VALUES (4, 'appkit/admin/access');
--INSERT INTO aclrule VALUES (5, 'appkit/admin/access/addrole');
--INSERT INTO aclrule VALUES (6, 'appkit/admin/access/role_specific');
--INSERT INTO aclrule VALUES (7, 'appkit/admin/access/delete_role');
--INSERT INTO aclrule VALUES (8, 'appkit/admin/access/show_role');
--INSERT INTO aclrule VALUES (9, 'appkit/admin/access/users_add_to_role');
--INSERT INTO aclrule VALUES (10, 'appkit/admin/access/users_for_role');
--INSERT INTO aclrule VALUES (11, 'appkit/admin/access/users_delete_from_role');
--
--
--INSERT INTO aclrule VALUES (12, 'test/access_admin');
--INSERT INTO aclrule VALUES (13, 'test/access_users_or_admin');
--INSERT INTO aclrule VALUES (14, 'test/access_users');
--
--INSERT INTO aclrule VALUES (15, 'extensiona/expansionaa/startchain');
--INSERT INTO aclrule VALUES (16, 'extensiona/expansionaa/midchain');
--INSERT INTO aclrule VALUES (17, 'extensiona/expansionaa/endchain');
--
--INSERT INTO aclrule VALUES (18, 'extensionb/formpage');
--
--INSERT INTO aclrule VALUES (19, 'test/portlet_test');
--INSERT INTO aclrule VALUES (20, 'appkit/change_password');
--
--INSERT INTO role VALUES (1, 'administrator');
--INSERT INTO role VALUES (2, 'normal users');
--
--INSERT INTO parameter VALUES (1,'integer','client_id' );
--INSERT INTO parameter VALUES (2,'boolean','Login Validation via SMS' );
--INSERT INTO parameter VALUES (3,'select','Location' );
--
--INSERT INTO parameter_defaults VALUES (1,3, 'Cardiff' );
--INSERT INTO parameter_defaults VALUES (2,3, 'Blackpool' );
--INSERT INTO parameter_defaults VALUES (3,3, 'Brighton' );
--INSERT INTO parameter_defaults VALUES (4,3, 'Northampton' );
--
--INSERT INTO users_role VALUES (1, 1);
--INSERT INTO users_role VALUES (1, 2);
--INSERT INTO users_role VALUES (2, 2);
--
--INSERT INTO users_parameter VALUES (1, 1, '%');
--INSERT INTO users_parameter VALUES (2, 1, '1');
--INSERT INTO users_parameter VALUES (2, 2, '1');
--
---- ..apply the rules to the 'administrator' role...
--INSERT INTO aclrule_role VALUES (1, 1);
--INSERT INTO aclrule_role VALUES (2, 1);
--INSERT INTO aclrule_role VALUES (3, 1);
--INSERT INTO aclrule_role VALUES (4, 1);
--INSERT INTO aclrule_role VALUES (5, 1);
--INSERT INTO aclrule_role VALUES (6, 1);
--INSERT INTO aclrule_role VALUES (7, 1);
--INSERT INTO aclrule_role VALUES (8, 1);
--INSERT INTO aclrule_role VALUES (9, 1);
--INSERT INTO aclrule_role VALUES (10, 1);
--INSERT INTO aclrule_role VALUES (11, 1);
--
--INSERT INTO aclrule_role VALUES (12, 1);
--INSERT INTO aclrule_role VALUES (13, 1);
--
--INSERT INTO aclrule_role VALUES (15, 1);
--INSERT INTO aclrule_role VALUES (16, 1);
--INSERT INTO aclrule_role VALUES (17, 1);
--INSERT INTO aclrule_role VALUES (18, 1);
--
--INSERT INTO aclrule_role VALUES (19, 1);
--INSERT INTO aclrule_role VALUES (20, 1);
--
---- ..apply the rules to the 'users' role...
--INSERT INTO aclrule_role VALUES (1, 2);
--INSERT INTO aclrule_role VALUES (2, 2);
--INSERT INTO aclrule_role VALUES (13, 2);
--INSERT INTO aclrule_role VALUES (14, 2);
--INSERT INTO aclrule_role VALUES (20, 2);
--
