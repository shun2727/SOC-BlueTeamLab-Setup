## 29 June 2026
---
- Discussion with mr Khoo
	- NIST , will be used to map the steps to the NIST framework, there is too many things therefore it will go thorugh the brief overview only 
	- MISP / OPENCTI is too much
	- use seedlabs to create scenarios
	- focus on L1 and L2 

1. Installing Wazuh agent on seedlabs deivce for SQLinjeciton LAB
	#### Issue 8.0 - Wazuh Agent Installation Failed Due to SSL Certificate Verification
	---
	Problem

	While installing the Wazuh agent on the target virtual machine, the package download failed because the SSL certificate presented by the Wazuh package repository could not be verified.

	Installation command :
	```bash
	sudo wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.5-1_amd64.deb && \
	sudo WAZUH_MANAGER='10.0.2.3' \
	WAZUH_AGENT_GROUP='default' \
	WAZUH_AGENT_NAME='SeedLabs_SQLInjection' \
	dpkg -i ./wazuh-agent_4.14.5-1_amd64.deb
	```

	Error received :
	```bash
	ERROR: cannot verify packages.wazuh.com's certificate,
	issued by 'CN=Amazon RSA 2048 M01,O=Amazon,C=US'

	Unable to locally verify the issuer's authority.
	To connect to packages.wazuh.com insecurely, use '--no-check-certificate'.
	Investigation
	```

	The error indicated that the system could not verify the certificate authority (CA) used to sign the Wazuh repository's SSL certificate. As a result, wget refused to establish a trusted HTTPS connection and the installation package could not be downloaded.

	Resolution :
	As a temporary workaround within the isolated lab environment, SSL certificate verification was disabled during the download.
	```bash
	sudo wget --no-check-certificate https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.5-1_amd64.deb && \
	sudo WAZUH_MANAGER='10.0.2.3' \
	WAZUH_AGENT_GROUP='default' \
	WAZUH_AGENT_NAME='SeedLabs_SQLInjection' \
	dpkg -i ./wazuh-agent_4.14.5-1_amd64.deb
	```

2. Import SEEDlabs.ova to proxmox interface
	#### Issue 9.0 - OVA Upload to Proxmox Failed During VM Migration
	---

	Problem :
	While migrating the virtual machine from VirtualBox to Proxmox, the `.ova` image repeatedly disappeared after being uploaded through the Proxmox web interface. As a result, the virtual machine could not be imported into Proxmox.

	The following troubleshooting steps were performed:
	1. Attempted to upload the `.ova` image through the Proxmox web interface multiple times.
	2. Observed that the upload would disappear from the interface before the import process could begin.
	3. Switched to transferring the `.ova` file directly to the Proxmox server using the command-line interface (CLI).
	4. Verified that the uploaded file existed in the Proxmox import directory before attempting the import.

	To monitor the upload progress and verify that the file was still being transferred, the following command was used:

	```bash
	watch -n 1 "du -h /var/lib/vz/import/SEED_Ubuntu.ova"
	```

	> Replace `SEED_Ubuntu.ova` with the name of the uploaded OVA file.

	Upload progress was monitored using the `watch` command until the file size stopped increasing, confirming that the transfer had completed successfully. The OVA image was then imported into Proxmox from the local import directory.


3. Configure the vms on proxmox
	- change the ip address of the wazuh manager on the wazuh agent devices 
		```bash
		sudo nano /var/ossec/etc/ossec.conf
		```
	- find 
		```
		<client>
		<server>
			<address>10.0.2.3</address>
			<port>1514</port>
			<protocol>tcp</protocol>
		</server>
		</client>
		```
	- change ip address to `172.29.1.100` <- the new static ip on proxmox
	- refresh by running 
		```bash
		sudo systemctl restart wazuh-agent
		```
	- need to get evan to set a static ip so that in the future other devices dont get the same ipe `172.29.1.100`
	- need to get evan to unblock allow vlan tag 911 to connect to vlan tag 901 (victim device `172.29.11.101` was unable to ping `172.29.1.100` but t workes the other way around)

### 1 July 2026 
---

