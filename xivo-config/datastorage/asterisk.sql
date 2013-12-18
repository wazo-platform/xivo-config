/*
 * XiVO Base-Config
 * Copyright (C) 2006-2012  Avencall
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

DO
$body$
BEGIN
   IF NOT EXISTS (
      SELECT *
      FROM   pg_catalog.pg_user
      WHERE  usename = 'asterisk') THEN

        CREATE ROLE asterisk WITH LOGIN PASSWORD 'proformatique';
   END IF;
END
$body$
;

CREATE DATABASE asterisk WITH OWNER asterisk ENCODING 'UTF8';

\connect asterisk;

BEGIN;

-- GENERIC ENUM TYPES
DROP TYPE  IF EXISTS "generic_bsfilter" CASCADE;
CREATE TYPE "generic_bsfilter" AS ENUM ('no', 'boss', 'secretary');

DROP TYPE IF EXISTS "trunk_protocol" CASCADE;
CREATE TYPE "trunk_protocol" AS ENUM ('sip', 'iax', 'sccp', 'custom');


DROP TABLE IF EXISTS "accessfeatures" CASCADE;
DROP TYPE  IF EXISTS "accessfeatures_feature";

CREATE TYPE "accessfeatures_feature" AS ENUM ('phonebook');

CREATE TABLE "accessfeatures" (
 "id" SERIAL,
 "host" VARCHAR(255) NOT NULL DEFAULT '',
 "feature" accessfeatures_feature NOT NULL,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "accessfeatures__uidx__host_feature" ON "accessfeatures"("host","feature");


DROP TABLE IF EXISTS "agentfeatures" CASCADE;

CREATE TABLE "agentfeatures" (
 "id" SERIAL,
 "numgroup" INTEGER NOT NULL,
 "firstname" VARCHAR(128) NOT NULL DEFAULT '',
 "lastname" VARCHAR(128) NOT NULL DEFAULT '',
 "number" VARCHAR(40) NOT NULL,
 "passwd" VARCHAR(128) NOT NULL,
 "context" VARCHAR(39) NOT NULL,
 "language" VARCHAR(20) NOT NULL,
 -- features
 "autologoff" INTEGER,
 "group" VARCHAR(255) DEFAULT NULL::character varying,
 "description" text NOT NULL,
 "preprocess_subroutine" VARCHAR(40),
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "agentfeatures__uidx__number" ON "agentfeatures"("number");


DROP TABLE IF EXISTS "agentgroup" CASCADE;
CREATE TABLE "agentgroup" (
 "id" SERIAL,
 "groupid" INTEGER NOT NULL,
 "name" VARCHAR(128) NOT NULL DEFAULT '',
 "groups" VARCHAR(255) NOT NULL DEFAULT '',
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "deleted" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

INSERT INTO "agentgroup" VALUES (DEFAULT,1,'default','',0,0,'');


DROP TABLE IF EXISTS "agentqueueskill" CASCADE;
CREATE TABLE "agentqueueskill" (
 "agentid" INTEGER,
 "skillid" INTEGER,
 "weight" INTEGER NOT NULL DEFAULT 0,
 PRIMARY KEY("agentid", "skillid")
);


DROP TABLE IF EXISTS "attachment" CASCADE;
CREATE TABLE "attachment" (
 "id" SERIAL,
 "name" VARCHAR(64) NOT NULL,
 "object_type" VARCHAR(16) NOT NULL,
 "object_id" INTEGER NOT NULL,
 "file" bytea,
 "size" INTEGER NOT NULL,
 "mime" VARCHAR(64) NOT NULL
);

CREATE UNIQUE INDEX "attachment__uidx__object_type__object_id" ON "attachment"("object_type","object_id");


DROP TABLE IF EXISTS "callerid" CASCADE;
DROP TYPE  IF EXISTS "callerid_mode";
DROP TYPE  IF EXISTS "callerid_type";

CREATE TYPE callerid_mode AS ENUM ('prepend', 'overwrite', 'append');
CREATE TYPE callerid_type AS ENUM ('callfilter','incall','group','queue');
CREATE TABLE "callerid" (
 "mode" callerid_mode,
 "callerdisplay" VARCHAR(80) NOT NULL DEFAULT '',
 "type" callerid_type NOT NULL,
 "typeval" INTEGER NOT NULL,
 PRIMARY KEY("type","typeval")
);


DROP TABLE IF EXISTS "callfilter" CASCADE;
DROP TYPE  IF EXISTS "callfilter_type";
DROP TYPE  IF EXISTS "callfilter_bosssecretary";
DROP TYPE  IF EXISTS "callfilter_callfrom";

CREATE TYPE "callfilter_type" AS ENUM ('bosssecretary');
CREATE TYPE "callfilter_bosssecretary" AS ENUM ('bossfirst-serial', 'bossfirst-simult', 'secretary-serial', 'secretary-simult', 'all');
CREATE TYPE "callfilter_callfrom" AS ENUM ('internal', 'external', 'all');

CREATE TABLE "callfilter" (
 "id" SERIAL,
 "name" VARCHAR(128) NOT NULL DEFAULT '',
 "type" callfilter_type NOT NULL,
 "bosssecretary" callfilter_bosssecretary,
 "callfrom" callfilter_callfrom,
 "ringseconds" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "callfilter__uidx__name" ON "callfilter"("name");


DROP TABLE IF EXISTS "callfiltermember" CASCADE;
DROP TYPE IF EXISTS "callfiltermember_type" CASCADE;
--DROP TYPE IF EXISTS "callfiltermember_bstype" CASCADE;

CREATE TYPE "callfiltermember_type" AS ENUM ('user');
--CREATE TYPE "callfiltermember_bstype" AS ENUM ('boss', 'secretary');

CREATE TABLE "callfiltermember" (
 "id" SERIAL,
 "callfilterid" INTEGER NOT NULL DEFAULT 0,
 "type" callfiltermember_type NOT NULL,
 "typeval" VARCHAR(128) NOT NULL DEFAULT 0,
 "ringseconds" INTEGER NOT NULL DEFAULT 0,
 "priority" INTEGER NOT NULL DEFAULT 0,
 "bstype" generic_bsfilter CHECK (bstype in ('boss', 'secretary')),
 "active" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "callfiltermember__uidx__callfilterid_type_typeval" ON "callfiltermember"("callfilterid","type","typeval");


DROP TABLE IF EXISTS "call_log" CASCADE;
CREATE TABLE "call_log" (
 "id" SERIAL PRIMARY KEY,
 "date" TIMESTAMP NOT NULL,
 "source_name" VARCHAR(255),
 "source_exten" VARCHAR(255),
 "source_line_identity" VARCHAR(255),
 "destination_name" VARCHAR(255),
 "destination_exten" VARCHAR(255),
 "destination_line_identity" VARCHAR(255),
 "duration" INTERVAL NOT NULL,
 "user_field" VARCHAR(255),
 "answered" BOOLEAN
);


DROP TABLE IF EXISTS "cel" CASCADE;
CREATE TABLE "cel" (
 "id" serial , 
 "eventtype" VARCHAR (30) NOT NULL ,
 "eventtime" timestamp NOT NULL ,
 "userdeftype" VARCHAR(255) NOT NULL ,
 "cid_name" VARCHAR (80) NOT NULL , 
 "cid_num" VARCHAR (80) NOT NULL ,
 "cid_ani" VARCHAR (80) NOT NULL , 
 "cid_rdnis" VARCHAR (80) NOT NULL ,
 "cid_dnid" VARCHAR (80) NOT NULL ,
 "exten" VARCHAR (80) NOT NULL ,
 "context" VARCHAR (80) NOT NULL , 
 "channame" VARCHAR (80) NOT NULL ,
 "appname" VARCHAR (80) NOT NULL ,
 "appdata" VARCHAR (512) NOT NULL ,
 "amaflags" int NOT NULL ,
 "accountcode" VARCHAR (20) NOT NULL ,
 "peeraccount" VARCHAR (20) NOT NULL ,
 "uniqueid" VARCHAR (150) NOT NULL ,
 "linkedid" VARCHAR (150) NOT NULL , 
 "userfield" VARCHAR (255) NOT NULL ,
 "peer" VARCHAR (80) NOT NULL ,
 "call_log_id" INTEGER REFERENCES "call_log"("id") ON DELETE SET NULL DEFAULT NULL,
 PRIMARY KEY("id")
);

CREATE INDEX "cel__idx__uniqueid" ON "cel"("uniqueid");
CREATE INDEX "cel__idx__eventtime" ON "cel"("eventtime");
CREATE INDEX "cel__idx__call_log_id" ON "cel" ("call_log_id");

DROP TABLE IF EXISTS "context" CASCADE;
CREATE TABLE "context" (
 "name" VARCHAR(39) NOT NULL,
 "displayname" VARCHAR(128) NOT NULL DEFAULT '',
 "entity" VARCHAR(64),
 "contexttype" VARCHAR(40) NOT NULL DEFAULT 'internal',
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("name")
);


DROP TABLE IF EXISTS "contextinclude" CASCADE;
CREATE TABLE "contextinclude" (
 "context" VARCHAR(39) NOT NULL,
 "include" VARCHAR(39) NOT NULL,
 "priority" INTEGER NOT NULL DEFAULT 0,
 PRIMARY KEY("context","include")
);


DROP TABLE IF EXISTS "contextmember" CASCADE;
CREATE TABLE "contextmember" (
 "context" VARCHAR(39) NOT NULL,
 "type" VARCHAR(32) NOT NULL,
 "typeval" VARCHAR(128) NOT NULL DEFAULT '',
 "varname" VARCHAR(128) NOT NULL DEFAULT '',
 PRIMARY KEY("context","type","typeval","varname")
);

CREATE INDEX "contextmember__idx__context" ON "contextmember"("context");
CREATE INDEX "contextmember__idx__context_type" ON "contextmember"("context","type");


DROP TABLE IF EXISTS "contextnumbers" CASCADE;
DROP TYPE  IF EXISTS "contextnumbers_type";

CREATE TYPE "contextnumbers_type" AS ENUM ('user', 'group', 'queue', 'meetme', 'incall');

CREATE TABLE "contextnumbers" (
 "context" VARCHAR(39) NOT NULL,
 "type" contextnumbers_type NOT NULL,
 "numberbeg" VARCHAR(16) NOT NULL DEFAULT '',
 "numberend" VARCHAR(16) NOT NULL DEFAULT '',
 "didlength" INTEGER NOT NULL DEFAULT 0,
 PRIMARY KEY("context","type","numberbeg","numberend")
);


DROP TABLE IF EXISTS "contexttype" CASCADE;
CREATE TABLE "contexttype" (
 "id" SERIAL,
 "name" VARCHAR(40) NOT NULL,
 "commented" INTEGER,
 "deletable" INTEGER,
 "description" text,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "contexttype__uidx__name" ON "contexttype"("name");

INSERT INTO "contexttype" VALUES(DEFAULT, 'internal', 0, 0, '');
INSERT INTO "contexttype" VALUES(DEFAULT, 'incall', 0, 0, '');
INSERT INTO "contexttype" VALUES(DEFAULT, 'outcall', 0, 0, '');
INSERT INTO "contexttype" VALUES(DEFAULT, 'services', 0, 0, '');
INSERT INTO "contexttype" VALUES(DEFAULT, 'others', 0, 0, '');


DROP TABLE IF EXISTS "cti_service" CASCADE;
CREATE TABLE "cti_service" (
 "id" SERIAL PRIMARY KEY,
 "key" VARCHAR(255) NOT NULL
);

INSERT INTO "cti_service" VALUES (DEFAULT, 'enablevm');
INSERT INTO "cti_service" VALUES (DEFAULT, 'callrecord');
INSERT INTO "cti_service" VALUES (DEFAULT, 'incallrec');
INSERT INTO "cti_service" VALUES (DEFAULT, 'incallfilter');
INSERT INTO "cti_service" VALUES (DEFAULT, 'enablednd');
INSERT INTO "cti_service" VALUES (DEFAULT, 'fwdunc');
INSERT INTO "cti_service" VALUES (DEFAULT, 'fwdbusy');
INSERT INTO "cti_service" VALUES (DEFAULT, 'fwdrna');


DROP TABLE IF EXISTS "cti_preference" CASCADE;
CREATE TABLE "cti_preference" (
 "id" SERIAL PRIMARY KEY,
 "option" VARCHAR(255) NOT NULL
);

INSERT INTO "cti_preference" VALUES (DEFAULT, 'loginwindow.url');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'xlet.identity.logagent');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'xlet.identity.pauseagent');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'xlet.agentdetails.noqueueaction');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'xlet.agentdetails.hideastid');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'xlet.agentdetails.hidecontext');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'xlet.agents.fontname');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'xlet.agents.fontsize');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'xlet.agents.iconsize');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'xlet.queues.statsfetchperiod');
INSERT INTO "cti_preference" VALUES (DEFAULT, 'presence.autochangestate');

DROP TABLE IF EXISTS "cti_xlet" CASCADE;
CREATE TABLE "cti_xlet" (
 "id" SERIAL PRIMARY KEY,
 "plugin_name" VARCHAR(40) NOT NULL
);

INSERT INTO "cti_xlet" VALUES (DEFAULT, 'identity');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'dial');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'history');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'search');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'directory');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'fax');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'features');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'conference');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'datetime');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'tabber');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'mylocaldir');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'customerinfo');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'agents');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'agentdetails');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'queues');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'queuemembers');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'queueentrydetails');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'switchboard');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'remotedirectory');
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'agentstatusdashboard');

DROP TABLE IF EXISTS "cti_xlet_layout" CASCADE;
CREATE TABLE "cti_xlet_layout" (
 "id" SERIAL PRIMARY KEY,
 "name" VARCHAR(255) NOT NULL
);

INSERT INTO "cti_xlet_layout" VALUES (DEFAULT, 'dock');
INSERT INTO "cti_xlet_layout" VALUES (DEFAULT, 'grid');
INSERT INTO "cti_xlet_layout" VALUES (DEFAULT, 'tab');


DROP TABLE IF EXISTS "ctiphonehintsgroup" CASCADE;
CREATE TABLE "ctiphonehintsgroup" (
 "id" SERIAL,
 "name" VARCHAR(255),
 "description" VARCHAR(255),
 "deletable" INTEGER, -- BOOLEAN
 PRIMARY KEY("id")
);

INSERT INTO "ctiphonehintsgroup" VALUES(DEFAULT,'xivo','De base non supprimable',0);


DROP TABLE IF EXISTS "ctipresences" CASCADE;
CREATE TABLE "ctipresences" (
 "id" SERIAL,
 "name" VARCHAR(255),
 "description" VARCHAR(255),
 "deletable" INTEGER, -- BOOLEAN
 PRIMARY KEY("id")
);

INSERT INTO "ctipresences" VALUES(DEFAULT,'xivo','De base non supprimable',0);


DROP TABLE IF EXISTS "cti_profile" CASCADE;
CREATE TABLE "cti_profile" (
       "id" SERIAL PRIMARY KEY,
       "name" VARCHAR(255),
       "presence_id" INTEGER REFERENCES "ctipresences"("id") ON DELETE RESTRICT,
       "phonehints_id" INTEGER REFERENCES "ctiphonehintsgroup"("id") ON DELETE RESTRICT
);

INSERT INTO "cti_profile" VALUES (DEFAULT, 'Supervisor', 1, 1);
INSERT INTO "cti_profile" VALUES (DEFAULT, 'Agent', 1, 1);
INSERT INTO "cti_profile" VALUES (DEFAULT, 'Client', 1, 1);
INSERT INTO "cti_profile" VALUES (DEFAULT, 'Switchboard', 1, 1);


DROP TABLE IF EXISTS "cti_profile_xlet" CASCADE;
CREATE TABLE "cti_profile_xlet" (
       "xlet_id" INTEGER REFERENCES cti_xlet("id") ON DELETE CASCADE,
       "profile_id" INTEGER REFERENCES cti_profile("id") ON DELETE CASCADE,
       "layout_id" INTEGER REFERENCES cti_xlet_layout("id") ON DELETE RESTRICT,
       "closable" BOOLEAN DEFAULT TRUE,
       "movable" BOOLEAN DEFAULT TRUE,
       "floating" BOOLEAN DEFAULT TRUE,
       "scrollable" BOOLEAN DEFAULT TRUE,
       "order" INTEGER,
       PRIMARY KEY("xlet_id", "profile_id")
);

/* agentsup */
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'identity'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Supervisor'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'grid'),
                                       TRUE, TRUE, TRUE, TRUE, 0);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'queues'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Supervisor'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'));
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'queuemembers'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Supervisor'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'));
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'queueentrydetails'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Supervisor'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'));
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'agents'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Supervisor'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'));
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'agentdetails'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Supervisor'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'));
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'conference'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Supervisor'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'));

