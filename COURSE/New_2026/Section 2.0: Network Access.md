
**Learning Style:** Technical Explanation + Banking Examples + Cisco IOS Commands + Analogies + Troubleshooting

---

# TABLE OF CONTENTS (QUICK MENU)

1. [VLAN Configuration (2.1)](#21-configure-and-verify-vlans-normal-range)
   - [Access Ports: Data and Voice](#21a-access-ports-data-and-voice)
   - [Default VLAN](#21b-default-vlan)
   - [Inter-VLAN Connectivity](#21c-inter-vlan-connectivity)
2. [Interswitch Connectivity (2.2)](#22-configure-and-verify-interswitch-connectivity)
   - [Trunk Ports](#22a-trunk-ports)
   - [IEEE 802.1Q](#22b-ieee-8021q)
   - [Native VLAN](#22c-native-vlan)
3. [CDP and LLDP (2.3)](#23-configure-and-verify-layer-2-discovery-protocols)
4. [EtherChannel and LACP (2.4)](#24-configure-and-verify-etherchannel-lacp)
5. [Rapid PVST+ STP (2.5)](#25-rapid-pvst-spanning-tree-protocol)
   - [Root Bridge and Port Roles](#25a-root-bridge-and-port-roles)
   - [Port States](#25b-port-states-and-roles)
   - [PortFast](#25c-portfast)
   - [STP Protection Features](#25d-root-guard-loop-guard-bpdu-filter-and-bpdu-guard)
6. [Cisco Wireless Architecture and AP Modes (2.6)](#26-cisco-wireless-architectures-and-ap-modes)
7. [WLAN Physical Infrastructure (2.7)](#27-physical-infrastructure-connections-of-wlan-components)
8. [Network Device Management Access (2.8)](#28-network-device-management-access)
9. [Wireless LAN GUI Configuration (2.9)](#29-wireless-lan-gui-configuration)
10. [Final Revision Cheat Sheet](#final-network-access-revision)
11. [Official Technical References](#official-technical-references)

---

# 2.1 Configure and Verify VLANs (Normal Range)

## What is a VLAN?

**VLAN = Virtual Local Area Network.**

A VLAN logically divides one physical switch network into multiple separate Layer 2 broadcast domains.

**Simple Explanation:** One physical switch can behave like several logically separate switches.

### Banking Example

Suppose a bank has four departments:

| Department | VLAN ID | Network |
|---|---:|---|
| Treasury | 10 | 192.168.10.0/24 |
| Remittance | 20 | 192.168.20.0/24 |
| Trade | 30 | 192.168.30.0/24 |
| SWIFT | 40 | 192.168.40.0/24 |

### One Physical Switch — Four Logical Networks

```text
              ONE PHYSICAL SWITCH
                       |
          +------------+------------+
          |            |            |
       VLAN 10       VLAN 20       VLAN 30       VLAN 40
       Treasury     Remittance      Trade         SWIFT
          |            |            |              |
         PCs          PCs          PCs            PCs
```

**Analogy:** One bank building has four separate departments. They share the same building but operate in separate areas.

### Why Do We Use VLANs?

1. Network segmentation.
2. Reduced broadcast domains.
3. Improved network management.
4. Better security policy enforcement.
5. Department-based network organization.

**Important:** VLANs provide Layer 2 separation. Communication between different VLANs requires Layer 3 routing.

### Normal-Range VLANs

| VLAN Range | Purpose |
|---|---|
| 1–1005 | Normal-range VLAN IDs |
| 1 | Default VLAN |
| 2–1001 | Generally available for normal VLAN creation |
| 1002–1005 | Reserved for legacy Token Ring/FDDI |

Extended-range VLANs are 1006–4094.

**Important:** VLAN 1 cannot normally be deleted or renamed on standard Cisco Catalyst switches.

## 2.1.a Access Ports (Data and Voice)

### What is an Access Port?

An access port is a switch port assigned to one data VLAN.

Commonly connects:
- PC.
- Laptop.
- Printer.
- Server.
- Other end devices.

### Example: Treasury Access Port

```cisco
enable
configure terminal

vlan 10
name TREASURY
exit

interface gigabitEthernet 0/1
switchport mode access
switchport access vlan 10
no shutdown
exit
```

### Command Explanation

| Command | Purpose |
|---|---|
| `vlan 10` | Creates VLAN 10 |
| `name TREASURY` | Names the VLAN |
| `switchport mode access` | Makes port an access port |
| `switchport access vlan 10` | Assigns port to VLAN 10 |
| `no shutdown` | Enables the port |

### What is a Voice VLAN?

A Voice VLAN is a separate VLAN used to carry IP phone traffic.

One physical switch port can carry:
- PC data in VLAN 10.
- IP phone voice traffic in VLAN 50.

### Network Diagram

```text
             SWITCH
              Gi0/1
                |
             IP PHONE
             /      \
        Voice VLAN   PC Port
            50         |
                       PC
                    Data VLAN 10
```

### Cisco Configuration

```cisco
vlan 10
name TREASURY

vlan 50
name VOICE

interface gigabitEthernet 0/1
switchport mode access
switchport access vlan 10
switchport voice vlan 50
no shutdown
```

**How Does It Work?**

1. PC sends ordinary data traffic in VLAN 10, normally untagged.
2. IP phone sends voice traffic in VLAN 50, normally tagged with 802.1Q.
3. Switch separates the two traffic types.
4. QoS can prioritize voice traffic.

Cisco phones can receive voice VLAN information through CDP. LLDP-MED is another standardized method supported by suitable devices.

**Memory Trick:**
- Access VLAN = Data.
- Voice VLAN = IP Phone.

## 2.1.b Default VLAN

**Default VLAN = VLAN 1.**

On Cisco Catalyst switches:

- All switch ports initially belong to VLAN 1.
- VLAN 1 is created by default.
- VLAN 1 cannot normally be deleted or renamed.
- VLAN 1 is the default native VLAN in common Cisco configurations.
- Cisco control protocols commonly use VLAN 1 by default.

### Why Avoid VLAN 1 for User Traffic?

For better network security and management, administrators commonly move user and management traffic into dedicated VLANs.

| Purpose | VLAN |
|---|---:|
| Default | 1 |
| Treasury | 10 |
| Remittance | 20 |
| Trade | 30 |
| SWIFT | 40 |
| Management | 99 |
| Unused Native VLAN | 999 |

**Important:** Default VLAN and Native VLAN are different concepts, even though both are VLAN 1 by default in common Cisco configurations.

## 2.1.c Inter-VLAN Connectivity

### What is Inter-VLAN Routing?

Inter-VLAN routing allows devices belonging to different VLANs to communicate through a Layer 3 device.

**Example:**
- Treasury = VLAN 10.
- Remittance = VLAN 20.

A Layer 2 switch alone cannot route between them.

Two common methods:

1. Router-on-a-Stick.
2. Layer 3 Switch using SVIs.

### Method 1: Router-on-a-Stick

A single physical router interface uses multiple logical subinterfaces to route between VLANs.

**Analogy:** One bank security gate handles employees from several departments by checking their department ID.

```text
          ROUTER R1
        G0/0.10  G0/0.20
              |
          802.1Q TRUNK
              |
          LAYER 2 SWITCH
             /      \
         VLAN 10   VLAN 20
         Treasury Remittance
```

**Router Configuration:**

```cisco
enable
configure terminal

interface gigabitEthernet 0/0
no shutdown
exit

interface gigabitEthernet 0/0.10
encapsulation dot1Q 10
ip address 192.168.10.1 255.255.255.0
exit

interface gigabitEthernet 0/0.20
encapsulation dot1Q 20
ip address 192.168.20.1 255.255.255.0
exit
```

**Switch Configuration:**

```cisco
vlan 10
name TREASURY

vlan 20
name REMITTANCE

interface gigabitEthernet 0/1
switchport mode trunk
switchport trunk allowed vlan 10,20
no shutdown
```

**PC Default Gateways:**

| Department | Default Gateway |
|---|---|
| Treasury | 192.168.10.1 |
| Remittance | 192.168.20.1 |

**Important:** Router subinterface VLAN numbers must match the VLAN tags received on the trunk.

### Method 2: Layer 3 Switch (SVI)

**SVI = Switched Virtual Interface.**

An SVI is a logical Layer 3 interface associated with a VLAN.

A Layer 3 switch can route between VLANs without requiring a separate external router.

**Cisco Configuration:**

```cisco
enable
configure terminal

ip routing

vlan 10
name TREASURY

vlan 20
name REMITTANCE

interface vlan 10
ip address 192.168.10.1 255.255.255.0
no shutdown
exit

interface vlan 20
ip address 192.168.20.1 255.255.255.0
no shutdown
exit
```

**PC Gateways:**
- Treasury → `192.168.10.1`
- Remittance → `192.168.20.1`

### Router-on-a-Stick vs Layer 3 Switch

| Feature | Router-on-a-Stick | Layer 3 Switch |
|---|---|---|
| Routing Device | Router | Layer 3 Switch |
| Physical Connection | Router trunk | SVI |
| Routing Interface | Subinterfaces | VLAN Interfaces |
| Performance | Depends on router capacity and link | Often hardware-based |
| Common Use | Smaller LANs | Enterprise LANs |

### Verification Commands

```cisco
show vlan brief
show interfaces trunk
show interfaces gigabitEthernet 0/1 switchport
show ip interface brief
show ip route
```

**Troubleshooting Checklist:**
- VLAN exists and is active.
- Access ports belong to correct VLANs.
- Trunk permits required VLANs.
- Default gateway is correct.
- Router subinterfaces or SVIs are operational.
- Routing is enabled on the Layer 3 switch.

---

# 2.2 Configure and Verify Interswitch Connectivity

## 2.2.a Trunk Ports

### What is a Trunk Port?

A trunk port carries traffic from multiple VLANs over one physical link between switches or other network devices.

**Analogy:** One road carries employees from different bank departments, but each employee's department is identified separately.

### Access vs Trunk

| Access Port | Trunk Port |
|---|---|
| Normally carries one data VLAN | Carries multiple VLANs |
| Used for end devices | Used for switch-to-switch links |
| Frames normally untagged | VLAN frames tagged except native VLAN |
| `switchport mode access` | `switchport mode trunk` |

### Example

Two switches need to carry VLANs 10, 20 and 30.

```text
       SWITCH 1
       /  |  \
      /   |   \
   VLAN10 VLAN20 VLAN30
          |
          | TRUNK
          |
       SWITCH 2
       /  |  \
      /   |   \
   VLAN10 VLAN20 VLAN30
```

### Cisco Configuration

```cisco
interface gigabitEthernet 0/1
switchport mode trunk
switchport trunk allowed vlan 10,20,30
no shutdown
```

Verification:

```cisco
show interfaces trunk
```

**Important:** VLANs must exist and be active on the relevant switches, and the trunk's allowed VLAN list must permit their traffic.

## 2.2.b IEEE 802.1Q

### What is 802.1Q?

IEEE 802.1Q is the standard VLAN tagging mechanism used on Ethernet trunk links.

It identifies which VLAN an Ethernet frame belongs to.

### How Does It Work?

1. Switch receives an Ethernet frame.
2. It identifies the VLAN.
3. The trunking switch adds an 802.1Q tag.
4. The receiving switch reads the VLAN ID.
5. It forwards the frame within the correct VLAN.
6. When the frame exits an access port, it is normally sent without the trunk VLAN tag.

### Important 802.1Q Details

- Adds a 4-byte VLAN tag.
- Uses a 12-bit VLAN ID field.
- VLAN IDs 1–4094 are usable in the 802.1Q VLAN ID space.
- VLAN 0 and 4095 are reserved.
- Includes priority information for QoS.

**Memory Trick:** 802.1Q = VLAN Tagging Standard.

## 2.2.c Native VLAN

### What is Native VLAN?

The Native VLAN is the VLAN used for untagged traffic on an IEEE 802.1Q trunk.

By default, Cisco switches commonly use VLAN 1 as the native VLAN.

### Example

Suppose a trunk carries:
- VLAN 10.
- VLAN 20.
- VLAN 30.
- Native VLAN 999.

| VLAN | Trunk Frame |
|---|---|
| VLAN 10 | Tagged |
| VLAN 20 | Tagged |
| VLAN 30 | Tagged |
| VLAN 999 | Untagged |

### Why Is Native VLAN Important?

Both ends of a trunk should use the same native VLAN.

If native VLANs differ, untagged frames can be classified into different VLANs at opposite ends, potentially causing connectivity and security problems.

### Cisco Configuration

On both switches:

```cisco
interface gigabitEthernet 0/1
switchport mode trunk
switchport trunk native vlan 999
switchport trunk allowed vlan 10,20,30,999
```

Verification:

```cisco
show interfaces trunk
show interfaces gigabitEthernet 0/1 switchport
```

**Best Practice:** Use an unused VLAN as the native VLAN where supported, keep it consistent at both ends, and do not use it for normal user traffic.

**Memory Trick:** Native VLAN = Untagged Traffic.

---

# 2.3 Configure and Verify Layer 2 Discovery Protocols

Two important discovery protocols:

1. CDP.
2. LLDP.

## A. CDP — Cisco Discovery Protocol

CDP is a Cisco-proprietary Layer 2 discovery protocol.

It helps Cisco devices discover directly connected neighboring devices.

### Information Discovered

- Device ID.
- Neighbor port.
- Local port.
- Platform.
- Device capabilities.
- Management IP address, when advertised.

### Cisco Commands

Enable globally:

```cisco
configure terminal
cdp run
```

Disable globally:

```cisco
no cdp run
```

Disable on one interface:

```cisco
interface gigabitEthernet 0/1
no cdp enable
```

Verification:

```cisco
show cdp neighbors
show cdp neighbors detail
show cdp interface
```

## B. LLDP — Link Layer Discovery Protocol

LLDP is an IEEE 802.1AB vendor-neutral Layer 2 discovery protocol.

Unlike CDP, LLDP supports discovering neighboring devices from different vendors when they implement LLDP.

### Cisco Commands

Enable globally:

```cisco
configure terminal
lldp run
```

Disable globally:

```cisco
no lldp run
```

Disable reception on one interface:

```cisco
interface gigabitEthernet 0/1
no lldp receive
```

Disable transmission:

```cisco
no lldp transmit
```

Verification:

```cisco
show lldp
show lldp neighbors
show lldp neighbors detail
```

### CDP vs LLDP

| Feature | CDP | LLDP |
|---|---|---|
| Full Form | Cisco Discovery Protocol | Link Layer Discovery Protocol |
| Standard | Cisco Proprietary | IEEE 802.1AB |
| Vendor Support | Cisco Devices | Multivendor |
| Layer | Layer 2 | Layer 2 |
| Purpose | Neighbor Discovery | Neighbor Discovery |

**Banking Analogy:** CDP and LLDP are like employee ID cards that help identify which person or department is directly connected to another.

**Security Tip:** Disable discovery protocols on untrusted interfaces where neighbor information should not be advertised.

---

# 2.4 Configure and Verify EtherChannel (LACP)

## What is EtherChannel?

EtherChannel combines multiple physical Ethernet links into one logical link called a Port-Channel.

**Purpose:**
1. Increase aggregate bandwidth.
2. Provide link redundancy.
3. Improve link utilization.
4. Simplify STP topology.

### Banking Example

Two switches connect using two Gigabit Ethernet cables.

Instead of treating them as two independent links, EtherChannel combines them into one logical link.

```text
     WITHOUT ETHERCHANNEL

       SWITCH 1
          |  |
          |  |
          |  |
       SWITCH 2

      WITH ETHERCHANNEL

       SWITCH 1
          ||
     PORT-CHANNEL 1
          ||
       SWITCH 2
```

## What is LACP?

**LACP = Link Aggregation Control Protocol.**

LACP is a standards-based protocol that automatically negotiates EtherChannel formation.

It is standardized under IEEE 802.1AX (originally IEEE 802.3ad).

### LACP Modes

| Mode | Function |
|---|---|
| Active | Initiates LACP negotiation |
| Passive | Responds to LACP negotiation |

### Which Combinations Work?

| Switch 1 | Switch 2 | Result |
|---|---|---|
| Active | Active | Works |
| Active | Passive | Works |
| Passive | Active | Works |
| Passive | Passive | Does not form |

**Memory Trick:** At least one side must be Active.

### EtherChannel Requirements

Member interfaces must have compatible settings:

- Same speed and duplex.
- Same Layer 2 or Layer 3 characteristics.
- Matching access VLAN or trunk configuration.
- Matching native VLAN.
- Matching allowed VLANs for trunks.
- Compatible EtherChannel negotiation settings.
- Supported hardware and interface combinations.

## Layer 2 EtherChannel Configuration

Suppose two switches connect through G0/1 and G0/2.

Configure on both switches:

```cisco
configure terminal

interface range gigabitEthernet 0/1-2
switchport mode trunk
switchport trunk allowed vlan 10,20,30
channel-group 1 mode active
no shutdown
exit

interface port-channel 1
switchport mode trunk
switchport trunk allowed vlan 10,20,30
no shutdown
```

This creates a Layer 2 EtherChannel using LACP.

## Layer 3 EtherChannel Configuration

A Layer 3 EtherChannel is used for routed connectivity between Layer 3 devices.

```cisco
configure terminal

interface range gigabitEthernet 0/1-2
no switchport
channel-group 2 mode active
no shutdown
exit

interface port-channel 2
no switchport
ip address 10.0.0.1 255.255.255.252
no shutdown
```

**Difference:**
- Layer 2 EtherChannel = Switching.
- Layer 3 EtherChannel = Routing.

## Load Balancing

EtherChannel distributes traffic using a hashing algorithm based on selected fields such as:
- Source/destination MAC.
- Source/destination IP.
- Transport ports, when supported.

It does not normally send every packet of one flow over a different physical link.

One individual flow may remain limited to one member link's capacity, while multiple flows can use different members.

If one physical link fails, traffic can continue through the remaining active links.

### Verification Commands

```cisco
show etherchannel summary
show etherchannel detail
show lacp neighbor
show interfaces port-channel 1
show etherchannel load-balance
```

**Memory Trick:** EtherChannel = Multiple Physical Links → One Logical Link.

---

# 2.5 Interpret Basic Operations of Rapid PVST+ Spanning Tree Protocol

## What is STP?

**STP = Spanning Tree Protocol.**

STP prevents Layer 2 switching loops by logically blocking redundant paths while keeping them available as backups.

### Why Do We Need STP?

Imagine two switches connected with two separate links.

If both links forward frames without loop prevention, Ethernet frames can circulate repeatedly.

This may cause:
- Broadcast storms.
- Duplicate frames.
- MAC address table instability (MAC flapping).
- Network congestion.
- Network outages.

**Banking Analogy:** Two roads connect the same bank buildings. One road is used normally; the other remains available as a backup. If the first road fails, the second can become active.

### What is Rapid PVST+?

Rapid PVST+ is Cisco's per-VLAN spanning-tree implementation based on IEEE 802.1w Rapid Spanning Tree Protocol.

It provides:
- A separate spanning-tree instance per VLAN.
- Faster convergence than traditional 802.1D STP.
- Redundant link protection.
- Loop prevention.

| Protocol | Standard / Description |
|---|---|
| STP | IEEE 802.1D |
| RSTP | IEEE 802.1w |
| PVST+ | Cisco per-VLAN STP |
| Rapid PVST+ | Cisco per-VLAN implementation of rapid STP |

## 2.5.a Root Bridge and Port Roles

### What is a Root Bridge?

The Root Bridge is the central reference switch selected by STP for each VLAN.

All other switches calculate their best path toward the Root Bridge.

### How Is the Root Bridge Selected?

STP selects the switch with the lowest Bridge ID.

Bridge ID consists of:
1. Bridge Priority.
2. Extended System ID (VLAN ID).
3. MAC Address.

If priorities are equal, the lowest MAC address breaks the tie.

### Root Bridge Election Example

| Switch | Base Priority | MAC Address | Result |
|---|---:|---|---|
| SW1 | 32768 | AAAA.AAAA.AAAA | Root |
| SW2 | 32768 | BBBB.BBBB.BBBB | Non-root |
| SW3 | 32768 | CCCC.CCCC.CCCC | Non-root |

Assuming the same VLAN and equal priority, SW1 wins because it has the lowest MAC address.

### Root Primary and Root Secondary

Cisco provides commands to influence root bridge election.

**Configure Primary Root:**

```cisco
configure terminal
spanning-tree vlan 10 root primary
```

**Configure Secondary Root:**

```cisco
spanning-tree vlan 10 root secondary
```

- Root Primary = Preferred root bridge.
- Root Secondary = Backup candidate if the primary root fails.

These commands adjust bridge priorities. They do not guarantee the selected switch will remain root if another switch has a superior Bridge ID.

### Important STP Port Roles

| Port Role | Function | Analogy |
|---|---|---|
| Root Port (RP) | Best path from a non-root switch toward root | Main road to HQ |
| Designated Port (DP) | Forwarding port selected for a network segment | Main road entrance |
| Alternate Port | Backup path toward root | Alternative road |
| Backup Port | Backup for a designated port on the same shared segment | Spare road |
 
**Important Rules:**
- Root Bridge ports are normally Designated Ports.
- Each non-root switch has one Root Port per spanning-tree instance.
- Each network segment has one Designated Port.
- Alternate and Backup ports provide redundancy.

### Cisco Verification Commands

```cisco
show spanning-tree
show spanning-tree vlan 10
show spanning-tree root
show spanning-tree summary
```

## 2.5.b Port States and Roles

Do not confuse Port Role with Port State.

- Role = What job the port performs.
- State = What the port is currently allowed to do.

### Rapid PVST+ Port States

| State | Meaning |
|---|---|
| Discarding | Does not forward normal data frames or learn source MAC addresses |
| Learning | Learns source MAC addresses but does not forward normal data frames |
| Forwarding | Learns MAC addresses and forwards data frames |

**Important:** Traditional STP uses Blocking, Listening, Learning and Forwarding. RSTP combines the old Blocking and Listening behavior into Discarding.

### Port Role vs Port State

| Port | Role | State |
|---|---|---|
| SW2 Root Port | Root | Forwarding |
| SW2 Alternate Port | Alternate | Discarding |
| SW1 Root Bridge Port | Designated | Forwarding |

**Memory Trick:**
- Root Port = Best route to root.
- Designated Port = Forwarding port for segment.
- Alternate = Backup route.
- Discarding = No normal data forwarding.
- Forwarding = Data passes.

## 2.5.c PortFast

### What is PortFast?

PortFast is a Cisco STP feature that allows an edge port to enter the forwarding state immediately when its link comes up, without waiting through normal STP transition delays.

### Why Do We Need It?

Without PortFast, a PC connected to a switch may wait before normal data forwarding begins.

With PortFast, the PC can start communicating faster.

### Banking Example

A Treasury employee switches on a desktop computer.

PortFast allows the connected access port to move quickly into forwarding state.

### Cisco Configuration

```cisco
configure terminal

interface gigabitEthernet 0/10
switchport mode access
spanning-tree portfast
no shutdown
```

### Important Warning

Use PortFast on ports connected to:
- PCs.
- Printers.
- Servers.
- Other end devices that do not create Layer 2 loops.

Do not enable PortFast indiscriminately on switch-to-switch links.

**Memory Trick:** PortFast = Faster Forwarding for Edge Devices.

## 2.5.d Root Guard, Loop Guard, BPDU Filter and BPDU Guard

### What is a BPDU?

**BPDU = Bridge Protocol Data Unit.**

BPDUs are control messages exchanged by switches to build and maintain the spanning-tree topology.

Think of BPDUs as regular road-status messages exchanged between switches.

### Comparison of STP Protection Features

| Feature | Main Purpose | What Happens? |
|---|---|---|
| Root Guard | Prevents unexpected switch becoming root | Root-Inconsistent state |
| Loop Guard | Prevents loops when expected BPDUs stop arriving | Loop-Inconsistent state |
| BPDU Guard | Protects edge/PortFast ports | Err-Disabled state |
| BPDU Filter | Suppresses BPDU transmission and/or reception | STP protection is bypassed on affected port |

### A. Root Guard

**Purpose:** Prevents an unexpected downstream switch from becoming the Root Bridge.

Example:

The bank's distribution switch should remain the root.

An unauthorized switch connected downstream sends superior BPDUs.

Root Guard blocks that port in the affected VLAN by placing it in Root-Inconsistent state.

**Command:**

```cisco
interface gigabitEthernet 0/24
spanning-tree guard root
```

**Memory:** Root Guard = Protect the Root Position.

### B. Loop Guard

**Purpose:** Prevents a non-designated port from incorrectly transitioning to forwarding when expected BPDUs stop arriving.

Example:

A link suffers a one-way failure. A switch stops receiving expected BPDUs.

Without protection, a previously blocked redundant path might become forwarding and create a loop.

Loop Guard places the affected port into Loop-Inconsistent state.

**Command:**

```cisco
interface gigabitEthernet 0/24
spanning-tree guard loop
```

**Memory:** Loop Guard = Prevents Loops Caused by Missing BPDUs.

### C. BPDU Guard

**Purpose:** Protects PortFast-enabled edge ports from receiving unexpected BPDUs.

Example:

An employee connects an unauthorized switch to a port intended for a PC.

The port receives BPDUs.

BPDU Guard places the port into Err-Disabled state.

**Command:**

```cisco
interface gigabitEthernet 0/10
spanning-tree portfast
spanning-tree bpduguard enable
```

Global configuration for PortFast ports:

```cisco
spanning-tree portfast bpduguard default
```

**Memory:** BPDU Guard = If an Edge Port Receives BPDU, Shut It Down.

### D. BPDU Filter

**Purpose:** Suppresses the sending and receiving of BPDUs on a configured port.

It can prevent STP from operating normally on that interface.

**Interface Command:**

```cisco
interface gigabitEthernet 0/10
spanning-tree bpdufilter enable
```

**Global Command:**

```cisco
spanning-tree portfast bpdufilter default
```

Important difference:

- Interface-level BPDU Filter can suppress BPDUs completely on that port.
- Global PortFast BPDU Filter behavior is conditional; if a BPDU is received on an operational PortFast port, the filter is disabled for that port.

**Warning:** BPDU Filter is dangerous if used incorrectly because it can create Layer 2 loops. It is not a replacement for BPDU Guard.

### Four Protection Features — At a Glance

| Feature | Remember |
|---|---|
| Root Guard | Protects Root Bridge Position |
| Loop Guard | Protects Against Missing BPDUs |
| BPDU Guard | Disables Edge Port on BPDU |
| BPDU Filter | Suppresses BPDUs |

**CCNA Memory Trick:**
- Root Guard = No Unexpected Root.
- Loop Guard = No Loop from Missing BPDU.
- BPDU Guard = Protect Edge Port.
- BPDU Filter = Stop BPDU Exchange.

---

# 2.6 Describe Cisco Wireless Architectures and AP Modes

## What is a Wireless Architecture?

Wireless architecture describes how wireless access points, controllers and clients are organized and managed.

### A. Autonomous Wireless Architecture

An autonomous AP works independently without requiring a central WLC for normal operation.

**Characteristics:**
- Individual AP configuration.
- AP manages its own wireless services.
- Distributed management.
- Suitable for small deployments.
- Configuration becomes harder as AP numbers increase.

**Analogy:** Every bank branch manages its own security system independently.

### B. Controller-Based Wireless Architecture

Lightweight APs communicate with a Wireless LAN Controller (WLC).

The WLC provides centralized configuration, management, monitoring and policy control.

**Characteristics:**
- Centralized management.
- Common WLAN configuration.
- Centralized security policies.
- RF management.
- Client monitoring.
- CAPWAP communication between AP and WLC.

**CAPWAP = Control and Provisioning of Wireless Access Points.**

Common UDP ports:
- UDP 5246 = Control.
- UDP 5247 = Data.

**Analogy:** One head office manages Wi-Fi policies for all bank branches.

### C. Cloud-Managed Wireless Architecture

APs are managed through a cloud-based dashboard or management platform.

Example: Cisco Meraki Dashboard.

**Characteristics:**
- Centralized cloud management.
- Remote monitoring.
- Configuration through web interface.
- Easier multi-site management.
- Requires connectivity to the management cloud for cloud-based management operations.

**Important:** Cloud management does not mean all client data must pass through the cloud. Client traffic may be locally bridged or tunnelled depending on design.

### Architecture Comparison

| Feature | Autonomous | Controller-Based | Cloud-Managed |
|---|---|---|---|
| Management | Per AP | Central WLC | Cloud Dashboard |
| Configuration | Individual | Centralized | Centralized |
| Scalability | Lower | High | High |
| Monitoring | Individual | Centralized | Centralized |
| Common Use | Small Networks | Enterprise | Multi-site Organizations |

## Cisco AP Modes

Cisco lightweight APs can operate in different modes.

| AP Mode | Function | Client Service? |
|---|---|---|
| Local | Normal client-serving mode; client traffic centrally tunnelled | Yes |
| FlexConnect | Supports local or central switching | Yes |
| Monitor | Monitors wireless channels, RF and rogue activity | No |
| Sniffer | Captures wireless packets and forwards them to an analyzer | No |
| Rogue Detector | Monitors wired LAN for rogue AP activity | No |
| Bridge | Provides wireless mesh bridging | Yes, depending on design |
| Flex+Bridge | Combines FlexConnect-related capabilities with mesh deployment | Yes, depending on design |
| SE-Connect | Dedicated RF spectrum analysis | No |

### Important Modes

**1. Local Mode**
- Default lightweight AP mode.
- Uses CAPWAP to tunnel client traffic to the controller.
- Provides normal wireless access.

**2. FlexConnect Mode**
- Common for remote branch offices.
- Can centrally switch traffic through the WLC.
- Can locally switch traffic through the AP's wired LAN connection.
- Supports local authentication options when properly configured.

**3. Monitor Mode**
- Dedicated wireless monitoring.
- Used for RF monitoring and rogue detection.
- Does not provide normal client access.

**4. Sniffer Mode**
- Captures 802.11 wireless frames.
- Sends captured traffic to an external packet analyzer.
- Used for wireless troubleshooting.

**5. Rogue Detector Mode**
- Monitors wired-side MAC information to help identify rogue wireless devices.
- AP radios are disabled in this legacy mode.
- Availability is platform-dependent.

**6. Bridge Mode**
- Used in wireless mesh deployments.
- Connects network segments over wireless backhaul.

**7. SE-Connect**
- Dedicated spectrum analysis mode.
- Helps identify RF interference.

**Important:** Not every Cisco AP supports every mode. Mode availability depends on AP model and software release.

**Memory Trick:**
- Local = Normal Wi-Fi.
- FlexConnect = Branch Wi-Fi.
- Monitor = Observe.
- Sniffer = Capture.
- Rogue Detector = Detect.
- Bridge = Mesh.
- SE-Connect = Spectrum Analysis.

---

# 2.7 Describe Physical Infrastructure Connections of WLAN Components

Important components:
1. Access Point.
2. Wireless LAN Controller.
3. Access Port.
4. Trunk Port.
5. Link Aggregation Group (LAG).

## A. Access Point to Switch

An AP connects to a switch using an Ethernet cable.

The AP may receive:
- Network data.
- PoE power.
- Management connectivity.
- VLAN connectivity.

### When Is an Access Port Used?

For a local-mode AP or an AP that centrally switches WLAN traffic, an access port in the AP management VLAN is commonly sufficient.

Example:

```cisco
interface gigabitEthernet 0/10
switchport mode access
switchport access vlan 99
spanning-tree portfast
power inline auto
```

Here:
- VLAN 99 = AP Management VLAN.
- PortFast = Faster AP link activation.
- PoE = Supplies power, where supported.

## B. When Is a Trunk Port Used for an AP?

A FlexConnect AP using local switching for multiple WLANs usually needs a trunk connection so that it can locally bridge client traffic into different VLANs.

Example:

```cisco
interface gigabitEthernet 0/10
switchport mode trunk
switchport trunk native vlan 99
switchport trunk allowed vlan 99,10,20,30
spanning-tree portfast
```

Example Mapping:

| WLAN | VLAN |
|---|---:|
| Treasury Wi-Fi | 10 |
| Remittance Wi-Fi | 20 |
| Trade Wi-Fi | 30 |
| AP Management | 99 |

**Remember:** AP access vs trunk depends on the AP's switching design, not simply on whether it is wireless.

## C. WLC to Switch

A WLC connects to the distribution or core switching infrastructure.

For multiple VLANs, the WLC uplink is commonly configured as a trunk.

The trunk may carry:
- Wireless management VLAN.
- Client VLANs.
- Other required infrastructure VLANs.

The WLC's WLAN/policy configuration maps client traffic to the appropriate VLAN.

## D. What is LAG?

**LAG = Link Aggregation Group.**

LAG combines multiple physical Ethernet links between a WLC and a switch into one logical connection.

Benefits:
- Additional aggregate bandwidth.
- Redundancy.
- Automatic traffic redistribution if a member link fails.

### WLC LAG Detail

LAG support and negotiation methods depend on the controller model and software release.

For example, Cisco Catalyst 9800 standalone controllers support static port-channel mode and, on supported releases, dynamic LACP/PAgP negotiation. Older WLC platforms may have different restrictions.

Do not assume every WLC supports LACP.

### WLAN Infrastructure Diagram

```text
        WIRELESS CLIENTS
                |
                |
               AP
                |
          ETHERNET / PoE
                |
          ACCESS SWITCH
                |
                |
             WLC / LAG
             /       \
          LINK 1    LINK 2
             \       /
              SWITCH
                |
            CORE NETWORK
                |
              INTERNET
```

**Memory Trick:**
- AP Access Port = Management / Central Switching.
- AP Trunk Port = Multiple Locally Switched VLANs.
- WLC Trunk = Multiple WLAN Client VLANs.
- LAG = Multiple Physical Links → One Logical Link.

---

# 2.8 Describe Network Device Management Access

Network device management access means the methods administrators use to configure, monitor and troubleshoot routers, switches, WLCs and other network devices.

Three main categories:
1. Local Management.
2. Remote Management.
3. Centralized AAA / Cloud Management.

## A. Telnet

**Telnet = Teletype Network.**

Telnet allows remote CLI access to network devices.

**Characteristics:**
- Uses TCP port 23.
- Remote command-line access.
- Sends credentials and data in plaintext.
- Not recommended for secure management.

**Memory:** Telnet = Remote Access without Encryption.

## B. SSH

**SSH = Secure Shell.**

SSH provides encrypted remote command-line access.

**Characteristics:**
- Uses TCP port 22.
- Encrypts management communication.
- Supports secure authentication.
- Preferred over Telnet.

### Cisco SSH Configuration

```cisco
enable
configure terminal

hostname SW1
ip domain-name bank.local

username admin privilege 15 secret StrongPassword123

crypto key generate rsa modulus 2048

ip ssh version 2

line vty 0 15
login local
transport input ssh
exit

end
write memory
```

Verification:

```cisco
show ip ssh
show ssh
```

*RSA key size and supported syntax depend on the IOS version and security policy.*

**Memory:** SSH = Secure Remote Access.

## C. HTTP

**HTTP = Hypertext Transfer Protocol.**

HTTP provides browser-based management access.

- Uses TCP port 80.
- Web-based management.
- Does not encrypt traffic.
- Not recommended for sensitive management sessions.

Example:

`http://192.168.10.1`

## D. HTTPS

**HTTPS = Hypertext Transfer Protocol Secure.**

HTTPS provides encrypted browser-based management using TLS.

- Uses TCP port 443.
- Encrypts management communication.
- Supports certificate-based server authentication.
- Preferred over HTTP.

Example:

`https://192.168.10.1`

**Memory:**
- HTTP = Web Management without TLS.
- HTTPS = Encrypted Web Management.

## E. Console Access

Console access provides direct local access to a network device.

**Characteristics:**
- Uses a physical console connection.
- Serial or USB connection, depending on device.
- Does not require normal IP network connectivity.
- Commonly used for initial setup and recovery.

**Banking Example:** If a router loses its IP configuration and SSH becomes unavailable, an administrator can access it through the console port.

**Memory:** Console = Direct Local Management.

## F. TACACS+ and RADIUS

Both are AAA-related protocols used for centralized authentication and access control.

**AAA Means:**

| Term | Meaning |
|---|---|
| Authentication | Who are you? |
| Authorization | What are you allowed to do? |
| Accounting | What did you do? |

### TACACS+

**TACACS+ = Terminal Access Controller Access-Control System Plus.**

Characteristics:
- Uses TCP port 49.
- Separates Authentication, Authorization and Accounting.
- Encrypts the packet body.
- Commonly used for centralized network-device administration.
- Supports detailed command authorization.

### RADIUS

**RADIUS = Remote Authentication Dial-In User Service.**

Characteristics:
- Uses UDP.
- UDP 1812 = Authentication.
- UDP 1813 = Accounting.
- Commonly used for wireless 802.1X authentication and network access control.
- Combines authentication and authorization information in its protocol exchange.

### TACACS+ vs RADIUS

| Feature | TACACS+ | RADIUS |
|---|---|---|
| Transport | TCP | UDP |
| Common Port | 49 | 1812 / 1813 |
| AAA | Separates AAA functions | Combines authentication and authorization |
| Encryption | Packet body encrypted | Protects password field in classic RADIUS |
| Common Use | Device Administration | Network Access / Wi-Fi Authentication |

**Banking Example:**
- TACACS+ → Central authentication for network administrators accessing switches.
- RADIUS → Authentication for employees connecting to secure bank Wi-Fi.

**Memory Trick:**
- TACACS+ = Administrator Access.
- RADIUS = Network Access Authentication.

## G. Cloud-Managed Device Access

Cloud-managed networking allows administrators to manage network devices through a cloud-based dashboard.

Example: Cisco Meraki Dashboard.

**Functions:**
- Centralized configuration.
- Remote monitoring.
- Device inventory.
- Network performance monitoring.
- Configuration deployment.
- Alerts and troubleshooting.

**Banking Example:** A network administrator in Dhaka manages wireless APs at branches in Chattogram and Sylhet through a centralized cloud dashboard.

**Important:** Cloud-managed devices still have physical hardware. Cloud management does not necessarily mean user traffic passes through the cloud.

### Complete Management Access Comparison

| Method | Access Type | Port / Connection | Security |
|---|---|---|---|
| Telnet | Remote CLI | TCP 23 | Unencrypted |
| SSH | Remote CLI | TCP 22 | Encrypted |
| HTTP | Web GUI | TCP 80 | Unencrypted |
| HTTPS | Web GUI | TCP 443 | TLS Encrypted |
| Console | Local CLI | Serial/USB | Physical Access |
| TACACS+ | Centralized AAA | TCP 49 | Packet Body Encrypted |
| RADIUS | Centralized AAA | UDP 1812/1813 | Password Protection in Classic Protocol |
| Cloud Managed | Cloud Dashboard | Internet-Based | Depends on Platform and Configuration |

**Exam Memory:** SSH is preferred over Telnet; HTTPS is preferred over HTTP.

---

# 2.9 Interpret Wireless LAN GUI Configuration for Client Connectivity

This objective tests your understanding of how to configure a WLAN through a Wireless LAN Controller's graphical interface.

You should understand:
1. WLAN Creation.
2. SSID Configuration.
3. Security Settings.
4. QoS Profiles.
5. Advanced Settings.
6. Client Connectivity Verification.

## A. What is a WLAN?

**WLAN = Wireless Local Area Network.**

A WLAN provides wireless network connectivity through access points.

Example:

A bank provides three wireless networks:

| WLAN | SSID | Purpose |
|---|---|---|
| WLAN 1 | BANK-EMPLOYEE | Employee Wi-Fi |
| WLAN 2 | BANK-GUEST | Guest Wi-Fi |
| WLAN 3 | BANK-VOICE | Wireless Voice |

Each WLAN can be associated with different security and network policies.

## B. WLAN Creation

When creating a WLAN through a WLC GUI, important fields include:

| GUI Field | Meaning |
|---|---|
| WLAN ID | Unique WLAN identifier on controller |
| Profile Name | Internal WLAN profile name |
| SSID | Wireless network name |
| Status | Enables or disables the WLAN |
| VLAN / Policy Profile | Determines client network assignment |
| Radio Policy | Determines supported radio bands |

### Example: Create Treasury WLAN

Suppose we create:

- WLAN ID = 10.
- Profile Name = TREASURY-WLAN.
- SSID = BANK-TREASURY.
- VLAN = 10.
- Status = Enabled.

### Simple GUI Workflow

```text
          WLC GUI
             |
             v
          WLANs
             |
             v
         Create New
             |
             v
        WLAN ID = 10
             |
             v
        Profile Name
        TREASURY-WLAN
             |
             v
            SSID
        BANK-TREASURY
             |
             v
         Enable WLAN
             |
             v
          Map VLAN 10
             |
             v
       Configure Security
             |
             v
          Apply / Save
```

**Important:** A WLAN must be enabled and associated with the correct policy/VLAN before clients can use it.

## C. Wireless Security Settings

Security determines how wireless clients authenticate and how their traffic is protected.

### Common Security Methods

| Security Type | Description |
|---|---|
| Open | No Wi-Fi authentication or encryption by itself |
| WPA2-Personal | Uses a Pre-Shared Key (PSK) |
| WPA2-Enterprise | Uses 802.1X authentication |
| WPA3-Personal | Uses SAE authentication |
| WPA3-Enterprise | Enterprise authentication with stronger security options |

### WPA2-Personal

Uses a shared Wi-Fi password.

Example:

`BankTreasury@2026`

All authorized users enter the configured password.

### WPA2-Enterprise

Uses 802.1X authentication, commonly with a RADIUS server.

Each employee can authenticate using individual credentials or certificates, depending on the EAP method.

**Banking Example:** Instead of sharing one Wi-Fi password with 100 employees, the bank uses individual employee authentication through RADIUS.

### Important Security Terms

| Term | Meaning |
|---|---|
| PSK | Pre-Shared Key |
| 802.1X | Port-Based Network Access Control |
| RADIUS | Centralized Authentication Server |
| AES-CCMP | Wireless Encryption Mechanism used by WPA2 |
| SAE | Simultaneous Authentication of Equals, used by WPA3-Personal |
| EAP | Extensible Authentication Protocol |

**Memory Trick:**
- Personal = Shared Password.
- Enterprise = Individual Authentication.

Avoid WEP and legacy WPA/TKIP for modern secure deployments.

## D. QoS Profiles

**QoS = Quality of Service.**

QoS prioritizes selected network traffic to improve performance for applications that need low latency, controlled jitter and reduced packet loss.

### Why Do We Need QoS?

Imagine a bank employee is making a VoIP call while another employee downloads a large file.

Without proper traffic prioritization, voice traffic may experience delay or jitter.

QoS helps prioritize voice and other important traffic.

### Cisco Traditional WLC QoS Profiles

| Profile | Purpose | Priority |
|---|---|---|
| Platinum | Voice | Highest |
| Gold | Video | High |
| Silver | Best Effort / Normal Data | Default |
| Bronze | Background Traffic | Lowest |

### Banking Example

| WLAN | Application | Suggested QoS |
|---|---|---|
| BANK-VOICE | Voice Calls | Platinum |
| BANK-VIDEO | Video Conference | Gold |
| BANK-EMPLOYEE | Normal Data | Silver |
| BANK-GUEST | Background/Guest Traffic | Bronze |

**Important:** These four named profiles are from traditional Cisco AireOS WLC configuration. Modern Catalyst 9800 controllers use QoS policy maps, class maps and policy profiles; do not assume every modern GUI has the same four-profile interface.

## E. Advanced WLAN Settings

Advanced settings help control client connectivity and WLAN behavior.

| Setting | Purpose |
|---|---|
| Broadcast SSID | Makes WLAN name visible in Wi-Fi scans |
| Client Exclusion | Temporarily blocks clients based on configured security policies |
| Session Timeout | Controls session duration |
| Peer-to-Peer Blocking | Restricts direct communication between wireless clients |
| Radio Policy | Controls supported wireless bands |
| FlexConnect Local Switching | Allows client traffic to exit through AP locally |
| DHCP Address Assignment | Controls or verifies DHCP-related client behavior |
| ACL / Policy | Controls client network access |

### Understand Important Settings

**1. Broadcast SSID**
- Enabled = Wi-Fi name appears in normal network scans.
- Disabled = SSID is not advertised normally.

Hiding an SSID does not provide meaningful security.

**2. Client Exclusion**

Can block clients temporarily based on configured security and failure policies.

**3. Peer-to-Peer Blocking**

Restricts direct communication between wireless clients associated with the same WLAN, depending on configuration.

**4. Radio Policy**

Controls which radio bands are available to the WLAN.

Examples:
- 2.4 GHz.
- 5 GHz.
- 6 GHz, when supported.

**5. FlexConnect Local Switching**

Allows wireless client traffic to be switched locally at the AP instead of being tunnelled centrally to the WLC.

## F. Verify Wireless Client Connectivity

After configuring the WLAN, verify:

1. WLAN is enabled.
2. SSID is correct.
3. Security settings match the client.
4. AP has joined the controller.
5. Correct VLAN/policy profile is assigned.
6. Required VLAN exists and is allowed on the trunk.
7. DHCP is working.
8. Client successfully authenticates and associates.

### Cisco Catalyst 9800 Verification Commands

```cisco
show wlan summary
show wireless client summary
show ap summary
show wireless client mac-address <MAC-ADDRESS> detail
```

### Traditional AireOS WLC Commands

```text
show wlan
show client summary
show ap summary
```

### Common WLAN Problems

| Problem | Possible Cause | Solution |
|---|---|---|
| SSID not visible | WLAN disabled or radio issue | Check WLAN status and AP radios |
| Client cannot authenticate | Wrong password or RADIUS issue | Check security configuration |
| Client connects but gets no IP | DHCP/VLAN problem | Check VLAN and DHCP |
| Client connects to wrong network | Wrong VLAN mapping | Check WLAN policy profile |
| Poor wireless performance | RF interference or congestion | Review channel and RF settings |
| AP does not join WLC | CAPWAP or discovery issue | Check IP reachability, DNS/DHCP and UDP 5246/5247 |

### Important Catalyst 9800 GUI Configuration Relationship

Understand these objects:

- **WLAN Profile:** SSID, WLAN ID and wireless security.
- **Policy Profile:** Client VLAN, switching policy and other client policies.
- **Policy Tag:** Maps a WLAN profile to its policy profile.
- **Site Tag:** Defines AP site and FlexConnect-related behavior.
- **RF Tag:** Associates radio frequency profiles with an AP.

A WLAN profile alone does not complete client connectivity; it must be associated with the appropriate policy and AP configuration.

---

# FINAL NETWORK ACCESS REVISION

## 1. VLANs

| Topic | Remember |
|---|---|
| VLAN | Logical Network Segmentation |
| Access Port | One Data VLAN |
| Voice VLAN | IP Phone Traffic |
| Default VLAN | VLAN 1 |
| Normal VLAN Range | 1–1005 |
| Inter-VLAN Routing | Layer 3 Required |
| Router-on-a-Stick | Router Subinterfaces |
| SVI | Layer 3 VLAN Interface |

## 2. Trunking

| Topic | Remember |
|---|---|
| Trunk | Carries Multiple VLANs |
| 802.1Q | VLAN Tagging |
| Native VLAN | Untagged Traffic |
| Native VLAN Mismatch | Potential Connectivity/Security Problem |
| Allowed VLAN | VLANs Permitted on Trunk |

## 3. Discovery Protocols

| CDP | LLDP |
|---|---|
| Cisco Proprietary | IEEE Standard |
| Vendor Specific | Multivendor |
| Layer 2 | Layer 2 |
| Neighbor Discovery | Neighbor Discovery |

## 4. EtherChannel

| Topic | Remember |
|---|---|
| EtherChannel | Multiple Links → One Logical Link |
| LACP | IEEE Standard |
| Active | Initiates Negotiation |
| Passive | Responds |
| Passive + Passive | No Channel |
| Port-Channel | Logical Interface |
| Load Balancing | Hash-Based Distribution |

## 5. Rapid PVST+

| Feature | Remember |
|---|---|
| Root Bridge | Lowest Bridge ID |
| Root Port | Best Path to Root |
| Designated Port | Forwarding Port for Segment |
| Alternate Port | Backup Root Path |
| Backup Port | Backup Designated Path |
| PortFast | Fast Edge Forwarding |
| Root Guard | Protects Root Position |
| Loop Guard | Protects Against Missing BPDUs |
| BPDU Guard | Disables Edge Port on BPDU |
| BPDU Filter | Suppresses BPDUs |

## 6. Wireless

| Topic | Remember |
|---|---|
| Autonomous AP | Independent Management |
| Controller-Based AP | Centralized WLC |
| Cloud-Managed AP | Cloud Dashboard |
| Local Mode | Central Switching |
| FlexConnect | Local/Central Switching |
| Monitor | RF Monitoring |
| Sniffer | Packet Capture |
| Bridge | Wireless Mesh |
| CAPWAP Control | UDP 5246 |
| CAPWAP Data | UDP 5247 |

## 7. Device Management

| Method | Port / Connection |
|---|---|
| Telnet | TCP 23 |
| SSH | TCP 22 |
| HTTP | TCP 80 |
| HTTPS | TCP 443 |
| Console | Physical Serial/USB |
| TACACS+ | TCP 49 |
| RADIUS Authentication | UDP 1812 |
| RADIUS Accounting | UDP 1813 |

## 8. WLAN GUI

| Topic | Remember |
|---|---|
| WLAN ID | WLAN Identifier |
| SSID | Wireless Network Name |
| Security | WPA2/WPA3 |
| PSK | Shared Password |
| 802.1X | Enterprise Authentication |
| RADIUS | Central Authentication |
| Platinum | Voice |
| Gold | Video |
| Silver | Best Effort |
| Bronze | Background |

---

# FINAL MEMORY TRICK — NETWORK ACCESS

**VLAN → Separates Networks**

**Access Port → One Data VLAN**

**Voice VLAN → IP Phone**

**Trunk → Carries Multiple VLANs**

**802.1Q → Adds VLAN Tag**

**Native VLAN → Untagged Traffic**

**CDP → Cisco Discovery**

**LLDP → Standard Discovery**

**EtherChannel → Combines Links**

**LACP Active → Initiates**

**LACP Passive → Responds**

**STP → Prevents Loops**

**Root Bridge → Lowest Bridge ID**

**PortFast → Fast Edge Port**

**BPDU Guard → Stops Unexpected BPDU**

**Root Guard → Protects Root**

**Loop Guard → Protects Against Missing BPDUs**

**AP → Provides Wi-Fi**

**WLC → Central Wireless Management**

**FlexConnect → Branch Wireless**

**SSH → Secure CLI**

**HTTPS → Secure GUI**

**TACACS+ → Centralized Device Administration**

**RADIUS → Network Access Authentication**

**QoS → Prioritizes Traffic**

---

# OFFICIAL TECHNICAL REFERENCES

The following sources are primarily Cisco official documentation and IEEE standards. Commands and GUI labels may differ by Cisco platform and software release.

## 1. Cisco CCNA Official Exam Topics

- [Cisco 200-301 CCNA Exam Topics](https://learningnetwork.cisco.com/s/ccna-exam-topics)

## 2. VLANs, Trunking and Inter-VLAN Routing

- [Cisco — VLAN Configuration Guide](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/vlan/vlan-configuration-guide/configure-vlan.html)
- [Cisco — Voice VLAN Configuration](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/vlan/vlan-configuration-guide/configure-voice-vlan.html)
- [Cisco — VLAN Trunking and Native VLAN](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/vlan/vlan-configuration-guide/configure-vlan-trunks.html)
- [Cisco — Inter-VLAN Routing](https://www.cisco.com/c/en/us/support/docs/lan-switching/inter-vlan-routing/41260-189.html)
- [IEEE 802.1Q — Bridges and Bridged Networks](https://standards.ieee.org/standard/802_1Q-2022.html)

## 3. CDP, LLDP and EtherChannel

- [Cisco — CDP Configuration Guide](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/cdp-lldp-mac-udld/cdp-lldp-mac-udld-configuration-guide/c-configure-cdp.html)
- [Cisco — LLDP Configuration Guide](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/cdp-lldp-mac-udld/cdp-lldp-mac-udld-configuration-guide/c-configure-lldp.html)
- [Cisco — EtherChannel Configuration Guide](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/etherchannel/etherchannel-configuration-guide/etherchannels.html)
- [IEEE 802.1AX — Link Aggregation](https://standards.ieee.org/standard/802_1AX-2020.html)

## 4. Spanning Tree Protocol

- [Cisco — STP Configuration Guide](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/stp/stp-configuration-guide/m-stp.html)
- [Cisco — Root Guard](https://www.cisco.com/c/en/us/support/docs/lan-switching/spanning-tree-protocol/10588-74.html)
- [Cisco — Loop Guard](https://www.cisco.com/c/en/us/support/docs/lan-switching/spanning-tree-protocol-stp-8021d/218321-configure-stp-with-loop-guard-and-bpdu-s.html)
- [Cisco — PortFast and BPDU Guard](https://www.cisco.com/c/en/us/support/docs/lan-switching/spanning-tree-protocol/10586-65.html)
- [IEEE 802.1w — Rapid Spanning Tree Protocol](https://standards.ieee.org/standard/802_1w-2001.html)

## 5. Cisco Wireless Architecture and AP Modes

- [Cisco — Wireless Controller Configuration Guide: AP Modes](https://www.cisco.com/c/en/us/td/docs/wireless/controller/8-5/config-guide/b_cg85/managing_aps.html)
- [Cisco — AP and WLC Communication Troubleshooting](https://www.cisco.com/c/en/us/support/docs/wireless/5500-series-wireless-controllers/119286-lap-notjoin-wlc-tshoot.html)
- [Cisco — Catalyst 9800 Configuration Best Practices](https://www.cisco.com/c/en/us/td/docs/wireless/controller/9800/technical-reference/c9800-best-practices.html)

## 6. Wireless GUI, Security and QoS

- [Cisco — Catalyst 9800 WLAN Configuration](https://www.cisco.com/c/en/us/td/docs/wireless/controller/9800/26-1/configuration-guide/wl-26-1-cg/wlans/how-to-configure-wlans.html)
- [Cisco — WLAN Security Configuration](https://www.cisco.com/c/en/us/td/docs/wireless/controller/9800/26-1/configuration-guide/wl-26-1-cg/configuring-wlan-security/how-to-configure-wlan-security.html)
- [Cisco — Wireless QoS Profiles](https://www.cisco.com/c/en/us/td/docs/wireless/controller/8-5/config-guide/b_cg85/quality_of_service.html)

## 7. Network Device Management and AAA

- [Cisco — Configure SSH on Routers](https://www.cisco.com/c/en/us/support/docs/security-vpn/secure-shell-ssh/4145-ssh.html)
- [Cisco — TACACS+ and RADIUS Comparison](https://www.cisco.com/c/en/us/support/docs/security-vpn/remote-authentication-dial-user-service-radius/13838-10.html)
- [Cisco — TACACS+ Configuration Guide](https://www.cisco.com/c/en/us/td/docs/routers/ios-xe/security-vpn/security-vpn/m_sec-cfg-tacacs-0.html)
- [Cisco — Principles of Secure Operations](https://sec.cloudapps.cisco.com/security/center/resources/principles_secure_operations)

---

**END OF SECTION 2.0 — NETWORK ACCESS**

**Study Priority:**

1. Master VLANs, access ports and trunking.
2. Practise Inter-VLAN routing.
3. Understand CDP, LLDP and EtherChannel.
4. Master Rapid PVST+ port roles and protection features.
5. Understand wireless architecture and AP modes.
6. Memorize management protocols and ports.
7. Practise WLAN GUI configuration and troubleshooting.

**Final Goal:** Be able to explain the concept, draw the topology, configure Cisco IOS commands, verify the result and troubleshoot common failures.
