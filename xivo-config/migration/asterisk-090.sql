/*
 * XiVO Base-Config
 * Copyright (C) 2012  Avencall
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

BEGIN;

ALTER TABLE "userfeatures"
    ADD COLUMN "cti_profile_id" INTEGER REFERENCES cti_profile("id") ON DELETE RESTRICT;

UPDATE "userfeatures" SET "cti_profile_id" = (
    SELECT "cti_profile"."id" FROM "cti_profile"
    WHERE "cti_profile"."name" = "userfeatures"."profileclient"
);

ALTER TABLE "userfeatures"
    DROP COLUMN "profileclient";

UPDATE "cti_profile" SET "name"='Client' WHERE "name"='client';
UPDATE "cti_profile" SET "name"='Agent' WHERE "name"='agent';
UPDATE "cti_profile" SET "name"='Supervisor' WHERE "name"='agentsup';
UPDATE "cti_profile" SET "name"='Switchboard' WHERE "name"='switchboard';

COMMIT;