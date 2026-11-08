




3.0 IP Connectivity (25%), the heaviest domain
- Reading the routing table
- Router forwarding decisions (longest match, administrative distance, metric)
- IPv4 and IPv6 static routes (default, host, floating)
- Single-area OSPFv2
- First hop redundancy protocols








================





Practical Case Study: Core IP Connectivity & Routing Infrastructure at Pubali Bank PLC
Executive Summary & Background
Pubali Bank PLC, headquartered in Motijheel, Dhaka, Bangladesh, is completing the third phase of its network transformation project. Following the deployment of Layer 2 network access standards, Senior IT & Infrastructure Analyst Alex and the network engineering team have architected and deployed a resilient Layer 3 IP Connectivity Infrastructure.
This case study covers the practical application of CCNA Domain 3.0 principles: routing table evaluation, deterministic packet forwarding rules, static and floating route deployment, single-area OSPFv2 dynamic routing, and high-availability First Hop Redundancy Protocols (HSRP).

Section 1: Routing Table Evaluation & Subnet Calculation
To support operations across regional hubs in Dhaka, Chittagong, and Sylhet, Pubali Bank PLC utilizes hierarchical IPv4 addressing. When evaluating an incoming packet or configuring route entries, network engineers analyze the structure of the routing table using show ip route.

O IA     10.3.3.0/24 [110/50] via 10.1.1.4, 01:05:10, GigabitEthernet0/1
Routing Field Identification
•	Route Code (O): Learned dynamically via Open Shortest Path First (OSPF).
•	Destination Prefix (10.2.2.0/24): Target destination subnet.
•	Administrative Distance / Metric ([110/20]): AD of 110 (OSPF trust rating) and an outbound metric/cost of 20.
•	Next-Hop Address (via 10.1.1.3): Ingress interface IP of the adjacent router.
•	Exit Interface (Gi0/0): Outbound physical/logical interface on the local router.

Subnetting Verification Scenario
A core banking application host is assigned IP 192.168.10.25 with subnet mask 255.255.255.240 (/28).

•	Block Size: $256 - 240 = 16$.
•	Subnet Boundaries: .0, .16, .32, .48, etc.
•	Assigned Subnet Address: 192.168.10.16/28 (Usable IP range: 192.168.10.17 to 192.168.10.30; Broadcast: 192.168.10.31).

Section 2: Router Forwarding Logic & Decision Engine
When a router receives an IP packet, it evaluates candidates in its routing table using a strict five-step hierarchy:
         |
          v
5. No Match & No Default Route -> Drop Packet & Send ICMP Unreachable
Administrative Distance (AD) Reference Table
Route Source	Administrative Distance (AD)	Trust Level
Directly Connected (C)	0	Highest Trust
Static Route (S)	1	Manual Override
eBGP	20	External Border Gateway
Internal EIGRP (D)	90	Cisco Interior Routing
OSPF (O)	110	Open Link-State
IS-IS	115	Intermediate System
RIP (R)	120	Distance Vector
External EIGRP	170	Redistributed Routes
iBGP	200	Internal Border Gateway
Unusable Route	255	Untrusted / Dropped
Critical Rule: Longest Prefix Match overrides Administrative Distance. A /24 route learned via RIP (AD 120) will be selected over a /16 static route (AD 1) when forwarding traffic to a host matching the /24 block.

Section 3: Static & Floating Backup Route Deployment
To guarantee link survival between Motijheel HQ and the Disaster Recovery (DR) site in Agrabad, Chittagong, Alex configured a combination of static routes.
+-------------------+      Floating Static Route (AD 130)   +-------------------+
Static Configuration Commands
link drops)
ip route 10.2.0.0 255.255.0.0 10.9.9.2 130
IPv6 Static Configuration

Section 4: Single-Area OSPFv2 Implementation
Pubali Bank PLC runs Single-Area OSPFv2 (Area 0) across its primary backbone to provide dynamic link-state routing, rapid convergence, and automated topology recalculation via Dijkstra's Shortest Path First (SPF) algorithm.
C ]
             (Router-ID 2.2.2.2)     (Router-ID 3.3.3.3)
OSPF Operational Parameters

•	Transport: Runs directly over IP Protocol 89.
•	Multicast Addresses: 224.0.0.5 (All OSPF Routers), 224.0.0.6 (DR/BDR Routers).
•	Router ID (RID) Order of Precedence:


