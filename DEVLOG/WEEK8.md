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
| Lab Section | Attack Description | MySQL Rule | Apache Rule | Correlated (Critical) |
|-------------|--------------------|------------|-------------|-----------------------|
| 4.1.1 / 4.1.2 | Login page comment bypass: entering `Admin' #` as username truncates the password check (`WHERE name='Admin' #and Password=...`), logging in without a valid password. Same attack reproduced via curl with `%23` for `#`. | 100050 | 100051 | 100070 |
| 4.1.3 | Stacked query via login field: `Admin'; UPDATE credential SET Name = 'bingus' WHERE Name = 'Alice';#` attempts to run a second UPDATE statement in the same request, modifying another user's record while only authenticating as Admin. Requires `mysqli::multi_query()` to succeed (blocked by default query API). | 100058 | 100052 | 100071 |
| 5.1.1 / 5.1.2 | Profile edit field hijack: injecting `123', salary = 800000 WHERE name = 'Alice' #` (or targeting another user, e.g. `WHERE name = 'Boby' #`) into an editable profile field abuses the single-query UPDATE to modify salary/fields for any user, not just the logged-in one. | 100059 | 100053 | 100072 |
| 5.1.3 | Password tampering via SQL function: injecting `Value', Password = SHA1('amongus') WHERE Name='Boby' #` sets another user's password using the same SHA1 hashing the application expects, making the account log-in-able with a chosen password. | 100060 | 100054 | 100074 |
| Bonus | Classic tautology bypass: `' OR 1=1 --` style payloads that make the WHERE clause always evaluate true, bypassing authentication without needing to know a valid username. | 100061 | 100055 | 100075 |
| Bonus | UNION SELECT: appending `UNION SELECT ...` to pull data from other tables/columns beyond what the query was designed to expose. | 100062 | 100056 | 100073 |
| Bonus | Generic catch-all: any quote immediately followed by OR, AND, UNION, or SELECT — broad fallback for injection variants not covered by the more specific rules above. | 100063 | 100057 | Intentionally uncorrelated — broad fallback |


 - confirm all the possible attacks 
 - create the cases and the 
 - create scripts to delete to blank lsat e

