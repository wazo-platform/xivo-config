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

DROP FUNCTION IF EXISTS "fill_leaveempty_calls" (text, text);
CREATE OR REPLACE FUNCTION "fill_leaveempty_calls" (period_start text, period_end text)
  RETURNS void AS
$$
INSERT INTO stat_call_on_queue (callid, time, waittime, queue_id, status)
SELECT
  callid,
  enter_time as time,
  EXTRACT(EPOCH FROM (leave_time - enter_time))::INTEGER as waittime,
  queue_id,
  'leaveempty' AS status
FROM (SELECT
        CAST (time AS TIMESTAMP) AS enter_time,
        (select CAST (time AS TIMESTAMP) from queue_log where callid=main.callid AND event='LEAVEEMPTY') AS leave_time,
        callid,
        (SELECT id FROM stat_queue WHERE name=queuename) AS queue_id
      FROM queue_log AS main
      WHERE callid IN (SELECT callid FROM queue_log WHERE event = 'LEAVEEMPTY')
            AND event = 'ENTERQUEUE'
            AND time BETWEEN $1 AND $2) AS first;
$$
LANGUAGE SQL;

COMMIT;
