INSERT INTO tmp_useriax (
	id,
	name,
	type,
	username,
	secret,
	dbsecret,
	context,
	language,
	accountcode,
	amaflags,
	mailbox,
	callerid,
	fullname,
	cid_number,
	trunk,
	auth,
	encryption,
	maxauthreq,
	inkeys,
	outkey,
	adsi,
	transfer,
	codecpriority,
	jitterbuffer,
	forcejitterbuffer,
	sendani,
	qualify,
	qualifysmoothing,
	qualifyfreqok,
	qualifyfreqnotok,
	timezone,
	disallow,
	allow,
	mohinterpret,
	mohsuggest,
	deny,
	permit,
	defaultip,
	sourceaddress,
	setvar,
	host,
	port,
	mask,
	regexten,
	peercontext,
	ipaddr,
	regseconds,
	protocol,
	category,
	commented)
SELECT
	useriax.id,
	useriax.name,
	useriax.type,
	useriax.username,
	useriax.secret,
	'',
	useriax.context,
	NULL,
	NULLIF(useriax.accountcode,''),
	NULLIF(useriax.amaflags,''),
	NULLIF(useriax.mailbox,''),
	useriax.callerid,
	NULL,
	NULL,
	0,
	'plaintext,md5',
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	0,
	useriax.qualify,
	0,
	60000,
	10000,
	NULL,
	useriax.disallow,
	useriax.allow,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	'',
	useriax.host,
	NULL,
	NULL,
	NULL,
	NULL,
	IFNULL(useriax.ipaddr,''),
	IFNULL(useriax.regseconds,0),
	useriax.protocol,
	useriax.category,
	useriax.commented
FROM useriax
WHERE useriax.category = 'user';