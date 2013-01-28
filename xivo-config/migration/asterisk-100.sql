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
  -- DDL for RECORDINGS:
  
CREATE TABLE record_campaign
(
  id serial NOT NULL,
  campaign_name character varying(128) NOT NULL,
  activated boolean NOT NULL,
  base_filename character varying(64) NOT NULL,
  queue_id integer,
  start_date timestamp without time zone,
  end_date timestamp without time zone,
  CONSTRAINT record_campaign_pkey PRIMARY KEY (id ),
  CONSTRAINT record_campaign_queue_id_fkey FOREIGN KEY (queue_id)
      REFERENCES queuefeatures (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT campaign_name_u UNIQUE (campaign_name )
);


CREATE TABLE recording
(
  cid character varying(32) NOT NULL,
  start_time timestamp without time zone,
  end_time timestamp without time zone,
  caller character varying(32),
  client_id character varying(1024),
  callee character varying(32),
  filename character varying(1024),
  campaign_id integer NOT NULL,
  agent_id integer NOT NULL,
  CONSTRAINT recording_pkey PRIMARY KEY (cid ),
  CONSTRAINT recording_agent_id_fkey FOREIGN KEY (agent_id)
      REFERENCES agentfeatures (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT recording_campaign_id_fkey FOREIGN KEY (campaign_id)
      REFERENCES record_campaign (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE record_campaign
  OWNER TO asterisk;
ALTER TABLE recording
  OWNER TO asterisk;

COMMIT;
