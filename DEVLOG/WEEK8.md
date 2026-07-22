## 20 July 2026
---
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

## 21 July 2026
---
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


- regex : regular expression 
issue : kept trying to use decoder but even simplet decoders that catch everything isnt working 
found error : https://documentation.wazuh.com/current/user-manual/ruleset/ruleset-xml-syntax/decoders.html
soution : added pcre2 to the regex

1. confirm if the agent is actually fowarding the file : 
	`sudo tail -50 /var/ossec/logs/ossec.log`
	-> currently it shows that there is some error so in order to get that eeror 
	- based on the log s, fix the error 
	- if see something such as the following the its workign on the agent end : 
	```bash
	ossec-logcollector: INFO: Analyzing file: '/home/seed/Downloads/Labsetup/mysql_logs/query.log'.
	```
	
2. confirm if the manager is receiving the file :
	1. enable log all first or else we will need rules to deetct and log it inside the ossec file `<logall> yes </logall>`
	2. enter the query to check it inside `/var/ossec/logs/archives/archives.log`
	3. after verify  can delet the files 
	`du -sh /var/ossec/logs/archives/` <- to chekc the size
	4. then delete 
	```bash
	sudo rm /var/ossec/logs/archives/archives.log
	sudo rm /var/ossec/logs/archives/archives.json
	```

3. Create rules to detect the logs 
	issue : cant save the rules due to xml error 
	debugging : 
	- run 
	```bash
	 /var/ossec/bin/wazuh-analysisd -t 
	 ```
	Found bug : 
	resource to aid in torubleshooting : https://www.reddit.com/r/Wazuh/comments/1r9csdl/hello_i_have_been_facing_a_problem_using_wazuh

	Initially, the custom rule could not be uploaded through the Wazuh Dashboard because it returned an XML syntax error. To troubleshoot the issue, I bypassed the Dashboard editor and edited the rule directly in `local_rules.xml` using the terminal. I then validated the rules by running:

	```bash
	sudo /var/ossec/bin/wazuh-analysisd -t
	```

	The validation output reported:

	```text
	Failure to read rule 100050. Field 'data' is static.
	```

	This indicated that the rule incorrectly used:

	```xml
	<field name="data" type="pcre2">...</field>
	```

	The `data` field in the `mysql-querylog` decoder is a static field and cannot be matched using the `<field>` element. I modified the rule to use the `<match type="pcre2">...</match>` element instead, saved the changes, and revalidated the rules. Finally, I verified the rule using `wazuh-logtest`, where the custom rule (`100050`) successfully matched the test MySQL query and generated an alert, confirming that the issue had been resolved.


## 22 July 2026
---
 To do : 
1. create the rules to detect 
- created rules for both apache and mysql (first for injeciton and malicious activity but not for succeful attempts)
| Scenario | Apache sees it? | MySQL sees it? |
|----------|------------------|----------------|
| GET-based injection | Yes | Yes (usually) |
| POST-based injection | No (request body not logged) | Yes |
| PHP transforms or partially sanitizes input | Sees original request, but not necessarily the final executed query | Sees the final executed query |
| Apache logging misconfigured or wrong virtual host | May miss the request | Still works (independent of Apache logging) |
- 

- confrim the alert levels in wazuh :



 - confirm all the possible attacks 
 - create the cases and the 
 - create scripts to delete to blank lsat e

