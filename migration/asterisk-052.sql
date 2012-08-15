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

-- Empty cache tables
TRUNCATE stat_call_on_queue CASCADE;
TRUNCATE stat_queue_periodic CASCADE;

-- Change the enum content
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

ALTER TABLE stat_call_on_queue ADD COLUMN status call_exit_type NOT NULL;

-- Remove unused columns rerouted{guide,number}
ALTER TABLE stat_queue_periodic DROP COLUMN IF EXISTS reroutedguide;
ALTER TABLE stat_queue_periodic DROP COLUMN IF EXISTS reroutednumber;

-- Add new columns for divert_{ca_ratio,waittime}
ALTER TABLE stat_queue_periodic ADD COLUMN divert_ca_ratio INTEGER NOT NULL DEFAULT 0;
ALTER TABLE stat_queue_periodic ADD COLUMN divert_waittime INTEGER NOT NULL DEFAULT 0;

COMMIT;
