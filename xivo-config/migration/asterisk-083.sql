
/*
 * XiVO BASe-Config
 * Copyright (C) 2012  Avencall
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License AS published by
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

BEGIN;

DROP TABLE IF EXISTS "cti_service" CASCADE;
CREATE TABLE "cti_service" (
 "id" SERIAL PRIMARY KEY,
 "key" VARCHAR(255) NOT NULL
);

INSERT INTO "cti_service"("key") VALUES ('enablevm');
INSERT INTO "cti_service"("key") VALUES ('callrecord');
INSERT INTO "cti_service"("key") VALUES ('incallrec');
INSERT INTO "cti_service"("key") VALUES ('incallfilter');
INSERT INTO "cti_service"("key") VALUES ('enablednd');
INSERT INTO "cti_service"("key") VALUES ('fwdunc');
INSERT INTO "cti_service"("key") VALUES ('fwdbusy');
INSERT INTO "cti_service"("key") VALUES ('fwdrna');

DROP TABLE IF EXISTS "cti_preference" CASCADE;
CREATE TABLE "cti_preference" (
 "id" SERIAL PRIMARY KEY,
 "option" VARCHAR(255) NOT NULL
);

INSERT INTO "cti_preference"("option") VALUES ('loginwindow.url');
INSERT INTO "cti_preference"("option") VALUES ('xlet.identity.logagent');
INSERT INTO "cti_preference"("option") VALUES ('xlet.identity.pauseagent');
INSERT INTO "cti_preference"("option") VALUES ('xlet.agentdetails.noqueueaction');
INSERT INTO "cti_preference"("option") VALUES ('xlet.agentdetails.hideastid');
INSERT INTO "cti_preference"("option") VALUES ('xlet.agentdetails.hidecontext');
INSERT INTO "cti_preference"("option") VALUES ('xlet.agents.fontname');
INSERT INTO "cti_preference"("option") VALUES ('xlet.agents.fontsize');
INSERT INTO "cti_preference"("option") VALUES ('xlet.agents.iconsize');
INSERT INTO "cti_preference"("option") VALUES ('xlet.queues.statsfetchperiod');
INSERT INTO "cti_preference"("option") VALUES ('presence.autochangestate');

DROP TABLE IF EXISTS "cti_xlet" CASCADE;
CREATE TABLE "cti_xlet" (
 "id" SERIAL PRIMARY KEY,
 "plugin_name" VARCHAR(40) NOT NULL
);

INSERT INTO "cti_xlet"("plugin_name") VALUES ('identity');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('dial');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('history');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('search');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('directory');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('fax');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('features');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('conference');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('datetime');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('tabber');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('mylocaldir');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('customerinfo');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('agents');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('agentdetails');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('queues');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('queuemembers');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('queueentrydetails');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('switchboard');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('calls');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('callcampaign');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('operator');
INSERT INTO "cti_xlet"("plugin_name") VALUES ('xletweb');

DROP TABLE IF EXISTS "cti_xlet_layout" CASCADE;
CREATE TABLE "cti_xlet_layout" (
 "id" SERIAL PRIMARY KEY,
 "name" VARCHAR(255) NOT NULL
);

INSERT INTO "cti_xlet_layout"("name") VALUES ('dock');
INSERT INTO "cti_xlet_layout"("name") VALUES ('grid');
INSERT INTO "cti_xlet_layout"("name") VALUES ('tab');

DROP TABLE IF EXISTS "cti_profile" CASCADE;
CREATE TABLE "cti_profile" (
       "id" SERIAL PRIMARY KEY,
       "name" VARCHAR(255),
       "presence_id" INTEGER REFERENCES "ctipresences"("id") ON DELETE RESTRICT,
       "phonehints_id" INTEGER REFERENCES "ctiphonehintsgroup"("id") ON DELETE RESTRICT
);
INSERT INTO "cti_profile" ("name","presence_id","phonehints_id") (
SELECT "ctiprofiles"."name",
       "ctipresences"."id" AS "presence_id",
       "ctiphonehintsgroup"."id" AS "phonehints_id"
FROM "ctiprofiles", "ctipresences", "ctiphonehintsgroup"
WHERE "ctiphonehintsgroup"."name" = "ctiprofiles"."phonehints" AND "ctipresences"."name" = "ctiprofiles"."presence"
);

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
INSERT INTO "cti_profile_xlet" (
SELECT DISTINCT ON ("xlet_id", "profile_id") *
FROM (
  SELECT (SELECT "cti_xlet"."id" FROM "cti_xlet" WHERE "cti_xlet"."plugin_name" = "cti_profile_step_two"."name") AS "xlet_id",
         (SELECT "cti_profile"."id" FROM "cti_profile" WHERE "cti_profile"."name" = "cti_profile_step_two"."profile_name") AS "profile_id",
         (SELECT "cti_xlet_layout"."id" FROM "cti_xlet_layout" WHERE "cti_xlet_layout"."name" = "cti_profile_step_two"."layout") AS "layout_id",
         strpos(properties, 'c') <> 0 AS "closable",
         strpos(properties, 'm') <> 0 AS "movable",
         strpos(properties, 'f') <> 0 AS "floating",
         strpos(properties, 's') <> 0 AS "scrollable",
         CASE WHEN "number" = 'N/A' THEN NULL
              ELSE CAST("number" AS INTEGER)
              END AS "order"
  FROM (
    SELECT "id",
           "name" AS "profile_name",
           trim(both '"' FROM trim(both ' ' FROM xlet[1])) AS "name",
           trim(both '"' FROM trim(both ' ' FROM xlet[2])) AS "layout",
           xlet[3] AS "properties",
           trim(both '"' FROM trim(both ' ' FROM xlet[4])) AS "number"
    FROM (
      SELECT "id",
             "name",
             regexp_split_to_array(trim(trailing ']' FROM trim(leading '[' FROM regexp_split_to_table(xlets, '],'))), ',') AS "xlet"
      FROM "ctiprofiles"
      WHERE "xlets" <> '[]'
    ) AS "cti_profile_step_one"
  ) AS "cti_profile_step_two"
) AS "distincting"
);

DROP TABLE IF EXISTS "cti_profile_preference" CASCADE;
CREATE TABLE "cti_profile_preference" (
       "profile_id" INTEGER REFERENCES "cti_profile"("id") ON DELETE CASCADE,
       "preference_id" INTEGER REFERENCES "cti_preference"("id") ON DELETE CASCADE,
       "value" VARCHAR(255),
       PRIMARY KEY("profile_id", "preference_id")
);

INSERT INTO "cti_profile_preference" (
  SELECT
    (SELECT "cti_profile"."id" FROM "cti_profile" WHERE "cti_profile"."name" = "profile_name") AS "profile_id",
    (SELECT "cti_preference"."id" FROM "cti_preference" where "cti_preference"."option" = "preference_name") AS "preference_id",
    "value"
  FROM (
   SELECT
     "id" AS "profile_id",
     "name" AS "profile_name",
     trim(both '"' FROM trim(both ' ' FROM pref[1])) AS "preference_name",
     trim(both '"' FROM trim(both ' ' FROM pref[2])) AS "value"
   FROM (
     SELECT "id",
        "name",
        regexp_split_to_array(trim(trailing '}' FROM trim(leading '{' FROM regexp_split_to_table("preferences", ','))), ':') AS "pref"
     FROM "ctiprofiles"
     WHERE "preferences" <> ''
   ) AS "preference_split"
 ) AS "preference_id"
 WHERE "preference_name" <> ''
);


DROP TABLE IF EXISTS "cti_profile_service" CASCADE;
CREATE TABLE "cti_profile_service" (
       "profile_id" INTEGER REFERENCES "cti_profile"("id") ON DELETE CASCADE,
       "service_id" INTEGER REFERENCES "cti_service"("id") ON DELETE CASCADE,
       PRIMARY KEY("profile_id", "service_id")
);

INSERT INTO "cti_profile_service" (
  SELECT
    (SELECT "cti_profile"."id" FROM "cti_profile" WHERE "cti_profile"."name" = "profile_name") AS "profile_id",
    (SELECT "cti_service"."id" FROM "cti_service" WHERE "cti_service"."key" = "service_name") AS "service_id"
  FROM (
    SELECT
      "id" AS "profile_id",
      "name" AS "profile_name",
      regexp_split_to_table("services", ',') AS "service_name"
    FROM "ctiprofiles"
    WHERE "services" <> ''
  ) AS "service"
);


DELETE FROM "cti_profile" WHERE "name" = 'oper';
DELETE FROM "cti_profile" WHERE "name" = 'clock';

DELETE FROM "cti_xlet" WHERE "plugin_name" = 'operator';
DELETE FROM "cti_xlet" WHERE "plugin_name" = 'calls';
DELETE FROM "cti_xlet" WHERE "plugin_name" = 'callcampaign';
DELETE FROM "cti_xlet" WHERE "plugin_name" = 'xletweb';

DROP TABLE "ctiprofiles";

DELETE FROM "cti_profile" WHERE "name" = 'switchboard';
INSERT INTO "cti_profile" VALUES (DEFAULT, 'switchboard', 1, 1);

/* switchboard */
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'identity'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'switchboard'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'grid'),
                                       TRUE, TRUE, TRUE, TRUE, 0);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'switchboard'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'switchboard'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'),
                                       TRUE, TRUE, TRUE, TRUE, 1);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'dial'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'switchboard'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'),
                                       TRUE, TRUE, TRUE, TRUE, 2);
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'search'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'switchboard'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'),
                                       TRUE, TRUE, TRUE, TRUE, 3);


GRANT ALL ON ALL SEQUENCES IN SCHEMA public to asterisk;
GRANT ALL ON ALL TABLES IN SCHEMA public TO asterisk;

COMMIT;
