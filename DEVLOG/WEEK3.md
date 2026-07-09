### 18 June 2026
---
1. Installed ubuntu 22.04 (Jammy jellyfish) on 2 virtual machines
	- password : `password` 

2. Installed virtualbox guest additions for convenience later on 
	- install page needed to run the .iso `sudo apt install gcc make perl` , for the missing dependency

### 19 June 2026
---
1. Downloading wazuh manager, following the quickstart guide to install at at once : 

	Wazuh Quickstart guide (https://documentation.wazuh.com/current/quickstart.html)

	```bash
	curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
	
	sudo bash ./wazuh-install.sh -a
	```

- Hardware requirements :
	- Agents : 1–25
	- Cores : 4 vCPU
	-  RAM :  8 GiB 
	- Storage : 50 GB

	#### Issue 1.0 - Wazuh manager installation fail due to insufficient resource
	---

	Failed installation due to lack of space and memory, had to manually remove packages one by one taking up lots of time. Memory was increased to 6GB to support wazuh alone


2. Reccommended disable the auto updates within the guide

	```bash
	sed -i "s/^deb /#deb /" /etc/apt/sources.list.d/wazuh.list

	apt update
	```

	Wazuh single node deplayment (https://medium.com/@rupesharma203wazuh-single-node-installation-guide-for-home-lab-on-ubuntu-0eb2ca339408)

3. Testing the wazuh availability by opening the webpage on 
	- Webpage : `https://10.0.2.3:443`
	- User: `admin`
	- Password: `n*QH4zpz?nt9Te0SdV5?J5nJGEm+5zKP`

4. starting the Wazuh dashboard anytime before accessing the webpage 
	```bash
	sudo systemctl start wazuh-dashboard
	```
5. Additional :
	- to stop the services
	```bash 
	sudo systemctl stop wazuh-dashboard
	sudo systemctl stop wazuh-indexer
	sudo systemctl stop wazuh-manager
	```
	- to check what services are running :
	```bash
	systemctl list-units --type=service --state=running
	```
	- to check available system resources 
	```bash
	free -h
	```
	- check which services are using the most system resources
	```bash
	top 
	```
### 20 June 2026
---
1. installing wazuh agent on second device 

	#### Issue 2.0 - Network conflict where two devices have same IP
	---
	1. Ping to check connectiviy between two devices `ip a` command to check

	- manager IP : `10.0.2.3`

	- victim IP : `10.0.2.15`

	- need to resolve the issue of having the same ip addresses
		- Create NAT network
		- assign two devices to NAT network
		- resolved

	- cmd to check connectivity : `ping -c 4 10.0.2.3`

- Installation steps on wazuh manger agent deployment page:
	- package to install : DEB(debian) amd 64 | _extra info : RPM (red hat package manager)_
	- server address : `10.0.2.3`
	- cmd to run for installation on agent :
		```bash
		wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.5-1_amd64.deb && sudo WAZUH_MANAGER='10.0.2.3' dpkg -i ./wazuh-agent_4.14.5-1_amd64.deb
		```
	- cmd to start agent :

		```bash
		sudo systemctl daemon-reload
		sudo systemctl enable wazuh-agent
		sudo systemctl start wazuh-agent
		```
	- cmd to check wazuh manager status :
		```bash
		sudo systemctl status wazuh-manager
		sudo systemctl status wazuh-indexer
		sudo systemctl status wazuh-dashboard	
		```

		#### Issue 3.0 - Succesfull setup but unable to connect on wazuh manager
		---
		- TCP doesnt work, but DHCP(ping works)

		- troubleshooting :

			```bash
			sudo nc -l 1516
			```

			`nc` is a simple TCP server/client. If `-l` is used, it acts as a server. Otherwise it acts as a client. Used to test connectivity to a specific port.

		- solution : add `sudo` before running the manager, to ensure it has permissions to access ports


2. Installing theHIVE on manager node

	Detail regarding wazuh and the hive (https://wazuh.com/blog/using-wazuh-and-thehive-for-threat-protection-and-incident-response/)

	Main : theHIVE setup guide (https://docs.strangebee.com/thehive/installation/installation-guide-linux-standalone-server/)

	theHIVE hardware requirements for standard production (https://docs.strangebee.com/thehive/installation/system-requirements/)

	- Before installaiton, i must first be aware of theHIVE's architecture (TheHive application, database and indexing engine, and file storage), the current setup will be for a standalone server
	- Installaiton will be done using Docker for futureproof reasons
	- requirements :
		- docker engine
		- docker compose plugin
		- jq

	 #### Issue 4.0 - NAT network setup but no internet access 
	 ---
	- solution (but lowkey like a duct tape fix): manually set the DNS server to 8.8.8.8 && 1.1.1.1 , the issue was DNS server was failing (as evident of ping google.com failing but ping 8.8.8.8 working)


	Steps (Based on theHIVE setup guide): 
	1. update docker , install docker compose
	2. clone the repository
		```bash
		git clone https://github.com/StrangeBeeCorp/docker.git
		```
	3. navigate to prod1-thehive
		```bash
		cd docker/prod1-thehive
		```
	4. Before starting TheHive, initialize the environment using the provided init.sh script. within ./scripts
		```bash
		bash ./script/init.sh
		```
	5. start the docker containers containing the services theHive uses
		```bash
		sudo docker-compose up
		```
		- `-d` is to run in backgorund, omit to run in forground
		To reset when there's an error running up:
		```bash
		sudo docker-compose down
		```
		
		#### Issue 5.0 - docker compose corrupt 
		---
		- during  installation , several attempts of installing the hive with docker failed and the issues narrowed down to insufficient reources, no fixes were done


### 21 June 2026
---

#### Issue 6.0 - Elasticsearch Failed to Start During TheHive Deployment
---

After running `docker compose up`, the deployment failed because the **TheHive** container was marked as **unhealthy**, even though both the **Cassandra** and **Elasticsearch** containers had started.

Initial output:

```bash
compose up

Starting cassandra     ... done
Starting elasticsearch ... done

ERROR: for thehive  Container "d71af42b9a25" is unhealthy.
ERROR: Encountered errors while bringing up the project.
```

### Investigation

The following troubleshooting steps were performed:

1. Checked the status of the running containers.

```bash
docker ps
```

2. Examined the container logs, which revealed the following error:

```text
error.message: can not run elasticsearch as root
```

3. Investigated possible causes and identified the following:

* Previous Docker commands had been executed using `sudo`, causing Elasticsearch to attempt running as the root user.
* The Docker Compose Plugin (`docker compose`) had not been installed because `docker-compose` and `docker compose` were mistakenly assumed to be the same tool.
* The virtual machine had limited memory, while Cassandra, Elasticsearch, and TheHive each required a significant amount of RAM.

### Troubleshooting Performed

The following actions were taken in an attempt to resolve the issue:

1. Rebuilt the Docker environment from a clean state.

2. Installed Docker's official repository and the Docker Compose Plugin.

3. Repeated the TheHive installation steps without using `sudo`.

4. Increased the virtual machine memory allocation from **6 GB** to **10 GB**.

5. Re-ran the deployment using:

```bash
docker compose up
```

6. Verified the status of the containers using:

```bash
docker compose ps
```

Cassandra and Elasticsearch eventually reported a **healthy** status.

### Outcome

Although the dependency services (Cassandra and Elasticsearch) became healthy after troubleshooting, **TheHive itself remained unable to start successfully**. The issue could not be fully resolved during this stage of the project, and further deployment attempts were postponed due to hardware limitations on the development machine.
