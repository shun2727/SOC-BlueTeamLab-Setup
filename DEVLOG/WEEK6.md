### 7 July 2026
---
1. created reaserch on what to expect in L1 to L3 working in SOC, narrow down scope unsder "SOC Level.txt"

2. create a CASE TEMPLATE for the bruteforce attack following this guide https://docs.strangebee.com/thehive/user-guides/organization/configure-organization/manage-templates/case-templates/create-a-case-template/

3. Filled up the feilds for the current SSH brute force attack (stored under theHIVE case details)

### 8 July 2026
---
1. finish creating the case template for the ssh brute force attack
	- add more templates as necessary
	- update into .xml
	- double check the rules and stuff

### 9 JUly 2026
--- 
1. Change SEEDlabs ip
- wazuh agent is set but the ip is different, settle the ip conflict the same way with the ssh lab ass before by going into te ossec config file 

2. Configure to read from apache2
	- the apache2 is inside the docker, and not the local device, therefore it must be configures to retriev the logs from apache hosted within docker 
	```bash
	docksh <id>
	ls -la /var/log/apache2/ #to confirm is within docker
	```
	- Add a bind mount so the host (and OSSEC) can read it
	Open the lab's docker-compose.yml and find the service block for the 10.9.0.5 container (likely named something like web or hostA). Add a volumes entry:
	- take /var/log/apache2 inside the container, and make it literally the same folder as ./apache-logs on host (it is stoed within the Labsetup folder)

	inside seedlabs\docker-compose.yml : (DO NOT USE TABS FOR YAML files )
	```yaml
	services:
	www:
			build: ./image_www
			volumes: #must be under the same indentation of build
				- ./apache-logs:/var/log/apache2
			image: seed-image-www-sqli
			ports:
				-"80:80"
		...
	```

	- restart the docker
	```bash
	dcdown
	dcup
	```
	- run the command to check its success

	```bash
	ls -la apache-logs/
	```

	- update the `/var/ossec/etc/ossec.conf", details written in the sql_injecition file 
	- restart the wazuh agent 
	`sudo systemctl restart wazuh-agent`

!! level treshold is set to 10, only will it be fowarded , rules will be sepereated by the 100s to prevent overlap and in case rules are added in the future
given all the possible attacks, the issue is that they do not reach the server, the logs do not fire alerts, therefore more htings need to be done to ensure the logs will show up and provide alerts

3. Configure to read from mysql database logs
	To check : 
	```bash
	docker exec -it mysql-10.9.0.6 bash
	ls -la /var/log/mysql/
	```

	Create a place to put the log into  by first logging into the mysql shell
	```bash
	docker exec -it mysql-10.9.0.6 bash
	mysql -u root -p
	```

	Once logged in , enable logging and direct the logs into a file called query.log 
	```bash
	SET GLOBAL general_log_file = '/var/log/mysql/query.log';
	SET GLOBAL general_log = 'ON';
	```

	go into docker-compose.yml to create an entry to foward a log from the docker to the host device just as the apache logs under volume 
	```yml
	volumes :
		- ./mysql-logs:/var/log/mysql 
	```

4. Tentatve : Add digital forensics and incident response tools as suggested by Mr Khoo ? (https://docs.velociraptor.app/)

### 10 July 2026 
--- 
1. Restructured all the documentation so far for better readability

2. 