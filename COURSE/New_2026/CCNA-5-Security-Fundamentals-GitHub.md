# CCNA 200-301: Domain 5.0 Security Fundamentals (15%)

All IPs come from documentation ranges (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24). Replace every `<PLACEHOLDER>` with your own secret. IOS syntax varies slightly by platform and version, so check yours.

---

## 📚 Table of Contents (Clickable GitHub Menu)

- [5.1 Key Security Concepts](#51-key-security-concepts)
  - [Technical explanation](#technical-explanation)
  - [Banking example](#banking-example)
  - [IOS commands (baseline hardening)](#ios-commands-baseline-hardening)
  - [Analogy](#analogy)
  - [Troubleshooting (security triage)](#troubleshooting-security-triage)
- [5.2 Security Program Elements (Awareness, Training, Physical Access)](#52-security-program-elements-awareness-training-physical-access)
  - [Technical explanation](#technical-explanation-1)
  - [Banking example](#banking-example-1)
  - [IOS commands](#ios-commands)
  - [Analogy](#analogy-1)
  - [Troubleshooting](#troubleshooting)
- [5.3 Device Access Control Using Local Passwords](#53-device-access-control-using-local-passwords)
  - [Technical explanation](#technical-explanation-2)
  - [Configuration](#configuration)
  - [Banking example](#banking-example-2)
  - [Verification](#verification)
  - [Analogy](#analogy-2)
  - [Troubleshooting](#troubleshooting-1)
- [5.4 Password Policy Elements and Alternatives](#54-password-policy-elements-and-alternatives)
  - [Technical explanation](#technical-explanation-3)
  - [Configuration (IOS)](#configuration-ios)
  - [Banking example](#banking-example-3)
  - [Verification](#verification-1)
  - [Analogy](#analogy-3)
  - [Troubleshooting](#troubleshooting-2)
- [5.5 IPsec Remote Access and Site-to-Site VPNs](#55-ipsec-remote-access-and-site-to-site-vpns)
  - [Technical explanation](#technical-explanation-4)
  - [Configuration (site-to-site, IKEv1 crypto map, illustrative)](#configuration-site-to-site-ikev1-crypto-map-illustrative)
  - [Banking example](#banking-example-4)
  - [Verification](#verification-2)
  - [Analogy](#analogy-4)
  - [Troubleshooting](#troubleshooting-3)
- [5.6 Access Control Lists](#56-access-control-lists)
  - [Technical explanation](#technical-explanation-5)
  - [Configuration](#configuration-1)
  - [Banking example](#banking-example-5)
  - [Verification](#verification-3)
  - [Analogy](#analogy-5)
  - [Troubleshooting](#troubleshooting-4)
- [5.7 Layer 2 Security: Port Security, DHCP Snooping, DAI](#57-layer-2-security-port-security-dhcp-snooping-dai)
  - [Technical explanation](#technical-explanation-6)
  - [Configuration](#configuration-2)
  - [Banking example](#banking-example-6)
  - [Verification](#verification-4)
  - [Analogy](#analogy-6)
  - [Troubleshooting](#troubleshooting-5)
- [5.8 AAA: Authentication, Authorization, Accounting](#58-aaa-authentication-authorization-accounting)
  - [Technical explanation](#technical-explanation-7)
  - [Configuration](#configuration-3)
  - [Banking example](#banking-example-7)
  - [Verification](#verification-5)
  - [Analogy](#analogy-7)
  - [Troubleshooting](#troubleshooting-6)
- [5.9 Wireless Security Protocols (WPA, WPA2, WPA3)](#59-wireless-security-protocols-wpa-wpa2-wpa3)
  - [Technical explanation](#technical-explanation-8)
  - [Banking example](#banking-example-8)
  - [IOS/WLC commands](#ioswlc-commands)
  - [Analogy](#analogy-8)
  - [Troubleshooting](#troubleshooting-7)
- [5.10 Configure a WLAN in the GUI Using WPA2 PSK](#510-configure-a-wlan-in-the-gui-using-wpa2-psk)
  - [Technical explanation](#technical-explanation-9)
  - [CLI equivalent (AireOS, for reference, check your version)](#cli-equivalent-aireos-for-reference-check-your-version)
  - [Banking example](#banking-example-9)
  - [Verification](#verification-6)
  - [Analogy](#analogy-9)
  - [Troubleshooting](#troubleshooting-8)
- [Exam tips](#exam-tips)
- [References](#references)

---
## 5.1 Key Security Concepts

### Technical explanation

| Term | Meaning | Example |
|---|---|---|
| **Asset** | Anything of value | Customer database, core-banking server |
| **Threat** | Potential danger that could harm an asset | Ransomware gang, insider, DDoS |
| **Vulnerability** | Weakness that a threat can use | Unpatched IOS, default password, Telnet |
| **Exploit** | Code or technique that uses a vulnerability | Script targeting a known CVE |
| **Risk** | Likelihood × impact of a threat using a vulnerability | Unpatched internet-facing server |
| **Mitigation** | Control that reduces risk | Patching, ACLs, MFA, segmentation |
| **Zero-day** | Exploit for a flaw with no patch yet | |

**CIA triad:** **Confidentiality** (only authorized access, e.g. encryption), **Integrity** (data not altered, e.g. hashing), **Availability** (systems usable, e.g. redundancy).

**Common attacks and mitigations (exam favorites):**

| Attack | What happens | Mitigation |
|---|---|---|
| **Reconnaissance** | Ping sweeps and port scans to map the network | ACLs, IPS, disable unused services |
| **DoS / DDoS** | Flood a target to exhaust resources | Rate limiting, ISP scrubbing, redundancy |
| **Spoofing** | Fake source IP/MAC/ARP | uRPF, port security, DAI |
| **Man-in-the-middle** | Attacker sits between two parties | Encryption (SSH, TLS, IPsec), DAI |
| **Malware** (virus, worm, trojan, ransomware) | Malicious code | Endpoint protection, patching, segmentation, backups |
| **Phishing / social engineering** | Tricks the user | Awareness training, MFA, email filtering |
| **Password attacks** (brute force, dictionary) | Guess credentials | Lockout, MFA, complexity |
| **Reflection/amplification** | Spoofed requests to third parties | Filtering, uRPF |
| **Insider threat** | Misuse of legitimate access | Least privilege, AAA accounting |
| **VLAN hopping** | Switch spoofing or double tagging | Disable DTP, change native VLAN, trunk allowed lists |

**Defense in depth:** layered controls (perimeter firewall, ACLs, segmentation, endpoint security, AAA, monitoring) so one failure does not expose everything.

### Banking example

An internet-facing web server runs an unpatched component, which is a **vulnerability**. An attacker's script is the **exploit**, ransomware is the **threat**, and the risk is high because the server holds customer data. Mitigations: patch, place the server in a DMZ, restrict access with ACLs, apply MFA for admins, and keep offline backups.

### IOS commands (baseline hardening)

```
no ip http server
no ip http secure-server          ! only if the web UI is not needed
no cdp run                        ! or restrict it per interface
no ip source-route
no ip domain-lookup
banner login ^C Authorized access only. Activity is monitored. ^C

! Anti-spoofing on an Internet edge interface
interface GigabitEthernet0/1
 ip verify unicast source reachable-via rx

! Shut down and park unused switch ports
interface range GigabitEthernet0/10-24
 switchport mode access
 switchport access vlan 999
 shutdown
```

### Analogy

A bank branch: the **vault** is the asset, a **robber** is the threat, an **unlocked back door** is the vulnerability, the **crowbar or stolen key** is the exploit, and **locks, guards, cameras, and a time-lock** are layered mitigations.

### Troubleshooting (security triage)

- **Sudden high CPU or link saturation:** `show processes cpu sorted`, `show interfaces`, `show ip traffic`. Look for a scan or flood.
- **Unauthorized change suspected:** `show archive log config all` and AAA accounting logs.
- **Unknown device on the LAN:** `show mac address-table`, `show ip arp`, `show ip dhcp snooping binding`.
- **Repeated login failures:** `show login failures`, syslog entries.

---

## 5.2 Security Program Elements (Awareness, Training, Physical Access)

### Technical explanation

A security program combines **people, process, and technology**. Most breaches start with a person, so users are a control, not only a risk.

| Element | Purpose | Banking example |
|---|---|---|
| **User awareness** | Ongoing, general reminders | Posters, monthly tips, **simulated phishing** campaigns |
| **Training** | Formal, role-based, with tracked completion | Annual cyber training; extra modules for tellers, IT admins, and the payments team |
| **Education** | Deeper knowledge for security staff | Certifications (CCNA, Security+) |
| **Physical access control** | Prevent unauthorized physical access | Badges, biometrics, locks, CCTV, guards |

**Physical controls by type:**
- **Preventive:** locked server racks, badge readers, **mantraps**, cages.
- **Detective:** CCTV, door-open alarms, access logs.
- **Deterrent:** signs, visible guards, lighting.

**Why physical access matters:** anyone with physical access to a device can use the **console port, password recovery, or a rogue device**. Software controls can be bypassed.

### Banking example

The data center needs **two-factor entry** (badge plus fingerprint) through a mantrap, with visitor escort, a logged sign-in sheet, and 90 days of CCTV retention. Branch network closets stay locked, with unused wall jacks disabled, because an attacker plugging a laptop into an empty teller-area jack is a real risk. ATM sites use tamper alarms.

### IOS commands

```
! Reduce the impact of physical access
line console 0
 exec-timeout 5 0
 login local
line aux 0
 no exec
 transport input none

! Protect wall jacks
interface range GigabitEthernet0/10-24
 shutdown
! or use port security (see 5.7)

! Optional, use with caution:
no service password-recovery      ! disables ROMMON password recovery; recovery then wipes the config
```

### Analogy

Awareness and training are teaching **every employee to spot a fake courier** at the door. Physical controls are the **locked door, guard, and camera**. If the fake courier walks in anyway, nothing on the network can fully protect you.

### Troubleshooting

- **High click rate in phishing simulations:** more targeted training, add MFA and mail filtering.
- **Tailgating at doors:** mantraps, anti-passback, a challenge-everyone culture.
- **Unknown device on a wall jack:** `show mac address-table interface <int>`, then shut the port and investigate.
- **Locked out after `no service password-recovery`:** you must wipe the config. Document before enabling.

---

## 5.3 Device Access Control Using Local Passwords

### Technical explanation

**Password storage types in IOS:**

| Type | Method | Strength |
|---|---|---|
| **0** | Plaintext | None |
| **7** | Reversible obfuscation (`service password-encryption`) | **Weak**, trivially decoded; stops only shoulder-surfing |
| **5** | MD5 hash (default for `enable secret` on many versions) | Moderate, legacy |
| **8** | PBKDF2-SHA-256 | Strong |
| **9** | scrypt | Strongest |

- **`enable secret` overrides `enable password`**, so always use `secret`.
- `username <u> secret` is hashed. `username <u> password` is not.
- **Line passwords** (`line vty` → `password` + `login`) share one password for everyone. **`login local`** uses per-user accounts, which is better for accountability.
- **Privilege levels:** 0 to 15. User EXEC is 1, privileged EXEC is 15.

### Configuration

```
hostname BR-SW1
enable algorithm-type scrypt secret <ENABLE-SECRET>
username admin privilege 15 algorithm-type scrypt secret <ADMIN-PASS>
username teller1 privilege 1 secret <TELLER-PASS>
service password-encryption
security passwords min-length 12

! Brute-force protection
login block-for 120 attempts 3 within 60
login on-failure log
login on-success log

line console 0
 login local
 exec-timeout 5 0
 logging synchronous
! Alternative (shared line password): password <CON-PASS> / login

line vty 0 15
 login local
 transport input ssh
 exec-timeout 5 0

banner login ^C Authorized users only. Activity is monitored. ^C
```

### Banking example

Each engineer has a **named local account** (for audit trails) as a fallback if the central AAA server is unreachable. Break-glass credentials are stored in a password vault, and VTY access is limited to SSH from the management network (see 4.8).

### Verification

```
show running-config | include secret|password
show running-config | section line
show login
show login failures
show users
show privilege
```

### Analogy

A **shared vault code** (line password) means nobody knows who opened the vault. **Individual key cards** (`login local`) record who entered. Type 7 is a **sticky note hidden under the keyboard**: slightly out of sight, not secure.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| Can't enter privileged mode | `enable secret` not set, or wrong password (secret overrides password) |
| `login local` fails | No user exists, or typo in the secret |
| "Password required, but none set" | `login` configured on a line with no `password` |
| Locked out for 120 s | `login block-for` triggered; wait or allow from an exempt ACL (`login quiet-mode access-class`) |
| Passwords visible in the config | Using `password` instead of `secret`, or only type 7 |
| Type 8/9 command not accepted | Platform or IOS version doesn't support it; fall back to type 5 |

---

## 5.4 Password Policy Elements and Alternatives

### Technical explanation

| Element | Good practice |
|---|---|
| **Management** | Unique per person, vaulted, rotated on compromise or role change, never shared or emailed, lockout after repeated failures, history to prevent reuse |
| **Complexity** | Length first (12+ characters or passphrases), mix of character classes, block common or breached passwords |
| **Alternatives** | MFA, certificates, biometrics, passkeys/FIDO2 |

Current guidance (NIST SP 800-63B) favors **length and breach checking** over forced periodic changes. Change passwords when compromise is suspected.

**Multifactor authentication (MFA):** two or more **different** factors.

| Factor | Examples |
|---|---|
| **Something you know** | Password, PIN |
| **Something you have** | Hardware token, authenticator app, smart card |
| **Something you are** | Fingerprint, face, iris |

Two passwords are not MFA.

**Certificates:** X.509 certificates issued by a CA bind an identity to a public key. They are used for VPNs, 802.1X (EAP-TLS), HTTPS, and SSH or SSL device identity. They remove password guessing.

**Biometrics:** convenient and hard to share, but **not secret and not revocable**. Metrics: **FAR** (false accept rate), **FRR** (false reject rate), and **CER/EER** (where they meet). Use liveness detection, and treat biometrics as one factor.

### Configuration (IOS)

```
security passwords min-length 12
login block-for 120 attempts 3 within 60

! Key-based SSH authentication (alternative to passwords)
ip ssh pubkey-chain
 username admin
  key-hash ssh-rsa <KEY-HASH> admin@bank.example

! MFA is applied through the AAA/ISE server (5.8)
```

### Banking example

Internet banking uses password plus a **one-time code** (app or hardware token) for login and for high-value transfers. Network admins authenticate to the **TACACS+ server** with MFA. Staff laptops and VPN use **certificates** (EAP-TLS), and the data center door uses a badge plus fingerprint.

### Verification

```
show login
show login failures
show ip ssh
show crypto pki certificates      ! if certificates are used on the device
```

### Analogy

Passwords are a **key**. MFA is a key **plus** a fingerprint-checked ID. A certificate is a **passport issued by a trusted government**: the border officer trusts the issuer, not your word. A biometric is your **face on the passport**: handy, but you can't change it if it leaks.

### Troubleshooting

- **Users reuse passwords:** vaulting, breach-list checking, and MFA.
- **Locked-out admins:** keep a local break-glass account and out-of-band console access.
- **Certificate login fails:** expired certificate, untrusted CA, wrong clock (NTP from 4.2), or the revocation check is unreachable.
- **High biometric false rejects:** retrain templates, improve capture conditions, offer a fallback factor.
- **SSH key rejected:** wrong key hash or user name, or `pubkey-chain` not configured.

---

## 5.5 IPsec Remote Access and Site-to-Site VPNs

### Technical explanation

IPsec provides **confidentiality** (encryption), **integrity** (hashing/HMAC), **authentication** (PSK or certificates), and **anti-replay**.

| Building block | Notes |
|---|---|
| **IKE** | Negotiates keys and SAs, **UDP 500** (**UDP 4500** for NAT-T) |
| **ESP** | IP protocol **50**, encrypts and authenticates (the one used in practice) |
| **AH** | IP protocol **51**, authentication only, **no encryption**, breaks with NAT |
| **Tunnel mode** | Whole original packet encapsulated (VPN gateways) |
| **Transport mode** | Only the payload is protected (host to host) |
| **Diffie-Hellman** | Key exchange (use group 14 or higher) |

**IKEv1 phases:**
- **Phase 1** builds the **ISAKMP/IKE SA** (the secure management channel). Authentication happens here.
- **Phase 2** builds the **IPsec SAs** (data channel) in quick mode.

IKEv2 simplifies this and is preferred where supported.

| | **Site-to-site VPN** | **Remote-access VPN** |
|---|---|---|
| Connects | Network to network | Single user to network |
| Client | Not needed (gateways do it) | Client software (e.g. Cisco Secure Client/AnyConnect) |
| Typical use | Branch to HQ over the internet | Staff working from home |
| Protocols | IPsec (IKE/ESP), often with GRE, VTI, or DMVPN | IPsec/IKEv2 or **TLS/SSL** |

Remote-access VPNs are often TLS-based because TLS passes through firewalls and NAT easily.

### Configuration (site-to-site, IKEv1 crypto map, illustrative)

```
crypto isakmp policy 10
 encryption aes 256
 hash sha256
 authentication pre-share
 group 14
 lifetime 86400
crypto isakmp key <PSK> address 198.51.100.2

crypto ipsec transform-set BANK-TS esp-aes 256 esp-sha256-hmac
 mode tunnel

ip access-list extended VPN-TRAFFIC
 permit ip 10.10.0.0 0.0.255.255 10.20.0.0 0.0.255.255

crypto map BANK-MAP 10 ipsec-isakmp
 set peer 198.51.100.2
 set transform-set BANK-TS
 match address VPN-TRAFFIC

interface GigabitEthernet0/1
 ip address 203.0.113.2 255.255.255.252
 crypto map BANK-MAP
```

The peer router uses the **mirror-image** ACL and the matching policy. Exempt VPN traffic from NAT. CCNA tests the concepts more than this configuration.

### Banking example

Each branch builds a **site-to-site IPsec tunnel** to HQ over its internet or broadband link, carrying core-banking and ATM traffic encrypted. Staff working remotely use a **remote-access VPN with MFA** to reach internal apps. Keys and PSKs follow the bank's key-management policy.

### Verification

```
show crypto isakmp sa              ! want QM_IDLE
show crypto ipsec sa               ! #pkts encaps / decaps increasing
show crypto map
show crypto isakmp policy
debug crypto isakmp                ! lab only
```

### Analogy

A site-to-site VPN is an **armored truck convoy** between two bank buildings on a public road, with the same contents and routine every day. A remote-access VPN is a **courier with an ID badge** who gets escorted into the building. IKE phase 1 is the two guards checking each other's ID. Phase 2 is agreeing on the lockbox to use for the actual cargo.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| Phase 1 stuck (`MM_NO_STATE`) | UDP 500/4500 blocked, wrong peer IP, mismatched policy (encryption, hash, DH, auth), wrong PSK |
| Phase 1 up, Phase 2 fails | Transform-set mismatch, **ACLs not mirrored**, PFS mismatch |
| Tunnel up, no traffic | Routing, NAT not exempted, ACL blocking, wrong interested traffic |
| `encaps` increases, `decaps` stays at zero | Return path or the remote side is failing |
| Large transfers hang | MTU/MSS issue: lower `ip tcp adjust-mss` |
| Drops after idle | Lifetime or dead-peer-detection mismatch |

---

## 5.6 Access Control Lists

### Technical explanation

ACLs permit or deny packets by header fields.

| Type | Numbers | Matches | Placement |
|---|---|---|---|
| **Standard** | 1-99, 1300-1999 | **Source IP only** | **Close to destination** |
| **Extended** | 100-199, 2000-2699 | Protocol, source, destination, ports | **Close to source** |
| **Named** | Names | Either type, supports sequence editing | |

**Rules:**
- Processed **top-down, first match wins**.
- **Implicit `deny any`** at the end.
- One ACL **per interface, per direction, per protocol**.
- **Wildcard mask:** 0 = must match, 1 = ignore. `/24` is `0.0.0.255`. A single host is `host x.x.x.x` or `0.0.0.0`.
- ACLs on an interface filter **transit** traffic. Traffic the router itself originates is not filtered by an outbound ACL.
- VTY lines use **`access-class`**, not `ip access-group`.
- **IPv6 ACLs** are always named, applied with `ipv6 traffic-filter`, and have implicit permits for neighbor discovery before the implicit deny.

### Configuration

```
! ---- Standard (numbered) ----
access-list 10 permit 192.0.2.0 0.0.0.255
access-list 10 deny any log

! ---- Extended named ----
ip access-list extended TELLER-IN
 10 permit udp any eq bootpc any eq bootps
 20 permit tcp 10.10.10.0 0.0.0.255 host 10.20.0.50 eq 8443
 30 permit icmp 10.10.10.0 0.0.0.255 any echo
 40 permit tcp 10.10.10.0 0.0.0.255 any eq 443
 50 deny   ip any any log

interface GigabitEthernet0/0
 ip access-group TELLER-IN in

! ---- Edit an ACL ----
ip access-list extended TELLER-IN
 no 30
 25 permit tcp 10.10.10.0 0.0.0.255 host 10.20.0.51 eq 8443

! ---- Management access ----
line vty 0 15
 access-class 10 in

! ---- IPv6 ----
ipv6 access-list V6-BLOCK
 deny tcp any any eq telnet
 permit ipv6 any any
interface GigabitEthernet0/1
 ipv6 traffic-filter V6-BLOCK in
```

### Banking example

Teller VLAN hosts may reach only the core-banking application on TCP 8443, DNS, DHCP, and web proxy traffic. Everything else is denied and logged. A standard ACL on the VTY lines allows only the management jump host to SSH into the network devices.

### Verification

```
show access-lists
show ip access-lists TELLER-IN
show ip interface GigabitEthernet0/0 | include access list
show running-config | section access-list
show ipv6 access-list
```

Match counters in `show access-lists` show which line is being hit.

### Analogy

An ACL is a **bouncer reading a guest list from top to bottom**. The first line that matches decides, and the bouncer's default for anyone not listed is "no." An extended ACL is a bouncer who also checks **where you're going** (destination, port).

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| Everything blocked | Missing `permit` at the end (implicit deny) |
| Rule never hits | An earlier broader rule matches first (order) |
| ACL has no effect | Wrong interface or direction, or not applied at all |
| Wildcard mistake | `255.255.255.0` written instead of `0.0.0.255` |
| Can't edit a numbered ACL on old IOS | Use named ACLs with sequence numbers |
| Router's own pings still work | Outbound ACLs don't filter router-originated traffic |
| Return traffic blocked | Allow established sessions (`permit tcp any any established`) or use a stateful firewall |
| VTY access lost | `access-class` ACL doesn't include your management IP |

---

## 5.7 Layer 2 Security: Port Security, DHCP Snooping, DAI

### Technical explanation

**Port security** limits which and how many MAC addresses may use an **access** (or static trunk) port.

- Defaults: **maximum 1**, violation mode **shutdown**.
- **Sticky** learning saves learned MACs to the running config.

| Violation mode | Drops violating frames | Logs/counts | Port err-disabled |
|---|---|---|---|
| **protect** | Yes | No | No |
| **restrict** | Yes | **Yes** | No |
| **shutdown** (default) | Yes | Yes | **Yes** |

**DHCP snooping** stops rogue DHCP servers and starvation.

- **Untrusted** ports (default): clients only, so server messages (Offer/Ack) are dropped.
- **Trusted** ports: uplinks and legitimate DHCP servers.
- Builds a **binding table**: MAC, IP, VLAN, port, lease.
- Rate limiting on untrusted ports (e.g. 15 pps).

**Dynamic ARP Inspection (DAI)** stops ARP poisoning.

- Checks ARP packets against the **DHCP snooping binding table** (or static ARP ACLs).
- Ports are **untrusted by default**, and uplinks are configured as trusted.
- Optional validation: src-mac, dst-mac, ip.
- Needs DHCP snooping, or it drops legitimate ARP.

### Configuration

```
! ---- Port security (access port) ----
interface GigabitEthernet0/5
 switchport mode access
 switchport access vlan 10
 switchport port-security
 switchport port-security maximum 2
 switchport port-security mac-address sticky
 switchport port-security violation restrict
 switchport port-security aging time 60
 switchport port-security aging type inactivity

errdisable recovery cause psecure-violation
errdisable recovery interval 300

! ---- DHCP snooping ----
ip dhcp snooping
ip dhcp snooping vlan 10,20
interface GigabitEthernet0/1
 description Uplink to distribution
 ip dhcp snooping trust
interface range GigabitEthernet0/2-24
 ip dhcp snooping limit rate 15

! ---- Dynamic ARP Inspection ----
ip arp inspection vlan 10,20
ip arp inspection validate src-mac dst-mac ip
interface GigabitEthernet0/1
 ip arp inspection trust
```

Hosts with a **static IP** need an ARP ACL for DAI. Snooping may insert option 82, and some servers or relays reject it. That is handled with `no ip dhcp snooping information option` where required.

### Banking example

Teller-area wall jacks accept only the **registered PC and IP phone** (maximum 2 MACs, sticky). The switch trusts only the uplink toward the **DHCP relay and server**, so a rogue consumer router plugged in by a staff member cannot hand out addresses. DAI blocks an attacker's poisoning attempt that tries to pose as the default gateway.

### Verification

```
show port-security
show port-security interface GigabitEthernet0/5
show port-security address
show interfaces status err-disabled
show errdisable recovery
show ip dhcp snooping
show ip dhcp snooping binding
show ip arp inspection
show ip arp inspection interfaces
show ip arp inspection statistics
```

### Analogy

- **Port security:** a **named seat reservation**. Only the registered guest may sit there.
- **DHCP snooping:** only the **official reception desk** may hand out room keys.
- **DAI:** the doorman **cross-checks "I'm the manager" claims** against the guest register.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| Port `err-disabled` | Port-security violation (mode shutdown); fix the cause, then `shutdown` / `no shutdown` or let `errdisable recovery` clear it |
| Port security won't enable | Port is dynamic; set `switchport mode access` first |
| Clients get no DHCP after enabling snooping | Uplink or server port not set to **trust** |
| Option 82 problems | Server or relay rejects option 82; disable insertion |
| Static-IP hosts lose connectivity after DAI | No binding; add an ARP ACL |
| DAI drops all ARP | Snooping not enabled or no binding entries; check the trusted uplink |
| IP phone plus PC flapping | Maximum too low (use 2 or 3) |
| Err-disable on DAI/snooping rate limit | Burst exceeded; raise the limit or investigate the host |

Related hardening: disable DTP (`switchport nonegotiate`), use a dedicated native VLAN, enable **BPDU Guard** and **PortFast** on access ports, and shut down unused ports.

---

## 5.8 AAA: Authentication, Authorization, Accounting

### Technical explanation

| Function | Question answered | Example |
|---|---|---|
| **Authentication** | Who are you? | Username and password, MFA |
| **Authorization** | What may you do? | Privilege 15, allowed commands |
| **Accounting** | What did you do? | Login times, commands, config changes |

**RADIUS vs TACACS+:**

| | **RADIUS** | **TACACS+** |
|---|---|---|
| Standard | Open (IETF) | Cisco-originated |
| Transport | **UDP 1812/1813** (older 1645/1646) | **TCP 49** |
| Encryption | **Password only** | **Entire payload** |
| AAA separation | Combines authentication and authorization | **Separates** all three |
| Command authorization | Limited | **Per-command** |
| Typical use | Network access: 802.1X, Wi-Fi, VPN users | **Device administration** |

**Central AAA** (e.g. Cisco ISE) gives one identity source and consistent policy across devices. **Always keep local fallback** so an AAA outage doesn't lock you out. Fallback applies when the server is **unreachable**, not when it rejects the credentials.

### Configuration

```
aaa new-model

username breakglass privilege 15 algorithm-type scrypt secret <BREAKGLASS-PASS>

! ---- TACACS+ for device administration ----
tacacs server TAC1
 address ipv4 192.0.2.80
 key <TACACS-KEY>
tacacs server TAC2
 address ipv4 192.0.2.81
 key <TACACS-KEY>
aaa group server tacacs+ TAC-GROUP
 server name TAC1
 server name TAC2
ip tacacs source-interface Loopback0

aaa authentication login default group TAC-GROUP local
aaa authentication login CONSOLE local
aaa authorization exec default group TAC-GROUP local
aaa authorization commands 15 default group TAC-GROUP local
aaa accounting exec default start-stop group TAC-GROUP
aaa accounting commands 15 default start-stop group TAC-GROUP

line console 0
 login authentication CONSOLE
line vty 0 15
 login authentication default
 transport input ssh

! ---- RADIUS example ----
radius server RAD1
 address ipv4 192.0.2.82 auth-port 1812 acct-port 1813
 key <RADIUS-KEY>
```

Test from a second session before closing your current one.

### Banking example

Network admins log in with **TACACS+ plus MFA**. Junior staff are authorized for **show commands only**, senior engineers get full access, and every command is recorded. The accounting log is evidence for auditors and fraud investigations. Wi-Fi and 802.1X use **RADIUS**.

### Verification

```
show aaa servers
show aaa sessions
show tacacs
test aaa group TAC-GROUP <user> <pass> new-code
show running-config | section aaa
debug aaa authentication          ! lab only
debug tacacs
```

### Analogy

At a bank: **authentication** is the guard checking your ID at the door, **authorization** is your badge deciding which floors the elevator will take you to, and **accounting** is the access log recording where you went and when. TACACS+ is the **sealed, separate paperwork for each step**. RADIUS is a single form with only the password section sealed.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| All logins fail | Wrong shared key, server unreachable, device not defined as a client on the server |
| Falls back to local unexpectedly | Server timeout, routing/source-interface problem |
| Rejected despite correct password | Server policy denies it (rejection, **not** failure, so no fallback) |
| Locked out of console | No `CONSOLE` method list; keep a local method on the console |
| Commands denied | Authorization policy or privilege level mismatch |
| Accounting empty | `aaa accounting` not configured, or the server isn't logging |
| Intermittent auth | Time skew (NTP), UDP or TCP 49 filtering |

---

## 5.9 Wireless Security Protocols (WPA, WPA2, WPA3)

### Technical explanation

| | **WEP** | **WPA** | **WPA2** | **WPA3** |
|---|---|---|---|---|
| Cipher | RC4 | **TKIP** (RC4-based) | **AES-CCMP** | **AES-CCMP-128**; **GCMP-256** in Enterprise 192-bit mode |
| Integrity | CRC-32 (weak) | MIC | CCMP MIC | CCMP / GCMP |
| Personal auth | Shared key | **PSK** | **PSK** | **SAE** (Simultaneous Authentication of Equals) |
| Enterprise auth | n/a | 802.1X/EAP | 802.1X/EAP | 802.1X/EAP (**192-bit** option) |
| Status | **Broken** | Deprecated | Widely used | **Current best** |

**Modes:**
- **Personal (PSK/SAE):** a shared passphrase.
- **Enterprise (802.1X):** each user authenticates through RADIUS with EAP (PEAP, EAP-TLS).

**WPA3 improvements:**
- **SAE** replaces PSK, giving resistance to **offline dictionary attacks** and **forward secrecy**.
- **Protected Management Frames (PMF, 802.11w)** are mandatory.
- **OWE** (Enhanced Open) encrypts open guest networks.
- Stronger Enterprise suite for high-security environments.

**WPA2 weaknesses:** offline attacks on a captured 4-way handshake with a weak PSK, and flaws such as KRACK (patched in clients and APs).

### Banking example

- **Staff Wi-Fi:** WPA2/WPA3-**Enterprise** with 802.1X and certificates (EAP-TLS), so no shared password to leak.
- **Guest Wi-Fi:** separate SSID and VLAN, WPA2/WPA3 Personal with a strong passphrase, or OWE, isolated from the bank network with ACLs and bandwidth limits.
- ATM and branch devices don't share the staff SSID.

### IOS/WLC commands

Wireless is mainly configured on the WLC (see 5.10). Related switch-side verification:

```
show interfaces trunk              ! WLC/AP trunk VLANs allowed
show cdp neighbors                 ! AP and WLC connectivity
show dot11 associations            ! autonomous IOS AP
```

### Analogy

- **WEP:** a **cardboard door** with a lock painted on.
- **WPA:** a **temporary lock** on the same door.
- **WPA2:** a **steel door**, but everyone shares one key (PSK).
- **WPA3:** a **door that issues a new key for every visit** (SAE), so stealing the key later doesn't open past visits.

### Troubleshooting

- **Client won't connect after security change:** old client doesn't support WPA3, so use **WPA2/WPA3 transition mode**.
- **Intermittent for old devices:** TKIP-only device against an AES-only WLAN.
- **Repeated authentication failures:** wrong PSK, RADIUS or EAP problem, expired certificate.
- **Open guest network concerns:** use captive portal, OWE, isolation.
- **Offline cracking worry:** use a long random PSK, or move to Enterprise or WPA3.

---

## 5.10 Configure a WLAN in the GUI Using WPA2 PSK

### Technical explanation

On a Cisco WLC, a **WLAN** is an SSID with settings: security, VLAN or interface mapping, and QoS. APs join the WLC through **CAPWAP**, and the WLC maps each WLAN to a **dynamic interface (VLAN)**.

**GUI steps (AireOS-style WLC GUI, as tested on CCNA):**

1. Log in to the WLC GUI → **WLANs** → select **Create New** → **Go**.
2. **Type:** WLAN. Enter **Profile Name**, **SSID**, and **ID** → **Apply**.
3. **General** tab: set **Status = Enabled**. Choose the **Interface/Interface Group** (the VLAN for this WLAN). Leave **Broadcast SSID** enabled unless there's a reason to hide it.
4. **Security** tab → **Layer 2**:
   - **Layer 2 Security:** `WPA+WPA2`
   - **WPA2 Policy:** checked, **WPA2 Encryption: AES**. Uncheck TKIP and WPA policy.
   - **Auth Key Mgmt:** check **PSK** (and uncheck 802.1X)
   - **PSK Format:** ASCII, then enter the **passphrase (8 to 63 characters)**
5. **Layer 3** tab: leave **None** for a normal WLAN.
6. **QoS** tab: choose a profile (Silver is the default; Platinum for voice).
7. Click **Apply**, then **Save Configuration**.

On a **Catalyst 9800 (IOS-XE)** controller the path is under **Configuration → Tags & Profiles → WLANs**, using the same concepts (SSID, WPA2, AES, PSK) plus policy and site tags.

### CLI equivalent (AireOS, for reference, check your version)

```
config wlan create 10 BANK-GUEST BANK-GUEST
config wlan interface 10 guest-vlan
config wlan security wpa disable 10
config wlan security wpa wpa2 enable 10
config wlan security wpa wpa2 ciphers aes enable 10
config wlan security wpa akm 802.1x disable 10
config wlan security wpa akm psk enable 10
config wlan security wpa akm psk set-key ascii <PASSPHRASE> 10
config wlan enable 10
```

You may need to `config wlan disable 10` before changing some security settings.

### Banking example

The branch customer-waiting-area Wi-Fi uses a **WPA2-PSK, AES** WLAN mapped to an isolated **guest VLAN**. It has internet-only ACLs and rate limits, and the passphrase is rotated on a schedule. Staff use a separate 802.1X WLAN.

### Verification

```
show wlan summary
show wlan 10
show client summary
show ap summary
```

GUI: **Monitor → Clients** shows connected clients and **Monitor → Access Points** shows AP status.

### Analogy

Building a WLAN is **opening a new reception counter**: pick a name (SSID), assign it to a department corridor (VLAN/interface), choose the lock type (WPA2-AES), set the counter password (PSK), then open it (Status Enabled).

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| SSID not visible | WLAN disabled, broadcast SSID off, AP not joined, or the AP's radio or band is not enabled |
| Client can't authenticate | Wrong passphrase, or TKIP/AES mismatch |
| Associates but gets no IP | Interface/VLAN mapping wrong, VLAN missing on the switch trunk, DHCP unreachable |
| AP not joining | CAPWAP discovery/DHCP option 43, trunk/native VLAN problem, time or certificate issue |
| Works on 2.4 GHz not 5 GHz (or vice versa) | Client band support or radio policy |
| Settings greyed out | WLAN must be disabled before editing certain security settings |
| WPA3-only client fails | Controller or AP doesn't support WPA3; use WPA2 or transition mode |

---

## Exam tips

- **Threat** is the danger, **vulnerability** is the weakness, **exploit** is the tool that uses it, and **mitigation** reduces risk.
- **`enable secret` beats `enable password`.** Type 7 is **reversible**. Use `login local` for per-user accountability.
- **MFA** needs **different factor types**, and biometrics is "something you are."
- **IPsec:** ESP = protocol 50, AH = 51, IKE = UDP 500, NAT-T = 4500. Phase 1 builds the management SA, phase 2 the data SA.
- **ACLs:** top-down, implicit deny. Standard = source only, near destination. Extended = near source. **Wildcard ≠ subnet mask.** VTY uses `access-class`.
- **Port security defaults:** max 1, violation shutdown. **Restrict** logs, **protect** does not.
- **DHCP snooping** trusts uplinks and servers. **DAI** depends on the snooping table, and its ports are untrusted by default.
- **TACACS+** = TCP 49, encrypts all, separates AAA. **RADIUS** = UDP 1812/1813, encrypts the password only.
- **WPA2 = AES-CCMP. WPA3 = SAE** (forward secrecy, PMF mandatory). TKIP is legacy.
- **WLAN GUI:** Layer 2 Security = WPA+WPA2, **AES**, **PSK**, passphrase 8 to 63 characters.

---

## References

I haven't live-checked links, so search these titles on the named sites.

1. Cisco, **CCNA 200-301 Exam Topics** (Domain 5.0 Security Fundamentals), Cisco Learning Network / cisco.com.
2. Wendell Odom, **CCNA 200-301 Official Cert Guide, Vol. 1 and Vol. 2**, Cisco Press (security, ACL, Layer 2 security, AAA, wireless chapters).
3. Cisco, **Security Configuration Guide: Access Control Lists**, IOS XE documentation.
4. Cisco, **Security Configuration Guide: Securing User Services (AAA)**, and **Configuration Fundamentals (passwords, privilege levels, login enhancements)**.
5. Cisco, **Catalyst Switch Security Configuration Guide** (port security, DHCP snooping, Dynamic ARP Inspection).
6. Cisco, **Security for VPNs with IPsec** and **Internet Key Exchange for IPsec VPNs Configuration Guide**, IOS XE.
7. Cisco, **Wireless LAN Controller Configuration Guide** (WLANs, WPA2/WPA3), and Cisco Catalyst 9800 documentation.
8. **NIST SP 800-63B**, *Digital Identity Guidelines: Authentication and Lifecycle Management*.
9. **NIST SP 800-53**, *Security and Privacy Controls*; **NIST Cybersecurity Framework**.
10. **RFC 4301**, *Security Architecture for IP*; **RFC 4303**, *ESP*; **RFC 7296**, *IKEv2*.
11. **RFC 2865** (RADIUS) and **RFC 8907** (TACACS+).
12. **RFC 2827 / BCP 38**, *Ingress Filtering*; **RFC 3704**, *Ingress Filtering for Multihomed Networks* (uRPF).
13. **IEEE 802.11i / 802.11w**, and **Wi-Fi Alliance** WPA2/WPA3 specifications.
14. **IEEE 802.1X**, *Port-Based Network Access Control*.
15. Cisco, **IOS Command Reference** and **Cisco ISE Administrator Guide** (AAA, TACACS+, RADIUS).

Want this as a Word/PDF study sheet, a mixed practice quiz for Domains 3, 4, and 5, or a LinkedIn-ready summary for US WealthTech?