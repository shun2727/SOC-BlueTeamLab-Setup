### 14 July 2026
---
step by step guide on how to setup the CIS benchamark using USG: https://www.youtube.com/watch?v=wyEX0eyoK88

| Method                          | Official CIS Compliance | Automatic Fixes | Speed | Learning Value | Best Use                           |
| ------------------------------- | ----------------------- | --------------- | ----- | -------------- | ---------------------------------- |
| **Ubuntu Security Guide (USG)** | ⭐⭐⭐⭐⭐                   | Yes             | ⭐⭐⭐⭐⭐ | ⭐⭐             | Enterprise, production, compliance |
| **OpenSCAP**                    | ⭐⭐⭐⭐                    | Some            | ⭐⭐⭐⭐  | ⭐⭐⭐            | Compliance auditing                |
| **Manual CIS Hardening**        | ⭐⭐⭐⭐⭐                   | No              | ⭐     | ⭐⭐⭐⭐⭐          | Learning, coursework               |
| **Lynis**                       | ⭐⭐                      | No              | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐           | General security assessment        |

- openscap will be used here to speed up the process, otherwise manual hardening requires me to read the benchmark and configure the system myself
- unfortunateley, for ubuntu 22.04 openscap is not installable via apt therefore i have to manually get the packages from the source instead. The version of oscap is 1.2.17

1. Run `sudo ss -tulnp` and dump the output to a file — this is your "as-is" baseline to check what are the current ports being used . Then save into this github repo

For OpenSCAP, it is made up of 3 items
- OpenSCAP scanner (oscap)
- security content (CIS/SCAP rules)
- Operating System-Specific Content (ssg) 

1. Install the scanner (- OpenSCAP scanner (oscap))
```bash
sudo apt update
sudo apt install -y libopenscap8
which oscap
oscap --version
```
2.  Get the current SSG content release URL and download
curl - a command-line tool and library used to transfer data to and from network servers

```bash
curl -s https://api.github.com/repos/ComplianceAsCode/content/releases/latest | grep browser_download_url
```
install and unzip the file (security content (CIS/SCAP rules))
```bash
cd ~
wget https://github.com/ComplianceAsCode/content/releases/download/v0.1.81/scap-security-guide-0.1.81.zip
unzip scap-security-guide-0.1.81.zip
cd scap-security-guide-0.1.81
```
[confirm] if the pacge is there 
```bash
ls | grep ubuntu2204
```

[confirm] check available profiles in the file ( Operating System-Specific Content (ssg))
```bash
oscap info ssg-ubuntu2204-ds.xml
```
3. Audit only — run oscap xccdf eval without --remediate, review the HTML report to see what fails. Must run in the directory contianing the .xml files

```bash
sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis_level1_server \
  --results ~/openscap-results/results-pre.xml \
  --report ~/openscap-results/report-pre.html \
  ssg-ubuntu2204-ds.xml
```
- `oscap xccdf eval` — the core command: "evaluate this system against an XCCDF checklist"
- `--profile xccdf_org.ssgproject.content_profile_cis_level1_server` — tells oscap which rule-set to use, since the file contains multiple profiles (CIS Level 1 Server, Level 2, Workstation, STIG, etc.)
- `--results ~/openscap-results/results-pre.xml` — saves raw machine-readable pass/fail results (used later for stats/comparison)
- `--report ~/openscap-results/report-pre.html` — saves a human-readable HTML report you can open in a browser
ssg-ubuntu2204-ds.xml — the actual checklist file being evaluated against

4. Open the report and check the results 
- Error : file access was denied because its owned by root and firefox can't access it
- Fix : `sudo chown bluteamlab:blueteamlab x.htl`
```bash
firefox /var/log/scap/report-pre.html
```

5. Generate e script file to exclude specific rules, creates fix-script.sh (arbituary name can be replaced)

```bash
oscap xccdf generate fix \
  --profile xccdf_org.ssgproject.content_profile_cis_level1_server \
  --output ~/openscap-results/fix-script.sh \
  ssg-ubuntu2204-ds.xml
```

6. Create a snapshot on the proxmox server, then change the .sh 

	Phase 1 :
	1. extract secitons related to things that may affect out operations 
	 - cat fix_script.sh | grep -n -i -A 10 "firewall\|iptables\|ufw\|nftables" fix-script.sh
	 - cat 

	2. find and replace ip_foward section using `sed` (this part is guided with AI), then do your own verification 
	
	```bash
	sed -i '/# BEGIN fix (152 \/ 398) for/,/# END fix for .*ip_forward/ s/^/#/' fix-script.sh
	```

	Phase 2 : executing the script 
	1. run the edited script
	2. confirm ip_foward wasnt touched
		`sysctl net.ipv4.ip_forward`
	3. check if the port survived
		`sudo ss -tulnp`
	4. confirm if the actual services are healthy andnot just the ports
		`sudo systemctl status wazuh-manager`
		`docker ps`
	5. re-run the script to check after status 
		```bash
			sudo oscap xccdf eval \
		--profile xccdf_org.ssgproject.content_profile_cis_level1_server \
		--results ~/openscap-results/results-post.xml \
		--report ~/openscap-results/report-post.html \
		ssg-ubuntu2204-ds.xml
		```
		`oscap xccdf generate stats /var/log/scap/results-post.xml`
	6. 
sudo oscap xccdf eval \
  --profile xccdf_org.ssgproject.content_profile_cis_level1_server \
  ssg-ubuntu2204-ds.xml | grep -B 3 "Result.*fail" | grep -E "Rule|Result|Title"
where would this output to ? the terminal ?




	1. Run the (edited) fix script
	— This applies only the fixes you chose to keep, based on what you reviewed beforehand.

	2. Don't close your current terminal/SSH session
	— If the script breaks SSH access, this session is your only way back in. Closing it before verifying is how people get permanently locked out.

	3. Open a second, fresh SSH session
	— Tests whether a new login still works, since your current session may still work even if new connections would fail. This is the real test of whether SSH survived.

	4. Check listening ports (ss -tulnp)
	— Confirms the script didn't close Wazuh/TheHive/SSH ports. Compares against your earlier baseline to catch anything that disappeared.

	5. Check the services are actually running (systemctl status)
	— A port can look "fine" while the underlying service is actually crashed or misconfigured. This confirms the tool itself is healthy, not just the network side.

	6. Re-run the audit and compare reports
	— Shows you what actually got fixed vs. what's still failing, so you know the hardening worked and can quantify the improvement.

	7. If anything broke — revert to your snapshot
	— This is why the snapshot existed in the first place: instant rollback instead of manual repair or a rebuild.

5. Verify access 

6. Verify services 

7. Review results — oscap xccdf generate stats on the post-remediation results to see pass/fail summary

Error : insufficient space on hard disk 
Solution : extand disk size on proxmox
Steps : 
	- on Proxmox 
	hardware > disks > disk actio > resize > 5Gib
	- on VM 
	lsblk (check size) > (seems ok dy idk )


## 15 July 2026 (wed)
---
2. configure and ensure the logs for seedlabs is working
- previoudly ensureed apache is logged, but since it couldt detect much sql is also logged
- carry out attacks and check against the created rules / create rules for it
- ensure all cases produce an alert that can be fowarded to the hive

3. create thehive response plan, based on the things that we did

4. Based on the meeting report, create a list of things that still need to be done + find ways to integrate veciloraptor


## 16 July 2026 (thurs)
---

3. veciloraptor checking 

4. map our requirements and stuff

## 17 July 2026 (fri)
---