1.	Manually configured router-id.
2.	Highest active IPv4 address on a Loopback interface.

3.	Highest active IPv4 address on a physical interface.

•	Adjacency States: Down → Init → 2-Way → ExStart → Exchange → Loading → Full.
•	Timers: Hello = 10s, Dead = 40s on Broadcast/Point-to-Point links. (Timers and Area IDs must match to form adjacencies).

OSPF Cost Metric Formula
Cost = \frac{\text{Reference Bandwidth}}{\text{Interface Bandwidth}}$$
By default, reference bandwidth is $100\text{ Mbps}$. To distinguish between FastEthernet ($100\text{ Mbps}$), GigabitEthernet ($1\text{ Gbps}$), and 10-GigabitEthernet ($10\text{ Gbps}$), Alex applied auto-cost reference-bandwidth 100000 across all routers.


Core OSPF Configuration Block
2
 default-information originate
Section 5: High-Availability Default Gateways (HSRP)
To prevent end-user workstations and teller terminals from losing connectivity if a default gateway router suffers a hardware failure, Pubali Bank PLC deployed Hot Standby Router Protocol Version 2 (HSRPv2) across distribution switch pairs.
                      [ CLIENT WORKSTATIONS ]
                     Default Gateway: 10.1.1.254
FHRP Protocol Comparison Table
Feature / Characteristic	Hot Standby Router Protocol (HSRP)	Virtual Router Redundancy Protocol (VRRP)	Gateway Load Balancing Protocol (GLBP)
Standard Type	Cisco Proprietary	Open Standard (RFC 5798)	Cisco Proprietary
Router Roles	Active / Standby	Master / Backup	Active Virtual Gateway (AVG) / AVFs
Multicast IP	v1: 224.0.0.2, v2: 224.0.0.102	224.0.0.18	224.0.0.102
Transport Layer	UDP Port 1985	IP Protocol 112	UDP Port 3222
Virtual MAC Structure	v1: 0000.0C07.ACxx


v2: 0000.0C9F.Fxxx
	0000.5E00.01xx	0007.B400.xxyy
Preemption Default	Disabled (standby preempt needed)	Enabled by Default	Disabled for AVG
Load Balancing Mode	Active/Standby per group	Master/Backup per group	Active Multi-Forwarder (Round-Robin)
Active HSRP Interface Configuration

Verification Questions & Answers
Q1: OSI Layer Operations
Question: Which layer of the OSI model handles logical addressing and packet routing across different networks?
Answer:
The Network Layer (Layer 3).

Q2: Subnet Calculation
Question: What is the network ID for a host configured with IP 192.168.10.25 and subnet mask 255.255.255.240 (/28)?
Answer:
192.168.10.16. (Block size of 16; subnets are .0, .16, .32; IP .25 falls inside the .16 network).

Q3: Switch Forwarding Role
Question: What is the primary operational task of a Layer 2 switch inside a LAN?

Answer:
To forward Ethernet frames based on destination MAC addresses stored in its CAM table.


Q4: Automated IP Allocation
Question: Which network service dynamically assigns IP addresses, subnet masks, default gateways, and DNS server addresses to endpoints?

Answer:
DHCP (Dynamic Host Configuration Protocol).


Q5: Loop Prevention
Question: What loop-related defect in switched network topologies does Spanning Tree Protocol (STP) prevent?

Answer:
Broadcast storms (and Layer 2 switching loops/MAC table instability).


Q6: Longest Prefix Match
Question: A router holds candidate routes 10.0.0.0/8, 10.1.0.0/16, and 10.1.1.0/24 in its routing table. Which route will be selected to forward a packet addressed to 10.1.1.45?

Answer:
10.1.1.0/24, because it represents the Longest Prefix Match (most specific network mask).


Q7: Administrative Distance Comparison
Question: If a router receives the exact same prefix 172.16.10.0/24 from OSPF (AD 110) and Internal EIGRP (AD 90), which route gets installed into the routing table?

Answer:
The EIGRP route, because it possesses a lower Administrative Distance (90 vs. 110).

Q8: Floating Static Route Mechanics
Question: How is a floating static route configured so that it remains inactive until the primary route fails?

