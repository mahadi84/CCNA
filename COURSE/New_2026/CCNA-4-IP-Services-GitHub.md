# CCNA 200-301: Domain 4.0 IP Services (10%)

All IPs below come from documentation ranges (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24). Replace passwords and keys with your own.

## 📚 Table of Contents (GitHub Quick Menu)

1. [4.1 Inside Source NAT — Static NAT, Dynamic NAT and PAT](#41-inside-source-nat-static-and-pools)
2. [4.2 NTP — Client and Server Mode](#42-ntp-client-and-server-mode)
3. [4.3 Role of DHCP and DNS](#43-role-of-dhcp-and-dns)
4. [4.4 SNMP in Network Operations](#44-snmp-in-network-operations)
5. [4.5 Syslog — Facilities and Severity Levels](#45-syslog-facilities-and-severity-levels)
6. [4.6 DHCP Client and Relay](#46-dhcp-client-and-relay)
7. [4.7 QoS Forwarding Per-Hop Behavior (PHB)](#47-qos-forwarding-per-hop-behavior-phb)
8. [4.8 Remote Access Using SSH](#48-remote-access-using-ssh)
9. [4.9 TFTP and FTP](#49-tftp-and-ftp)
10. [Exam Tips](#exam-tips)
11. [References](#references)

---

## 4.1 Inside Source NAT (Static and Pools)

### Technical explanation

NAT translates IP addresses as packets cross the router, mainly so private RFC 1918 hosts can use public addresses.

**Four address terms (exam favorite):**

| Term | Meaning | Example |
|---|---|---|
| **Inside local** | Inside host's address as seen on the inside network | 10.1.1.10 |
| **Inside global** | Inside host's address as seen from the outside | 203.0.113.10 |
| **Outside local** | Outside host's address as seen from the inside | 198.51.100.5 |
| **Outside global** | Outside host's real address | 198.51.100.5 |

For typical inside source NAT, the outside local and outside global addresses are the same.

**Types:**

| Type | Mapping | Use |
|---|---|---|
| **Static NAT** | 1:1, permanent | Servers that must be reachable from outside |
| **Dynamic NAT (pool)** | Many inside hosts to a pool, 1:1 while the entry exists | Limited by pool size |
| **PAT (overload)** | Many:1 using unique source ports | Most common, saves public IPs |

**Order of operations:**
- Inside to outside: the router **routes first, then translates**.
- Outside to inside: the router **translates first, then routes**.

Default dynamic entry timeout is about 24 hours (`ip nat translation timeout`).

### Configuration

```
! Mark interfaces
interface GigabitEthernet0/0
 ip nat inside
interface GigabitEthernet0/1
 ip nat outside

! ---- Static NAT ----
ip nat inside source static 10.1.1.10 203.0.113.10

! ---- Dynamic NAT with a pool ----
ip nat pool BANKPOOL 203.0.113.20 203.0.113.30 netmask 255.255.255.224
access-list 1 permit 10.1.1.0 0.0.0.255
ip nat inside source list 1 pool BANKPOOL

! ---- PAT using the outside interface address ----
ip nat inside source list 1 interface GigabitEthernet0/1 overload

! ---- PAT using a pool ----
ip nat inside source list 1 pool BANKPOOL overload
```

### Banking example

The internet banking web server (10.1.1.10) needs a fixed public address (`203.0.113.10`) so customers and the DNS record always reach it, so it uses **static NAT**. Staff PCs in 10.1.2.0/24 browse the internet through **PAT** on the ISP-facing interface. Public IPs are scarce and costly, and one overloaded address serves hundreds of staff.

### Verification

```
show ip nat translations
show ip nat translations verbose
show ip nat statistics
clear ip nat translation *
debug ip nat              ! lab only, can flood the console
```

### Analogy

NAT is a **bank reception desk using a company main number**. Staff phone out with desk extensions (private IPs), but the outside world sees only the main number (public IP). The receptionist remembers which extension made which call (the translation table), which is PAT. A static NAT is a **direct-dial number** for one executive.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| No translations appear | `ip nat inside`/`outside` missing or reversed; ACL doesn't match the inside local addresses |
| "Pool exhausted" (dynamic NAT only) | More hosts than pool addresses; use `overload` |
| Translation exists, no connectivity | Missing return route on the ISP side, or no default route on the router |
| ACL permits too much or too little | Wildcard mask error (`0.0.0.255`, not `255.255.255.0`) |
| Inside server unreachable from outside | Missing static NAT, or the pool overlaps the interface subnet |
| Stale entries | `clear ip nat translation *` |

---

## 4.2 NTP (Client and Server Mode)

### Technical explanation

NTP synchronizes clocks over **UDP 123**. Accurate time is essential for **log correlation, audit trails, certificates, Kerberos, and incident investigation**.

- **Stratum** shows distance from the reference clock: stratum 0 is the atomic/GPS source, stratum 1 is a server directly attached to it, and each hop adds 1. **Stratum 16 means unsynchronized.**
- **Server mode:** `ntp master [stratum]` makes the router an authoritative source. The default stratum is **8**. Use it only when no upstream source exists.
- **Client mode:** `ntp server <ip>` syncs to an upstream server.
- **Symmetric peer:** `ntp peer <ip>` lets two devices back each other up.
- Clients choose the **lowest stratum**, and synchronization can take several minutes.

### Configuration

```
! ---- Internal NTP server (R1) ----
ntp master 3
ntp source Loopback0
ntp authenticate
ntp authentication-key 1 md5 <NTP-KEY>
ntp trusted-key 1

! ---- Client (R2) ----
clock timezone UTC 0
ntp server 192.0.2.1 key 1
ntp authenticate
ntp authentication-key 1 md5 <NTP-KEY>
ntp trusted-key 1
ntp source Loopback0
ntp update-calendar              ! updates hardware calendar on platforms that have one
service timestamps log datetime msec
```

### Banking example

All branch routers, firewalls, and core-banking servers sync to two internal NTP servers at HQ, which in turn sync to an upstream source. During a fraud investigation or a regulatory audit, logs from the ATM switch, firewall, and application server must agree on the timestamp of an event, or the sequence of events cannot be proven.

### Verification

```
show ntp status
show ntp associations
show ntp associations detail
show clock detail
```

`show ntp status` should show **"Clock is synchronized"**. In `show ntp associations`, `*` marks the selected sync source, `+` a candidate, and `~` a configured peer.

### Analogy

NTP is the **bank's master wall clock**. Every teller's watch is corrected from the branch clock, which is corrected from head office, which is corrected from the national time signal. Each level is one stratum further away.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| "Clock is unsynchronized" | Wait a few minutes first; then check reachability and UDP 123 filtering |
| Association shows `~` but never `*` | Authentication key mismatch, wrong trusted-key, or server stratum too high |
| Large time gap | Set `clock set` manually first; NTP refuses big offsets in some cases |
| Server has no upstream source | Configure `ntp master` as a last resort |
| Logs show wrong time | Time zone, daylight saving, or `service timestamps` not configured |

---

## 4.3 Role of DHCP and DNS

### Technical explanation

**DHCP** automates IP configuration (address, mask, default gateway, DNS servers, lease time). It uses **UDP 67 (server)** and **UDP 68 (client)**.

**DORA process:**
1. **Discover:** client broadcasts to find a server.
2. **Offer:** server proposes an address.
3. **Request:** client accepts, still broadcast so other servers know.
4. **Acknowledge:** server confirms the lease.

Renewal is attempted at 50% of the lease (T1) and rebinding at 87.5% (T2). If no DHCP server answers, Windows falls back to **APIPA 169.254.0.0/16**.

**DNS** resolves names to IPs, using **UDP 53** (queries) and **TCP 53** (zone transfers, large responses).

| Record | Purpose |
|---|---|
| **A** | Name to IPv4 |
| **AAAA** | Name to IPv6 |
| **CNAME** | Alias to another name |
| **MX** | Mail server |
| **NS** | Name server for a zone |
| **PTR** | IP to name (reverse lookup) |

### Configuration

```
! ---- Router as DHCP server ----
ip dhcp excluded-address 10.10.10.1 10.10.10.10
ip dhcp pool TELLERS
 network 10.10.10.0 255.255.255.0
 default-router 10.10.10.1
 dns-server 198.51.100.53 198.51.100.54
 domain-name bank.example
 lease 7

! ---- Router as DNS client ----
ip domain name bank.example
ip name-server 198.51.100.53
ip domain-lookup            ! "no ip domain-lookup" stops typos from hanging the CLI
```

### Banking example

Teller PCs at a branch get addresses automatically from a DHCP pool. The gateway and gateway-redundancy VIP are excluded from the pool, and the DNS servers point to internal resolvers. **Servers, ATMs, and network devices use static or reserved addresses** so firewall rules and monitoring stay stable.

### Verification

```
show ip dhcp binding
show ip dhcp pool
show ip dhcp conflict
show ip dhcp server statistics
show hosts
! On a PC:  ipconfig /all   |   nslookup bank.example
```

### Analogy

- **DHCP** is a **hotel front desk** giving you a room number (IP) and a key card valid for a set time (lease).
- **DNS** is the **hotel phone directory**: you ask for "Accounts Department" and get the room number.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| Client has 169.254.x.x | No server reachable, exhausted pool, or no relay (see 4.6) |
| Duplicate IP | Static device inside the pool range; exclude those addresses |
| Pool exhausted | Lease too long, pool too small; check `show ip dhcp binding` |
| Wrong gateway or DNS | Missing `default-router` or `dns-server` in the pool |
| Rogue DHCP server | Unauthorized device answering; DHCP snooping is the mitigation (Domain 5.x/security) |
| Name fails but ping by IP works | DNS server or `ip name-server` problem |

---

## 4.4 SNMP in Network Operations

### Technical explanation

SNMP lets a **Network Management System (NMS)** monitor and manage devices.

- **Manager** (NMS) polls and receives alerts.
- **Agent** runs on the device and answers.
- **MIB** is the database of manageable objects, and each object has an **OID**.
- Polling uses **UDP 161**, and traps/informs go to **UDP 162**.

**Messages:**

| Message | Direction | Note |
|---|---|---|
| **Get / GetNext / GetBulk** | Manager to agent | Read values (GetBulk is v2c/v3) |
| **Set** | Manager to agent | Change a value |
| **Trap** | Agent to manager | Unsolicited, unacknowledged |
| **Inform** | Agent to manager | Acknowledged (v2c/v3) |

**Versions:**

| Version | Security |
|---|---|
| **v1** | Community string (plaintext) |
| **v2c** | Community string (plaintext), adds GetBulk and Inform |
| **v3** | Username-based, with **authentication and encryption** |

**v3 security levels:** `noAuthNoPriv`, `authNoPriv`, `authPriv` (best).

### Configuration

```
! ---- v2c (lab / legacy) ----
ip access-list standard NMS-ONLY
 permit 192.0.2.50
snmp-server community BANK-RO-xyz ro NMS-ONLY
snmp-server location Chattogram-Branch-01
snmp-server contact noc@bank.example
snmp-server host 192.0.2.50 version 2c BANK-RO-xyz
snmp-server enable traps

! ---- v3 (preferred) ----
snmp-server group NOCGROUP v3 priv
snmp-server user NOCUSER NOCGROUP v3 auth sha <AUTH-PASS> priv aes 128 <PRIV-PASS>
snmp-server host 192.0.2.50 version 3 priv NOCUSER
```

### Banking example

The NOC's monitoring system polls every router and switch for **interface utilization, CPU, memory, and link status**. A WAN link failure at a branch sends a trap, so the operations team sees it before the branch phones. Production uses **SNMPv3 authPriv** because community strings travel in plaintext and a read-write community can reconfigure devices.

### Verification

```
show snmp
show snmp community
show snmp group
show snmp user
show snmp host
```

### Analogy

SNMP is a **building's alarm and meter system**. The security office (NMS) regularly reads meters (polling) and gets sirens (traps) when something fails. v3 is the version where the readings travel in a **locked envelope** with an ID check.

### Troubleshooting

- **NMS can't poll:** community or user mismatch, ACL on the community, or UDP 161 blocked.
- **No traps:** `snmp-server enable traps` or `snmp-server host` missing, or UDP 162 blocked.
- **v3 failing:** auth/priv algorithm or password mismatch, wrong security level.
- **Security concern:** default community names such as `public`/`private`, or any read-write community without an ACL.

---

## 4.5 Syslog: Facilities and Severity Levels

### Technical explanation

Syslog sends event messages to a console, buffer, terminal, or remote server (**UDP 514**).

**Severity levels (lower number = more severe):**

| Level | Name | Keyword |
|---|---|---|
| 0 | Emergency | `emergencies` |
| 1 | Alert | `alerts` |
| 2 | Critical | `critical` |
| 3 | Error | `errors` |
| 4 | Warning | `warnings` |
| 5 | Notice | `notifications` |
| 6 | Informational | `informational` |
| 7 | Debugging | `debugging` |

**Mnemonic:** *Every Awesome Cisco Engineer Will Need Icecream Daily.*

Setting a level logs that level **and all more severe levels** (lower numbers). `logging trap warnings` sends levels 0 to 4.

**Facility:** a label identifying the source category (kernel, auth, local0 to local7, and so on). Cisco IOS uses **local7** by default and can be changed with `logging facility`. Do not confuse this with the facility name inside an IOS message.

**IOS message format:**

```
%LINK-3-UPDOWN: Interface GigabitEthernet0/1, changed state to down
 ^FACILITY ^SEVERITY ^MNEMONIC
```

**Default destinations:** console is level 7 (debugging), buffer is level 7, and trap (server) is level 6 (informational).

### Configuration

```
service timestamps log datetime msec
service sequence-numbers
logging host 192.0.2.60
logging trap warnings
logging facility local6
logging source-interface Loopback0
logging buffered 16384 informational
logging console warnings
! On a Telnet/SSH session:
terminal monitor
```

### Banking example

Branch routers forward warnings and above to the central syslog/SIEM. A burst of `%SEC-6-IPACCESSLOGP` denies, repeated `%OSPF-5-ADJCHG` changes, or `%LINK-3-UPDOWN` flaps on the core-banking uplink gives early warning of an attack or a failing link. Time-synced logs (4.2) make the sequence provable.

### Verification

```
show logging
show logging | include %LINK
show running-config | include logging
```

### Analogy

Syslog is the **branch's incident logbook**. Severity is how urgent the entry is, from "building on fire" (0) to "someone checked the thermostat" (7). The facility is which department wrote it, and the syslog server is the head-office filing cabinet.

### Troubleshooting

- **Nothing reaches the server:** UDP 514 blocked, wrong IP, or `logging trap` too restrictive.
- **Too many messages:** lower the verbosity, for example from informational to warnings.
- **Logs lack useful timestamps:** `service timestamps` missing or NTP not synced.
- **Buffer wraps too fast:** increase `logging buffered` size and set a level.
- **Console floods:** debugging level on the console during `debug`; set `logging console warnings` or `no debug all`.

---

## 4.6 DHCP Client and Relay

### Technical explanation

**DHCP client on a router interface:** the router obtains its address and may install a default route, which has **administrative distance 254** by default.

**DHCP relay:** DHCP Discover is a **broadcast** and routers don't forward broadcasts. `ip helper-address` makes the router convert the broadcast into a **unicast** toward the server.

- Configure it on the **interface facing the clients**.
- The relay inserts its own interface IP in the **giaddr** field, so the server knows which pool/subnet to use.
- By default `ip helper-address` also forwards other UDP services: TFTP (69), DNS (53), TACACS (49), NetBIOS (137/138), time (37), and BOOTP/DHCP (67/68).

### Configuration

```
! ---- Router interface as DHCP client ----
interface GigabitEthernet0/1
 ip address dhcp
 no shutdown

! ---- DHCP relay at a branch ----
interface GigabitEthernet0/0
 description Teller VLAN gateway
 ip address 10.10.10.1 255.255.255.0
 ip helper-address 192.0.2.10        ! central DHCP server

! Limit forwarded services (optional)
no ip forward-protocol udp 37
```

### Banking example

Branch teller and ATM VLANs don't have a local DHCP server. The central DHCP server at HQ has a scope for each branch subnet. The branch router's `ip helper-address` carries requests across the WAN, and the server picks the right scope from the giaddr.

### Verification

```
show ip interface GigabitEthernet0/0 | include Helper
show dhcp lease                      ! client side
show ip dhcp binding                 ! server side
debug ip dhcp server packet          ! lab only
```

### Analogy

The relay is a **branch courier**: a customer shouts "I need an account number!" in the branch lobby (broadcast), and the courier carries a sealed request to head office (unicast), writing the branch address on the envelope (giaddr) so head office knows where to reply.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| Clients get 169.254.x.x | `ip helper-address` missing or on the wrong interface |
| Server replies to the wrong scope | No scope for the giaddr subnet on the server |
| Relay configured but fails | No route to or from the server, or ACL blocking UDP 67/68 |
| Router lost its default route | DHCP-learned route (AD 254) overridden by another source |
| Clients on a Layer 2-only switch fail | Helper is needed on the Layer 3 gateway, not on the access switch |

---

## 4.7 QoS Forwarding Per-Hop Behavior (PHB)

### Technical explanation

QoS manages **bandwidth, delay, jitter, and loss** when links get congested. It matters most for voice, video, and critical applications.

Rough voice targets: one-way delay under 150 ms, jitter under 30 ms, loss under 1%.

**Per-hop behavior:** each router treats packets according to their marking, independently of other hops (DiffServ model).

| Tool | Function |
|---|---|
| **Classification** | Identify traffic (ACL, NBAR, existing markings) |
| **Marking** | Set a value: **DSCP** (6 bits in the IP header), **IP Precedence** (3 bits), **CoS** (3 bits in the 802.1Q tag) |
| **Queuing** | Decide order of transmission (FIFO, WFQ, **CBWFQ**, **LLQ**) |
| **Congestion avoidance** | Drop packets early to avoid tail drop (**RED/WRED**) |
| **Policing** | Enforces a rate: excess is **dropped or re-marked**; no buffering; can be applied inbound or outbound |
| **Shaping** | Smooths bursts by **buffering/delaying** excess; **outbound only** |

**Common DSCP values:**

| PHB | DSCP | Typical use |
|---|---|---|
| **EF** | 46 | Voice |
| **AF41** | 34 | Interactive video |
| **AF31** | 26 | Critical data |
| **CS3** | 24 | Call signaling |
| **CS6** | 48 | Network control |
| **BE/default** | 0 | Best effort |

AFxy: x is the class and y is the drop precedence, with DSCP = 8x + 2y. Higher drop precedence means that traffic is dropped sooner under congestion. The **trust boundary** is the point where markings are accepted or rewritten.

### Configuration (Modular QoS CLI)

```
ip access-list extended CBS-APP
 permit tcp 10.10.10.0 0.0.0.255 host 10.20.0.50 eq 8443

class-map match-any VOICE
 match dscp ef
class-map match-all CORE-BANKING
 match access-group name CBS-APP

policy-map WAN-OUT
 class VOICE
  priority percent 20              ! LLQ, strict priority, implicitly policed
 class CORE-BANKING
  bandwidth percent 40             ! CBWFQ guaranteed share
  set dscp af31
 class class-default
  fair-queue

interface GigabitEthernet0/1
 service-policy output WAN-OUT

! ---- Shaping to the ISP's contracted rate (parent/child) ----
policy-map SHAPE-10M
 class class-default
  shape average 10000000
  service-policy WAN-OUT
! interface GigabitEthernet0/1
!  service-policy output SHAPE-10M

! ---- Policing example ----
policy-map LIMIT-GUEST
 class class-default
  police cir 2000000 conform-action transmit exceed-action drop
```

### Banking example

Branch voice calls (IP telephony) get EF priority, while core-banking transactions get a guaranteed share. Non-critical traffic such as software updates and personal browsing shares what remains. If the carrier sells a 10 Mbps service on a 100 Mbps handoff, **shaping** to 10 Mbps keeps the router in control of what to drop instead of the carrier.

### Verification

```
show policy-map interface GigabitEthernet0/1
show class-map
show policy-map
show interfaces GigabitEthernet0/1 | include drops
```

### Analogy

QoS is **airport check-in lanes**: classification sorts passengers by ticket type, marking is the wristband, queuing is which lane is served first (business class is the priority queue), WRED is turning back low-priority passengers before the hall overflows, **policing** is a guard who turns away anyone beyond the quota, and **shaping** is a guard who lets them wait in a holding area and enter at a steady pace.

### Troubleshooting

- **Policy not matching:** the ACL or class-map is wrong, or classes are evaluated **in order** and a broader class catches the traffic first.
- **No counters in `show policy-map interface`:** policy applied in the wrong direction or on the wrong interface.
- **Markings lost:** an upstream device re-marks (trust boundary), or traffic is tunneled.
- **Voice still choppy:** the priority queue is too small, the link is oversubscribed, or no shaping on a sub-rate circuit.
- **Policing vs shaping mix-up:** the shaper delays and may cause jitter-sensitive delay, while the policer causes drops and TCP retransmissions.
- **Starvation risk:** an oversized LLQ can starve other classes.

---

## 4.8 Remote Access Using SSH

### Technical explanation

SSH provides encrypted remote CLI access over **TCP 22**. **Telnet (TCP 23)** sends credentials and commands in plaintext, so it must not be used in production. SSHv2 is required for strong security (SSHv1 is deprecated).

**Prerequisites on IOS:**
1. Hostname (not the default)
2. Domain name
3. RSA key pair (**2048-bit recommended**; SSHv2 needs at least 768)
4. Local user account (or AAA)
5. VTY lines set to SSH with `login local`

### Configuration

```
hostname BR-RTR1
ip domain name bank.example
username admin privilege 15 secret <STRONG-PASSWORD>
enable secret <ENABLE-SECRET>
service password-encryption

crypto key generate rsa modulus 2048
ip ssh version 2
ip ssh time-out 60
ip ssh authentication-retries 3

ip access-list standard MGMT-ONLY
 permit 192.0.2.0 0.0.0.255

line vty 0 15
 transport input ssh
 login local
 access-class MGMT-ONLY in
 exec-timeout 5 0
 logging synchronous
```

### Banking example

All network devices accept only **SSHv2 from the management subnet or jump host**, with Telnet disabled. Accounts are tied to named engineers (or AAA/TACACS+), and VTY sessions time out after inactivity. These controls support internal audit and regulatory expectations on privileged access.

### Verification

```
show ip ssh
show ssh
show crypto key mypubkey rsa
show line vty 0 15
show users
! Client side:
ssh -l admin 10.1.1.1
```

`show ip ssh` should show **SSH Enabled, version 2.0**.

### Analogy

Telnet is shouting your password across a crowded lobby. SSH is **whispering through a sealed tube** to a verified recipient, so even someone standing next to you hears only noise.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| "Please create RSA keys" | Keys not generated, or hostname/domain missing |
| Connection refused | `transport input` doesn't include SSH, or VTY lines are full |
| Authentication fails | `login local` set but no user exists, or wrong privilege level |
| Timeout | ACL (`access-class`) blocking, routing issue, or TCP 22 filtered |
| Client can't negotiate | Old client with disabled ciphers or SSHv1-only |
| Key regeneration warning | Regenerating keys changes the host fingerprint; users will get a warning |

---

## 4.9 TFTP and FTP

### Technical explanation

| Feature | **TFTP** | **FTP** |
|---|---|---|
| Transport | **UDP 69** | **TCP 21** (control), **TCP 20** (data, active mode) |
| Authentication | None | Username and password |
| Reliability | Simple lock-step acknowledgments | TCP reliability |
| Features | Read/write files only | Directory listing, many commands |
| Security | Plaintext, no auth | Plaintext credentials |
| Typical use | Boot images, config backup in labs, PXE | Larger transfers, IOS images |

FTP has **active** and **passive** modes (passive avoids inbound connections to the client, which is friendlier to firewalls). **Secure alternatives:** **SCP** and **SFTP** (both over SSH) and FTPS (FTP over TLS). On IOS, `ip scp server enable` allows SCP, and it is the better choice on production networks.

### Configuration and file operations

```
! ---- TFTP ----
copy running-config tftp://192.0.2.70/BR-RTR1-confg
copy tftp://192.0.2.70/ios-image.bin flash:
copy flash:ios-image.bin tftp://192.0.2.70/ios-image.bin
ip tftp source-interface Loopback0

! ---- FTP ----
ip ftp username backup
ip ftp password <FTP-PASSWORD>
ip ftp source-interface Loopback0
copy running-config ftp://192.0.2.71/BR-RTR1-confg
copy ftp://192.0.2.71/ios-image.bin flash:

! ---- SCP (secure) ----
ip scp server enable
```

### Banking example

Before an IOS upgrade, the network team copies the running configuration to the backup server. For lab and recovery use, TFTP is a quick way to restore an image. In production, the images are retrieved from a protected repository over **SCP/SFTP**, and the **MD5/SHA hash is verified** because a corrupted or tampered image on a core router is a serious risk.

### Verification

```
dir flash:
show file systems
verify /md5 flash:ios-image.bin
show flash:
```

### Analogy

- **TFTP** is a **self-service drop box**: no ID, no questions, quick and simple.
- **FTP** is a **front-desk transfer** that checks your login and supports more services.
- **SCP/SFTP** is **armored-car delivery** of the same package.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| Timeouts or `%Error opening tftp` | Server not running, UDP 69 (and the ephemeral ports it uses) blocked by a firewall, wrong IP |
| TFTP upload fails | Server needs a pre-existing, writable file, or permissions are wrong |
| "Not enough space" | Flash is full; delete old images or check `dir flash:` |
| FTP login failure | Wrong `ip ftp username/password` |
| Image won't boot after copy | Hash mismatch, wrong image for the platform, or incomplete transfer |
| Only some transfers work | Source interface or routing asymmetry; set `ip tftp source-interface` |

---

## Exam tips

- **NAT terms:** inside local is the private address, inside global is the translated public address. **PAT = overload.**
- **NAT order:** inside to outside is route then translate; outside to inside is translate then route.
- **NTP:** `ntp master` is a last resort (default stratum 8). Stratum 16 means unsynchronized.
- **DHCP:** DORA uses UDP 67/68. **`ip helper-address` goes on the client-facing interface.**
- **SNMP:** v3 is the only version with authentication **and** encryption. Polling uses 161, traps use 162.
- **Syslog:** severity 0 to 7 (Emergency to Debugging), and a level includes all lower numbers. Default facility is local7.
- **QoS:** shaping buffers (outbound only), policing drops or re-marks. EF = 46 for voice.
- **SSH:** requires hostname, domain name, RSA keys, a user, and `transport input ssh`.
- **TFTP is UDP 69 with no authentication. FTP is TCP 20/21 with login.**

---

## References

I haven't live-checked links, so search these titles on the named sites.

1. Cisco, **CCNA 200-301 Exam Topics** (Domain 4.0 IP Services), Cisco Learning Network / cisco.com.
2. Wendell Odom, **CCNA 200-301 Official Cert Guide, Vol. 1 and Vol. 2**, Cisco Press (NAT, NTP, DHCP/DNS, SNMP, syslog, QoS, SSH, file transfer chapters).
3. Cisco, **IP Addressing: NAT Configuration Guide**, IOS XE documentation.
4. Cisco, **Network Management Configuration Guide** (NTP, SNMP, syslog), IOS XE documentation.
5. Cisco, **IP Addressing: DHCP Configuration Guide** (DHCP server, client, relay).
6. Cisco, **QoS: Congestion Management / Policing and Shaping Configuration Guides**, IOS XE documentation.
7. Cisco, **Security Configuration Guide: Secure Shell** and **Configuration Fundamentals Guide** (file transfer, SCP).
8. **RFC 3022**, *Traditional IP Network Address Translator*; **RFC 1918**, *Address Allocation for Private Internets*.
9. **RFC 5905**, *Network Time Protocol Version 4*.
10. **RFC 2131**, *DHCP*; **RFC 1035**, *Domain Names: Implementation and Specification*.
11. **RFC 3411** to **3418**, *SNMPv3 architecture and USM*.
12. **RFC 5424**, *The Syslog Protocol*; **RFC 3164**, *BSD Syslog Protocol*.
13. **RFC 2474**, *DiffServ Field*; **RFC 2597**, *AF PHB*; **RFC 3246**, *EF PHB*; **RFC 2475**, *DiffServ Architecture*.
14. **RFC 4251** and **RFC 4253**, *SSH Protocol Architecture and Transport Layer*.
15. **RFC 1350**, *TFTP Protocol (Revision 2)*; **RFC 959**, *File Transfer Protocol*.

Want this as a Word/PDF study sheet, a practice quiz for Domains 3 and 4, or a LinkedIn-ready summary for US WealthTech?