- configureing the sql to be persitent
	- done

- confiure docker to auto restart 
	- (done, by adding restart : always )


- current issue : apache is not showing any logs, need to set as persistent and ensure logs are flowing into it
	- logs are flowing to it buts its being showed on error.log and other_vhosts only
	- explanation : 
	**Why my SQL injection attempts weren't showing up in `access.log`**

	Apache keeps a few different log files, and by default, `access.log` is only used for the "default" website on the server — basically a fallback/generic site.

	But the SEED Lab website isn't the default site. It's set up as a **named site** (called a "virtual host"), like it has its own specific web address (e.g. `www.seedlabsqlinjection.com`). Whenever a site is set up this way, Apache automatically routes all its traffic to a *different* log file called **`other_vhosts_access.log`** instead of the regular `access.log`.

	So this isn't a bug or something broken — it's just how Apache is configured out of the box on Ubuntu/Debian systems. `access.log` staying empty is completely normal in this setup.

	**In short:**
	- `access.log` = logs for the generic/default site (empty in my case, and that's fine)
	- `other_vhosts_access.log` = logs for the actual SEED Lab site I'm attacking, since it's a named virtual host — **this is where my requests actually show up**
	- `error.log` = logs for errors, including SQL syntax errors caused by my injection payloads breaking the query — **this is where I can see the injection actually affecting the database**

	**Takeaway:** For this lab, I don't need to check `access.log` at all. I just need `other_vhosts_access.log` (to see the requests I sent) and `error.log` (to see the SQL errors my payloads caused).


- ensure that the rules created matches all the scenarios, also implement rules for the sql logs or else it skinfs useles...
	- first ensure if there are any decoders for it (apache and mysql query logs)

	- ensure if there the files that were tracked can be decodded by the existing decoders(currently the sql statement cannot be done by wazuh)
		- the dcoders live in (log format and decoders are not the sam)
		`/var/ossec/ruleset/decoders/`
		- 

		To do : 
		- check what is the sql version (MYSQL 8.0.22 COmmunity version)
		- check what is the 

		Issue : cassendra suddenly has an issue running due to potential cis hardening 
		Cause : CIS hardening caused a runtime user restriciton that forces casandra container to run as UID/GUID 1000:1000. Which overrode cassandra''simage's normal intitializaiton process, causing the entrypoint scirpt to lose permission to modify /etc/cassandra/cassandra.ymlresulting in a startup failure
		Sluiton : removing user under cassandra, restores cassandra's image stratup failure while maintianing CIS security controls 

	- need to crate a decoder for wazuh, 