Answer:
By manually assigning it an Administrative Distance higher than the primary route's AD (e.g., AD 130 to back up an OSPF route with AD 110).

Q9: IPv6 Routing Requirement
Question: What global configuration command must be executed on a Cisco router before it will forward IPv6 packets or process IPv6 static routes?

Answer:
ipv6 unicast-routing

Q10: OSPF Transport Protocol
Question: Which IP transport protocol number does OSPF use to encapsulate its messages directly over IP?

Answer:
IP Protocol 89.


Q11: OSPF Multicast Destination Addresses
Question: What are the two dedicated IPv4 multicast addresses utilized by OSPFv2?

Answer:

•	224.0.0.5 (All OSPF Routers)
•	224.0.0.6 (Designated Routers / Backup Designated Routers - DR/BDR)

Q12: OSPF Router ID Precedence
Question: How does an OSPF router determine its Router ID if it is not manually configured?

Answer:
It chooses the highest IPv4 address among its active loopback interfaces. If no loopback interfaces exist, it selects the highest IPv4 address among its active physical interfaces.


Q13: OSPF DR/BDR Election
Question: What priority value must be configured on an OSPF interface to prevent a router from ever participating in a Designated Router (DR) election?

Answer:
An OSPF priority of 0 (ip ospf priority 0).

Q14: OSPF Neighbor Adjacency Parameters
Question: Identify three configuration parameters that must match identically between two neighbor interfaces for an OSPF adjacency to reach the FULL state.
Answer:

•	Hello and Dead Timers
•	Area ID
•	Subnet Address and Network Mask

(Additional valid answers: OSPF Authentication password, MTU size).

Q15: OSPF Passive Interface Function
Question: What is the effect of configuring passive-interface on an OSPF-enabled interface?
Answer:
The router stops sending and receiving OSPF Hello packets on that interface (preventing adjacencies), but continues to advertise the interface's connected subnet into OSPF.

Q16: Default Route Distribution in OSPF
Question: Which command instructs an OSPF router to advertise its local default route (0.0.0.0/0) to all adjacent OSPF neighbors?

Answer:
default-information originate

Q17: HSRP Router Roles
Question: In an HSRP group, what role is assumed by the router that actively responds to ARP requests sent to the Virtual IP address?
Answer:
The Active Router.

Q18: HSRP Preemption Behavior
Question: What happens when a higher-priority HSRP router recovers from a failure if preemption is NOT configured?

Answer:
The recovered router remains in the Standby state and will not reclaim the Active role until the currently active router fails or its HSRP service is restarted.

Q19: VRRP Protocol Standards
Question: Is Virtual Router Redundancy Protocol (VRRP) proprietary to Cisco or open-standard? What transport protocol does it use?
Answer:
VRRP is an open-standard protocol (RFC 5798) running directly over IP Protocol 112.

Q20: Automatic FHRP Load Balancing
Question: Which First Hop Redundancy Protocol provides dynamic, per-host load balancing across multiple active gateways without requiring multi-group configurations?
Answer:
GLBP (Gateway Load Balancing Protocol).






=============================================================

Here are 5 CCNA-style questions for practice:

1. Which OSI layer is responsible for routing packets between different networks?
A. Data Link layer
B. Network layer
C. Transport layer
D. Application layer

2. A host is configured with IP address 192.168.10.25 and subnet mask 255.255.255.240. Which of the following is the network address?
A. 192.168.10.0
B. 192.168.10.16
C. 192.168.10.24
D. 192.168.10.32

3. What is the main purpose of a switch in a LAN?
A. To connect different autonomous systems
B. To forward frames based on MAC addresses
C. To convert public IP addresses to private IP addresses
D. To encrypt traffic between hosts

4. Which protocol is used to automatically assign IP addresses to devices on a network?
A. DNS
B. DHCP
C. FTP
D. SNMP

5. What does STP (Spanning Tree Protocol) prevent in a switched network?
A. Duplicate IP addresses
B. Broadcast storms
C. Routing loops
D. ARP cache poisoning

Answer key:
1. B
2. B
3. B
4. B
5. C

If you want, I can also give:
- 5 easier beginner-level CCNA questions
- 5 harder troubleshooting questions
- 5 questions based specifically on a chapter from your repo if you share the Chap_03 content





================================================

