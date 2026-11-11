# CCNA 200-301: Domain 3.0 IP Connectivity (25%)

## Table of Contents (Clickable GitHub Menu)

- [3.1 Interpret the Components of a Routing Table](#31-interpret-the-components-of-a-routing-table)
  - [3.1.a Routing Protocol Code](#routing-protocol-code)
  - [3.1.b Prefix](#routing-prefix)
  - [3.1.c Network Mask](#routing-network-mask)
  - [3.1.d Next Hop](#routing-next-hop)
  - [3.1.e Administrative Distance](#routing-administrative-distance)
  - [3.1.f Metric](#routing-metric)
  - [3.1.g Gateway of Last Resort](#routing-gateway-of-last-resort)
- [3.2 How a Router Makes a Forwarding Decision](#32-how-a-router-makes-a-forwarding-decision)
  - [3.2.a Longest Prefix Match](#forward-longest-prefix)
  - [3.2.b Administrative Distance](#forward-administrative-distance)
  - [3.2.c Metric](#forward-metric)
- [3.3 Static Routing (IPv4 and IPv6)](#33-static-routing-ipv4-and-ipv6)
  - [3.3.a Default Route](#static-default-route)
  - [3.3.b Network Route](#static-network-route)
  - [3.3.c Host Route](#static-host-route)
  - [3.3.d Floating Static Route](#static-floating-route)
- [3.4 Single-Area OSPFv2](#34-single-area-ospfv2)
  - [3.4.a Neighbor Adjacency and States](#ospf-neighbor-adjacency)
  - [3.4.b Point-to-Point Networks](#ospf-point-to-point)
  - [3.4.c Broadcast Networks and DR/BDR](#ospf-broadcast)
  - [3.4.d Router ID Selection](#ospf-router-id)
- [3.5 First Hop Redundancy Protocols (FHRP)](#35-first-hop-redundancy-protocols-fhrp)
  - [HSRP](#fhrp-hsrp)
  - [VRRP](#fhrp-vrrp)
  - [GLBP](#fhrp-glbp)
- [Exam Tips](#exam-tips)
- [References](#references)

---


## 3.1 Interpret the Components of a Routing Table

### Technical explanation

Sample entry:

```
O    10.20.0.0/16 [110/20] via 10.1.1.2, 00:05:12, GigabitEthernet0/0
```

| Component | In the example | Meaning |
|---|---|---|
| <a id="routing-protocol-code"></a>**3.1.a Routing protocol code** | `O` | How the route was learned. |
| <a id="routing-prefix"></a>**3.1.b Prefix** | `10.20.0.0` | Destination network address. |
| <a id="routing-network-mask"></a>**3.1.c Network mask** | `/16` | Defines how many bits identify the network. |
| <a id="routing-next-hop"></a>**3.1.d Next hop** | `via 10.1.1.2` | IP of the next router. The exit interface is shown at the end. |
| <a id="routing-administrative-distance"></a>**3.1.e Administrative distance** | `110` | Trustworthiness of the *source*. Lower is better. |
| <a id="routing-metric"></a>**3.1.f Metric** | `20` | Quality of the path *within one protocol*. Lower is better. |
| <a id="routing-gateway-of-last-resort"></a>**3.1.g Gateway of last resort** | `Gateway of last resort is x.x.x.x to network 0.0.0.0` | The default route used when no specific match exists. |

**Common codes:**
- `C` connected
- `L` local (a /32 for the router's own interface IP)
- `S` static
- `S*` static candidate default
- `O` OSPF intra-area
- `O IA` OSPF inter-area
- `O E1/E2` OSPF external
- `D` EIGRP
- `D EX` EIGRP external
- `R` RIP
- `B` BGP
- `i` IS-IS

**Administrative distance (memorize):**

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

**Metrics by protocol:**
- **OSPF:** cost = reference bandwidth ÷ interface bandwidth (default reference 100 Mbps, minimum cost 1).
- **RIP:** hop count (16 = unreachable).
- **EIGRP:** composite of bandwidth and delay by default.

### Banking example

A branch router in Chattogram learns the Head Office core-banking subnet `10.20.0.0/16` through OSPF. It sees `[110/20]` via the WAN next hop. Internet traffic follows `S* 0.0.0.0/0 [1/0] via 203.0.113.1`, the gateway of last resort toward the ISP.

### IOS commands

```
show ip route
show ip route 10.20.5.10          ! how would I reach this specific host?
show ip route ospf
show ipv6 route
show ip route | include Gateway
```

### Analogy

The routing table is a **GPS contact list**:
- The prefix is the destination.
- The next hop is the first turn.
- AD is "which map app do I trust more."
- The metric is "which road is shorter on that app."
- The gateway of last resort is "if I don't know the address, take the highway to the city center."

### Troubleshooting

- **Route missing:** check the neighbor, the `network` statement, or the interface state.
- **Wrong route used:** check the AD and prefix length (see 3.2).
- **No gateway of last resort:** the default route is missing, or the OSPF `default-information originate` is absent.
- **`L` and `C` entries missing:** the interface is down/down or has no IP.

---

## 3.2 How a Router Makes a Forwarding Decision

### Technical explanation

The order is strict, and the first rule decides before the next is considered:

1. <a id="forward-longest-prefix"></a>**Longest prefix match (3.2.a):** the most specific matching route wins, regardless of AD or metric.
2. <a id="forward-administrative-distance"></a>**Administrative distance (3.2.b):** applies when *two sources offer the identical prefix/mask*. The lowest AD wins.
3. <a id="forward-metric"></a>**Metric (3.2.c):** applies when the *same protocol* offers multiple paths to the same prefix. The lowest metric wins. Equal metrics give **ECMP**, load-balancing across paths (default max is 4 for OSPF on most IOS).

Packet to `10.10.10.5` with these routes:

```
S    10.10.0.0/16  [1/0]   via 192.168.1.2
O    10.10.10.0/24 [110/20] via 192.168.2.2
```

The router uses the **OSPF /24 route**. The /24 is more specific, so the static route's better AD never comes into play.

Hardware forwarding uses **CEF** (FIB plus adjacency table). The routing table feeds the FIB, but the *decision logic is the same*.

### Banking example

Static `10.30.0.0/16` points to a backup DR site, while OSPF advertises `10.30.5.0/24` for the ATM switch VLAN at the primary site. ATM traffic to `10.30.5.x` goes to the primary site because of the /24, even though static has AD 1.

### IOS commands

```
show ip route 10.10.10.5
show ip cef 10.10.10.5
show ip route 10.10.10.0 255.255.255.0 longer-prefixes
```

### Analogy

Think of a **postal sorter**. A letter addressed to "Apt 4B, 12 Main St" goes to the exact building (longest match) before the general neighborhood depot. If two depots claim the same address, the more trusted depot wins (AD). If one depot has two trucks, the faster truck wins (metric).

### Troubleshooting

- **Traffic bypasses an expected path:** a more specific summary or stray route (for example a /32) is stealing it. Use `show ip route <ip>`.
- **Static not overriding OSPF for the same prefix:** check whether the AD was set above 110 (floating static).
- **Asymmetric traffic:** check the return path on the far router.

---

## 3.3 Static Routing (IPv4 and IPv6)

### Technical explanation

| Type | Purpose | Key detail |
|---|---|---|
| <a id="static-default-route"></a>**3.3.a Default route** | Catch-all | `0.0.0.0/0` (IPv4), `::/0` (IPv6) |
| <a id="static-network-route"></a>**3.3.b Network route** | Specific subnet | Any mask length |
| <a id="static-host-route"></a>**3.3.c Host route** | Single device | `/32` IPv4, `/128` IPv6 |
| <a id="static-floating-route"></a>**3.3.d Floating static** | Backup route | Configured AD *higher* than the primary route's AD, so it stays out of the table until the primary disappears |

**Next-hop forms:**
- **Next-hop IP (recursive):** needs a recursive lookup to reach the next hop.
- **Exit interface only:** on Ethernet it triggers an ARP per destination (proxy ARP dependency), so avoid it.
- **Fully specified (interface plus next hop):** best on multi-access links. It is *required for IPv6 link-local next hops*.

**IPv6 requires `ipv6 unicast-routing`** globally, or the router won't forward IPv6.

### Configuration (documentation IP ranges)

```
! ---- IPv4 ----
ip route 10.50.0.0 255.255.255.0 192.168.1.2        ! network route
ip route 10.50.0.25 255.255.255.255 192.168.1.2     ! host route
ip route 0.0.0.0 0.0.0.0 203.0.113.1                ! default route
ip route 0.0.0.0 0.0.0.0 198.51.100.1 150           ! floating static (AD 150)

! ---- IPv6 ----
ipv6 unicast-routing
ipv6 route 2001:db8:50::/64 2001:db8:1::2           ! network route
ipv6 route 2001:db8:50::25/128 2001:db8:1::2        ! host route
ipv6 route ::/0 2001:db8:ffff::1                    ! default route
ipv6 route ::/0 2001:db8:eeee::1 150                ! floating static
ipv6 route 2001:db8:50::/64 GigabitEthernet0/0 FE80::2   ! link-local next hop
```

### Banking example

A branch has a primary MPLS link to Head Office and an internet-VPN backup:

```
ip route 0.0.0.0 0.0.0.0 10.255.0.1          ! MPLS (AD 1), primary
ip route 0.0.0.0 0.0.0.0 172.16.99.1 200     ! VPN backup, floating
```

If the MPLS interface goes down, the primary route leaves the table and the AD 200 route is installed. A host route (`/32`) can pin the branch's SWIFT gateway to a specific secure path.

### Verification

```
show ip route static
show ip route 0.0.0.0
show ipv6 route static
ping 10.50.0.25 source loopback0
traceroute 10.50.0.25
show running-config | include ip route
```

### Analogy

- **Default route:** "When in doubt, take the main highway."
- **Host route:** a reserved parking spot for one VIP.
- **Floating static:** a spare tire, used only when the primary fails.

### Troubleshooting

- **Route not installed:** the next hop is unreachable, or the exit interface is down, so the route is removed.
- **Floating static never takes over:** the primary link is up/up but the path beyond it is dead. The router can't detect that, so you need IP SLA with tracking (beyond CCNA).
- **Floating static always active:** its AD is not higher than the primary's.
- **IPv6 not working:** `ipv6 unicast-routing` is missing, or a link-local next hop was used without an exit interface.
- **Wrong mask:** `255.255.255.0` typed as a wildcard, or a /24 vs /32 mix-up.
- **Routing loop:** two static default routes pointing at each other. Check with `traceroute`.

---

## 3.4 Single-Area OSPFv2

### Technical explanation

OSPF is a **link-state** protocol. Routers flood LSAs, build an identical LSDB, and run SPF (Dijkstra). OSPFv2 runs as IP protocol 89, with hellos to **224.0.0.5** and DR/BDR traffic to **224.0.0.6**.

<a id="ospf-neighbor-adjacency"></a>**3.4.a Neighbor adjacency, state machine:**
Down → Init → 2-Way → ExStart → Exchange → Loading → Full

**Parameters that must match for a neighbor to form:**
- Area ID
- Hello/dead timers
- Subnet and mask
- Authentication
- Stub flags
- MTU (otherwise the neighbor gets stuck at ExStart/Exchange)

The router ID must also be **unique**.

<a id="ospf-point-to-point"></a>**3.4.b Point-to-point:** no DR/BDR election, hello 10 / dead 40, neighbors go straight to Full. This is the best choice for two-router links, and converges faster:

```
ip ospf network point-to-point
```

<a id="ospf-broadcast"></a>**3.4.c Broadcast (Ethernet default):** hello 10 / dead 40 with a **DR/BDR election**:
1. Highest interface priority wins (0-255; **0 = never eligible**, default 1).
2. Tie: highest router ID wins.
3. Election is **non-preemptive**. A better router that joins later does not take over.

All routers form Full adjacencies only with the DR and BDR. **DROther** routers stay at **2-Way** with each other, which is normal.

<a id="ospf-router-id"></a>**3.4.d Router ID selection order:**
1. Manual `router-id`
2. Highest loopback IP
3. Highest active physical interface IP

The RID is chosen when the process starts. Changing it requires `clear ip ospf process` or a reload.

**Cost:** the default reference bandwidth is 100 Mbps, so FastEthernet, GigabitEthernet, and 10G all equal cost 1. Fix it with `auto-cost reference-bandwidth 10000` (**the same on all routers**) or set `ip ospf cost` per interface.

### Configuration

```
router ospf 1
 router-id 1.1.1.1
 auto-cost reference-bandwidth 10000
 network 10.1.1.0 0.0.0.255 area 0
 network 1.1.1.1 0.0.0.0 area 0
 passive-interface default
 no passive-interface GigabitEthernet0/0
 default-information originate
!
interface GigabitEthernet0/0
 ip ospf priority 100            ! DR candidate
 ip ospf network point-to-point  ! on a two-router link
 ip ospf hello-interval 10
!
! Alternative (interface-based):
interface GigabitEthernet0/1
 ip ospf 1 area 0
```

### Banking example

Head Office core switches and two data-center routers sit on a shared LAN segment. Set the primary core to priority 100 (DR) and the second to 90 (BDR), and set branch-facing edge routers to priority 0 so they never become DR. Loopback-based router IDs (e.g., `1.1.1.1`) stay stable even if a physical link flaps. Use `passive-interface` on the ATM and user LAN interfaces so OSPF hellos never reach end devices.

### Verification

```
show ip ospf neighbor
show ip ospf interface brief
show ip ospf interface GigabitEthernet0/0
show ip protocols
show ip ospf database
show ip route ospf
debug ip ospf adj          ! lab use only
debug ip ospf hello
```

### Analogy

OSPF is a **shared city map**. Every router draws the same map (LSDB) and each finds its own shortest route. On a busy meeting room (broadcast), instead of everyone briefing everyone, they brief a **chairperson (DR)** and a deputy (BDR). On a phone call between two people (point-to-point), no chairperson is needed.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| No neighbor | Passive interface, wrong subnet/mask, area mismatch, timers or authentication mismatch, ACL blocking 224.0.0.5 |
| Stuck in **Init** | Hellos received but ours aren't reaching them (ACL, one-way link) |
| Stuck in **2-Way** | Normal for DROther. Otherwise check the priority-0 misconfiguration (everyone at 0 means no DR). |
| Stuck in **ExStart/Exchange** | **MTU mismatch** or duplicate router ID |
| Route missing | `network` statement/wildcard wrong, or the interface isn't in the process |
| Wrong DR | Election is non-preemptive. Reset the process (`clear ip ospf process`) after changing priorities. |
| Suboptimal path | Reference-bandwidth mismatch across routers |

---

## 3.5 First Hop Redundancy Protocols (FHRP)

### Technical explanation

**Problem:** hosts have only one configured default gateway. If it fails, hosts lose all off-subnet access even if a second router exists.

**Solution:** two or more routers share a **virtual IP (VIP) and virtual MAC**. Hosts use the VIP as their default gateway, and the active router answers ARP for it. If it fails, another router takes over the VIP/vMAC without changing host configuration.

| Feature | <a id="fhrp-hsrp"></a>**HSRP** | <a id="fhrp-vrrp"></a>**VRRP** | <a id="fhrp-glbp"></a>**GLBP** |
|---|---|---|---|
| Standard | Cisco proprietary | Open (RFC 5798) | Cisco proprietary |
| Roles | Active / Standby | Master / Backup | AVG + AVFs (multiple forwarders) |
| Load balancing | Per group only (multiple groups) | Per group only | **Built-in** per host |
| Multicast | 224.0.0.2 (v1), 224.0.0.102 (v2) | 224.0.0.18 | 224.0.0.102 |
| Transport | UDP 1985 | IP protocol 112 | UDP 3222 |
| Virtual MAC | 0000.0C07.ACxx (v1), 0000.0C9F.Fxxx (v2) | 0000.5E00.01xx | 0007.B400.xxyy |
| Default priority | 100 | 100 | 100 |
| Preempt default | **Off** | **On** | Off for AVG |
| Timers | Hello 3 s / hold 10 s | Advertisement 1 s | Hello 3 s / hold 10 s |

**Key concepts:**
- **Priority** decides the active/master. Higher wins, with ties broken by the highest IP.
- **Preemption** lets a higher-priority router retake the active role after recovery.
- **Tracking** lowers the priority if an uplink fails, so the active role moves to the router with a working uplink.

### Configuration (HSRP, plus brief VRRP and GLBP)

```
! ---- HSRP on R1 (intended active) ----
interface GigabitEthernet0/0
 ip address 10.10.10.2 255.255.255.0
 standby version 2
 standby 10 ip 10.10.10.1
 standby 10 priority 110
 standby 10 preempt
 standby 10 track GigabitEthernet0/1 20     ! lower priority by 20 if uplink fails

! ---- HSRP on R2 ----
interface GigabitEthernet0/0
 ip address 10.10.10.3 255.255.255.0
 standby version 2
 standby 10 ip 10.10.10.1
 standby 10 priority 100

! ---- VRRP ----
interface GigabitEthernet0/0
 vrrp 10 ip 10.10.10.1
 vrrp 10 priority 110

! ---- GLBP ----
interface GigabitEthernet0/0
 glbp 10 ip 10.10.10.1
 glbp 10 load-balancing round-robin
```

Note: newer IOS-XE releases use `vrrp 10 address-family ipv4` syntax, and `standby ... track` may use object tracking. Check your platform.

### Banking example

The core-banking application VLAN uses a VIP `10.10.10.1` as gateway. Core Switch-1 is HSRP active and Core Switch-2 is standby. If Core-1 or its WAN uplink fails, Core-2 takes over in about 10 seconds by default (hold time), without reconfiguring the application servers. Cutover can be faster with tuned timers. For branch gateways serving tellers and ATMs, GLBP can spread load across both routers when the branch has equal links.

### Verification

```
show standby brief
show standby
show vrrp brief
show glbp brief
show ip arp           ! should show the virtual MAC for the VIP
```

### Analogy

Like a **bank's main phone number** that rings at the front desk. If the clerk on duty leaves, the call automatically rings at the colleague's desk. Callers always dial one number (the VIP) and never need to know who's answering.

### Troubleshooting

- **Both routers Active (split brain):** hellos are blocked by a layer-2 issue (VLAN, trunk, STP, ACL on the multicast address).
- **Wrong router active after recovery:** HSRP preempt is off by default.
- **No group formation:** check group number, version mismatch (v1 vs v2), authentication, and VIP subnet.
- **Hosts can't reach the gateway:** check the VIP in the same subnet and that the host's gateway is the VIP, not a physical IP.
- **Failover doesn't happen on uplink loss:** no tracking is configured, so the router stays active while its uplink is dead.
- **Traffic asymmetry:** STP root and HSRP active are on different switches. Align them.

---

## Exam tips

- **Longest prefix → AD → metric.** Never reverse this.
- **Floating static:** AD must be *greater* than the primary's.
- **OSPF DR/BDR is not preemptive.** DROther-to-DROther stays at 2-Way.
- **Router ID:** manual > highest loopback > highest physical IP.
- **HSRP preempt is off by default. VRRP is open standard. GLBP load-balances.**
- **IPv6 static** needs `ipv6 unicast-routing`.

---

## References

Domain content follows the official exam blueprint. I haven't live-checked links, so search these titles on the named sites.

1. Cisco, **CCNA 200-301 Exam Topics** (Domain 3.0 IP Connectivity), Cisco Learning Network / cisco.com.
2. Wendell Odom, **CCNA 200-301 Official Cert Guide, Vol. 1 and Vol. 2**, Cisco Press (routing table, static routing, OSPF, FHRP chapters).
3. Cisco, **IP Routing: OSPF Configuration Guide** and **IP Routing: Protocol-Independent Configuration Guide** (static routes, AD), Cisco IOS/IOS XE documentation at cisco.com.
4. Cisco, **IP Application Services Configuration Guide, FHRP** (HSRP, GLBP, VRRP), Cisco IOS XE documentation.
5. **RFC 2328**, *OSPF Version 2* (IETF).
6. **RFC 5798**, *Virtual Router Redundancy Protocol (VRRP) Version 3* (IETF).
7. **RFC 2281**, *Cisco Hot Standby Router Protocol (HSRP)* (IETF, informational).
8. **RFC 8200**, *Internet Protocol, Version 6 (IPv6) Specification* (IETF).
9. **RFC 4632**, *Classless Inter-domain Routing (CIDR)* (IETF), for prefix and longest-match concepts.
10. Cisco, **IOS Command Reference** (`show ip route`, `show ip ospf`, `standby`, `ip route`, `ipv6 route`).

Want this as a Word/PDF study sheet, a CCNA practice quiz on these topics, or a LinkedIn-ready summary for US WealthTech?
