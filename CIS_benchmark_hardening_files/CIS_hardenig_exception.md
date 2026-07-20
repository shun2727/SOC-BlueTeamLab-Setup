# CIS Benchmark Hardening — Exception & Deviation Log

**System:** Ubuntu 22.04 LTS — SOC Lab Host (Proxmox VM) running Wazuh Manager, TheHive, Cortex (via Docker)
**CIS Benchmark Used:** CIS Ubuntu Linux 22.04 LTS Benchmark (matching ComplianceAsCode SSG content)
**Profile Applied:** Level 1 - Server (`xccdf_org.ssgproject.content_profile_cis_level1_server`)
**Tool Used:** OpenSCAP 1.2.17 + ComplianceAsCode SSG v0.1.81 (`ssg-ubuntu2204-ds.xml`)
**Date of Remediation:** 2026-07-15
**Performed By:** _(your name / role)_

---

## Summary

- **Total rules evaluated:** 398
- **Rules passed (post-remediation):** 390
- **Rules failed / excluded:** 8
- **Of the 8:** 1 intentionally excluded pre-remediation (ip_forward); 7 identified post-remediation as either not applicable, not automatable, or requiring a manual decision

---

## Exception Entries

### Exception #1 — IPv4 Forwarding

| Field | Detail |
|---|---|
| **Rule ID** | `xccdf_org.ssgproject.content_rule_sysctl_net_ipv4_ip_forward` |
| **Rule Title** | Disable Kernel Parameter for IPv4 Forwarding |
| **Default Requirement** | Sets `net.ipv4.ip_forward = 0` to prevent the host from routing traffic between network interfaces (reduces attack surface / prevents unintended routing). |
| **Why It Was Not Applied** | This host runs Docker (TheHive, Cortex, Elasticsearch via `docker-proxy`). Docker requires `net.ipv4.ip_forward = 1` to route traffic between containers and the host/external network. Setting this to `0` would break container networking for TheHive/Cortex. Excluded from the remediation script prior to running it (rule block commented out). |
| **Risk Accepted** | Low–Medium. IP forwarding is required for legitimate container operation on this host; the host is not acting as a general-purpose router beyond Docker's managed scope. |
| **Compensating Control** | Docker's own iptables/nftables rules (DOCKER, DOCKER-USER chains) restrict forwarded traffic to defined container port mappings only. Host firewall additionally restricts inbound access to required ports. |
| **Status** | Excluded pre-remediation — documented and accepted |

---

### Exception #2 — Separate /tmp Partition

| Field | Detail |
|---|---|
| **Rule ID** | `xccdf_org.ssgproject.content_rule_partition_for_tmp` |
| **Rule Title** | Ensure /tmp Located On Separate Partition |
| **Default Requirement** | Requires `/tmp` to be mounted as its own dedicated partition (separate from root `/`), typically with `nodev`, `nosuid`, `noexec` options applied. |
| **Why It Was Not Applied** | This VM was provisioned with a single-partition disk layout (standard for the base image used in this lab). Creating a separate `/tmp` partition after the fact requires repartitioning/reformatting the disk, which is disruptive and out of scope for a config-level hardening pass. |
| **Risk Accepted** | Low. This is primarily a defense-in-depth control against `/tmp`-based privilege escalation/DoS via disk-fill attacks. Lab environment has controlled, single-admin access reducing this risk. |
| **Compensating Control** | Standard file permissions on `/tmp` remain in effect; no untrusted multi-user access exists on this host. |
| **Status** | Not applied — architectural limitation, documented and accepted |

---

### Exception #3 — Root Access Control (su restriction)

| Field | Detail |
|---|---|
| **Rule ID** | `xccdf_org.ssgproject.content_rule_ensure_root_access_controlled` |
| **Rule Title** | Ensure Access to the su Command Is Restricted |
| **Default Requirement** | Restricts use of the `su` command to members of a specific group (e.g., via `pam_wheel.so` in `/etc/pam.d/su`), so only authorized users can attempt to switch to root. |
| **Why It Was Not Applied** | Not automatically remediated in this run; requires manually configuring the `wheel`/admin group and editing PAM config. |
| **Risk Accepted** | Medium. This is a legitimate, fixable gap rather than an architectural limitation. |
| **Compensating Control** | Single-administrator lab environment; only one operator has console/login access to this host. |
| **Status** | Open — recommended for manual remediation (see Notes) |

---

### Exception #4 — GRUB Bootloader Password (BIOS)

| Field | Detail |
|---|---|
| **Rule ID** | `xccdf_org.ssgproject.content_rule_grub2_password` |
| **Rule Title** | Set Boot Loader Password |
| **Default Requirement** | Requires a password to modify GRUB boot parameters at startup, preventing bypass of normal login via single-user/rescue mode. |
| **Why It Was Not Applied** | Requires manually generating a GRUB password hash and applying it — not something OpenSCAP's automated fix can safely do without an operator-supplied password. |
| **Risk Accepted** | Low for this environment. This VM is hosted on Proxmox; console access to the VM already requires authenticated access to the Proxmox host itself, which functions as a compensating access control. |
| **Compensating Control** | Proxmox host-level authentication gates access to the VM console before GRUB is ever reachable. |
| **Status** | Not applied — accepted due to virtualization platform access control |

