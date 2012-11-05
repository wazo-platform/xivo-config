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

ALTER TABLE "agentfeatures" DROP COLUMN IF EXISTS "silent";

ALTER TABLE "agentfeatures" DROP COLUMN IF EXISTS "ackcall";
DROP TYPE IF EXISTS "agentfeatures_ackcall";

ALTER TABLE "agentfeatures" DROP COLUMN IF EXISTS "acceptdtmf";

ALTER TABLE "agentfeatures" DROP COLUMN IF EXISTS "enddtmf";

ALTER TABLE "agentfeatures" DROP COLUMN IF EXISTS "musiconhold";

COMMIT;