1. setting up the seedlabs server
	- add ip to /etc/hosts
	- enter labsetup folder then use docker-compose.yml to set up lab environment
		```bash
		docker-compose build #dcbuild
		docker compose up #dcup
		docker copose down #dcdown
		```
	- note : to ensure lab reusablility, attempt to rm the sql data with the following command 
		```bash
		sudo rm -rf mysql_data
		```
	- proceed to www.seed-server.com for the employee login page 

2. Completed documentation for all possible attack scearios for sqlinjection lab

### 2 July 2026
---
1. Setting up the hive
	- following the rules and things listed on 20th June
	#### Issue 10.0 -  conflict due to port :443 being used by wazuh manager
	---
	Problem :
	While deploying TheHive on the same virtual machine as the Wazuh Manager, Docker failed to start the TheHive container because port 443 was already occupied by the Wazuh Dashboard.

	Docker returned an error similar to:
	```
	Error response from daemon:
	Bind for 0.0.0.0:443 failed: port is already allocated
	```

	Investigation :
	The conflict occurred because both applications attempted to expose HTTPS services on the host's port 443:

	Wazuh Dashboard → Port 443
	TheHive → Port 443

	Since only one service can bind to a host port at a time, Docker was unable to start TheHive.

	Resolution : 

	The host port used by TheHive was changed in the docker-compose.yml file from:
	```
	ports:
	- "443:443"
	```
	to:
	```
	ports:
	- "9443:443"
	```
	This configuration maps:

	Host Port: 9443
	Container Port: 443

	The left-hand port (9443) is the port exposed on the Proxmox virtual machine, while the right-hand port (443) remains the HTTPS port used internally by the TheHive container.

	Port 9443 was selected because it is a commonly used alternative HTTPS port for secure web applications and management interfaces.

	TheHive could then be accessed through:
	https://localhost:9443