/* agent */
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'identity'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Agent'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'grid'),
                                       TRUE, TRUE, TRUE, TRUE, 0);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'queues'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Agent'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'));
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'customerinfo'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Agent'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'));
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'agentdetails'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Agent'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'));

/* client */
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'identity'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'grid'),
                                       TRUE, TRUE, TRUE, TRUE, 0);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'tabber'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'grid'),
                                       TRUE, TRUE, TRUE, TRUE, 1);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'dial'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'grid'),
                                       TRUE, TRUE, TRUE, TRUE, 2);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'search'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'tab'),
                                       TRUE, TRUE, TRUE, TRUE, 0);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'customerinfo'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'tab'),
                                       TRUE, TRUE, TRUE, TRUE, 1);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'fax'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'tab'),
                                       TRUE, TRUE, TRUE, TRUE, 2);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'history'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'tab'),
                                       TRUE, TRUE, TRUE, TRUE, 3);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'remotedirectory'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'tab'),
                                       TRUE, TRUE, TRUE, TRUE, 4);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'features'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'tab'),
                                       TRUE, TRUE, TRUE, TRUE, 5);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'mylocaldir'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'tab'),
                                       TRUE, TRUE, TRUE, TRUE, 6);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'conference'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'tab'),
                                       TRUE, TRUE, TRUE, TRUE, 7);

/* switchboard */
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'identity'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Switchboard'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'grid'),
                                       TRUE, TRUE, TRUE, TRUE, 0);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'switchboard'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Switchboard'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'),
                                       TRUE, TRUE, TRUE, TRUE, 1);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'dial'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Switchboard'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'),
                                       TRUE, TRUE, TRUE, TRUE, 2);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'directory'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Switchboard'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'),
                                       TRUE, TRUE, TRUE, TRUE, 3);



DROP TABLE IF EXISTS "cti_profile_preference" CASCADE;
CREATE TABLE "cti_profile_preference" (
       "profile_id" INTEGER REFERENCES "cti_profile"("id") ON DELETE CASCADE,
       "preference_id" INTEGER REFERENCES "cti_preference"("id") ON DELETE CASCADE,
       "value" VARCHAR(255),
       PRIMARY KEY("profile_id", "preference_id")
);


DROP TABLE IF EXISTS "cti_profile_service" CASCADE;
CREATE TABLE "cti_profile_service" (
       "profile_id" INTEGER REFERENCES "cti_profile"("id") ON DELETE CASCADE,
       "service_id" INTEGER REFERENCES "cti_service"("id") ON DELETE CASCADE,
       PRIMARY KEY("profile_id", "service_id")
);

/* client */
INSERT INTO "cti_profile_service" VALUES ((SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                          (SELECT "id" FROM "cti_service" WHERE "key" = 'enablednd'));
INSERT INTO "cti_profile_service" VALUES ((SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                          (SELECT "id" FROM "cti_service" WHERE "key" = 'fwdunc'));
INSERT INTO "cti_profile_service" VALUES ((SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                          (SELECT "id" FROM "cti_service" WHERE "key" = 'fwdbusy'));
INSERT INTO "cti_profile_service" VALUES ((SELECT "id" FROM "cti_profile" WHERE "name" = 'Client'),
                                          (SELECT "id" FROM "cti_service" WHERE "key" = 'fwdrna'));


DROP TABLE IF EXISTS "ctilog" CASCADE;
CREATE TABLE "ctilog" (
 "id" SERIAL,
 "eventdate" TIMESTAMP,
 "loginclient" VARCHAR(64),
 "company" VARCHAR(64),
 "status" VARCHAR(64),
 "action" VARCHAR(64),
 "arguments" VARCHAR(255),
 "callduration" INTEGER,
 PRIMARY KEY("id")
);


DROP TABLE IF EXISTS "cticontexts" CASCADE;
CREATE TABLE "cticontexts" (
 "id" SERIAL,
 "name" VARCHAR(50),
 "directories" text NOT NULL,
 "display" text NOT NULL,
 "description" text NOT NULL,
 "deletable" INTEGER, -- BOOLEAN
 PRIMARY KEY("id")
);

INSERT INTO "cticontexts" VALUES(DEFAULT,'default','xivodir,internal','Display','Contexte par défaut',1);
INSERT INTO "cticontexts" VALUES(DEFAULT, '__switchboard_directory', 'xivodir', 'switchboard', '', 1);


DROP TABLE IF EXISTS "ctidirectories" CASCADE;
CREATE TABLE "ctidirectories" (
 "id" SERIAL,
 "name" VARCHAR(255),
 "uri" VARCHAR(255),
 "delimiter" VARCHAR(20),
 "match_direct" text NOT NULL,
 "match_reverse" text NOT NULL,
 "description" VARCHAR(255),
 "deletable" INTEGER, -- BOOLEAN
 PRIMARY KEY("id")
);

INSERT INTO "ctidirectories" VALUES(DEFAULT,'xivodir', 'phonebook', '', '["phonebook.firstname","phonebook.lastname","phonebook.displayname","phonebook.society","phonebooknumber.office.number"]','["phonebooknumber.office.number","phonebooknumber.mobile.number"]','Répertoire XiVO Externe',1);
INSERT INTO "ctidirectories" VALUES(DEFAULT,'internal','internal','','["userfeatures.firstname","userfeatures.lastname"]','','Répertoire XiVO Interne',1);


DROP TABLE IF EXISTS "ctidirectoryfields" CASCADE;
CREATE TABLE "ctidirectoryfields" (
 "dir_id" INTEGER,
 "fieldname" VARCHAR(255),
 "value" VARCHAR(255),
 PRIMARY KEY("dir_id", "fieldname")
);

INSERT INTO "ctidirectoryfields" VALUES(1, 'phone', 'phonebooknumber.office.number');
INSERT INTO "ctidirectoryfields" VALUES(1, 'firstname', 'phonebook.firstname');
INSERT INTO "ctidirectoryfields" VALUES(1, 'lastname', 'phonebook.lastname');
INSERT INTO "ctidirectoryfields" VALUES(1, 'fullname', 'phonebook.fullname');
INSERT INTO "ctidirectoryfields" VALUES(1, 'company', 'phonebook.society');
INSERT INTO "ctidirectoryfields" VALUES(1, 'mail', 'phonebook.email');
INSERT INTO "ctidirectoryfields" VALUES(1, 'reverse', 'phonebook.fullname');
INSERT INTO "ctidirectoryfields" VALUES(2, 'firstname', 'userfeatures.firstname');
INSERT INTO "ctidirectoryfields" VALUES(2, 'lastname', 'userfeatures.lastname');
INSERT INTO "ctidirectoryfields" VALUES(2, 'phone', 'extensions.exten');


DROP TABLE IF EXISTS "ctidisplays" CASCADE;
CREATE TABLE "ctidisplays" (
 "id" SERIAL,
 "name" VARCHAR(50),
 "data" text NOT NULL,
 "deletable" INTEGER, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

INSERT INTO "ctidisplays" VALUES(DEFAULT,'Display','{"10": [ "Nom","","","{db-firstname} {db-lastname}" ],"20": [ "Numéro","phone","","{db-phone}" ],"30": [ "Entreprise","","Inconnue","{db-company}" ],"40": [ "E-mail","","","{db-mail}" ], "50": [ "Source","","","{xivo-directory}" ]}',1,'Affichage par défaut');
INSERT INTO "ctidisplays" VALUES(DEFAULT, 'switchboard', '{ "10": [ "", "status", "", ""],"20": [ "Name", "name", "", "{db-firstname} {db-lastname}"],"30": [ "Number", "number_office", "", "{db-phone}"]}', 1, '');


DROP TABLE IF EXISTS "ctimain" CASCADE;
CREATE TABLE "ctimain" (
 "id" SERIAL, 
 "commandset" VARCHAR(20),
 "ami_ip" VARCHAR(16),
 "ami_port" INTEGER,
 "ami_login" VARCHAR(64),
 "ami_password" VARCHAR(64),
 "cti_ip" VARCHAR(16),
 "cti_port" INTEGER,
 "cti_active" INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "ctis_ip" VARCHAR(16),
 "ctis_port" INTEGER,
 "ctis_active" INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "webi_ip" VARCHAR(16),
 "webi_port" INTEGER,
 "webi_active" INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "info_ip" VARCHAR(16),
 "info_port" INTEGER,
 "info_active" INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "tlscertfile" VARCHAR(128),
 "tlsprivkeyfile" VARCHAR(128),
 "socket_timeout" INTEGER, -- BOOLEAN
 "login_timeout" INTEGER, -- BOOLEAN
 "context_separation" INTEGER, -- BOOLEAN
 "live_reload_conf" INTEGER, -- BOOLEAN
 PRIMARY KEY("id")
);

INSERT INTO "ctimain" VALUES(DEFAULT, 'xivocti', '127.0.0.1', 5038, 'xivo_cti_user', 'phaickbebs9', '0.0.0.0', 5003, 1, '0.0.0.0', 5013, 0, '127.0.0.1', 5004, 1, '127.0.0.1', 5005, 1, '', '', 10, 5, 0, 1);


DROP TABLE IF EXISTS "ctiphonehints" CASCADE;
CREATE TABLE "ctiphonehints" (
 "id" SERIAL,
 "idgroup" INTEGER,
 "number" VARCHAR(8),
 "name" VARCHAR(255),
 "color" VARCHAR(128),
 PRIMARY KEY("id")
);

INSERT INTO "ctiphonehints" VALUES(DEFAULT,1,'-2','Inexistant','#030303');
INSERT INTO "ctiphonehints" VALUES(DEFAULT,1,'-1','Désactivé','#000000');
INSERT INTO "ctiphonehints" VALUES(DEFAULT,1,'0','Disponible','#0DFF25');
INSERT INTO "ctiphonehints" VALUES(DEFAULT,1,'1','En ligne OU appelle','#FF032D');
INSERT INTO "ctiphonehints" VALUES(DEFAULT,1,'2','Occupé','#FF0008');
INSERT INTO "ctiphonehints" VALUES(DEFAULT,1,'4','Indisponible','#FFFFFF');
INSERT INTO "ctiphonehints" VALUES(DEFAULT,1,'8','Sonne','#1B0AFF');
INSERT INTO "ctiphonehints" VALUES(DEFAULT,1,'9','(En Ligne OU Appelle) ET Sonne','#FF0526');
INSERT INTO "ctiphonehints" VALUES(DEFAULT,1,'16','En Attente','#F7FF05');


DROP TABLE IF EXISTS "ctireversedirectories" CASCADE;
CREATE TABLE "ctireversedirectories" (
 "id" SERIAL,
 "directories" text NOT NULL,
 PRIMARY KEY("id")
);

INSERT INTO "ctireversedirectories" VALUES(DEFAULT,'["xivodir"]');


DROP TABLE IF EXISTS "ctisheetactions" CASCADE;
CREATE TABLE "ctisheetactions" (
 "id" SERIAL,
 "name" VARCHAR(50),
 "description" text NOT NULL,
 "whom" VARCHAR(50),
 "sheet_info" text,
 "systray_info" text,
 "sheet_qtui" text,
 "action_info" text,
 "focus" INTEGER, -- BOOLEAN
 "deletable" INTEGER, -- BOOLEAN
 "disable" INTEGER, -- BOOLEAN
 PRIMARY KEY("id")
);

INSERT INTO "ctisheetactions" VALUES(DEFAULT,'XiVO','Modèle de fiche de base.','dest','{"10": [ "Nom","title","","{xivo-calleridname}",0 ],"20": [ "Numéro","text","","{xivo-calleridnum}",0 ],"30": [ "Origine","text","","{xivo-origin}",0 ]}','{"10": [ "Nom","title","","{xivo-calledidname}" ],"20": [ "Numéro","body","","{xivo-calleridnum}" ],"30": [ "Origine","body","","{xivo-origin}" ]}','','{}',0,1,1);


DROP TABLE IF EXISTS "ctisheetevents" CASCADE;
CREATE TABLE "ctisheetevents" (
 "id" SERIAL,
 "incomingdid" VARCHAR(50),
 "hangup" VARCHAR(50),
 "dial" VARCHAR(50),
 "link" VARCHAR(50),
 "unlink" VARCHAR(50),
 PRIMARY KEY("id")
);

INSERT INTO "ctisheetevents" VALUES(DEFAULT,'','','XiVO','','');


DROP TABLE IF EXISTS "ctistatus" CASCADE;
CREATE TABLE "ctistatus" (
 "id" SERIAL,
 "presence_id" INTEGER,
 "name" VARCHAR(255),
 "display_name" VARCHAR(255),
 "actions" VARCHAR(255),
 "color" VARCHAR(20),
 "access_status" VARCHAR(255),
 "deletable" INTEGER, -- BOOLEAN
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "ctistatus_presence_name" ON "ctistatus" (presence_id,name);

INSERT INTO "ctistatus" VALUES(DEFAULT,1,'available','Disponible','enablednd(false)','#08FD20','1,2,3,4,5',0);
INSERT INTO "ctistatus" VALUES(DEFAULT,1,'away','Sorti','enablednd(false)','#FDE50A','1,2,3,4,5',1);
INSERT INTO "ctistatus" VALUES(DEFAULT,1,'outtolunch','Parti Manger','enablednd(false)','#001AFF','1,2,3,4,5',1);
INSERT INTO "ctistatus" VALUES(DEFAULT,1,'donotdisturb','Ne pas déranger','enablednd(true)','#FF032D','1,2,3,4,5',1);
INSERT INTO "ctistatus" VALUES(DEFAULT,1,'berightback','Bientôt de retour','enablednd(false)','#FFB545','1,2,3,4,5',1);
INSERT INTO "ctistatus" VALUES(DEFAULT,1,'disconnected','Déconnecté','agentlogoff()','#202020','',0);


DROP TABLE IF EXISTS "dialaction" CASCADE;
DROP TABLE IF EXISTS "schedule" CASCADE; -- USE dialaction_action
DROP TABLE IF EXISTS "schedule_time" CASCADE; -- USE dialaction_action
DROP TYPE IF EXISTS "dialaction_event" CASCADE;
DROP TYPE IF EXISTS "dialaction_category" CASCADE;
DROP TYPE IF EXISTS "dialaction_action" CASCADE;

CREATE TYPE "dialaction_event" AS ENUM ('answer',
 'noanswer',
 'congestion',
 'busy',
 'chanunavail',
 'inschedule',
 'outschedule',
 'qwaittime',
 'qwaitratio');
CREATE TYPE "dialaction_category" AS ENUM ('callfilter','group','incall','queue','schedule','user','outcall');
CREATE TYPE "dialaction_action" AS ENUM ('none',
  'endcall:busy',
  'endcall:congestion',
  'endcall:hangup',
  'user',
  'group',
  'queue',
  'meetme',
  'voicemail',
  'trunk',
  'schedule',
  'voicemenu',
  'extension',
  'outcall',
  'application:callbackdisa',
  'application:disa',
  'application:directory',
  'application:faxtomail',
  'application:voicemailmain',
  'application:password',
  'sound',
  'custom');

CREATE TABLE "dialaction" (
 "event" dialaction_event NOT NULL,
 "category" dialaction_category,
 "categoryval" VARCHAR(128) NOT NULL DEFAULT '',
 "action" dialaction_action NOT NULL,
 "actionarg1" VARCHAR(255) DEFAULT NULL::character varying,
 "actionarg2" VARCHAR(255) DEFAULT NULL::character varying,
 "linked" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 PRIMARY KEY("event","category","categoryval")
);

CREATE INDEX "dialaction__idx__action_actionarg1" ON "dialaction"("action","actionarg1");


DROP TABLE IF EXISTS "dialpattern" CASCADE;
CREATE TABLE "dialpattern" (
 "id" SERIAL,
 "type" VARCHAR(32) NOT NULL,
 "typeid" INTEGER NOT NULL,
 "externprefix" VARCHAR(64),
 "prefix" VARCHAR(32),
 "exten" VARCHAR(40) NOT NULL,
 "stripnum" INTEGER,
 "callerid" VARCHAR(80),
 PRIMARY KEY("id")
);

CREATE INDEX "dialpattern__idx__type_typeid" ON "dialpattern"("type","typeid");


DROP TYPE  IF EXISTS "extenumbers_type";

CREATE TYPE "extenumbers_type" AS ENUM ('extenfeatures',
'featuremap',
'generalfeatures',
'group',
'incall',
'meetme',
'outcall',
'queue',
'user',
'voicemenu');

DROP TABLE IF EXISTS "extensions" CASCADE;
CREATE TABLE "extensions" (
 "id" SERIAL,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "context" VARCHAR(39) NOT NULL DEFAULT '',
 "exten" VARCHAR(40) NOT NULL DEFAULT '',
 "type" extenumbers_type NOT NULL,
 "typeval" VARCHAR(255) NOT NULL DEFAULT '',
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "extensions__uidx__exten_context" ON "extensions"("exten","context");
CREATE INDEX "extensions__idx__exten" ON "extensions"("exten");
CREATE INDEX "extensions__idx__context" ON "extensions"("context");
CREATE INDEX "extensions__idx__type" ON "extensions"("type");
CREATE INDEX "extensions__idx__typeval" ON "extensions"("typeval");

INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*31.','extenfeatures','agentstaticlogin');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*32.','extenfeatures','agentstaticlogoff');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*30.','extenfeatures','agentstaticlogtoggle');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*37.','extenfeatures','bsfilter');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*664.','extenfeatures','callgroup');
INSERT INTO "extensions" VALUES (DEFAULT,1,'xivo-features','*34','extenfeatures','calllistening');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*667.','extenfeatures','callmeetme');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*665.','extenfeatures','callqueue');
INSERT INTO "extensions" VALUES (DEFAULT,1,'xivo-features','*26','extenfeatures','callrecord');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*666.','extenfeatures','calluser');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','*36','extenfeatures','directoryaccess');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','*25','extenfeatures','enablednd');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','*90','extenfeatures','enablevm');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*90.','extenfeatures','enablevmslt');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*23.','extenfeatures','fwdbusy');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*22.','extenfeatures','fwdrna');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*21.','extenfeatures','fwdunc');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','*20','extenfeatures','fwdundoall');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','*48378','extenfeatures','autoprov');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','*27','extenfeatures','incallfilter');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','*10','extenfeatures','phonestatus');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*735.','extenfeatures','phoneprogfunckey');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*8.','extenfeatures','pickup');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','*9','extenfeatures','recsnd');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*99.','extenfeatures','vmboxmsgslt');
INSERT INTO "extensions" VALUES (DEFAULT,1,'xivo-features','_*93.','extenfeatures','vmboxpurgeslt');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*97.','extenfeatures','vmboxslt');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','*98','extenfeatures','vmusermsg');
INSERT INTO "extensions" VALUES (DEFAULT,1,'xivo-features','*92','extenfeatures','vmuserpurge');
INSERT INTO "extensions" VALUES (DEFAULT,1,'xivo-features','_*92.','extenfeatures','vmuserpurgeslt');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*96.','extenfeatures','vmuserslt');
INSERT INTO "extensions" VALUES (DEFAULT,0,'xivo-features','_*11.','extenfeatures','paging');