3.0 IP Connectivity (25%), the heaviest domain
- Reading the routing table
- Router forwarding decisions (longest match, administrative distance, metric)
- IPv4 and IPv6 static routes (default, host, floating)
- Single-area OSPFv2
- First hop redundancy protocols




================================================




# Domain 3.0 IP Connectivity: Study Notes (25%)

## 1. Reading the routing table

What: The routing table is the router's list of known destination networks and how to reach each. Commands: `show ip route`, `show ip route 10.2.2.5` (lookup for one address), `show ip route ospf`, `show ipv6 route`.

```
Gateway of last resort is 10.1.1.1 to network 0.0.0.0

S*    0.0.0.0/0 [1/0] via 10.1.1.1
      10.0.0.0/8 is variably subnetted, 3 subnets, 3 masks
C        10.1.1.0/24 is directly connected, GigabitEthernet0/0
L        10.1.1.2/32 is directly connected, GigabitEthernet0/0
O        10.2.2.0/24 [110/20] via 10.1.1.3, 00:05:12, GigabitEthernet0/0
```

Field breakdown for the OSPF line:

| Field | Value | Meaning |
|---|---|---|
| Code | `O` | Learned via OSPF |
| Prefix/mask | `10.2.2.0/24` | Destination network |
| `[AD/metric]` | `[110/20]` | Administrative distance 110, metric (cost) 20 |
| Next hop | `via 10.1.1.3` | Neighbor router's IP |
| Age | `00:05:12` | Time since learned |
| Exit interface | `Gi0/0` | Where the packet leaves |

Route codes:

| Code | Meaning |
|---|---|
| C | Directly connected network |
| L | Local: the router's own interface address (/32 IPv4, /128 IPv6) |
| S | Static |
| S* | Static candidate default |
| O | OSPF (intra-area); O IA = inter-area; O E1/E2 = external |
| D | EIGRP |
| R | RIP |
| B | BGP |

Gateway of last resort: the default route (0.0.0.0/0) is used when nothing else matches.

Analogy: a road-sign board at a junction. Each sign shows the destination area, how trustworthy the source is (AD), the distance (metric) and which exit to take. "Gateway of last resort" is the sign saying "everything else, take the highway".

---

## 2. Router forwarding decision

Selection order, every packet:

1. Longest prefix match. The most specific matching route wins, regardless of AD or metric.
2. Lowest AD applies only when the *same exact prefix* is learned from different sources.
3. Lowest metric applies within the same protocol for the same prefix.
4. Equal metric: equal-cost load balancing (OSPF defaults to 4 paths; maximum is configurable).
5. No match and no default route: drop the packet and send ICMP unreachable.

Longest match example:

| Routes in table | Packet to | Used route |
|---|---|---|
| 10.0.0.0/8, 10.1.0.0/16, 10.1.1.0/24, 0.0.0.0/0 | 10.1.1.5 | /24 |
| (same) | 10.1.2.9 | /16 |
| (same) | 10.5.5.5 | /8 |
| (same) | 8.8.8.8 | /0 (default) |

Analogy: a courier's address book. A rule for "Lane 3, Sector 2" beats a rule for "Sector 2", which beats "this city". The most specific instruction wins. AD is only used when two sources claim the *same* lane.

Administrative distance (trust ranking, lower is better):

| Source | AD |
|---|---|
| Connected | 0 |
| Static | 1 |
| eBGP | 20 |
| EIGRP (internal) | 90 |
| OSPF | 110 |
| IS-IS | 115 |
| RIP | 120 |
| EIGRP (external) | 170 |
| iBGP | 200 |
| Unusable | 255 |

Metrics (not comparable across protocols, which is why AD exists):
- OSPF: cost = reference bandwidth ÷ interface bandwidth. Default reference is 100 Mbps.
- RIP: hop count (max 15).
- EIGRP: composite of bandwidth and delay.

Per-hop actions: TTL decreases by 1, and a new Layer 2 header is built (source MAC = egress interface, destination MAC = next hop, found via ARP).

Traps:
- AD is *never* compared between different prefix lengths.
- A /24 learned from RIP (AD 120) beats a /16 learned from a static route (AD 1), because the /24 is more specific.

---

## 3. Static routes: network, host, default and floating

IPv4 syntax:
```
ip route <network> <mask> <next-hop-IP | exit-interface> [AD]
```

