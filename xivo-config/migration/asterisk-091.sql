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

-- Rename the directory xlet to remote directory
UPDATE "cti_xlet" SET "plugin_name"='remotedirectory' WHERE "plugin_name"='directory';

-- Create a new xlet with name directory
INSERT INTO "cti_xlet" VALUES (DEFAULT, 'directory');

-- Remove the contact xlet from the switchboard profile
DELETE FROM "cti_profile_xlet" WHERE "xlet_id" = (SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'search')
       AND "profile_id" = (SELECT "id" FROM "cti_profile" WHERE "name" = 'Switchboard');

-- Assign the new directory xlet to the switchboard profile
INSERT INTO "cti_profile_xlet" VALUES ((SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'directory'),
                                       (SELECT "id" FROM "cti_profile" WHERE "name" = 'Switchboard'),
                                       (SELECT "id" FROM "cti_xlet_layout" WHERE "name" = 'dock'),
                                       TRUE, TRUE, TRUE, TRUE, 3);

COMMIT;
