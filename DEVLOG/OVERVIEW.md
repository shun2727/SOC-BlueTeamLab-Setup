![WBS](/Images/Work_Breakdown_Structure.png)

# Planned to do list
- [x] wazuh manager installation
- [x] wazuh agent installaitons
- [x] The HIVE installaiton 
- [	] Manager node hardening according to CIS benchmark
- [ ] Have a complete flow 

Additional requirements:
- double confirm the required resources
- understand and use the wazuh manager tools to demonstrate understanding

# Hardware requiremnets
Wazuh manager
- Hardware requirements :
	- Agents : 1–25
	- Cores : 4 vCPU
	-  RAM :  8 GiB 
	- Storage : 50 GB

theHIVE
- Hardware requirements :
	- 

# Progress summary
## Week 1 & 2 :
- NULL

## Week 3 :
- Installed manager node and a victim node
- Intalled Wazuh manager and Wazuh agent software on both nodes
- Attempted to install theHIVE on manager node 
	- failed due to insufficient resources
- Conducted meeting with industry supervisor 

### Week 3 Issues :
---
- [Issue 1.0 - Wazuh Manager Installation Fail Due to Insufficient Resource](WEEK3.md#issue-10---wazuh-manager-installation-fail-due-to-insufficient-resource)
- [Issue 2.0 - Network Conflict Where Two Devices Have Same IP](WEEK3.md#issue-20---network-conflict-where-two-devices-have-same-ip)
- [Issue 3.0 - Succesfull Setup but Unable to Connect on Wazuh Manager](WEEK3.md#issue-30---succesfull-setup-but-unable-to-connect-on-wazuh-manager)
- [Issue 4.0 - NAT Network Setup but No Internet Access](WEEK3.md#issue-40---nat-network-setup-but-no-internet-access)
- [Issue 5.0 - Docker Compose Corrupt](WEEK3.md#issue-50---docker-compose-corrupt)
- [Issue 6.0 - Elasticsearch Failed to Start During TheHive Deployment](WEEK3.md#issue-60---elasticsearch-failed-to-start-during-thehive-deployment)

## Week 4 :
- Researching restructuring scope of the project 
- Researched on creating rules on Wazuh 
- Reduced amount of logs (noise) shown on wazuh manager by configuring ossec file
- Created scenario 1 SSH bruteforce login
	- ensured conectivity between devices
	- installed openssh servers
	- conducted attempt to connect to victim device via an "attack"
- Upload wazuh manager .ova and toproxmox interface

### Week 4 Issues :
---
- [Issue 7.0 - SSH Server Installation Blocked by Package Manager Lock](WEEK4.md#issue-70---ssh-server-installation-blocked-by-package-manager-lock)

## Week 5 
- Discusison to reduce scope 
	- exclude MISP and OPENCTI
	- focus on L1 and L2
	- use seedlabs to create scenarios rather then building from scratch
- Set up seedlabs on the seedlabs scenario planned
	- upload the .ova to proxmox
	- configure the ips
	- create documentaiton on the possible attacks
- Set up theHIVE 
	- create accounts for theHIVE users
	- obtain community lisence for theHIVE
- Move disks around proxmox
- Intergrate wazuh and theHIVE
	- Ensure alerts from Wazuh can be seen on theHIVE


### Week 5 Issues :
---
- [Issue 8.0 - Wazuh Agent Installation Failed Due to SSL Certificate Verification](WEEK5.md#issue-80---wazuh-agent-installation-failed-due-to-ssl-certificate-verification)
- [Issue 9.0 - OVA Upload Failed Through Proxmox Web Interface During VM Migration](WEEK5.md#issue-90---ova-upload-failed-through-proxmox-web-interface-during-vm-migration)
- [Issue 10.0 - Port 443 Conflict Between Wazuh Dashboard and TheHive](WEEK5.md#issue-100---port-443-conflict-between-wazuh-dashboard-and-thehive)
- [Issue 11.0 - Wazuh Alerts Not Being Forwarded to TheHive](WEEK5.md#issue-110---wazuh-alerts-not-being-forwarded-to-thehive)
- [Issue 12.0 - SSL Certificate Verification Failure Between Wazuh and TheHive](WEEK5.md#issue-120---ssl-certificate-verification-failure-between-wazuh-and-thehive)

## Week 6 
- Conduct research on the roles for SOC L1 to L3
	- narrowed down focus of fyp project to focus on L1 and L2 
- Created a case template for the ssh lab scenario
-  Set up the seedlabs device on proxmox
	- condigure ossec file to include the logs from apache and sql
	- configure the interfaces of apache and sql to allow logs to be fowarded

### Week 6 Issues :
---