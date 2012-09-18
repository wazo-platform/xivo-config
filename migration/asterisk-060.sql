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

CREATE TABLE "stat_agent_periodic" (
 "id" SERIAL PRIMARY KEY,
 "time" timestamp NOT NULL,
 "login_time" INTERVAL NOT NULL DEFAULT '00:00:00',
 "agent_id" INTEGER REFERENCES stat_agent (id)
);

CREATE INDEX "stat_agent_periodic__idx__time" ON "stat_agent_periodic"("time");
CREATE INDEX "stat_agent_periodic__idx__agent_id" ON "stat_agent_periodic"("agent_id");

GRANT ALL ON "stat_agent_periodic" TO "asterisk";
GRANT ALL ON "stat_agent_periodic_id_seq" TO "asterisk";

COMMIT;