DROP TABLE IF EXISTS "features" CASCADE;
CREATE TABLE "features" (
 "id" SERIAL,
 "cat_metric" INTEGER NOT NULL DEFAULT 0,
 "var_metric" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "filename" VARCHAR(128) NOT NULL,
 "category" VARCHAR(128) NOT NULL,
 "var_name" VARCHAR(128) NOT NULL,
 "var_val" VARCHAR(255),
 PRIMARY KEY("id")
);

CREATE INDEX "features__idx__category" ON "features"("category");

INSERT INTO "features" VALUES (DEFAULT,0,0,0,'features.conf','general','parkext','700');
INSERT INTO "features" VALUES (DEFAULT,0,0,0,'features.conf','general','parkpos','701-750');
INSERT INTO "features" VALUES (DEFAULT,0,0,0,'features.conf','general','context','parkedcalls');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','parkinghints','no');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','parkingtime','45');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','comebacktoorigin','yes');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','courtesytone',NULL);
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','parkedplay','caller');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','parkedcalltransfers','no');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','parkedcallreparking','no');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','parkedcallhangup','no');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','parkedcallrecording','no');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','parkeddynamic','no');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','adsipark','no');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','findslot','next');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','parkedmusicclass','default');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','transferdigittimeout','5');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','xfersound',NULL);
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','xferfailsound',NULL);
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','pickupexten','*8');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','pickupsound','');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','pickupfailsound','');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','featuredigittimeout','1500');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','atxfernoanswertimeout','15');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','atxferdropcall','no');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','atxferloopdelay','10');
INSERT INTO "features" VALUES (DEFAULT,0,0,1,'features.conf','general','atxfercallbackretries','2');
INSERT INTO "features" VALUES (DEFAULT,1,0,0,'features.conf','featuremap','blindxfer','*1');
INSERT INTO "features" VALUES (DEFAULT,1,0,0,'features.conf','featuremap','disconnect','*0');
INSERT INTO "features" VALUES (DEFAULT,1,0,0,'features.conf','featuremap','automon','*3');
INSERT INTO "features" VALUES (DEFAULT,1,0,0,'features.conf','featuremap','atxfer','*2');


