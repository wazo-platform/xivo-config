/*
 * XiVO Base-Config
 * Copyright (C) 2013  Avencall
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

ALTER TABLE "agent_membership_status"
    ADD COLUMN "queue_name" VARCHAR(128) NOT NULL;


INSERT INTO "agent_membership_status" (
    "agent_id",
    "queue_id",
    "queue_name"
)
SELECT
    "agent_login_status"."agent_id" AS "agent_id",
    "queuefeatures"."id"            AS "queue_id",
    "queuefeatures"."name"          AS "queue_name"
FROM
    "agent_login_status"
    INNER JOIN "queuemember"
        ON "agent_login_status"."agent_id" = "queuemember"."userid"
        AND "queuemember"."usertype" = 'agent'
        INNER JOIN "queuefeatures"
            ON "queuefeatures"."name" = "queuemember"."queue_name"
;

COMMIT;