---

### Exception #5 — GRUB Bootloader Password (UEFI)

| Field | Detail |
|---|---|
| **Rule ID** | `xccdf_org.ssgproject.content_rule_grub2_uefi_password` |
| **Rule Title** | Set Boot Loader Password (UEFI) |
| **Default Requirement** | Same as Exception #4, for UEFI boot mode specifically. |
| **Why It Was Not Applied** | Same reasoning as Exception #4 — this VM boots via BIOS/standard boot, not UEFI, so this rule's applicability is minimal in addition to the manual-password requirement. |
| **Risk Accepted** | Low, and largely not applicable given the VM's boot configuration. |
| **Compensating Control** | Proxmox host-level authentication (as above). |
| **Status** | Not applicable / not applied — documented |

---

### Exception #6 — nftables Service Enabled

| Field | Detail |
|---|---|
| **Rule ID** | `xccdf_org.ssgproject.content_rule_service_nftables_enabled` |
| **Rule Title** | Ensure nftables Service is Enabled |
| **Default Requirement** | Requires `nftables.service` to be actively running as the host's firewall backend. |
| **Why It Was Not Applied** | This host's active network filtering approach was not fully finalized as `nftables` during this remediation pass — needs a deliberate decision on which firewall backend (nftables vs. ufw vs. none, relying on Docker-managed iptables rules) this host should standardize on before enabling. |
| **Risk Accepted** | Medium — to be resolved. |
| **Compensating Control** | Docker manages its own iptables rules (DOCKER/DOCKER-USER chains) for container traffic in the interim. |
| **Status** | Open — decision pending (see Notes) |

---

### Exception #7 — nftables Default Deny Policy

| Field | Detail |
|---|---|
| **Rule ID** | `xccdf_org.ssgproject.content_rule_nftables_ensure_default_deny_policy` |
| **Rule Title** | Ensure nftables Default Deny Firewall Policy |
| **Default Requirement** | Requires nftables base chains (input/forward/output) to have a default DROP/REJECT policy rather than ACCEPT. |
| **Why It Was Not Applied** | **No automated remediation exists for this rule in ComplianceAsCode SSG v0.1.81** — the generated fix script explicitly outputs `FIX FOR THIS RULE IS MISSING!` for this rule ID. This is a known gap in the tooling, not a configuration oversight. |
| **Risk Accepted** | Medium — to be resolved manually if a default-deny policy is desired, contingent on the decision in Exception #6. |
| **Compensating Control** | None currently beyond Docker's own container-scoped iptables rules. |
| **Status** | Open — no automated fix available; manual configuration required if pursued |

---

### Exception #8 — SSH User Access Restriction

| Field | Detail |
|---|---|
| **Rule ID** | `xccdf_org.ssgproject.content_rule_sshd_limit_user_access` |
| **Rule Title** | Limit Users' SSH Access |
| **Default Requirement** | Requires `sshd_config` to explicitly restrict which users/groups may authenticate via SSH (e.g., `AllowUsers`/`AllowGroups`). |
| **Why It Was Not Applied** | The SSH service (`sshd`) is confirmed **not running/enabled** on this host (verified via `systemctl status ssh`). This rule checks a configuration file for a service that isn't in use on this system, making the finding not applicable in practice. |
| **Risk Accepted** | None — no active attack surface since the service is disabled. |
| **Compensating Control** | SSH daemon disabled entirely; access to this host is via Proxmox console only. |
| **Status** | Not applicable — service not in use |

---

## Verification Performed After Remediation

- [x] Re-ran `ss -tulnp` and confirmed all required ports still listening (Wazuh 1514/1515/55000, Dashboard 443, TheHive 9000, Cortex/other 9443, Elasticsearch 9200/9300 localhost-only)
- [x] Confirmed `sysctl net.ipv4.ip_forward` still returns `1`
- [ ] Confirmed TheHive web UI loads and is reachable
- [ ] Confirmed Cortex/other Docker service loads and is reachable
- [ ] Confirmed `wazuh-manager` / `wazuh-remoted` / `wazuh-authd` services are `active (running)`
- [x] Re-ran OpenSCAP audit and compared pre/post reports (`results-pre.xml` vs `results-post.xml`)
- [ ] Proxmox snapshot taken before remediation (snapshot name/date: __________)

---

## Notes / Additional Context

This host is part of a SEED Labs-based SOC training environment integrating Wazuh, TheHive, Cortex, and Velociraptor. Hardening was scoped to CIS Level 1 Server with documented exceptions above for container-dependent services, architectural (partitioning/boot) limitations, and one confirmed tooling gap (Exception #7).

**Open items for follow-up (not yet remediated, tracked for future work):**
1. Restrict `su` access to an admin group (Exception #3)
2. Decide on and standardize the host's firewall backend — nftables vs. ufw vs. Docker-managed iptables only (Exceptions #6 and #7)

**Rationale for accepting current gaps:** This is a single-operator lab environment used for blue team training (SEED Labs scenarios + Wazuh/TheHive/Cortex/Velociraptor integration), not a multi-user production system. Risk acceptance decisions reflect that context and would be reassessed if the environment's threat model changes (e.g., additional users, external network exposure).