DROP TABLE IF EXISTS "paging" CASCADE;
CREATE TABLE "paging" (
 "id"		 		SERIAL NOT NULL,
 "number" 			VARCHAR(32),
 "duplex" 			INTEGER NOT NULL DEFAULT 0, -- BOOLEAN,
 "ignore" 			INTEGER NOT NULL DEFAULT 0, -- BOOLEAN,
 "record" 			INTEGER NOT NULL DEFAULT 0, -- BOOLEAN,
 "quiet" 			INTEGER NOT NULL DEFAULT 0, -- BOOLEAN,
 "timeout" 			INTEGER NOT NULL,
 "announcement_file" VARCHAR(64),
 "announcement_play" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN,
 "announcement_caller" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN,
 "commented" 		INTEGER NOT NULL DEFAULT 0, -- BOOLEAN,
 "description" 		text,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "paging__uidx__number" ON "paging"("number");

DROP TABLE IF EXISTS "paginguser" CASCADE;
CREATE TABLE "paginguser" (
 "pagingid" 		INTEGER NOT NULL,
 "userfeaturesid" 	INTEGER NOT NULL,
 "caller" 			INTEGER NOT NULL, -- BOOLEAN
 PRIMARY KEY("pagingid","userfeaturesid","caller")
);

CREATE INDEX "paginguser__idx__pagingid" ON "paginguser"("pagingid");


DROP TABLE IF EXISTS "parkinglot" CASCADE;
CREATE TABLE "parkinglot" (
 "id"            SERIAL,
 "name"          VARCHAR(255) NOT NULL,
 "context"       VARCHAR(39) NOT NULL,       -- SHOULD BE A REF TO CONTEXT TABLE IN 2.0
 "extension"     VARCHAR(40) NOT NULL,
 "positions"     INTEGER NOT NULL,           -- NUMBER OF POSITIONS, (positions starts at extension + 1)
 "next"          INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "duration"      INTEGER,
 
 "calltransfers" VARCHAR(8) DEFAULT NULL::character varying,
 "callreparking" VARCHAR(8) DEFAULT NULL::character varying,
 "callhangup"    VARCHAR(8) DEFAULT NULL::character varying,
 "callrecording" VARCHAR(8) DEFAULT NULL::character varying,
 "musicclass"    VARCHAR(255) DEFAULT NULL::character varying,
 "hints"         INTEGER    NOT NULL DEFAULT 0, -- BOOLEAN

 "commented"     INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description"   TEXT NOT NULL DEFAULT '',
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "parkinglot__idx__name" ON "parkinglot"("name");


DROP TABLE IF EXISTS "groupfeatures" CASCADE;
CREATE TABLE "groupfeatures" (
 "id" SERIAL,
 "name" VARCHAR(128) NOT NULL,
 "number" VARCHAR(40) NOT NULL DEFAULT '',
 "context" VARCHAR(39) NOT NULL,
 "transfer_user" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "transfer_call" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "write_caller" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "write_calling" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "timeout" INTEGER NOT NULL DEFAULT 0,
 "preprocess_subroutine" VARCHAR(39),
 "deleted" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 PRIMARY KEY("id")
);

CREATE INDEX "groupfeatures__idx__name" ON "groupfeatures"("name");
CREATE INDEX "groupfeatures__idx__number" ON "groupfeatures"("number");
CREATE INDEX "groupfeatures__idx__context" ON "groupfeatures"("context");


DROP TABLE IF EXISTS "incall" CASCADE;
CREATE TABLE "incall" (
 "id" SERIAL,
 "exten" VARCHAR(40) NOT NULL,
 "context" VARCHAR(39) NOT NULL,
 "preprocess_subroutine" VARCHAR(39),
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

CREATE INDEX "incall__idx__exten" ON "incall"("exten");
CREATE INDEX "incall__idx__context" ON "incall"("context");
CREATE UNIQUE INDEX "incall__uidx__exten_context" ON "incall"("exten","context");


DROP TABLE IF EXISTS "linefeatures" CASCADE;
CREATE TABLE "linefeatures" (
 "id" SERIAL,
 "protocol" "trunk_protocol" NOT NULL,
 "protocolid" INTEGER NOT NULL,
 "device" VARCHAR(32),
 "configregistrar" VARCHAR(128),
 "name" VARCHAR(128) NOT NULL,
 "number" VARCHAR(40),
 "context" VARCHAR(39) NOT NULL,
 "provisioningid" INTEGER NOT NULL,
 "num" INTEGER DEFAULT 0,
 "ipfrom" VARCHAR(15),
 "commented" INTEGER NOT NULL DEFAULT 0,
 "description" text,
 PRIMARY KEY("id")
);

CREATE INDEX "linefeatures__idx__device" ON "linefeatures"("device");
CREATE INDEX "linefeatures__idx__number" ON "linefeatures"("number");
CREATE INDEX "linefeatures__idx__context" ON "linefeatures"("context");
CREATE INDEX "linefeatures__idx__provisioningid" ON "linefeatures"("provisioningid");
CREATE UNIQUE INDEX "linefeatures__uidx__name" ON "linefeatures"("name");
CREATE UNIQUE INDEX "linefeatures__uidx__protocol_protocolid" ON "linefeatures"("protocol","protocolid");


DROP TABLE IF EXISTS "ldapfilter" CASCADE;
DROP TYPE  IF EXISTS "ldapfilter_additionaltype";

CREATE TYPE "ldapfilter_additionaltype" AS ENUM ('office', 'home', 'mobile', 'fax', 'other', 'custom');

CREATE TABLE "ldapfilter" (
 "id" SERIAL,
 "ldapserverid" INTEGER NOT NULL,
 "name" VARCHAR(128) NOT NULL DEFAULT '',
 "user" VARCHAR(255),
 "passwd" VARCHAR(255),
 "basedn" VARCHAR(255) NOT NULL DEFAULT '',
 "filter" VARCHAR(255) NOT NULL DEFAULT '',
 "attrdisplayname" VARCHAR(255) NOT NULL DEFAULT '',
 "attrphonenumber" VARCHAR(255) NOT NULL DEFAULT '',
 "additionaltype" ldapfilter_additionaltype NOT NULL,
 "additionaltext" VARCHAR(16) NOT NULL DEFAULT '',
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "ldapfilter__uidx__name" ON "ldapfilter"("name");


DROP TABLE IF EXISTS "meetmefeatures" CASCADE;
DROP TYPE  IF EXISTS "meetmefeatures_admin_typefrom";
DROP TYPE  IF EXISTS "meetmefeatures_admin_identification";
DROP TYPE  IF EXISTS "meetmefeatures_mode";
DROP TYPE  IF EXISTS "meetmefeatures_announcejoinleave";

CREATE TYPE "meetmefeatures_admin_typefrom" AS ENUM ('none', 'internal', 'external', 'undefined');
CREATE TYPE "meetmefeatures_admin_identification" AS ENUM ('calleridnum', 'pin', 'all');
CREATE TYPE "meetmefeatures_mode" AS ENUM ('listen', 'talk', 'all');
CREATE TYPE "meetmefeatures_announcejoinleave" AS ENUM ('no', 'yes', 'noreview');

CREATE TABLE "meetmefeatures" (
 "id" SERIAL,
 "meetmeid" INTEGER NOT NULL,
 "name" VARCHAR(80) NOT NULL,
 "confno" VARCHAR(40) NOT NULL,
 "context" VARCHAR(39) NOT NULL,
 "admin_typefrom" meetmefeatures_admin_typefrom,
 "admin_internalid" INTEGER,
 "admin_externalid" VARCHAR(40),
 "admin_identification" meetmefeatures_admin_identification NOT NULL,
 "admin_mode" meetmefeatures_mode NOT NULL,
 "admin_announceusercount" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "admin_announcejoinleave" meetmefeatures_announcejoinleave NOT NULL,
 "admin_moderationmode" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "admin_initiallymuted" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "admin_musiconhold" VARCHAR(128),
 "admin_poundexit" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "admin_quiet" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "admin_starmenu" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "admin_closeconflastmarkedexit" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "admin_enableexitcontext" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "admin_exitcontext" VARCHAR(39),
 "user_mode" meetmefeatures_mode NOT NULL,
 "user_announceusercount" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "user_hiddencalls" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "user_announcejoinleave" meetmefeatures_announcejoinleave NOT NULL,
 "user_initiallymuted" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "user_musiconhold" VARCHAR(128),
 "user_poundexit" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "user_quiet" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "user_starmenu" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "user_enableexitcontext" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "user_exitcontext" VARCHAR(39),
 "talkeroptimization" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "record" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "talkerdetection" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "noplaymsgfirstenter" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "durationm" INTEGER,
 "closeconfdurationexceeded" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "nbuserstartdeductduration" INTEGER,
 "timeannounceclose" INTEGER,
 "maxusers" INTEGER NOT NULL default 0,
 "startdate" INTEGER,
 "emailfrom" VARCHAR(255),
 "emailfromname" VARCHAR(255),
 "emailsubject" VARCHAR(255),
 "emailbody" text NOT NULL,
 "preprocess_subroutine" VARCHAR(39),
 "description" text NOT NULL,
 "commented" INTEGER DEFAULT 0, -- BOOLEAN
 PRIMARY KEY("id")
);

CREATE INDEX "meetmefeatures__idx__number" ON "meetmefeatures"("confno");
CREATE INDEX "meetmefeatures__idx__context" ON "meetmefeatures"("context");
CREATE UNIQUE INDEX "meetmefeatures__uidx__meetmeid" ON "meetmefeatures"("meetmeid");
CREATE UNIQUE INDEX "meetmefeatures__uidx__name" ON "meetmefeatures"("name");


DROP TABLE IF EXISTS "meetmeguest" CASCADE;
CREATE TABLE "meetmeguest" (
 "id" SERIAL,
 "meetmefeaturesid" INTEGER NOT NULL,
 "fullname" VARCHAR(255) NOT NULL,
 "telephonenumber" VARCHAR(40),
 "email" VARCHAR(320),
 PRIMARY KEY("id")
);


DROP TABLE IF EXISTS "musiconhold" CASCADE;
CREATE TABLE "musiconhold" (
 "id" SERIAL,
 "cat_metric" INTEGER NOT NULL DEFAULT 0,
 "var_metric" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "filename" VARCHAR(128) NOT NULL,
 "category" VARCHAR(128) NOT NULL,
 "var_name" VARCHAR(128) NOT NULL,
 "var_val" VARCHAR(128),
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "musiconhold__uidx__filename_category_var_name" ON "musiconhold"("filename","category","var_name");

INSERT INTO "musiconhold" VALUES (DEFAULT,0,0,0,'musiconhold.conf','default','mode','files');
INSERT INTO "musiconhold" VALUES (DEFAULT,0,0,1,'musiconhold.conf','default','application','');
INSERT INTO "musiconhold" VALUES (DEFAULT,0,0,0,'musiconhold.conf','default','random','no');
INSERT INTO "musiconhold" VALUES (DEFAULT,0,0,0,'musiconhold.conf','default','directory','/var/lib/xivo/moh/default');


DROP TABLE IF EXISTS "operator" CASCADE;
CREATE TABLE "operator" (
 "id" SERIAL,
 "name" VARCHAR(64) NOT NULL,
 "default_price" double precision,
 "default_price_is" VARCHAR(16) DEFAULT 'minute'::VARCHAR NOT NULL,
 "currency" VARCHAR(16) NOT NULL,
 "disable" INTEGER DEFAULT 0 NOT NULL,
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "operator__uidx__name" ON "operator"("name");


DROP TABLE IF EXISTS "operator_destination" CASCADE;
CREATE TABLE "operator_destination" (
 "id" SERIAL,
 "operator_id" INTEGER NOT NULL,
 "name" VARCHAR(64) NOT NULL,
 "exten" VARCHAR(40) NOT NULL,
 "price" double precision,
 "price_is" VARCHAR(16) DEFAULT 'minute'::VARCHAR NOT NULL,
 "disable" INTEGER DEFAULT 0 NOT NULL,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "operator_destination__uidx__name" ON "operator_destination"("name");


DROP TABLE IF EXISTS "operator_trunk" CASCADE;
CREATE TABLE "operator_trunk" (
 "operator_id" INTEGER NOT NULL,
 "trunk_id" INTEGER NOT NULL,
 PRIMARY KEY("operator_id","trunk_id")
);


DROP TABLE IF EXISTS "outcall" CASCADE;
CREATE TABLE "outcall" (
 "id" SERIAL,
 "name" VARCHAR(128) NOT NULL,
 "context" VARCHAR(39) NOT NULL,
 "useenum" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "internal" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "preprocess_subroutine" VARCHAR(39),
 "hangupringtime" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "outcall__uidx__name" ON "outcall"("name");


DROP TABLE IF EXISTS "outcalltrunk" CASCADE;
CREATE TABLE "outcalltrunk" (
 "outcallid" INTEGER NOT NULL DEFAULT 0,
 "trunkfeaturesid" INTEGER NOT NULL DEFAULT 0,
 "priority" INTEGER NOT NULL DEFAULT 0,
 PRIMARY KEY("outcallid","trunkfeaturesid")
);

CREATE INDEX "outcalltrunk__idx__priority" ON "outcalltrunk"("priority");


DROP TABLE IF EXISTS "outcalldundipeer" CASCADE;
CREATE TABLE "outcalldundipeer" (
 "outcallid" INTEGER NOT NULL DEFAULT 0,
 "dundipeerid" INTEGER NOT NULL DEFAULT 0,
 "priority" INTEGER NOT NULL DEFAULT 0,
 PRIMARY KEY("outcallid","dundipeerid")
);


DROP TABLE IF EXISTS "phonebook" CASCADE;
DROP TYPE  IF EXISTS "phonebook_title";

CREATE TYPE "phonebook_title" AS ENUM ('mr', 'mrs', 'ms');

CREATE TABLE "phonebook" (
 "id" SERIAL,
 "title" phonebook_title NOT NULL,
 "firstname" VARCHAR(128) NOT NULL DEFAULT '',
 "lastname" VARCHAR(128) NOT NULL DEFAULT '',
 "displayname" VARCHAR(64) NOT NULL DEFAULT '',
 "society" VARCHAR(128) NOT NULL DEFAULT '',
 "email" VARCHAR(255) NOT NULL DEFAULT '',
 "url" VARCHAR(255) NOT NULL DEFAULT '',
 "image" BYTEA,
 "description" text NOT NULL,
 PRIMARY KEY("id")
);


DROP TABLE IF EXISTS "phonebookaddress" CASCADE;
DROP TYPE  IF EXISTS "phonebookaddress_type";

CREATE TYPE "phonebookaddress_type" AS ENUM ('home', 'office', 'other');

CREATE TABLE "phonebookaddress" (
 "id" SERIAL,
 "phonebookid" INTEGER NOT NULL,
 "address1" VARCHAR(30) NOT NULL DEFAULT '',
 "address2" VARCHAR(30) NOT NULL DEFAULT '',
 "city" VARCHAR(128) NOT NULL DEFAULT '',
 "state" VARCHAR(128) NOT NULL DEFAULT '',
 "zipcode" VARCHAR(16) NOT NULL DEFAULT '',
 "country" VARCHAR(3) NOT NULL DEFAULT '',
 "type" phonebookaddress_type NOT NULL,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "phonebookaddress__uidx__phonebookid_type" ON "phonebookaddress"("phonebookid","type");


DROP TABLE IF EXISTS "phonebooknumber" CASCADE;
DROP TYPE  IF EXISTS "phonebooknumber_type";

CREATE TYPE "phonebooknumber_type" AS ENUM ('home', 'office', 'mobile', 'fax', 'other');

CREATE TABLE "phonebooknumber" (
 "id" SERIAL,
 "phonebookid" INTEGER NOT NULL,
 "number" VARCHAR(40) NOT NULL DEFAULT '',
 "type" phonebooknumber_type NOT NULL,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "phonebooknumber__uidx__phonebookid_type" ON "phonebooknumber"("phonebookid","type");


DROP TABLE IF EXISTS "phonefunckey" CASCADE;
DROP TYPE  IF EXISTS "phonefunckey_typeextenumbers";
DROP TYPE  IF EXISTS "phonefunckey_typeextenumbersright";

CREATE TYPE "phonefunckey_typeextenumbers" AS ENUM ('extenfeatures', 'featuremap', 'generalfeatures');
CREATE TYPE "phonefunckey_typeextenumbersright" AS ENUM ('agent', 'group', 'meetme', 'queue', 'user','paging');

CREATE TABLE "phonefunckey" (
 "iduserfeatures" INTEGER NOT NULL,
 "fknum" INTEGER NOT NULL,
 "exten" VARCHAR(40),
 "typeextenumbers" phonefunckey_typeextenumbers,
 "typevalextenumbers" VARCHAR(255),
 "typeextenumbersright" phonefunckey_typeextenumbersright,
 "typevalextenumbersright" VARCHAR(255),
 "label" VARCHAR(32),
 "supervision" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "progfunckey" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 PRIMARY KEY("iduserfeatures","fknum")
);

CREATE INDEX "phonefunckey__idx__exten" ON "phonefunckey"("exten");
CREATE INDEX "phonefunckey__idx__progfunckey" ON "phonefunckey"("progfunckey");
CREATE INDEX "phonefunckey__idx__typeextenumbers_typevalextenumbers" ON "phonefunckey"("typeextenumbers","typevalextenumbers");
CREATE INDEX "phonefunckey__idx__typeextenumbersright_typevalextenumbersright" ON "phonefunckey"("typeextenumbersright","typevalextenumbersright");


DROP TABLE IF EXISTS "queue" CASCADE;
DROP TYPE  IF EXISTS "queue_monitor_type" CASCADE;
DROP TYPE  IF EXISTS "queue_category" CASCADE;

CREATE TYPE "queue_monitor_type" AS ENUM ('no', 'mixmonitor');
-- WARNING: used also in queuemember table
CREATE TYPE "queue_category" AS ENUM ('group', 'queue');

CREATE TABLE "queue" (
 "name" VARCHAR(128) NOT NULL,
 "musicclass" VARCHAR(128),
 "announce" VARCHAR(128),
 "context" VARCHAR(39),
 "timeout" INTEGER DEFAULT 0,
 "monitor-type" queue_monitor_type,
 "monitor-format" VARCHAR(128),
 "queue-youarenext" VARCHAR(128),
 "queue-thereare" VARCHAR(128),
 "queue-callswaiting" VARCHAR(128),
 "queue-holdtime" VARCHAR(128),
 "queue-minutes" VARCHAR(128),
 "queue-seconds" VARCHAR(128),
 "queue-thankyou" VARCHAR(128),
 "queue-reporthold" VARCHAR(128),
 "periodic-announce" text,
 "announce-frequency" INTEGER,
 "periodic-announce-frequency" INTEGER,
 "announce-round-seconds" INTEGER,
 "announce-holdtime" VARCHAR(4),
 "retry" INTEGER,
 "wrapuptime" INTEGER,
 "maxlen" INTEGER,
 "servicelevel" INTEGER,
 "strategy" VARCHAR(11),
 "joinempty" VARCHAR(255),
 "leavewhenempty" VARCHAR(255),
 "eventmemberstatus" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "eventwhencalled" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "ringinuse" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "reportholdtime" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "memberdelay" INTEGER,
 "weight" INTEGER,
 "timeoutrestart" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "category" queue_category NOT NULL,
 "timeoutpriority" VARCHAR(10) NOT NULL DEFAULT 'app',
 "autofill" INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "autopause" INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "setinterfacevar" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "setqueueentryvar" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "setqueuevar" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "membermacro" VARCHAR(1024),
 "min-announce-frequency" INTEGER NOT NULL DEFAULT 60,
 "random-periodic-announce" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "announce-position" VARCHAR(1024) NOT NULL DEFAULT 'yes',
 "announce-position-limit" INTEGER NOT NULL DEFAULT 5,
 "defaultrule" VARCHAR(1024) DEFAULT NULL::character varying,
 PRIMARY KEY("name")
);

CREATE INDEX "queue__idx__category" ON "queue"("category");


DROP TABLE IF EXISTS "queue_info" CASCADE;
CREATE TABLE "queue_info" (
 "id" SERIAL,
 "call_time_t" INTEGER,
 "queue_name" VARCHAR(128) NOT NULL DEFAULT '',
 "caller" VARCHAR(80) NOT NULL DEFAULT '',
 "caller_uniqueid" VARCHAR(32) NOT NULL DEFAULT '',
 "call_picker" VARCHAR(80),
 "hold_time" INTEGER,
 "talk_time" INTEGER,
 PRIMARY KEY("id")
);

CREATE INDEX "queue_info_call_time_t_index" ON "queue_info" ("call_time_t");
CREATE INDEX "queue_info_queue_name_index" ON "queue_info" ("queue_name");


DROP TABLE IF EXISTS "queuefeatures" CASCADE;
CREATE TABLE "queuefeatures" (
 "id" SERIAL,
 "name" VARCHAR(128) NOT NULL,
 "displayname" VARCHAR(128) NOT NULL,
 "number" VARCHAR(40) NOT NULL DEFAULT '',
 "context" VARCHAR(39),
 "data_quality" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "hitting_callee" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "hitting_caller" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "retries" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "ring" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "transfer_user" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "transfer_call" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "write_caller" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "write_calling" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "url" VARCHAR(255) NOT NULL DEFAULT '',
 "announceoverride" VARCHAR(128) NOT NULL DEFAULT '',
 "timeout" INTEGER NOT NULL DEFAULT 0,
 "preprocess_subroutine" VARCHAR(39),
 "announce_holdtime" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 -- DIVERSIONS
 "waittime"    INTEGER,
 "waitratio"   FLOAT,
 PRIMARY KEY("id")
);

CREATE INDEX "queuefeatures__idx__number" ON "queuefeatures"("number");
CREATE INDEX "queuefeatures__idx__context" ON "queuefeatures"("context");
CREATE UNIQUE INDEX "queuefeatures__uidx__name" ON "queuefeatures"("name");


DROP TABLE IF EXISTS "queuemember" CASCADE;
DROP TYPE  IF EXISTS "queuemember_usertype";

CREATE TYPE "queuemember_usertype" AS ENUM ('agent', 'user');

CREATE TABLE "queuemember" (
 "queue_name" VARCHAR(128) NOT NULL,
 "interface" VARCHAR(128) NOT NULL,
 "penalty" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "usertype" queuemember_usertype NOT NULL,
 "userid" INTEGER NOT NULL,
 "channel" VARCHAR(25) NOT NULL,
 "category" queue_category NOT NULL,
 "position" INTEGER NOT NULL DEFAULT 0,
 PRIMARY KEY("queue_name","interface")
);

CREATE INDEX "queuemember__idx__usertype" ON "queuemember"("usertype");
CREATE INDEX "queuemember__idx__userid" ON "queuemember"("userid");
CREATE INDEX "queuemember__idx__channel" ON "queuemember"("channel");
CREATE INDEX "queuemember__idx__category" ON "queuemember"("category");
CREATE UNIQUE INDEX "queuemember__uidx__queue_name_channel_usertype_userid_category" ON "queuemember"("queue_name","channel","usertype","userid","category");


DROP TABLE IF EXISTS "queuepenalty" CASCADE;
CREATE TABLE "queuepenalty" (
 "id" SERIAL,
 "name" VARCHAR(255) NOT NULL UNIQUE,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" TEXT NOT NULL,
 PRIMARY KEY("id")
);


DROP TABLE IF EXISTS "queuepenaltychange" CASCADE;
DROP TYPE  IF EXISTS "queuepenaltychange_sign";

CREATE TYPE  "queuepenaltychange_sign" AS ENUM ('=','+','-');
CREATE TABLE "queuepenaltychange" (
 "queuepenalty_id" INTEGER NOT NULL,
 "seconds" INTEGER NOT NULL DEFAULT 0,
 "maxp_sign" queuepenaltychange_sign,
 "maxp_value" INTEGER,
 "minp_sign" queuepenaltychange_sign,
 "minp_value" INTEGER,
 PRIMARY KEY("queuepenalty_id", "seconds")
);


DROP TABLE IF EXISTS "rightcall" CASCADE;
CREATE TABLE "rightcall" (
 "id" SERIAL,
 "name" VARCHAR(128) NOT NULL DEFAULT '',
 "passwd" VARCHAR(40) NOT NULL DEFAULT '',
 "authorization" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "rightcall__uidx__name" ON "rightcall"("name");


DROP TABLE IF EXISTS "rightcallexten" CASCADE;
CREATE TABLE "rightcallexten" (
 "id" SERIAL,
 "rightcallid" INTEGER NOT NULL DEFAULT 0,
 "exten" VARCHAR(40) NOT NULL DEFAULT '',
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "rightcallexten__uidx__rightcallid_exten" ON "rightcallexten"("rightcallid","exten");


DROP TABLE IF EXISTS "rightcallmember" CASCADE;
DROP TYPE  IF EXISTS "rightcallmember_type";

CREATE TYPE "rightcallmember_type" AS ENUM ('user', 'group', 'incall', 'outcall');

CREATE TABLE "rightcallmember" (
 "id" SERIAL,
 "rightcallid" INTEGER NOT NULL DEFAULT 0,
 "type" rightcallmember_type NOT NULL,
 "typeval" VARCHAR(128) NOT NULL DEFAULT 0,
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "rightcallmember__uidx__rightcallid_type_typeval" ON "rightcallmember"("rightcallid","type","typeval");


DROP TABLE IF EXISTS "schedule" CASCADE;
CREATE TABLE "schedule" (
 "id" SERIAL,
 "name" VARCHAR(255) NOT NULL DEFAULT '',
 "timezone" VARCHAR(128) DEFAULT NULL::character varying,
 "fallback_action"  dialaction_action NOT NULL DEFAULT 'none',
 "fallback_actionid"   VARCHAR(255) DEFAULT NULL::character varying,
 "fallback_actionargs" VARCHAR(255) DEFAULT NULL::character varying,
 "description" TEXT,
 "commented"   INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 PRIMARY KEY("id")
);


DROP TABLE IF EXISTS "schedule_path" CASCADE;
DROP TYPE  IF EXISTS "schedule_path_type";

CREATE TYPE "schedule_path_type" AS ENUM ('user','group','queue','incall','outcall','voicemenu');
CREATE TABLE "schedule_path" (
 "schedule_id"   INTEGER NOT NULL,

 "path"  schedule_path_type NOT NULL,
 "pathid" INTEGER,
 "order" INTEGER NOT NULL,
 PRIMARY KEY("schedule_id","path","pathid")
);

CREATE INDEX "schedule_path_path" ON "schedule_path"("path","pathid");


DROP TABLE IF EXISTS "schedule_time" CASCADE;
DROP TYPE  IF EXISTS  "schedule_time_mode";

CREATE TYPE "schedule_time_mode" AS ENUM ('opened','closed');
CREATE TABLE "schedule_time" (
 "id" SERIAL,
 "schedule_id" INTEGER,
 "mode" schedule_time_mode NOT NULL DEFAULT 'opened',
 "hours"    VARCHAR(512) DEFAULT NULL::character varying,
 "weekdays" VARCHAR(512) DEFAULT NULL::character varying,
 "monthdays"   VARCHAR(512) DEFAULT NULL::character varying,
 "months"   VARCHAR(512) DEFAULT NULL::character varying,
 -- only when mode == 'closed'
 "action"   dialaction_action,
 "actionid" VARCHAR(255) DEFAULT NULL::character varying,
 "actionargs"  VARCHAR(255) DEFAULT NULL::character varying,

 "commented"   INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 PRIMARY KEY("id")
);

CREATE INDEX "schedule_time__idx__scheduleid_commented" ON "schedule_time"("schedule_id","commented");


DROP TABLE IF EXISTS "serverfeatures" CASCADE;
DROP TYPE  IF EXISTS "serverfeatures_feature";
DROP TYPE  IF EXISTS "serverfeatures_type";

CREATE TYPE "serverfeatures_feature" AS ENUM ('phonebook');
CREATE TYPE "serverfeatures_type" AS ENUM ('xivo', 'ldap');

CREATE TABLE "serverfeatures" (
 "id" SERIAL,
 "serverid" INTEGER NOT NULL,
 "feature" serverfeatures_feature NOT NULL,
 "type" serverfeatures_type NOT NULL,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "serverfeatures__uidx__serverid_feature_type" ON "serverfeatures"("serverid","feature","type");


DROP TABLE IF EXISTS "staticiax" CASCADE;
CREATE TABLE "staticiax" (
 "id" SERIAL,
 "cat_metric" INTEGER NOT NULL DEFAULT 0,
 "var_metric" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "filename" VARCHAR(128) NOT NULL,
 "category" VARCHAR(128) NOT NULL,
 "var_name" VARCHAR(128) NOT NULL,
 "var_val" VARCHAR(255),
 PRIMARY KEY("id")
);

CREATE INDEX "staticiax__idx__category" ON "staticiax"("category");

INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','bindport',4569);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','bindaddr','0.0.0.0');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','iaxthreadcount',10);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','iaxmaxthreadcount',100);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','iaxcompat','no');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','authdebug','yes');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','delayreject','no');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','trunkfreq',20);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','trunktimestamps','yes');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,1,'iax.conf','general','regcontext',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','minregexpire',60);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','maxregexpire',60);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','bandwidth','high');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,1,'iax.conf','general','tos',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','jitterbuffer','no');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','forcejitterbuffer','no');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','maxjitterbuffer',1000);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','maxjitterinterps',10);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','resyncthreshold',1000);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,1,'iax.conf','general','accountcode',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','amaflags','default');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','adsi','no');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','transfer','yes');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','language','fr_FR');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','mohinterpret','default');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,1,'iax.conf','general','mohsuggest',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','encryption','no');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','maxauthreq',3);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','codecpriority','host');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,1,'iax.conf','general','disallow',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,1,'iax.conf','general','allow',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','rtcachefriends','yes');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','rtupdate','yes');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','rtignoreregexpire','yes');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','rtautoclear','no');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','pingtime',20);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','lagrqtime',10);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','nochecksums','no');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','autokill','yes');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','calltokenoptional','0.0.0.0');
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','srvlookup',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','jittertargetextra',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','forceencryption',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','trunkmaxsize',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','trunkmtu',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','cos',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','allowfwdownload',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','parkinglot',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','maxcallnumbers',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','maxcallnumbers_nonvalidated',NULL);
INSERT INTO "staticiax" VALUES (DEFAULT,0,0,0,'iax.conf','general','shrinkcallerid',NULL);


