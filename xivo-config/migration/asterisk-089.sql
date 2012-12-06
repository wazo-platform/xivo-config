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

UPDATE "cti_profile_xlet" SET "order"=0
    WHERE "profile_id"=(SELECT "id" FROM "cti_profile" WHERE "name" = 'client') 
    AND "xlet_id"=(SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'search');
UPDATE "cti_profile_xlet" SET "order"=1
    WHERE "profile_id"=(SELECT "id" FROM "cti_profile" WHERE "name" = 'client') 
    AND "xlet_id"=(SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'customerinfo');
UPDATE "cti_profile_xlet" SET "order"=2
    WHERE "profile_id"=(SELECT "id" FROM "cti_profile" WHERE "name" = 'client') 
    AND "xlet_id"=(SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'fax');
UPDATE "cti_profile_xlet" SET "order"=3
    WHERE "profile_id"=(SELECT "id" FROM "cti_profile" WHERE "name" = 'client') 
    AND "xlet_id"=(SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'history');
UPDATE "cti_profile_xlet" SET "order"=4
    WHERE "profile_id"=(SELECT "id" FROM "cti_profile" WHERE "name" = 'client') 
    AND "xlet_id"=(SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'directory');
UPDATE "cti_profile_xlet" SET "order"=5
    WHERE "profile_id"=(SELECT "id" FROM "cti_profile" WHERE "name" = 'client') 
    AND "xlet_id"=(SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'features');
UPDATE "cti_profile_xlet" SET "order"=6
    WHERE "profile_id"=(SELECT "id" FROM "cti_profile" WHERE "name" = 'client') 
    AND "xlet_id"=(SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'mylocaldir');
UPDATE "cti_profile_xlet" SET "order"=7
    WHERE "profile_id"=(SELECT "id" FROM "cti_profile" WHERE "name" = 'client') 
    AND "xlet_id"=(SELECT "id" FROM "cti_xlet" WHERE "plugin_name" = 'conference');

COMMIT;