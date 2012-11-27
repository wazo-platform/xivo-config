/*
 * XiVO Base-Config
 * Copyright (C) 2011  Avencall
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

DROP TABLE IF EXISTS "callcenter_campaigns_general" CASCADE;
DROP TABLE IF EXISTS "callcenter_campaigns_campaign" CASCADE;
DROP TABLE IF EXISTS "callcenter_campaigns_campaign_filter" CASCADE;
DROP TYPE IF EXISTS "callcenter_campaigns_campaign_filter_type" CASCADE;
DROP TABLE IF EXISTS "callcenter_campaigns_tag" CASCADE;
DROP TYPE IF EXISTS "callcenter_campaigns_tag_action" CASCADE;
DROP TABLE IF EXISTS "callcenter_campaigns_records" CASCADE;

GRANT ALL ON ALL TABLES IN SCHEMA public TO asterisk;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public to asterisk;

COMMIT;
