In cybersecurity, CERT stands for Computer Emergency Response Team.

**Ping (ICMP) Overview**

* Ping uses the **Internet Control Message Protocol (ICMP)**, not TCP or UDP.
* ICMP operates at the **Network Layer (Layer 3)** of the OSI model.
* Ping **does not use port numbers**, as ports only apply to TCP and UDP protocols.
* A ping request sends an **ICMP Echo Request** packet to the destination host.
* If the destination is reachable and ICMP is allowed, it responds with an **ICMP Echo Reply**.
* ICMP packets are processed directly by the **operating system's kernel**, so no application or service listens on a specific port for ping requests.
* Ping is primarily used to **verify network connectivity** and measure the round-trip time between two hosts.

Cmd : 
`Wget` :  a free, command-line software utility used to download files and content from web servers. 
`curl` : 
`nmap` :
`netstat` : 