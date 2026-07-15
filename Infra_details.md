## theHIVE :
theHIVE API key : `59zLXJvvEfECJW3IeKs/mYxgO5CENIqv`

## Wazuh dashboard credentials : 
User: `admin`

Password: `n*QH4zpz?nt9Te0SdV5?J5nJGEm+5zKP`

ip address shows : 10.0.2.15/24, https://10.0.2.15:443


## Proxmox details : 
Ip and port : `https://192.168.90.2:8006`

Username : `root`

Password : `Y0uDunnoAh?` 


## Tailscalse details : 
if using tailscale (set the ip status according to the status) : `100.123.180.101:8006`

tailscale commands :

```bash
sudo tailscale down
sudo tailscale up
tailscale status
```

## Resources :
1. [creating & uploading .ova files to proxmox](https://4sysops.com/archives/ova-import-in-proxmox-83/)


## Ubuntu commads:

ubuntu check amt of cores : nproc
docker engine : like stdlib
docker compose : like libft (depends on stdlib)

## Vlan tagging :
VLAN range for manager : 172.29.1.10–100 | VLAN tag : 901
VLAN range for victim : 172.29.11.10–200 | VLAN tag : 911

## Device open ports
1) Wazuh Manager
	1514/TCP
	Wazuh agent to manager communication port.
	443/TCP
	Used by the Wazuh Dashboard.
	9443/TCP
	Reassigned for TheHive access after the 443 conflict.
2) SSH Victim
	22/TCP
	SSH service was installed and enabled.
	This is the main port used for the brute-force lab scenario.
3) SeedLabs
	80/TCP
	Exposed for the web container in the SeedLabs Docker setup.
	This was used for the lab web application.