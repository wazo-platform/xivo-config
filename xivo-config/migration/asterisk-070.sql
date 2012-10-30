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

DELETE FROM "extensions" WHERE "appdata" LIKE 'outcall%';

INSERT INTO "extensions" ("commented", "context", "exten", "priority", "app", "appdata", "name")
    SELECT
        "outcall"."commented",
        "outcall"."context",
        "dialpattern"."exten",
        1,
        'GoSub',
        'outcall,s,1('||"outcall"."id"||')',
        ''
    FROM "dialpattern"
    INNER JOIN "outcall"
        ON  "dialpattern"."typeid" = "outcall"."id";

COMMIT;