| Type | Example | Notes |
|---|---|---|
| Network | `ip route 10.2.0.0 255.255.0.0 10.1.1.2` | Reaches a whole subnet |
| Host | `ip route 10.2.2.50 255.255.255.255 10.1.1.2` | /32 for one device; most specific |
| Default | `ip route 0.0.0.0 0.0.0.0 10.1.1.1` | Matches everything; shows as S* |
| Floating | `ip route 10.2.0.0 255.255.0.0 10.9.9.2 130` | AD higher than the primary route; backup only |
| Fully specified | `ip route 10.2.0.0 255.255.0.0 g0/0 10.1.1.2` | Exit interface and next hop |

Next hop vs exit interface:
- Next-hop IP: the router does a recursive lookup to find the exit interface.
- Exit interface only: fine on point-to-point serial. On Ethernet it forces ARP for every destination, so use a next-hop or the fully specified form.

IPv6 syntax:
```
ipv6 unicast-routing                       ! required, off by default
ipv6 route 2001:db8:2::/64 2001:db8:12::2
ipv6 route ::/0 2001:db8:12::1             ! default route
ipv6 route 2001:db8:2::50/128 2001:db8:12::2   ! host route
ipv6 route 2001:db8:2::/64 g0/0 fe80::2    ! link-local next hop: exit interface required
ipv6 route 2001:db8:2::/64 2001:db8:99::2 130  ! floating
```

Floating static rules:
- Its AD must be greater than the primary route's AD. For a backup of an OSPF route (110), use any value above 110, such as 130.
- It stays out of the routing table until the primary route disappears. Then it is installed.

Analogies:
- Default route: if you don't know the address, take the main highway.
- Host route: a special instruction for one house.
- Floating: a diversion road behind a barrier that opens only when the highway closes.

Verify: `show ip route static`, `show ip route 10.2.2.5`, `ping`, `traceroute`.

Traps:
- IPv6 routing does nothing until `ipv6 unicast-routing` is enabled.
- A link-local IPv6 next hop *must* include the exit interface.

---

## 4. Single-area OSPFv2

Core facts:
- Link-state IGP, open standard, AD 110, metric = cost, SPF algorithm (Dijkstra).
- Runs directly over IP protocol 89. Multicast: 224.0.0.5 (all OSPF routers), 224.0.0.6 (DR/BDR).
- Single area means everything is in Area 0 (the backbone).
- Process ID is locally significant and need not match between routers.

Analogy: every router draws the same city map. Each announces "I'm connected to X at cost Y" (LSAs), builds a shared database (LSDB), then runs SPF alone to find the shortest route. Distance-vector protocols pass rumors ("I heard from Bob that..."). OSPF shares the map.

Timers (must match to form a neighbor):

| Network type | Hello | Dead |
|---|---|---|
| Broadcast, point-to-point | 10 s | 40 s |
| Non-broadcast (NBMA) | 30 s | 120 s |

Router ID (selected in this order):
1. Manual `router-id`
2. Highest IPv4 address on an up loopback interface
3. Highest IPv4 address on an up physical interface

A changed router ID needs `clear ip ospf process`.

Neighbor states: Down → Init → 2-Way → ExStart → Exchange → Loading → Full

DR/BDR (broadcast networks only):
- Elected at 2-Way. Highest priority wins (default 1, range 0-255, 0 = never DR). A tie goes to the highest router ID.
- Not preemptive: a later router with higher priority does not take over.
- Non-DR/BDR routers (DROTHERs) stay at 2-Way with each other and reach Full only with the DR and BDR.
- Analogy: a class monitor who collects and redistributes notices, so 20 students don't each talk to 19 others.
- Set `ip ospf network point-to-point` on an Ethernet link between exactly two routers to skip the election.

Cost:
- Cost = 100 Mbps ÷ interface bandwidth, minimum 1.

| Interface | Default cost |
|---|---|
| 10 Mbps Ethernet | 10 |
| T1 (1.544 Mbps) | 64 |
| FastEthernet | 1 |
| GigabitEthernet | 1 |
| 10 GigabitEthernet | 1 |

- Path cost is the sum of outgoing interface costs.
- To tell Gig and 10Gig apart, use `auto-cost reference-bandwidth 10000` on all routers. Other options: `ip ospf cost`, or `bandwidth`, which only affects the cost calculation.