DROP TABLE IF EXISTS "staticmeetme" CASCADE;
CREATE TABLE "staticmeetme" (
 "id" SERIAL,
 "cat_metric" INTEGER NOT NULL DEFAULT 0,
 "var_metric" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "filename" VARCHAR(128) NOT NULL,
 "category" VARCHAR(128) NOT NULL,
 "var_name" VARCHAR(128) NOT NULL,
 "var_val" VARCHAR(128),
 PRIMARY KEY("id")
);

CREATE INDEX "staticmeetme__idx__category" ON "staticmeetme"("category");

INSERT INTO "staticmeetme" VALUES (DEFAULT,0,0,0,'meetme.conf','general','audiobuffers',32);
INSERT INTO "staticmeetme" VALUES (DEFAULT,0,0,0,'meetme.conf','general','schedule','yes');
INSERT INTO "staticmeetme" VALUES (DEFAULT,0,0,0,'meetme.conf','general','logmembercount','yes');
INSERT INTO "staticmeetme" VALUES (DEFAULT,0,0,0,'meetme.conf','general','fuzzystart',300);
INSERT INTO "staticmeetme" VALUES (DEFAULT,0,0,0,'meetme.conf','general','earlyalert',3600);
INSERT INTO "staticmeetme" VALUES (DEFAULT,0,0,0,'meetme.conf','general','endalert',120);


DROP TABLE IF EXISTS "staticqueue" CASCADE;
CREATE TABLE "staticqueue" (
 "id" SERIAL,
 "cat_metric" INTEGER NOT NULL DEFAULT 0,
 "var_metric" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "filename" VARCHAR(128) NOT NULL,
 "category" VARCHAR(128) NOT NULL,
 "var_name" VARCHAR(128) NOT NULL,
 "var_val" VARCHAR(128),
 PRIMARY KEY("id")
);

CREATE INDEX "staticqueue__idx__category" ON "staticqueue"("category");

INSERT INTO "staticqueue" VALUES (DEFAULT,0,0,0,'queues.conf','general','persistentmembers','yes');
INSERT INTO "staticqueue" VALUES (DEFAULT,0,0,0,'queues.conf','general','autofill','no');
INSERT INTO "staticqueue" VALUES (DEFAULT,0,0,0,'queues.conf','general','monitor-type','no');
INSERT INTO "staticqueue" VALUES (DEFAULT,0,0,0,'queues.conf','general','updatecdr','no');
INSERT INTO "staticqueue" VALUES (DEFAULT,0,0,0,'queues.conf','general','shared_lastcall','no');


DROP TABLE IF EXISTS "staticsip" CASCADE;
CREATE TABLE "staticsip" (
 "id" SERIAL,
 "cat_metric" INTEGER NOT NULL DEFAULT 0,
 "var_metric" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "filename" VARCHAR(128) NOT NULL,
 "category" VARCHAR(128) NOT NULL,
 "var_name" VARCHAR(128) NOT NULL,
 "var_val" VARCHAR(255),
 PRIMARY KEY("id")
);

CREATE INDEX "staticsip__idx__category" ON "staticsip"("category");

INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','bindport',5060);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','autocreatepeer','persist');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','autocreate_context','xivo-initconfig');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','autocreate_type','friend');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','allowguest','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','allowsubscribe','yes');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','allowoverlap','yes');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','promiscredir','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','autodomain','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','domain',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','allowexternaldomains','yes');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','usereqphone','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','realm','xivo');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','alwaysauthreject','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','useragent','XiVO PBX');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','buggymwi','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','regcontext',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','callerid','xivo');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','fromdomain',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','sipdebug','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','dumphistory','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','recordhistory','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','callevents','yes');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','tos_sip',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','tos_audio',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','tos_video',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','t38pt_udptl','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','t38pt_usertpsource','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','localnet',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','externip',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','externhost',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','externrefresh',10);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','matchexterniplocally','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','outboundproxy',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','g726nonstandard','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','disallow',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','allow',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','t1min',100);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','relaxdtmf','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','rfc2833compensate','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','compactheaders','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','rtptimeout',0);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','rtpholdtimeout',0);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','rtpkeepalive',0);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','directrtpsetup','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','notifymimetype','application/simple-message-summary');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','srvlookup','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','pedantic','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','minexpiry',60);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','maxexpiry',3600);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','defaultexpiry',120);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','registertimeout',20);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','registerattempts',0);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','notifyringing','yes');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','notifyhold','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','allowtransfer','yes');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','maxcallbitrate',384);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','autoframing','yes');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','jbenable','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','jbforce','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','jbmaxsize',200);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','jbresyncthreshold',1000);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','jbimpl','fixed');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','jblog','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','context',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','nat','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','dtmfmode','info');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','qualify','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','useclientcode','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','progressinband','never');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','language','fr_FR');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','mohinterpret','default');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','mohsuggest',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','vmexten','*98');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','trustrpid','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','sendrpid','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','insecure','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','rtcachefriends','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','rtupdate','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','ignoreregexpire','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','rtsavesysname','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','rtautoclear','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,1,'sip.conf','general','subscribecontext',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','match_auth_username','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','udpbindaddr','0.0.0.0');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tcpenable','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tcpbindaddr',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tlsenable','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tlsbindaddr',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tlscertfile',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tlscafile',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tlscadir','/var/lib/asterisk/certs/cadir');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tlsdontverifyserver','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tlscipher',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','tos_text',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','cos_sip',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','cos_audio',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','cos_video',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','cos_text',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','mwiexpiry',3600);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','qualifyfreq',60);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','qualifygap',100);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','qualifypeers',1);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','parkinglot',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','permaturemedia',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','sdpsession',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','sdpowner',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','authfailureevents','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','dynamic_exclude_static','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','contactdeny',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','contactpermit',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','shrinkcallerid','yes');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','regextenonqualify','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','timer1',500);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','timerb',32000);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','session-timers',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','session-expires',600);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','session-minse',90);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','session-refresher','uas');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','hash_users',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','hash_peers',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','hash_dialogs',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','notifycid','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','callcounter','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','stunaddr',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','directmedia','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','ignoresdpversion','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','jbtargetextra',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','encryption','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','externtcpport',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','externtlsport',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','media_address',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','use_q850_reason','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','snom_aoc_enabled','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','subscribe_network_change_event','yes');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','maxforwards',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','disallowed_methods',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','domainsasrealm',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','textsupport',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','videosupport',NULL);
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','auth_options_requests','no');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','transport','udp');
INSERT INTO "staticsip" VALUES (DEFAULT,0,0,0,'sip.conf','general','prematuremedia','no');