2. After succesful login : 
	Guide to setup theHIVE(https://docs.strangebee.com/thehive/administration/perform-initial-setup-as-admin/#step-1-log-in-with-the-default-credentials)

	Login: `admin@thehive.local`
	Password: `secret`
	- TheHIVE requires users to create an account in order to fully use thier utilities, a community lisence will be requsted 
	- blueteamsoc123

3. Move disks on proxmox to the correct storage steps : 
	1. shut down machine
	2. select hard disk
	3. disk action
	4. move disk
	5. (within this lab environemnet move to local-lvm)
	6. it will be converted to raw format and source is deleted 

	
### 3 July 2026
---
Resources : 
- guide on how to create theHIVE case template : https://github.com/StrangeBeeCorp/thehive-templates
- In order to create a case, need to follow an indsustry template source :  
	- https://csrc.nist.gov/pubs/sp/800/61/r2/final
	- https://csrc.nist.gov/pubs/sp/800/61/r3/final
- OWSAP for the SQL injection guide : https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html?utm_source=chatgpt.com
- incident response playbook workflow : https://blog.n8n.io/automated-incident-response-workflow/
- guide on case creation for theHIVE : https://www.youtube.com/watch?v=niuf8nGTzBw&t=79s 11:56 mark
- there is a room on tryhack me to use the hive unfortunately it is a premium room therefore follow guide instead : https://tryhackme.com/room/thehiveproject
 [guide](https://rahulcyberx.medium.com/thehive-project-complete-tryhackme-walkthrough-ca816e766e6f)


1. provide theHIVE account with the community lisence
	- following the guide for first login :  https://docs.strangebee.com/thehive/administration/perform-initial-setup-as-admin/#step-1-log-in-with-the-default-credentials
	- after creating an account we need to activate the lisence following this guide : https://docs.strangebee.com/thehive/installation/licenses/license/
	- warning !
		community lisence only lasts for a year, therefore after my term using 0135347@student.uow.edu.my, a solution must be made in order to update or have a full plan 

2. intergraitng wazuh and theHIVE
	- Guide followed to integrate :  https://wazuh.com/blog/using-wazuh-and-thehive-for-threat-protection-and-incident-response/
	Steps : 
	1. User managemen & API key creation :
		- create a new organization on TheHive web interface and with an administrator account.
		- An organizaiton under `SOCBlueTeamLab` is created
		- under `SOCBlueTeamLab` a new user with organization org-admin privelages is created
		- the guide provided is for the oder version of theHIVE, current version is at theHIVE 5
			- this guide https://medium.com/@devkotasuprim832/home-lab-chronicles-part-09-integration-between-wazuh-siem-and-thehive-1424b3d71d44 , has a slightly more updated version 
			- LabUser@wazuh.com | type : normal | profile : org-admin | ( !note : within the guide it asks to create a service account, howver that account would nto be able to grant access)
				- Create a password for this user so that we can log in to view the dashboard and manage cases. This is done by clicking on “New password” 
					1. under the organization click preview (eye icon)
					2. hover on the user and clck preview (eye icon) 
					3. scroll down and click create password
		- To get the API key 
			1. under the organization click preview (eye icon)
			2. hover on the user and clck preview (eye icon) 
			3. scroll down and click create API key

	2. Configuring wazuh server for the hive 
		- install the hive python module 
		``` bash
		sudo /var/ossec/framework/python/bin/pip3 install thehive4py==1.8.1
		```
		- check the pytho3 version via :
		```bash
		python3 --version
		```
		- paste the python code provided within the guide into `/var/ossec/integrations/custom-w2thive.py`
			- editing is done for the line for the treshold to lvl10 and above
			```
			#threshold for wazuh rules level
			lvl_threshold=10
			```
		- create the bash script `/var/ossec/integrations/custom-w2thive` , with the code provided within the guide , to executethe .py script created in the previous step
		- change the ownsership with : (!note : current version of wazuh is 4.x and above therefore group is changed to wazuh, follow the following commands instead)
		```bash
		sudo chmod 755 /var/ossec/integrations/custom-w2thive.py
		sudo chmod 755 /var/ossec/integrations/custom-w2thive
		sudo chown root:wazuh /var/ossec/integrations/custom-w2thive.py
		sudo chown root:wazuh /var/ossec/integrations/custom-w2thive
		```
		- add the following lines  the manager configuration file located at `/var/ossec/etc/ossec.conf`. We insert the IP address for TheHive server along with the API key that was generated earlier, its important to knwo the archictecure to nsure that the conneciton is achived:
		```
		  <integration>
				<name>custom-w2thive</name>
				<hook_url>https://localhost:9443</hook_url>
				<api_key>59zLXJvvEfECJW3IeKs/mYxgO5CENIqv</api_key>
				<alert_format>json</alert_format>
			</integration>
		```

	3. refreshing theHIVE and show alrerts
	> **Note:** The integration creates **alerts** in TheHive, **not cases**. Cases are created manually from alerts by an analyst.
	#### Issue 11.0 - Wazuh Alerts Not Being Forwarded to TheHive
	---
	Problem :
	After configuring the Wazuh–TheHive integration, no alerts were being received in TheHive despite following the setup guide.
	
	Investigation :

	To determine whether the custom integration script was being executed, the integration logs were monitored using:

	```bash
	sudo tail -n 50 /var/ossec/logs/integrations.log
	```

	If no new log entries appeared after triggering an alert, it indicated that the integration was not being invoked, suggesting a configuration issue within `ossec.conf`.

	Cause :
	The `<name>` field in the integration configuration within `ossec.conf` was configured incorrectly, preventing Wazuh from invoking the custom integration script.

	Resolution:
	1. Corrected the `<name>` field in `ossec.conf`.
	2. Restarted the Wazuh Manager.
	3. Triggered another alert to verify the configuration.
	4. Confirmed that entries were now being written to the integration log.

	#### Issue 12.0 - SSL Certificate Verification Failure Between Wazuh and TheHive
	---

	Problem :
	Although the integration script was being executed, alerts still failed to reach TheHive because the Python client could not establish a trusted HTTPS connection.

	Investigation :
	The integration uses the `thehive4py` library, which internally relies on Python's `requests` library. The client rejected TheHive's SSL certificate, causing every API request to fail before reaching the server.

	To determine the installed library version:

	```bash
	sudo /var/ossec/framework/python/bin/pip3 show thehive4py
	```

	Resolution :

	Edited the integration script:

	```bash
	sudo nano /var/ossec/integrations/custom-w2thive.py
	```

	Modified the initialization of `TheHiveApi` from:

	```python
	thive_api = TheHiveApi(thive, thive_api_key)
	```

	to:

	```python
	thive_api = TheHiveApi(thive, thive_api_key, cert=False)
	```

	Setting `cert=False` disables SSL certificate verification, allowing the integration script to communicate with TheHive within the isolated lab environment.