Configuration:
```
router ospf 1
 router-id 1.1.1.1
 network 10.1.1.0 0.0.0.255 area 0      ! wildcard mask
 passive-interface g0/2                 ! LAN port: no hellos, network still advertised
 default-information originate          ! advertise default route (needs one in the table)
```
Alternative at interface level: `ip ospf 1 area 0`.

Verify: `show ip ospf neighbor`, `show ip ospf interface brief`, `show ip protocols`, `show ip route ospf`, `show ip ospf database`.

Neighbor won't form? Check:
- Hello/dead timers mismatch.
- Area ID mismatch.
- Subnet or mask mismatch.
- Authentication mismatch.
- Duplicate router ID.
- Passive interface.
- ACL blocking.
- Stuck in ExStart/Exchange, which usually means MTU mismatch.
- Network type mismatch.

---

## 5. First hop redundancy protocols (FHRP)

Problem: a PC has one default gateway. If that router dies, the PC loses off-subnet connectivity even though another router exists.

Solution: two or more routers share a virtual IP and virtual MAC. The PC's gateway is the virtual IP, so failover is invisible to it.

Analogy: a company hotline number forwarded to whoever is on duty. Callers never learn that the receptionist changed.

| | HSRP | VRRP | GLBP |
|---|---|---|---|
| Standard | Cisco proprietary | IEEE open (RFC 5798) | Cisco proprietary |
| Roles | Active / Standby | Master / Backup | AVG + up to 4 AVFs |
| Load balancing | Per group only | Per group only | Automatic per host (round-robin by default) |
| Multicast | v1 224.0.0.2; v2 224.0.0.102 | 224.0.0.18 | 224.0.0.102 |
| Transport | UDP 1985 | IP protocol 112 | UDP 3222 |
| Virtual MAC | v1 0000.0C07.ACxx; v2 0000.0C9F.Fxxx | 0000.5E00.01xx | 0007.B400.xxyy |
| Default priority | 100 (0-255) | 100 (0-255) | 100 |
| Timers | Hello 3 s / Hold 10 s | Advert 1 s / Master-down about 3 s | Hello 3 s / Hold 10 s |
| Preemption | Off by default | On by default | Off by default for AVG |
| Groups | v1: 0-255; v2: 0-4095 | 1-255 | 0-1023 |

How each works:
- HSRP: highest priority becomes Active, with ties going to the highest IP. The Standby takes over if hellos stop.
- VRRP: highest priority becomes Master. The Master can be the router that *owns* the virtual IP, with priority 255.
- GLBP: the AVG answers ARP requests with different forwarders' virtual MACs, so hosts spread across routers.

HSRP configuration:
```
interface g0/0
 ip address 10.1.1.2 255.255.255.0
 standby version 2
 standby 1 ip 10.1.1.254
 standby 1 priority 110
 standby 1 preempt
```
Verify with `show standby brief`. Hosts use 10.1.1.254 as their default gateway.

HSRP states: Initial, Learn, Listen, Speak, Standby, Active.

Traps:
- HSRP does *not* preempt unless `standby preempt` is configured, so a recovered high-priority router stays Standby.
- VRRP uses IP protocol 112, not UDP.
- Only GLBP load-balances automatically.

---

## Quick-recall sheet

| Topic | Remember |
|---|---|
| Routing table | `[AD/metric]`, next hop, exit interface, S* = default |
| Forwarding | Longest match → AD → metric → ECMP |
| AD | C 0, S 1, eBGP 20, EIGRP 90, OSPF 110, RIP 120 |
| Floating static | AD above the primary's; installs only when primary fails |
| IPv6 static | Needs `ipv6 unicast-routing`; link-local next hop needs exit interface |
| OSPF basics | AD 110, protocol 89, 224.0.0.5/.6, hello 10 / dead 40 |
| Router ID | Manual → highest loopback → highest physical |
| DR | Priority 0 = never; not preemptive; DROTHERs stay 2-Way |
| OSPF cost | 100 Mbps ÷ bandwidth; Gig = 1 by default; set reference bandwidth consistently |
| HSRP / VRRP / GLBP | Active-Standby / Master-Backup / load-balanced |
| Preempt | HSRP off by default; VRRP on by default |