DROP TABLE IF EXISTS "staticvoicemail" CASCADE;
CREATE TABLE "staticvoicemail" (
 "id" SERIAL,
 "cat_metric" INTEGER NOT NULL DEFAULT 0,
 "var_metric" INTEGER NOT NULL DEFAULT 0,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "filename" VARCHAR(128) NOT NULL,
 "category" VARCHAR(128) NOT NULL,
 "var_name" VARCHAR(128) NOT NULL,
 "var_val" text,
 PRIMARY KEY("id")
);

CREATE INDEX "staticvoicemail__idx__category" ON "staticvoicemail"("category");

INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','maxmsg',100);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','silencethreshold',256);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','minsecs',0);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','maxsecs',0);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','maxsilence',15);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','review','yes');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','operator','yes');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','format','wav');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','maxlogins',3);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','envelope','yes');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','saycid','no');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','cidinternalcontexts',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','sayduration','yes');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','saydurationm',2);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','forcename','no');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','forcegreetings','no');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','tempgreetwarn','yes');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','maxgreet',0);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','skipms',3000);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','sendvoicemail','no');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','usedirectory','yes');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','nextaftercmd','yes');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','dialout',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','callback',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','exitcontext',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','attach','yes');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','volgain',0);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','mailcmd','/usr/sbin/sendmail -t');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','serveremail','xivo');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','charset','UTF-8');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','fromstring','XiVO PBX');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','emaildateformat','%Y-%m-%d à %H:%M:%S');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','pbxskip','no');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','emailsubject','Messagerie XiVO');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','emailbody',E'Bonjour ${VM_NAME},\n\nVous avez reçu un message d''une durée de ${VM_DUR} minute(s), il vous reste actuellement ${VM_MSGNUM} message(s) non lu(s) sur votre messagerie vocale : ${VM_MAILBOX}.\n\nLe dernier a été envoyé par ${VM_CALLERID}, le ${VM_DATE}. Si vous le souhaitez vous pouvez l''écouter ou le consulter en tapant le *98 sur votre téléphone.\n\nMerci.\n\n-- Messagerie XiVO --');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','pagerfromstring','XiVO PBX');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','pagersubject',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','pagerbody',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','adsifdn','0000000F');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','adsisec','9BDBF7AC');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','adsiver',1);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','searchcontexts','no');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,0,'voicemail.conf','general','externpass','/usr/share/asterisk/bin/change-pass-vm');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','externnotify',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','smdiport',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','odbcstorage',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','odbctable',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,1,0,0,'voicemail.conf','zonemessages','eu-fr','Europe/Paris|''vm-received'' q ''digits/at'' kM');
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','moveheard',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','forward_urgent_auto',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','userscontext',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','smdienable',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','externpassnotify',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','externpasscheck',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','directoryinfo',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','pollmailboxes',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','pollfreq',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','imapgreetings',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','greetingsfolder',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','imapparentfolder',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','tz',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','hidefromdir',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','messagewrap',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','minpassword',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','vm-password',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','vm-newpassword',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','vm-passchanged',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','vm-reenterpassword',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','vm-mismatch',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','vm-invalid-password',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','vm-pls-try-again',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','listen-control-forward-key',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','listen-control-reverse-key',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','listen-control-pause-key',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','listen-control-restart-key',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','listen-control-stop-key',NULL);
INSERT INTO "staticvoicemail" VALUES (DEFAULT,0,0,1,'voicemail.conf','general','backupdeleted',NULL);

