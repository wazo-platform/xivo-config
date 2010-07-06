
CREATE TABLE queue_old AS SELECT * FROM queue;

DROP TABLE queue;
CREATE TABLE queue (
 name varchar(128) NOT NULL,
 musiconhold varchar(128),
 announce varchar(128),
 context varchar(39),
 timeout tinyint unsigned DEFAULT 0,
 "monitor-type" varchar(10),
 "monitor-format" varchar(128),
 "queue-youarenext" varchar(128),
 "queue-thereare" varchar(128),
 "queue-callswaiting" varchar(128),
 "queue-holdtime" varchar(128),
 "queue-minutes" varchar(128),
 "queue-seconds" varchar(128),
 "queue-lessthan" varchar(128),
 "queue-thankyou" varchar(128),
 "queue-reporthold" varchar(128),
 "periodic-announce" text,
 "announce-frequency" integer unsigned,
 "periodic-announce-frequency" integer unsigned,
 "announce-round-seconds" tinyint unsigned,
 "announce-holdtime" varchar(4),
 retry tinyint unsigned,
 wrapuptime tinyint unsigned,
 maxlen integer unsigned,
 servicelevel int(11),
 strategy varchar(11),
 joinempty varchar(6),
 leavewhenempty varchar(6),
 eventmemberstatus tinyint(1) NOT NULL DEFAULT 0,
 eventwhencalled tinyint(1) NOT NULL DEFAULT 0,
 ringinuse tinyint(1) NOT NULL DEFAULT 0,
 reportholdtime tinyint(1) NOT NULL DEFAULT 0,
 memberdelay integer unsigned,
 weight integer unsigned,
 timeoutrestart tinyint(1) NOT NULL DEFAULT 0,
 commented tinyint(1) NOT NULL DEFAULT 0,
 category char(5) NOT NULL,
 autopause tinyint(1) NOT NULL DEFAULT 0,
 setinterfacevar tinyint(1) NOT NULL DEFAULT 0,
 PRIMARY KEY(name)
);

CREATE INDEX queue__idx__commented ON queue(commented);
CREATE INDEX queue__idx__category ON queue(category);

INSERT INTO queue SELECT
	 name,
	 musiconhold,
	 announce,
	 context,
	 timeout,
	 "monitor-type",
	 "monitor-format",
	 "queue-youarenext",
	 "queue-thereare",
	 "queue-callswaiting",
	 "queue-holdtime",
	 "queue-minutes",
	 "queue-seconds",
	 "queue-lessthan",
	 "queue-thankyou",
	 "queue-reporthold",
	 "periodic-announce",
	 "announce-frequency",
	 "periodic-announce-frequency",
	 "announce-round-seconds",
	 "announce-holdtime",
	 retry,
	 wrapuptime,
	 maxlen,
	 servicelevel,
	 strategy,
	 joinempty,
	 leavewhenempty,
	 eventmemberstatus,
	 eventwhencalled,
	 0,
	 reportholdtime,
	 memberdelay,
	 weight,
	 timeoutrestart,
	 commented,
	 category,
	 0,
	 0
 FROM queue_old;

DROP TABLE queue_old;
