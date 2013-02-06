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

UPDATE ctisheetevents SET link=agentlinked WHERE link='' AND agentlinked<>'';
UPDATE ctisheetevents SET unlink=agentunlinked WHERE unlink='' AND agentunlinked<>'';
ALTER TABLE ctisheetevents DROP COLUMN agentlinked;
ALTER TABLE ctisheetevents DROP COLUMN agentunlinked;
ALTER TABLE ctisheetevents DROP COLUMN faxreceived;
ALTER TABLE ctisheetevents DROP COLUMN outcall;
ALTER TABLE ctisheetevents DROP COLUMN incomingqueue;
ALTER TABLE ctisheetevents DROP COLUMN incominggroup;

COMMIT;