DROP TABLE IF EXISTS "trunkfeatures" CASCADE;
CREATE TABLE "trunkfeatures" (
 "id" SERIAL,
 "protocol" "trunk_protocol" NOT NULL,
 "protocolid" INTEGER NOT NULL,
 "registerid" INTEGER NOT NULL DEFAULT 0,
 "registercommented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

CREATE INDEX "trunkfeatures__idx__registerid" ON "trunkfeatures"("registerid");
CREATE INDEX "trunkfeatures__idx__registercommented" ON "trunkfeatures"("registercommented");
CREATE UNIQUE INDEX "trunkfeatures__uidx__protocol_protocolid" ON "trunkfeatures"("protocol","protocolid");


DROP TABLE IF EXISTS "usercustom" CASCADE;
DROP TYPE  IF EXISTS "usercustom_category";

CREATE TYPE "usercustom_category" AS ENUM ('user', 'trunk');

CREATE TABLE "usercustom" (
 "id" SERIAL,
 "name" VARCHAR(40),
 "context" VARCHAR(39),
 "interface" VARCHAR(128) NOT NULL,
 "intfsuffix" VARCHAR(32) NOT NULL DEFAULT '',
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "protocol" "trunk_protocol" NOT NULL DEFAULT 'custom',
 "category" usercustom_category NOT NULL,
 PRIMARY KEY("id")
);

CREATE INDEX "usercustom__idx__name" ON "usercustom"("name");
CREATE INDEX "usercustom__idx__context" ON "usercustom"("context");
CREATE INDEX "usercustom__idx__category" ON "usercustom"("category");
CREATE UNIQUE INDEX "usercustom__uidx__interface_intfsuffix_category" ON "usercustom"("interface","intfsuffix","category");


DROP TABLE IF EXISTS "userfeatures" CASCADE;
DROP TYPE  IF EXISTS "userfeatures_voicemailtype";

CREATE TYPE "userfeatures_voicemailtype" AS ENUM ('asterisk', 'exchange');

CREATE TABLE "userfeatures" (
 "id" SERIAL,
 "firstname" VARCHAR(128) NOT NULL DEFAULT '',
 "lastname" VARCHAR(128) NOT NULL DEFAULT '',
 "voicemailtype" userfeatures_voicemailtype,
 "voicemailid" INTEGER,
 "agentid" INTEGER,
 "pictureid" INTEGER,
 "entityid" INTEGER,
 "callerid" VARCHAR(160),
 "ringseconds" INTEGER NOT NULL DEFAULT 30,
 "simultcalls" INTEGER NOT NULL DEFAULT 5,
 "enableclient" INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "loginclient" VARCHAR(64) NOT NULL DEFAULT '',
 "passwdclient" VARCHAR(64) NOT NULL DEFAULT '',
 "cti_profile_id" INTEGER REFERENCES cti_profile("id") ON DELETE RESTRICT,
 "enablehint" INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "enablevoicemail" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "enablexfer" INTEGER NOT NULL DEFAULT 1, -- BOOLEAN
 "enableautomon" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "callrecord" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "incallfilter" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "enablednd" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "enableunc" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "destunc" VARCHAR(128) NOT NULL DEFAULT '',
 "enablerna" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "destrna" VARCHAR(128) NOT NULL DEFAULT '',
 "enablebusy" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "destbusy" VARCHAR(128) NOT NULL DEFAULT '',
 "musiconhold" VARCHAR(128) NOT NULL DEFAULT '',
 "outcallerid" VARCHAR(80) NOT NULL DEFAULT '',
 "mobilephonenumber" VARCHAR(128) NOT NULL DEFAULT '',
 "userfield" VARCHAR(128) NOT NULL DEFAULT '',
 "bsfilter" generic_bsfilter NOT NULL DEFAULT 'no',
 "preprocess_subroutine" VARCHAR(39),
 "timezone" VARCHAR(128),
 "language" VARCHAR(20),
 "ringintern" VARCHAR(64),
 "ringextern" VARCHAR(64),
 "ringgroup" VARCHAR(64),
 "ringforward" VARCHAR(64),
 "rightcallcode" VARCHAR(16),
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

CREATE INDEX "userfeatures__idx__firstname" ON "userfeatures"("firstname");
CREATE INDEX "userfeatures__idx__lastname" ON "userfeatures"("lastname");
CREATE INDEX "userfeatures__idx__voicemailid" ON "userfeatures"("voicemailid");
CREATE INDEX "userfeatures__idx__entityid" ON "userfeatures"("entityid");
CREATE INDEX "userfeatures__idx__agentid" ON "userfeatures"("agentid");
CREATE INDEX "userfeatures__idx__loginclient" ON "userfeatures"("loginclient");
CREATE INDEX "userfeatures__idx__musiconhold" ON "userfeatures"("musiconhold");


DROP TABLE IF EXISTS "useriax" CASCADE;
DROP TABLE IF EXISTS "usersip" CASCADE;
DROP TYPE  IF EXISTS "useriax_type";
DROP TYPE  IF EXISTS "useriax_amaflags";
DROP TYPE  IF EXISTS "useriax_auth";
DROP TYPE  IF EXISTS "useriax_encryption";
DROP TYPE  IF EXISTS "useriax_transfer";
DROP TYPE  IF EXISTS "useriax_codecpriority";
DROP TYPE  IF EXISTS "useriax_protocol";
DROP TYPE  IF EXISTS "useriax_category";

-- WARNING: used also in usersip table
CREATE TYPE "useriax_type" AS ENUM ('friend', 'peer', 'user');
-- WARNING: used also in usersip table
CREATE TYPE "useriax_amaflags" AS ENUM ('default', 'omit', 'billing', 'documentation');
CREATE TYPE "useriax_auth" AS ENUM ('plaintext', 'md5', 'rsa', 'plaintext,md5', 'plaintext,rsa', 'md5,rsa', 'plaintext,md5,rsa');
CREATE TYPE "useriax_encryption" AS ENUM ('no', 'yes', 'aes128');
CREATE TYPE "useriax_transfer" AS ENUM ('no', 'yes', 'mediaonly');
CREATE TYPE "useriax_codecpriority" AS ENUM ('disabled', 'host', 'caller', 'reqonly');
CREATE TYPE "useriax_protocol" AS ENUM ('iax');
-- WARNING: used also in usersip table
CREATE TYPE "useriax_category" AS ENUM ('user', 'trunk');

CREATE TABLE "useriax" (
 "id" SERIAL,
 "name" VARCHAR(40) NOT NULL, -- user / peer --
 "type" useriax_type NOT NULL, -- user / peer --
 "username" VARCHAR(80), -- peer --
 "secret" VARCHAR(80) NOT NULL DEFAULT '', -- peer / user --
 "dbsecret" VARCHAR(255) NOT NULL DEFAULT '', -- peer / user --
 "context" VARCHAR(39), -- peer / user --
 "language" VARCHAR(20), -- general / user --
 "accountcode" VARCHAR(20), -- general / user --
 "amaflags" useriax_amaflags DEFAULT 'default', -- general / user --
 "mailbox" VARCHAR(80), -- peer --
 "callerid" VARCHAR(160), -- user / peer --
 "fullname" VARCHAR(80), -- user / peer --
 "cid_number" VARCHAR(80), -- user / peer --
 "trunk" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN -- user / peer --
 "auth" useriax_auth NOT NULL DEFAULT 'plaintext,md5', -- user / peer --
 "encryption" useriax_encryption, -- user / peer --
 "forceencryption" useriax_encryption,
 "maxauthreq" INTEGER, -- general / user --
 "inkeys" VARCHAR(80), -- user / peer --
 "outkey" VARCHAR(80), -- peer --
 "adsi" INTEGER, -- BOOLEAN -- general / user / peer --
 "transfer" useriax_transfer, -- general / user / peer --
 "codecpriority" useriax_codecpriority, -- general / user --
 "jitterbuffer" INTEGER, -- BOOLEAN -- general / user / peer --
 "forcejitterbuffer" INTEGER, -- BOOLEAN -- general / user / peer --
 "sendani" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN -- peer --
 "qualify" VARCHAR(4) NOT NULL DEFAULT 'no', -- peer --
 "qualifysmoothing" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN -- peer --
 "qualifyfreqok" INTEGER NOT NULL DEFAULT 60000, -- peer --
 "qualifyfreqnotok" INTEGER NOT NULL DEFAULT 10000, -- peer --
 "timezone" VARCHAR(80), -- peer --
 "disallow" VARCHAR(100), -- general / user / peer --
 "allow" text, -- general / user / peer --
 "mohinterpret" VARCHAR(80), -- general / user / peer --
 "mohsuggest" VARCHAR(80), -- general / user / peer --
 "deny" VARCHAR(31), -- user / peer --
 "permit" VARCHAR(31), -- user / peer --
 "defaultip" VARCHAR(255), -- peer --
 "sourceaddress" VARCHAR(255), -- peer --
 "setvar" VARCHAR(100) NOT NULL DEFAULT '', -- user --
 "host" VARCHAR(255) NOT NULL DEFAULT 'dynamic', -- peer --
 "port" INTEGER, -- peer --
 "mask" VARCHAR(15), -- peer --
 "regexten" VARCHAR(80), -- peer --
 "peercontext" VARCHAR(80), -- peer --
 "ipaddr" VARCHAR(255) NOT NULL DEFAULT '',
 "regseconds" INTEGER NOT NULL DEFAULT 0,
 "immediate" INTEGER, -- BOOLEAN
 "keyrotate" INTEGER, -- BOOLEAN
 "parkinglot" INTEGER,
 "protocol" "trunk_protocol" NOT NULL DEFAULT 'iax',
 "category" useriax_category NOT NULL,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "requirecalltoken" VARCHAR(4) NOT NULL DEFAULT 'no', -- peer--
 PRIMARY KEY("id")
);

CREATE INDEX "useriax__idx__mailbox" ON "useriax"("mailbox");
CREATE INDEX "useriax__idx__category" ON "useriax"("category");
CREATE UNIQUE INDEX "useriax__uidx__name" ON "useriax"("name");


DROP TABLE IF EXISTS "usersip" CASCADE;
DROP TYPE  IF EXISTS "usersip_insecure";
DROP TYPE  IF EXISTS "usersip_nat";
DROP TYPE  IF EXISTS "usersip_videosupport";
DROP TYPE  IF EXISTS "usersip_dtmfmode";
DROP TYPE  IF EXISTS "usersip_progressinband";
DROP TYPE  IF EXISTS "usersip_protocol";
DROP TYPE  IF EXISTS "usersip_directmedia";
DROP TYPE  IF EXISTS "usersip_session_timers";
DROP TYPE  IF EXISTS "usersip_session_refresher";


CREATE TYPE "usersip_insecure" AS ENUM ('port', 'invite', 'port,invite');
CREATE TYPE "usersip_nat" AS ENUM ('no','force_rport','comedia','force_rport,comedia');
CREATE TYPE "usersip_videosupport" AS ENUM ('no','yes','always');
CREATE TYPE "usersip_dtmfmode" AS ENUM ('rfc2833','inband','info','auto');
CREATE TYPE "usersip_progressinband" AS ENUM ('no','yes','never');
CREATE TYPE "usersip_protocol" AS ENUM ('sip');
CREATE TYPE "usersip_directmedia" AS ENUM ('no','yes','nonat','update','update,nonat');
CREATE TYPE "usersip_session_timers" AS ENUM ('originate','accept','refuse');
CREATE TYPE "usersip_session_refresher" AS ENUM ('uac','uas');

CREATE TABLE "usersip" (
 "id" SERIAL,
 "name" VARCHAR(40) NOT NULL, -- user / peer --
 "type" useriax_type NOT NULL, -- user / peer --
 "username" VARCHAR(80), -- peer --
 "secret" VARCHAR(80) NOT NULL DEFAULT '', -- user / peer --
 "md5secret" VARCHAR(32) NOT NULL DEFAULT '', -- user / peer --
 "context" VARCHAR(39), -- general / user / peer --
 "language" VARCHAR(20), -- general / user / peer --
 "accountcode" VARCHAR(20), -- user / peer --
 "amaflags" useriax_amaflags NOT NULL DEFAULT 'default', -- user / peer --

 "allowtransfer" INTEGER, -- BOOLEAN -- general / user / peer --
 "fromuser" VARCHAR(80), -- peer --
 "fromdomain" VARCHAR(255), -- general / peer --
 "mailbox" VARCHAR(80), -- peer --
 "subscribemwi" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN -- peer --
 "buggymwi" INTEGER, -- BOOLEAN -- general / user / peer --
 "call-limit" INTEGER NOT NULL DEFAULT 0, -- user / peer --
 "callerid" VARCHAR(160), -- general / user / peer --
 "fullname" VARCHAR(80), -- user / peer --
 "cid_number" VARCHAR(80), -- user / peer --
 "maxcallbitrate" INTEGER, -- general / user / peer --
 "insecure" usersip_insecure, -- general / user / peer --
 "nat" usersip_nat, -- general / user / peer --
 "promiscredir" INTEGER, -- BOOLEAN -- general / user / peer --
 "usereqphone" INTEGER, -- BOOLEAN -- general / peer --
 "videosupport" usersip_videosupport, -- general / user / peer --
 "trustrpid" INTEGER, -- BOOLEAN -- general / user / peer --
 "sendrpid" VARCHAR(16),

 "allowsubscribe" INTEGER, -- BOOLEAN -- general / user / peer --
 "allowoverlap" INTEGER, -- BOOLEAN -- general / user / peer --
 "dtmfmode" usersip_dtmfmode, -- general / user / peer --
 "rfc2833compensate" INTEGER, -- BOOLEAN -- general / user / peer --
 "qualify" VARCHAR(4), -- general / peer --
 "g726nonstandard" INTEGER, -- BOOLEAN -- general / user / peer --
 "disallow" VARCHAR(100), -- general / user / peer --
 "allow" text, -- general / user / peer --
 "autoframing" INTEGER, -- BOOLEAN -- general / user / peer --
 "mohinterpret" VARCHAR(80), -- general / user / peer --
 "mohsuggest" VARCHAR(80), -- general / user / peer --
 "useclientcode" INTEGER, -- BOOLEAN -- general / user / peer --
 "progressinband" usersip_progressinband, -- general / user / peer --

 "t38pt_udptl" INTEGER, -- BOOLEAN -- general / user / peer --
 "t38pt_usertpsource" INTEGER, -- BOOLEAN -- general / user / peer --
 "rtptimeout" INTEGER, -- general / peer --
 "rtpholdtimeout" INTEGER, -- general / peer --
 "rtpkeepalive" INTEGER, -- general / peer --
 "deny" VARCHAR(31), -- user / peer --
 "permit" VARCHAR(31), -- user / peer --
 "defaultip" VARCHAR(255), -- peer --

 "setvar" VARCHAR(100) NOT NULL DEFAULT '', -- user / peer --
 "host" VARCHAR(255) NOT NULL DEFAULT 'dynamic', -- peer --
 "port" INTEGER, -- peer --
 "regexten" VARCHAR(80), -- peer --
 "subscribecontext" VARCHAR(80), -- general / user / peer --
 "fullcontact" VARCHAR(255), -- peer --
 "vmexten" VARCHAR(40), -- general / peer --
 "callingpres" INTEGER, -- BOOLEAN -- user / peer --
 "ipaddr" VARCHAR(255) NOT NULL DEFAULT '',
 "regseconds" INTEGER NOT NULL DEFAULT 0,
 "regserver" VARCHAR(20),
 "lastms" VARCHAR(15) NOT NULL DEFAULT '',
 "parkinglot" INTEGER,
 "protocol" "trunk_protocol" NOT NULL DEFAULT 'sip',
 "category" useriax_category NOT NULL,

 "outboundproxy" VARCHAR(1024),
	-- asterisk 1.8 new values
 "transport" VARCHAR(255) DEFAULT NULL::character varying,
 "remotesecret" VARCHAR(255) DEFAULT NULL::character varying,
 "directmedia" usersip_directmedia,
 "callcounter" INTEGER, -- BOOLEAN
 "busylevel" INTEGER,
 "ignoresdpversion" INTEGER, -- BOOLEAN
 "session-timers" usersip_session_timers,
 "session-expires" INTEGER,
 "session-minse" INTEGER,
 "session-refresher" usersip_session_refresher,
 "callbackextension" VARCHAR(255) DEFAULT NULL::character varying,
 "registertrying" INTEGER, -- BOOLEAN
 "timert1" INTEGER,
 "timerb" INTEGER,
 
 "qualifyfreq" INTEGER,
 "contactpermit" VARCHAR(1024) DEFAULT NULL::character varying,
 "contactdeny" VARCHAR(1024) DEFAULT NULL::character varying,
 "unsolicited_mailbox" VARCHAR(1024) DEFAULT NULL::character varying,
 "use_q850_reason" INTEGER, -- BOOLEAN
 "encryption" INTEGER, -- BOOLEAN
 "snom_aoc_enabled" INTEGER, -- BOOLEAN
 "maxforwards" INTEGER,
 "disallowed_methods" VARCHAR(1024) DEFAULT NULL::character varying,
 "textsupport" INTEGER, -- BOOLEAN
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN -- user / peer --
 PRIMARY KEY("id")
);

CREATE INDEX "usersip__idx__mailbox" ON "usersip"("mailbox");
CREATE INDEX "usersip__idx__category" ON "usersip"("category");
CREATE UNIQUE INDEX "usersip__uidx__name" ON "usersip"("name");


DROP VIEW IF EXISTS "user_line" CASCADE;
CREATE TABLE "user_line" (
 "id" SERIAL,
 "user_id" INTEGER,
 "line_id" INTEGER NOT NULL,
 "extension_id" INTEGER,
 "main_user" boolean NOT NULL,
 "main_line" boolean NOT NULL,
 CONSTRAINT "user_line__userfeatures_id_fkey" FOREIGN KEY ("user_id")
     REFERENCES "userfeatures" (id) MATCH SIMPLE,
 CONSTRAINT "user_line__linefeatures_id_fkey" FOREIGN KEY ("line_id")
     REFERENCES "linefeatures" (id) MATCH SIMPLE,
 CONSTRAINT "user_line__extensions_id_fkey" FOREIGN KEY ("extension_id")
     REFERENCES "extensions" (id) MATCH SIMPLE,
 PRIMARY KEY("id", "line_id")
);

CREATE UNIQUE INDEX "user_line_extension__uidx__user_id_line_id" ON "user_line"("user_id","line_id");


DROP TABLE IF EXISTS "voicemail" CASCADE;
DROP TYPE  IF EXISTS "voicemail_hidefromdir";
DROP TYPE  IF EXISTS "voicemail_passwordlocation";

CREATE TYPE "voicemail_hidefromdir" AS ENUM ('no','yes');
CREATE TYPE "voicemail_passwordlocation" AS ENUM ('spooldir','voicemail');

CREATE TABLE "voicemail" (
 "uniqueid" SERIAL,
 "context" VARCHAR(39) NOT NULL,
 "mailbox" VARCHAR(40) NOT NULL,
 "password" VARCHAR(80) NOT NULL DEFAULT '',
 "fullname" VARCHAR(80) NOT NULL DEFAULT '',
 "email" VARCHAR(80),
 "pager" VARCHAR(80),
 "dialout" VARCHAR(39),
 "callback" VARCHAR(39),
 "exitcontext" VARCHAR(39),
 "language" VARCHAR(20),
 "tz" VARCHAR(80),
 "attach" INTEGER, -- BOOLEAN
 "saycid" INTEGER, -- BOOLEAN
 "review" INTEGER, -- BOOLEAN
 "operator" INTEGER, -- BOOLEAN
 "envelope" INTEGER, -- BOOLEAN
 "sayduration" INTEGER, -- BOOLEAN
 "saydurationm" INTEGER,
 "sendvoicemail" INTEGER, -- BOOLEAN
 "deletevoicemail" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "forcename" INTEGER, -- BOOLEAN
 "forcegreetings" INTEGER, -- BOOLEAN
 "hidefromdir" voicemail_hidefromdir NOT NULL DEFAULT 'no',
 "maxmsg" INTEGER,
 "emailsubject" VARCHAR(1024),
 "emailbody" text,
 "imapuser" VARCHAR(1024),
 "imappassword" VARCHAR(1024),
 "imapfolder" VARCHAR(1024),
 "imapvmsharedid" VARCHAR(1024),
 "attachfmt" VARCHAR(1024),
 "serveremail" VARCHAR(1024),
 "locale" VARCHAR(1024),
 "tempgreetwarn" INTEGER, -- BOOLEAN
 "messagewrap" INTEGER, -- BOOLEAN
 "moveheard" INTEGER, -- BOOLEAN
 "minsecs" INTEGER,
 "maxsecs" INTEGER,
 "nextaftercmd" INTEGER, -- BOOLEAN
 "backupdeleted" INTEGER,
 "volgain" float,
 "passwordlocation" voicemail_passwordlocation,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "skipcheckpass" integer NOT NULL DEFAULT 0,
 PRIMARY KEY("uniqueid")
);

CREATE INDEX "voicemail__idx__context" ON "voicemail"("context");
CREATE UNIQUE INDEX "voicemail__uidx__mailbox_context" ON "voicemail"("mailbox","context");


DROP TABLE IF EXISTS "voicemenu" CASCADE;
CREATE TABLE "voicemenu" (
 "id" SERIAL,
 "name" VARCHAR(29) NOT NULL DEFAULT '',
 "number" VARCHAR(40) NOT NULL,
 "context" VARCHAR(39) NOT NULL,
 "commented" INTEGER NOT NULL DEFAULT 0, -- BOOLEAN
 "description" text NOT NULL,
 PRIMARY KEY("id")
);

CREATE INDEX "voicemenu__idx__number" ON "voicemenu"("number");
CREATE INDEX "voicemenu__idx__context" ON "voicemenu"("context");
CREATE UNIQUE INDEX "voicemenu__uidx__name" ON "voicemenu"("name");


-- queueskill categories
DROP TABLE IF EXISTS "queueskillcat" CASCADE;
CREATE TABLE "queueskillcat" (
 "id" SERIAL,
 "name" VARCHAR(64) NOT NULL DEFAULT '',
 PRIMARY KEY("id")
);

CREATE UNIQUE INDEX "queueskillcat__uidx__name" ON "queueskillcat"("name");


-- queueskill values
DROP TABLE IF EXISTS "queueskill" CASCADE;
CREATE TABLE "queueskill" (
 "id" SERIAL,
 "catid" INTEGER NOT NULL DEFAULT 1,
 "name" VARCHAR(64) NOT NULL DEFAULT '',
 "description" text,
 "printscreen" VARCHAR(5),
 PRIMARY KEY("id")
);

CREATE INDEX "queueskill__idx__catid" ON "queueskill"("catid");
CREATE UNIQUE INDEX "queueskill__uidx__name" ON "queueskill"("name");


-- queueskill rules;
DROP TABLE IF EXISTS "queueskillrule" CASCADE;
CREATE TABLE "queueskillrule" (
 "id" SERIAL,
 "name" VARCHAR(64) NOT NULL DEFAULT '',
 "rule" text,
 PRIMARY KEY("id")
);


DROP TABLE IF EXISTS "general" CASCADE;
CREATE TABLE "general"
(
 "id" SERIAL,
 "timezone"         VARCHAR(128),
 "exchange_trunkid" INTEGER,
 "exchange_exten"   VARCHAR(128) DEFAULT NULL::character varying,
 "dundi"            INTEGER NOT NULL DEFAULT 0, -- boolean
 PRIMARY KEY("id")
);

INSERT INTO "general" VALUES (DEFAULT, 'Europe/Paris', NULL, NULL, 0);


DROP TABLE IF EXISTS "sipauthentication" CASCADE;
DROP TYPE  IF EXISTS "sipauthentication_secretmode";

CREATE TYPE "sipauthentication_secretmode" AS ENUM ('md5','clear');
CREATE TABLE "sipauthentication"
(
 "id" SERIAL,
 "usersip_id" INTEGER, -- if NULL, then its a general authentication param
 "user" VARCHAR(255) NOT NULL,
 "secretmode" sipauthentication_secretmode NOT NULL,
 "secret" VARCHAR(255) NOT NULL,
 "realm" VARCHAR(1024) NOT NULL,
 PRIMARY KEY("id")
);

CREATE INDEX "sipauthentication__idx__usersip_id" ON "sipauthentication"("usersip_id");


DROP TABLE IF EXISTS "iaxcallnumberlimits" CASCADE;
CREATE TABLE "iaxcallnumberlimits" (
 "id" SERIAL,
 "destination" VARCHAR(39) NOT NULL,
 "netmask" VARCHAR(39) NOT NULL,
 "calllimits" INTEGER NOT NULL DEFAULT 0,
 PRIMARY KEY("id")
);


DROP TABLE IF EXISTS "queue_log" ;
CREATE TABLE "queue_log" (
 "time" VARCHAR(26) DEFAULT ''::VARCHAR NOT NULL,
 "callid" VARCHAR(32) DEFAULT ''::VARCHAR NOT NULL,
 "queuename" VARCHAR(50) DEFAULT ''::VARCHAR NOT NULL,
 "agent" VARCHAR(50) DEFAULT ''::VARCHAR NOT NULL,
 "event" VARCHAR(20) DEFAULT ''::VARCHAR NOT NULL,
 "data1" VARCHAR(30) DEFAULT ''::VARCHAR,
 "data2" VARCHAR(30) DEFAULT ''::VARCHAR,
 "data3" VARCHAR(30) DEFAULT ''::VARCHAR,
 "data4" VARCHAR(30) DEFAULT ''::VARCHAR,
 "data5" VARCHAR(30) DEFAULT ''::VARCHAR
 );

CREATE INDEX queue_log__idx_time ON queue_log USING btree ("time");
CREATE INDEX queue_log__idx_callid ON queue_log USING btree ("callid");
CREATE INDEX queue_log__idx_queuename ON queue_log USING btree ("queuename");
CREATE INDEX queue_log__idx_event ON queue_log USING btree ("event");
CREATE INDEX queue_log__idx_agent ON queue_log USING btree ("agent");

DROP TYPE IF EXISTS "call_exit_type" CASCADE;
CREATE TYPE "call_exit_type" AS ENUM (
  'full',
  'closed',
  'joinempty',
  'leaveempty',
  'divert_ca_ratio',
  'divert_waittime',
  'answered',
  'abandoned',
  'timeout'
);

DROP TABLE IF EXISTS "stat_agent" CASCADE;
CREATE TABLE "stat_agent" (
 "id" SERIAL PRIMARY KEY,
 "name" VARCHAR(128) NOT NULL
);
CREATE INDEX stat_agent__idx_name ON stat_agent("name");


DROP TABLE IF EXISTS "stat_agent_periodic" CASCADE;
CREATE TABLE "stat_agent_periodic" (
 "id" SERIAL PRIMARY KEY,
 "time" timestamp NOT NULL,
 "login_time" INTERVAL NOT NULL DEFAULT '00:00:00',
 "pause_time" INTERVAL NOT NULL DEFAULT '00:00:00',
 "wrapup_time" INTERVAL NOT NULL DEFAULT '00:00:00',
 "agent_id" INTEGER REFERENCES stat_agent (id)
);

CREATE INDEX "stat_agent_periodic__idx__time" ON "stat_agent_periodic"("time");
CREATE INDEX "stat_agent_periodic__idx__agent_id" ON "stat_agent_periodic"("agent_id");


DROP TABLE IF EXISTS "stat_queue" CASCADE;
CREATE TABLE "stat_queue" (
 "id" SERIAL PRIMARY KEY,
 "name" VARCHAR(128) NOT NULL
);
CREATE INDEX stat_queue__idx_name ON stat_queue("name");

DROP TABLE IF EXISTS "stat_call_on_queue" CASCADE;
CREATE TABLE "stat_call_on_queue" (
 "id" SERIAL PRIMARY KEY,
 "callid" VARCHAR(32) NOT NULL,
 "time" timestamp NOT NULL,
 "ringtime" INTEGER NOT NULL DEFAULT 0,
 "talktime" INTEGER NOT NULL DEFAULT 0,
 "waittime" INTEGER NOT NULL DEFAULT 0,
 "status" call_exit_type NOT NULL,
 "queue_id" INTEGER REFERENCES stat_queue (id),
 "agent_id" INTEGER REFERENCES stat_agent (id)
);

DROP TABLE IF EXISTS "stat_queue_periodic" CASCADE;
CREATE TABLE "stat_queue_periodic" (
 "id" SERIAL PRIMARY KEY,
 "time" timestamp NOT NULL,
 "answered" INTEGER NOT NULL DEFAULT 0,
 "abandoned" INTEGER NOT NULL DEFAULT 0,
 "total" INTEGER NOT NULL DEFAULT 0,
 "full" INTEGER NOT NULL DEFAULT 0,
 "closed" INTEGER NOT NULL DEFAULT 0,
 "joinempty" INTEGER NOT NULL DEFAULT 0,
 "leaveempty" INTEGER NOT NULL DEFAULT 0,
 "divert_ca_ratio" INTEGER NOT NULL DEFAULT 0,
 "divert_waittime" INTEGER NOT NULL DEFAULT 0,
 "timeout" INTEGER NOT NULL DEFAULT 0,
 "queue_id" INTEGER REFERENCES stat_queue (id)
);

DROP TABLE IF EXISTS "pickup" CASCADE;
CREATE TABLE "pickup" (
 -- id is not an autoincrement number, because pickups are between 0 and 63 only
 "id" INTEGER NOT NULL,
 "name" VARCHAR(128) UNIQUE NOT NULL,
 "commented" INTEGER NOT NULL DEFAULT 0,
 "description" TEXT NOT NULL DEFAULT '',
 PRIMARY KEY("id")
);


DROP TABLE IF EXISTS "pickupmember" CASCADE;
DROP TYPE  IF EXISTS "pickup_category" CASCADE;
DROP TYPE  IF EXISTS "pickup_membertype" CASCADE;

CREATE TYPE "pickup_category" AS ENUM ('member','pickup');
CREATE TYPE "pickup_membertype" AS ENUM ('group','queue','user');
CREATE TABLE "pickupmember" (
 "pickupid" INTEGER NOT NULL,
 "category" pickup_category NOT NULL,
 "membertype"  pickup_membertype NOT NULL,
 "memberid" INTEGER NOT NULL,
 PRIMARY KEY("pickupid","category","membertype","memberid")
);


DROP TABLE IF EXISTS "agentglobalparams" CASCADE;
CREATE TABLE "agentglobalparams" (
 "id" SERIAL,
 "category" VARCHAR(128) NOT NULL,
 "option_name" VARCHAR(255) NOT NULL,
 "option_value" VARCHAR(255),
 PRIMARY KEY("id")
);

INSERT INTO "agentglobalparams" VALUES (DEFAULT,'general','multiplelogin','no');
INSERT INTO "agentglobalparams" VALUES (DEFAULT,'general','persistentagents','yes');
INSERT INTO "agentglobalparams" VALUES (DEFAULT,'agents','autologoffunavail','no');
INSERT INTO "agentglobalparams" VALUES (DEFAULT,'agents','maxlogintries','3');
INSERT INTO "agentglobalparams" VALUES (DEFAULT,'agents','endcall','no');


DROP TABLE IF EXISTS "sccpgeneralsettings" CASCADE;
CREATE TABLE "sccpgeneralsettings" (
    "id"                SERIAL,
    "option_name"       varchar(80) NOT NULL,
    "option_value"      varchar(80) NOT NULL,
    PRIMARY KEY("id")
);

INSERT INTO "sccpgeneralsettings" VALUES (DEFAULT, 'directmedia', 'no');
INSERT INTO "sccpgeneralsettings" VALUES (DEFAULT, 'dialtimeout', '5');
INSERT INTO "sccpgeneralsettings" VALUES (DEFAULT, 'keepalive', '10');
INSERT INTO "sccpgeneralsettings" VALUES (DEFAULT, 'language', 'en_US');
INSERT INTO "sccpgeneralsettings" VALUES (DEFAULT, 'allow', '');


DROP TABLE IF EXISTS "sccpline" CASCADE;
CREATE TABLE "sccpline" (
    "id"        SERIAL,
    "name"      varchar(80) NOT NULL,
    "context"   varchar(80) NOT NULL,
    "cid_name"  varchar(80) NOT NULL,
    "cid_num"   varchar(80) NOT NULL,
    "disallow"  varchar(100),
    "allow"     text,
    "protocol" "trunk_protocol" NOT NULL DEFAULT 'sccp',
    "commented" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY("id")
);


DROP TABLE IF EXISTS "sccpdevice" CASCADE;
CREATE TABLE "sccpdevice" (
    "id"        SERIAL,
    "name"      varchar(80) NOT NULL,
    "device"    varchar(80) NOT NULL,
    "line"      varchar(80) NOT NULL DEFAULT '',
    "voicemail" varchar(80) NOT NULL DEFAULT '',
    PRIMARY KEY("id")
);


DROP TYPE IF EXISTS "queue_statistics" CASCADE;
CREATE TYPE "queue_statistics" AS (
    received_call_count bigint,
    answered_call_count bigint,
    answered_call_in_qos_count bigint,
    abandonned_call_count bigint,
    received_and_done bigint,
    max_hold_time integer,
    mean_hold_time integer
);


DROP TABLE IF EXISTS "agent_login_status" CASCADE;
CREATE TABLE "agent_login_status" (
    "agent_id"        INTEGER      PRIMARY KEY,
    "agent_number"    VARCHAR(40)  NOT NULL,
    "extension"       VARCHAR(80)  NOT NULL,
    "context"         VARCHAR(80)  NOT NULL,
    "interface"       VARCHAR(128) NOT NULL UNIQUE,
    "state_interface" VARCHAR(128) NOT NULL,
    "login_at"        TIMESTAMP    NOT NULL DEFAULT NOW(),
    UNIQUE ("extension", "context")
);


DROP TABLE IF EXISTS "agent_membership_status" CASCADE;
CREATE TABLE "agent_membership_status" (
    "agent_id"        INTEGER      NOT NULL,
    "queue_id"        INTEGER      NOT NULL,
    "queue_name"      VARCHAR(128) NOT NULL,
    "penalty"         INTEGER      NOT NULL DEFAULT 0,
    PRIMARY KEY("agent_id", "queue_id")
);

--DDL for recordings: 
DROP TABLE IF EXISTS recording;
DROP TABLE IF EXISTS record_campaign;

CREATE TABLE record_campaign
(
  id serial NOT NULL,
  campaign_name character varying(128) NOT NULL,
  activated boolean NOT NULL,
  base_filename character varying(64) NOT NULL,
  queue_id integer,
  start_date timestamp without time zone,
  end_date timestamp without time zone,
  CONSTRAINT record_campaign_pkey PRIMARY KEY (id ),
  CONSTRAINT record_campaign_queue_id_fkey FOREIGN KEY (queue_id)
      REFERENCES queuefeatures (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT campaign_name_u UNIQUE (campaign_name )
);


CREATE TABLE recording
(
  cid character varying(32) NOT NULL,
  start_time timestamp without time zone,
  end_time timestamp without time zone,
  caller character varying(32),
  client_id character varying(1024),
  callee character varying(32),
  filename character varying(1024),
  campaign_id integer NOT NULL,
  agent_id integer NOT NULL,
  CONSTRAINT recording_pkey PRIMARY KEY (cid ),
  CONSTRAINT recording_agent_id_fkey FOREIGN KEY (agent_id)
      REFERENCES agentfeatures (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT recording_campaign_id_fkey FOREIGN KEY (campaign_id)
      REFERENCES record_campaign (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);



DROP FUNCTION IF EXISTS "fill_answered_calls" (text, text);
CREATE FUNCTION "fill_answered_calls"(period_start text, period_end text)
  RETURNS void AS
$$
  INSERT INTO stat_call_on_queue (callid, "time", talktime, waittime, queue_id, agent_id, status)
  SELECT
    outer_queue_log.callid,
    CAST ((SELECT "time"
           FROM queue_log
           WHERE callid=outer_queue_log.callid AND
                 queuename=outer_queue_log.queuename AND
                 event='ENTERQUEUE' ORDER BY "time" DESC LIMIT 1) AS TIMESTAMP) AS "time",
    CASE WHEN event IN ('COMPLETEAGENT', 'COMPLETECALLER') THEN CAST (data2 AS INTEGER)
         WHEN event = 'TRANSFER' THEN CAST (data4 AS INTEGER) END as talktime,
    CASE WHEN event IN ('COMPLETEAGENT', 'COMPLETECALLER') THEN CAST (data1 AS INTEGER)
         WHEN event = 'TRANSFER' THEN CAST (data3 AS INTEGER) END as waittime,
    stat_queue.id AS queue_id,
    stat_agent.id AS agent_id,
    'answered' AS status
  FROM
    queue_log as outer_queue_log
  LEFT JOIN
    stat_agent ON outer_queue_log.agent = stat_agent.name
  LEFT JOIN
    stat_queue ON outer_queue_log.queuename = stat_queue.name
  WHERE
    callid IN
      (SELECT callid
       FROM queue_log
       WHERE event = 'ENTERQUEUE' AND "time" BETWEEN $1 AND $2)
    AND event IN ('COMPLETEAGENT', 'COMPLETECALLER', 'TRANSFER');
$$
LANGUAGE SQL;

DROP FUNCTION IF EXISTS "fill_simple_calls" (text, text);
CREATE FUNCTION "fill_simple_calls"(period_start text, period_end text)
  RETURNS void AS
$$
  INSERT INTO "stat_call_on_queue" (callid, "time", queue_id, status)
    SELECT
      callid,
      CAST ("time" AS TIMESTAMP) as "time",
      (SELECT id FROM stat_queue WHERE name=queuename) as queue_id,
      CASE WHEN event = 'FULL' THEN 'full'::call_exit_type
           WHEN event = 'DIVERT_CA_RATIO' THEN 'divert_ca_ratio'
           WHEN event = 'DIVERT_HOLDTIME' THEN 'divert_waittime'
           WHEN event = 'CLOSED' THEN 'closed'
           WHEN event = 'JOINEMPTY' THEN 'joinempty'
      END as status
    FROM queue_log
    WHERE event IN ('FULL', 'DIVERT_CA_RATIO', 'DIVERT_HOLDTIME', 'CLOSED', 'JOINEMPTY') AND
          "time" BETWEEN $1 AND $2;
$$
LANGUAGE SQL;

DROP FUNCTION IF EXISTS "fill_leaveempty_calls" (text, text);
CREATE OR REPLACE FUNCTION "fill_leaveempty_calls" (period_start text, period_end text)
  RETURNS void AS
$$
INSERT INTO stat_call_on_queue (callid, time, waittime, queue_id, status)
SELECT
  callid,
  enter_time as time,
  EXTRACT(EPOCH FROM (leave_time - enter_time))::INTEGER as waittime,
  queue_id,
  'leaveempty' AS status
FROM (SELECT
        CAST (time AS TIMESTAMP) AS enter_time,
        (select CAST (time AS TIMESTAMP) from queue_log where callid=main.callid AND event='LEAVEEMPTY' LIMIT 1) AS leave_time,
        callid,
        (SELECT id FROM stat_queue WHERE name=queuename) AS queue_id
      FROM queue_log AS main
      WHERE callid IN (SELECT callid FROM queue_log WHERE event = 'LEAVEEMPTY')
            AND event = 'ENTERQUEUE'
            AND time BETWEEN $1 AND $2) AS first;
$$
LANGUAGE SQL;

DROP FUNCTION IF EXISTS "get_queue_statistics" (text, int, int);
CREATE FUNCTION "get_queue_statistics" (queue_name text, in_window int, xqos int)
  RETURNS "queue_statistics" AS
$$
    SELECT
        -- received_call_count
        count(*),
        -- answered_call_count
        count(case when call_picker <> '' then 1 end),
        -- answered_call_in_qos_count
        count(case when call_picker <> '' and hold_time < $3 then 1 end),
        -- abandonned_call_count
        count(case when hold_time is not null and (call_picker = '' or call_picker is null) then 1 end),
        -- received_and_done
        count(hold_time),
        -- max_hold_time
        max(hold_time),
         -- mean_hold_time
        cast (round(avg(hold_time)) as int)
    FROM
        queue_info
    WHERE
        queue_name = $1 and call_time_t > $2;
$$
LANGUAGE SQL;

DROP FUNCTION IF EXISTS "set_agent_on_pauseall" ();
CREATE FUNCTION "set_agent_on_pauseall" ()
  RETURNS trigger AS
$$
DECLARE
    "number" text;
BEGIN
    SELECT "agent_number" INTO "number" FROM "agent_login_status" WHERE "interface" = NEW."agent";
    IF FOUND THEN
        NEW."agent" := 'Agent/' || "number";
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER "change_queue_log_agent"
    BEFORE INSERT ON "queue_log"
    FOR EACH ROW
    WHEN (NEW."event" = 'PAUSEALL' OR NEW."event" = 'UNPAUSEALL')
    EXECUTE PROCEDURE "set_agent_on_pauseall"();

-- grant all rights to asterisk
GRANT ALL ON ALL TABLES IN SCHEMA public TO asterisk;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO asterisk;

COMMIT;
