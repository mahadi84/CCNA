
# CCNA 200-301 — Network Fundamentals (Section 1.0)

**Learning Style:** Technical Explanation + Banking Examples + Cisco CLI + Troubleshooting

---

# TABLE OF CONTENTS (QUICK MENU)

1. [Network Components (1.1)](#11-explain-the-role-and-function-of-network-components)
   - [1.1.a Routers](#11a-routers)
   - [1.1.b Layer 2 and Layer 3 Switches](#11b-layer-2-and-layer-3-switches)
   - [1.1.c NGFW and IPS](#11c-next-generation-firewalls-and-ips)
   - [1.1.d Access Points](#11d-access-points)
   - [1.1.e Controllers](#11e-controllers)
   - [1.1.f Endpoints](#11f-endpoints)
   - [1.1.g Servers](#11g-servers)
   - [1.1.h PoE](#11h-power-over-ethernet-poe)
2. [Network Topology Architectures (1.2)](#12-describe-characteristics-of-network-topology-architectures)
   - [Two-tier](#12a-two-tier-architecture)
   - [Three-tier](#12b-three-tier-architecture)
   - [Spine-leaf](#12c-spine-leaf-architecture)
   - [WAN](#12d-wide-area-network-wan)
   - [SOHO](#12e-small-officehome-office-soho)
   - [On-premises and Cloud](#12f-on-premises-vs-cloud)
3. [Physical Interfaces and Cabling (1.3)](#13-compare-physical-interface-and-cabling-types)
   - [Single-mode Fiber](#13a-single-mode-fiber-smf)
   - [Multimode Fiber](#13b-multimode-fiber-mmf)
   - [Copper](#13c-copper-cabling)
   - [Shared Media vs Point-to-Point](#13d-ethernet-shared-media-vs-point-to-point)
4. [Interface and Cable Issues (1.4)](#14-identify-interface-and-cable-issues)
5. [TCP vs UDP (1.5)](#15-compare-tcp-to-udp)
6. [IPv4 Addressing and Subnetting (1.6)](#16-configure-and-verify-ipv4-addressing-and-subnetting)
7. [Private IPv4 Addressing (1.7)](#17-describe-private-ipv4-addressing)
8. [IPv6 Addressing and Prefix (1.8)](#18-configure-and-verify-ipv6-addressing-and-prefix)
9. [IPv6 Address Types (1.9)](#19-describe-ipv6-address-types)
   - [Unicast](#19a-unicast)
   - [Anycast](#19b-anycast)
   - [Multicast](#19c-multicast)
   - [Modified EUI-64](#19d-modified-eui-64)
10. [Client OS IP Verification (1.10)](#110-verify-ip-parameters-for-client-os)
11. [Wireless Principles (1.11)](#111-describe-wireless-principles)
   - [Wi-Fi Channels](#111a-nonoverlapping-wi-fi-channels)
   - [SSID](#111b-ssid)
   - [RF](#111c-radio-frequency-rf)
   - [Encryption](#111d-wireless-encryption)
12. [Virtualization Fundamentals (1.12)](#112-explain-virtualization-fundamentals)
   - [Server Virtualization](#112a-server-virtualization)
   - [Containers](#112b-containers)
   - [VRF](#112c-virtual-routing-and-forwarding-vrf)
13. [Switching Concepts (1.13)](#113-describe-switching-concepts)
   - [MAC Learning and Aging](#113a-mac-learning-and-aging)
   - [Frame Switching](#113b-frame-switching)
   - [Frame Flooding](#113c-frame-flooding)
   - [MAC Address Table](#113d-mac-address-table)
14. [Final CCNA Revision Sheet](#final-ccna-network-fundamentals-revision)
15. [Official References](#official-technical-references)

---

# 1.1 Explain the Role and Function of Network Components

## 1.1.a Routers

### What is a Router?

A router is a Layer 3 (Network Layer) device that connects different IP networks and forwards packets based on destination IP addresses.

**Simple Explanation:** A router decides where a packet should go to reach another network.

### Banking Example

A bank has four departments:

| Department | Network |
|---|---|
| Treasury | 192.168.10.0/24 |
| Remittance | 192.168.20.0/24 |
| Trade | 192.168.30.0/24 |
| SWIFT | 192.168.40.0/24 |

If a Treasury computer wants to communicate with a Trade computer, the router forwards packets between the two networks.

### How Does a Router Work?

1. Receives an IP packet.
2. Reads the destination IP address.
3. Checks its routing table.
4. Selects the best matching route using longest-prefix matching.
5. Identifies the outgoing interface and next hop.
6. Re-encapsulates the packet in a new Layer 2 frame.
7. Forwards the packet.

### Important Router Functions

- Connects different networks.
- Performs IP routing.
- Selects the best path.
- Connects LAN to WAN/Internet.
- Supports routing protocols such as OSPF and BGP.
- Can provide NAT, DHCP, ACL and VPN services, depending on capabilities.

### Important Cisco Commands

```cisco
show ip route
show ip interface brief
show running-config
show ip protocols
```

**Memory Trick:** Router = Connects Different Networks using IP Addresses.

---

## 1.1.b Layer 2 and Layer 3 Switches

### Layer 2 Switch

A Layer 2 switch operates at the Data Link Layer (Layer 2).

It forwards Ethernet frames based on destination MAC addresses.

**Example:** Connecting computers within the Treasury department.

### Layer 3 Switch

A Layer 3 switch performs both Layer 2 switching and Layer 3 routing.

It can route IP packets between different VLANs using switched virtual interfaces (SVIs) or routed ports.

### Comparison

| Feature | Layer 2 Switch | Layer 3 Switch |
|---|---|---|
| OSI Layer | Layer 2 | Layer 2 + Layer 3 |
| Forwarding | MAC Address | MAC + IP |
| Main Function | Switching | Switching + Routing |
| Routing Between VLANs | Requires external router/L3 device | Can perform Inter-VLAN routing |
| Routing Table | No normal IP routing table for transit forwarding | Yes |
| Common Use | Access Layer | Distribution/Core Layer |

### Banking Example

- Layer 2 Switch: Connects 20 Treasury computers in the same VLAN.
- Layer 3 Switch: Connects Treasury VLAN 10 with Remittance VLAN 20.

### Layer 2 Switch Configuration Example

```cisco
enable
configure terminal

interface fastEthernet 0/1
switchport mode access
switchport access vlan 10
no shutdown
```

### Layer 3 Switch Configuration Example

```cisco
enable
configure terminal

ip routing

interface vlan 10
ip address 192.168.10.1 255.255.255.0
no shutdown

interface vlan 20
ip address 192.168.20.1 255.255.255.0
no shutdown
```

**Memory Trick:**
- Layer 2 = MAC Address = Switch.
- Layer 3 = IP Address = Router.
- Layer 3 Switch = Switch + Router.

---

## 1.1.c Next-Generation Firewalls and IPS

### What is a Firewall?

A firewall is a security device or software that controls incoming and outgoing network traffic according to security policies.

It can allow or deny traffic based on IP addresses, ports, protocols and connection state.

### What is a Next-Generation Firewall (NGFW)?

An NGFW is an advanced firewall that combines traditional firewall functions with application awareness, user identity awareness, integrated intrusion prevention and advanced threat detection.

### NGFW Functions

1. Stateful packet inspection.
2. Application awareness and control.
3. Intrusion Prevention System integration.
4. User identity-based policies.
5. Malware and threat detection.
6. URL filtering.
7. Encrypted traffic inspection where configured.

### What is IPS?

**IPS = Intrusion Prevention System.**

IPS monitors network traffic, detects suspicious or malicious activity and can automatically block or drop harmful traffic.

### IDS vs IPS

| IDS | IPS |
|---|---|
| Intrusion Detection System | Intrusion Prevention System |
| Detects suspicious traffic | Detects and blocks malicious traffic |
| Commonly monitors a traffic copy | Commonly deployed inline |
| Generates alerts | Can actively prevent attacks |

### How IPS Works

1. Monitors network traffic.
2. Examines packet information and patterns.
3. Compares traffic against signatures and detection policies.
4. Identifies suspicious activity.
5. Alerts administrators and/or blocks malicious traffic.

### Banking Example

Suppose a computer in the Remittance department attempts to communicate with a known malicious server.

- Firewall checks whether the connection is permitted.
- NGFW identifies the application and applies security policy.
- IPS detects malicious traffic.
- IPS can block the attack before it reaches its destination.

**Important:** NGFW and IPS improve security, but neither guarantees complete protection.

**Memory Trick:**
- Firewall = Controls Traffic.
- NGFW = Intelligent Firewall.
- IPS = Detects and Prevents Attacks.

---

## 1.1.d Access Points

### What is an Access Point (AP)?

An Access Point is a networking device that allows wireless devices to connect to a wired LAN using Wi-Fi.

It acts as a bridge between wireless clients and the wired network.

### How Does an AP Work?

1. AP broadcasts a wireless network (SSID).
2. A laptop or phone searches for available Wi-Fi.
3. The client selects the SSID.
4. The client authenticates.
5. The client associates with the AP.
6. Wireless traffic is bridged or tunneled into the network.

### Banking Example

A bank has employees using laptops and smartphones.

Instead of connecting every device through Ethernet cables, APs provide wireless connectivity.

### Types of Access Points

- Autonomous AP: Configured and managed individually.
- Lightweight/Controller-based AP: Managed centrally by a Wireless LAN Controller.
- Mesh AP: Uses wireless backhaul to connect APs where wired connections are unavailable.

### AP vs Router

| Access Point | Router |
|---|---|
| Provides wireless connectivity | Connects different IP networks |
| Bridges wireless and wired networks | Routes IP packets |
| Usually does not perform routing by itself | Maintains routing table |
| Extends WLAN coverage | Connects LAN to other networks |

**Memory Trick:** AP = Provides Wi-Fi Access.

---

## 1.1.e Controllers

A network controller is a centralized management system that helps configure, monitor, automate and manage network devices.

Two important Cisco examples:

### 1. Wireless LAN Controller (WLC)

A WLC centrally manages multiple wireless access points.

**Main Functions:**
- Centralized AP configuration.
- WLAN/SSID management.
- Wireless security policy.
- RF and channel management.
- Client monitoring.
- Wireless roaming support.

**CAPWAP:** Lightweight APs communicate with controllers using Control and Provisioning of Wireless Access Points (CAPWAP).

Common CAPWAP UDP ports:
- UDP 5246 = Control.
- UDP 5247 = Data.

### 2. Cisco Catalyst Center

Formerly called Cisco DNA Center.

It is a centralized network management and automation platform.

**Main Functions:**
- Network discovery.
- Device inventory.
- Configuration automation.
- Policy management.
- Network assurance.
- Troubleshooting and monitoring.

### WLC vs Catalyst Center

| WLC | Catalyst Center |
|---|---|
| Manages wireless APs and WLANs | Manages broader campus and branch networks |
| Focuses on wireless control | Focuses on network automation and assurance |
| Manages wireless policies and RF | Manages wired and wireless infrastructure |
| Controls AP operations | Provides centralized network management |

**Memory Trick:**
- WLC = Wireless Management.
- Catalyst Center = Network Management and Automation.

---

## 1.1.f Endpoints

### What is an Endpoint?

An endpoint is any device that connects to a network and communicates with other devices or services.

### Examples

- Desktop computers.
- Laptops.
- Smartphones.
- Tablets.
- Printers.
- IP phones.
- CCTV cameras.
- IoT devices.
- Network-connected terminals.

### Banking Example

Treasury employee's computer, Remittance printer and SWIFT workstation are all endpoints.

### Endpoint Security

Endpoints are common entry points for cyberattacks.

Security measures include:
- Antivirus/Endpoint Protection.
- Endpoint Detection and Response (EDR).
- Operating system updates.
- Authentication.
- Access control.
- Device compliance.

**Memory Trick:** Endpoint = Any Network-Connected End Device.

---

## 1.1.g Servers

### What is a Server?

A server is a computer or software system that provides services, resources or data to other computers called clients.

### Types of Servers

| Server | Main Function |
|---|---|
| DHCP Server | Assigns IP configuration |
| DNS Server | Resolves domain names |
| Web Server | Hosts websites and web applications |
| File Server | Stores and shares files |
| Database Server | Stores and manages data |
| Mail Server | Sends and receives emails |
| Authentication Server | Authenticates users |
| Application Server | Runs business applications |

### Banking Example

A bank may use:

- DHCP Server → Assigns IP addresses.
- DNS Server → Resolves internal website names.
- Database Server → Stores banking records.
- Web Server → Hosts internal banking portals.
- Authentication Server → Verifies employee login credentials.

### Client-Server Communication

```text
       CLIENT COMPUTER
              |
              | Service Request
              v
          NETWORK
              |
              v
          SERVER
              |
              | Processes Request
              v
       RESPONSE TO CLIENT
```

**Memory Trick:** Client Requests, Server Provides.

---

## 1.1.h Power over Ethernet (PoE)

### What is PoE?

**PoE = Power over Ethernet.**

PoE delivers electrical power and network data through the same Ethernet cable.

Normally, a device may require:
- One cable for network connectivity.
- Another cable for electrical power.

With PoE, one compatible Ethernet cable can provide both.

### Banking Example

A bank installs IP phones and wireless access points.

A PoE switch supplies both power and data through Ethernet cables.

### How PoE Works

1. PoE-capable switch acts as PSE (Power Sourcing Equipment).
2. Connected compatible device acts as PD (Powered Device).
3. PSE detects and classifies the powered device.
4. Power is supplied according to the supported PoE standard.
5. Data and electrical power travel through the Ethernet cable.

### PoE Standards

| Standard | Common Name | Maximum Power from PSE |
|---|---|---:|
| IEEE 802.3af | PoE | 15.4 W |
| IEEE 802.3at | PoE+ | 30 W |
| IEEE 802.3bt Type 3 | PoE++ | 60 W |
| IEEE 802.3bt Type 4 | PoE++ / 4PPoE | 90 W |

**Important:** Actual power available at the powered device is lower because of cable losses.

| Standard | Maximum Available at PD (Approx.) |
|---|---:|
| 802.3af | 12.95 W |
| 802.3at | 25.5 W |
| 802.3bt Type 3 | 51 W |
| 802.3bt Type 4 | 71.3 W |

### Common PoE Devices

- Wireless Access Points.
- IP Phones.
- CCTV Cameras.
- Video Conference Devices.
- Some IoT Devices.

**Memory Trick:** PoE = One Cable for Data + Power.

---

# 1.2 Describe Characteristics of Network Topology Architectures

## 1.2.a Two-Tier Architecture

### What is Two-Tier Architecture?

Two-tier architecture is a hierarchical network design where the Distribution and Core functions are combined into one layer.

It is also called **Collapsed Core Architecture**.

### Two Layers

1. Access Layer.
2. Collapsed Distribution/Core Layer.

### Network Diagram

```text
       COLLAPSED CORE
       /      |      \
      /       |       \
   ACCESS   ACCESS   ACCESS
   SWITCH   SWITCH   SWITCH
     |        |        |
    PCs      PCs      PCs
```

### Functions

**Access Layer:**
- Connects end devices.
- Provides Ethernet and Wi-Fi access.
- Supports VLANs and PoE.

**Collapsed Core/Distribution:**
- Aggregates access switches.
- Provides Layer 3 routing.
- Applies network policies.
- Connects WAN and Internet services.

### Advantages

- Lower cost.
- Less complexity.
- Easier management.
- Suitable for small and medium networks.

### Disadvantages

- Less scalability than a separate core design.
- Higher dependency on the collapsed core.
- A failure can affect a larger portion of the network.

### Banking Example

A small bank branch with 3 floors may use one pair of Layer 3 distribution switches and several access switches.

**Memory Trick:** Two-Tier = Access + Collapsed Core.

---

## 1.2.b Three-Tier Architecture

### What is Three-Tier Architecture?

Three-tier architecture is a hierarchical network design with three separate layers:

1. Access.
2. Distribution.
3. Core.

### Network Diagram

```text
              CORE
             /    \
            /      \
     DISTRIBUTION  DISTRIBUTION
        /   \         /   \
       /     \       /     \
   ACCESS  ACCESS  ACCESS  ACCESS
      |       |      |       |
     PCs     PCs    PCs     PCs
```

### Layer Functions

**1. Access Layer**
- Connects end devices.
- Provides wired and wireless access.
- Supports VLANs and PoE.

**2. Distribution Layer**
- Aggregates access switches.
- Performs Layer 3 routing.
- Applies ACLs and policies.
- Controls routing boundaries.

**3. Core Layer**
- Provides high-speed backbone connectivity.
- Connects multiple distribution blocks.
- Focuses on availability and fast transport.

### Advantages

- Highly scalable.
- Better fault isolation.
- Easier expansion.
- Better separation of network functions.

### Disadvantages

- Higher cost.
- More equipment.
- More configuration and management.

### Banking Example

A large bank with several buildings and many departments may use a separate core layer connecting multiple distribution blocks.

**Memory Trick:**
- Access = Connect.
- Distribution = Control.
- Core = Transport.

### Two-Tier vs Three-Tier

| Feature | Two-Tier | Three-Tier |
|---|---|---|
| Layers | 2 | 3 |
| Core | Combined with Distribution | Separate |
| Cost | Lower | Higher |
| Scalability | Small/Medium | Medium/Large |
| Complexity | Lower | Higher |
| Fault Isolation | Less granular | Better |

---

## 1.2.c Spine-Leaf Architecture

### What is Spine-Leaf?

Spine-leaf is a two-tier data center network architecture.

It consists of:
- Spine Switches.
- Leaf Switches.

### Network Diagram

```text
             SPINE LAYER
          +-------+-------+
          |       |       |
        SP1      SP2     SP3
          |\      |      /|
          | \     |     / |
          |  \    |    /  |
          |   \   |   /   |
          |    \  |  /    |
          |     \ | /     |
          +------+------+
             LEAF LAYER
           L1    L2    L3
           |     |     |
         SERVERS SERVERS
```

**Important:** In a typical spine-leaf fabric, every leaf connects to every spine. Leaf switches generally do not connect directly to other leaf switches, and spine switches do not connect directly to other spine switches.

### Spine Layer

- Provides backbone connectivity.
- Connects all leaf switches.
- Supports high-speed traffic forwarding.

### Leaf Layer

- Connects servers and endpoints.
- Provides access to the data center network.
- Connects to every spine switch.

### How Does It Work?

Suppose a server connected to Leaf 1 wants to communicate with another server connected to Leaf 3.

Traffic flows:

`Leaf 1 → Spine → Leaf 3`

If multiple equal-cost paths exist, ECMP (Equal-Cost Multipath) can distribute traffic across available paths.

### Advantages

- Low and predictable latency.
- High bandwidth.
- Scalability.
- Multiple redundant paths.
- Suitable for high-volume East-West data center traffic.

### Disadvantages

- More uplink requirements.
- Greater cabling complexity.
- Requires careful routing and capacity planning.

### Banking Example

A bank's data center hosts:
- Core banking servers.
- Database servers.
- Virtualization servers.
- Backup servers.

A spine-leaf architecture connects these high-performance systems.

**Memory Trick:** Spine = Backbone; Leaf = Server Access.

---

## 1.2.d Wide Area Network (WAN)

### What is WAN?

**WAN = Wide Area Network.**

A WAN connects networks across large geographical distances, such as different cities, districts or countries.

### Banking Example

A bank has:
- Head Office: Dhaka.
- Branch: Chattogram.
- Branch: Sylhet.
- Branch: Rajshahi.

A WAN connects these geographically separated networks.

### WAN Diagram

```text
       DHAKA HEAD OFFICE
               |
               |
          WAN CLOUD
          /    |    \
         /     |     \
    CHITTAGONG SYLHET RAJSHAHI
       BRANCH  BRANCH  BRANCH
```

### WAN Technologies

| Technology | Purpose |
|---|---|
| Leased Line | Dedicated connectivity |
| MPLS | Provider-managed WAN connectivity |
| Internet VPN | Encrypted connectivity over public Internet |
| SD-WAN | Software-defined WAN management |
| Broadband | Internet-based connectivity |
| Cellular WAN | 4G/5G connectivity |

### WAN Characteristics

- Connects distant locations.
- Usually uses service provider infrastructure.
- Can use public or private connectivity.
- Requires routing between sites.
- Supports redundancy and failover.

### LAN vs WAN

| LAN | WAN |
|---|---|
| Local Area Network | Wide Area Network |
| Small geographical area | Large geographical area |
| Usually organization-controlled | Often provider-supported |
| Typically high-speed local links | Depends on WAN service |
| Example: Bank building | Head Office to Branch |

**Memory Trick:** LAN = Local; WAN = Wide Geographic Coverage.

---

## 1.2.e Small Office/Home Office (SOHO)

### What is SOHO?

**SOHO = Small Office/Home Office.**

SOHO is a small network architecture designed for a home or small business.

### Typical SOHO Components

- Integrated Router.
- Small Ethernet Switch.
- Wireless Access Point.
- Firewall.
- PCs and Laptops.
- Printer.
- Internet Connection.

### Network Diagram

```text
             INTERNET
                 |
              ROUTER
                 |
          +------+------+
          |             |
        SWITCH        WI-FI
          |             |
       PC/PRINTER    LAPTOP
```

### Characteristics

- Small number of users.
- Lower cost.
- Simple installation.
- Often uses an integrated router, switch and AP.
- Usually provides DHCP, NAT and basic firewall functions.

### Banking Example

A small representative office with five employees may use a SOHO router to connect computers, printers and Wi-Fi devices.

**Memory Trick:** SOHO = Small, Simple, Integrated Network.

---

## 1.2.f On-Premises vs Cloud

### On-Premises

On-premises means the organization owns or directly controls its IT infrastructure located at its own premises or dedicated facilities.

**Examples:**
- Physical servers.
- Routers and switches.
- Storage systems.
- Firewalls.
- Local data center.

### Cloud

Cloud computing provides computing, storage and networking resources through a service provider's infrastructure.

Resources are provisioned and managed through cloud platforms.

### Comparison

| Feature | On-Premises | Cloud |
|---|---|---|
| Infrastructure | Organization's premises/facility | Cloud provider's infrastructure |
| Hardware | Organization procures | Provider operates underlying hardware |
| Control | More direct control | Shared responsibility |
| Scalability | Requires capacity planning and hardware | Often faster elastic scaling |
| Maintenance | Organization manages infrastructure | Provider manages underlying cloud infrastructure |
| Cost Model | Capital and operational expenditure | Often consumption/subscription based |
| Access | Local network and remote connectivity | Internet/private cloud connectivity |

### Cloud Service Models

| Model | Meaning | Example |
|---|---|---|
| IaaS | Infrastructure as a Service | Virtual Machines, virtual networks |
| PaaS | Platform as a Service | Managed application platforms |
| SaaS | Software as a Service | Hosted email and business applications |

### Banking Example

- On-premises: Bank operates its own internal data center.
- Cloud: Bank hosts an approved application on cloud infrastructure.
- Hybrid: Bank keeps sensitive systems on-premises and uses cloud for selected applications and services.

**Important:** Cloud does not mean there is no physical hardware. Cloud services still run on physical servers, storage and networking equipment.

**Memory Trick:** On-Premises = Your Infrastructure; Cloud = Provider's Infrastructure as a Service.

---

# 1.3 Compare Physical Interface and Cabling Types

## 1.3.a Single-Mode Fiber (SMF)

### What is Single-Mode Fiber?

Single-mode fiber is an optical fiber cable that transmits light primarily through one propagation mode.

It has a small core, typically around 9 micrometers.

### Characteristics

- Long-distance transmission.
- High bandwidth potential.
- Uses laser-based optical transceivers.
- Higher optical equipment cost in many deployments.
- Immune to electromagnetic interference.

### Common Uses

- Long-distance WAN links.
- Inter-building connections.
- Data center interconnections.
- ISP backbone networks.

**Memory Trick:** Single-Mode = Long Distance.

---

## 1.3.b Multimode Fiber (MMF)

### What is Multimode Fiber?

Multimode fiber allows multiple light propagation modes through a larger optical core.

Typical core sizes:
- 50 μm.
- 62.5 μm.

### Characteristics

- Usually used for shorter distances.
- Common in building and data center networks.
- Often uses lower-cost short-range optics.
- Distance depends on fiber grade, speed and transceiver.

### Common Types

| Fiber Type | Description |
|---|---|
| OM1 | Legacy multimode fiber |
| OM2 | Improved multimode fiber |
| OM3 | Laser-optimized multimode |
| OM4 | Higher-performance laser-optimized multimode |
| OM5 | Wideband multimode fiber |

### SMF vs MMF

| Feature | Single-Mode | Multimode |
|---|---|---|
| Core | Approximately 9 μm | Typically 50/62.5 μm |
| Light | Single propagation mode | Multiple modes |
| Distance | Longer | Shorter |
| Optics | Usually more expensive | Often less expensive |
| Common Use | WAN/Long-distance | LAN/Data Center |

**Important:** Never memorize one universal distance for all fiber. Maximum distance depends on the Ethernet standard, transceiver, wavelength, fiber grade and link budget.

**Memory Trick:** SMF = Long Distance; MMF = Short Distance.

---

## 1.3.c Copper Cabling

### What is Copper Cabling?

Copper Ethernet cabling transmits electrical signals through twisted copper wire pairs.

The most common Ethernet LAN copper cable is twisted-pair UTP.

### Common Categories

| Cable Type | Typical Use |
|---|---|
| Cat5e | Gigabit Ethernet |
| Cat6 | Gigabit and higher-speed short links |
| Cat6a | 10 Gigabit Ethernet up to 100 m |

### Important Characteristics

- Lower installation cost in many LAN deployments.
- Supports PoE.
- Easier installation.
- More susceptible to electromagnetic interference than fiber.
- Typical twisted-pair Ethernet channel length is up to 100 m, subject to the Ethernet standard and installation requirements.

### Common Copper Connectors

- RJ-45 / 8P8C modular connector.
- Commonly used with Ethernet twisted-pair cabling.

### Fiber vs Copper

| Feature | Fiber | Copper |
|---|---|---|
| Signal | Light | Electrical |
| EMI | Immune to electromagnetic interference | More susceptible |
| Distance | Longer | Typically up to 100 m for standard twisted-pair Ethernet |
| PoE | Standard Ethernet PoE not carried over optical fiber | Supports PoE |
| Common Use | Backbone/Uplink | Endpoint Connections |

**Memory Trick:** Fiber = Light; Copper = Electricity.

---

## 1.3.d Ethernet Shared Media vs Point-to-Point

### Ethernet Shared Media

Shared media means multiple devices share the same communication medium.

Example: Devices connected through an old Ethernet hub.

**Characteristics:**
- Shared bandwidth.
- Shared collision domain.
- Usually half-duplex.
- Uses CSMA/CD in traditional half-duplex Ethernet.

### What is CSMA/CD?

**CSMA/CD = Carrier Sense Multiple Access with Collision Detection.**

It is an Ethernet access method used in traditional half-duplex shared-media networks.

Process:
1. Device checks whether the medium is busy.
2. If free, it transmits.
3. If two devices transmit simultaneously, a collision may occur.
4. Devices detect the collision.
5. They stop transmitting and wait for a randomized backoff period.
6. They retry.

### Point-to-Point Ethernet

Point-to-point Ethernet connects two devices over a dedicated link.

Example: PC-to-switch or switch-to-switch connection.

**Characteristics:**
- Dedicated link between two devices.
- Full-duplex operation is common.
- Devices can transmit and receive simultaneously.
- No collisions in normal full-duplex operation.
- CSMA/CD is not required.

### Comparison

| Feature | Shared Media | Point-to-Point |
|---|---|---|
| Connection | Multiple devices share medium | Two devices |
| Bandwidth | Shared | Dedicated link capacity |
| Duplex | Traditionally Half-Duplex | Commonly Full-Duplex |
| Collisions | Possible | None in full-duplex |
| CSMA/CD | Used in legacy half-duplex Ethernet | Not needed in full-duplex |

**Memory Trick:**
- Shared Media = Shared Road.
- Point-to-Point = Dedicated Road.

---

# 1.4 Identify Interface and Cable Issues

This topic is important for real-world troubleshooting.

Common problems:
1. Collisions.
2. CRC/FCS Errors.
3. Duplex Mismatch.
4. Speed Mismatch.
5. Bad Cable.
6. Interface Errors.

## 1. Collisions

A collision occurs when two devices transmit simultaneously over a shared half-duplex Ethernet medium.

**Causes:**
- Shared Ethernet medium.
- Half-duplex communication.
- Duplex mismatch.

**Important:** Collisions are not expected on normal full-duplex Ethernet links.

## 2. CRC/FCS Errors

**CRC = Cyclic Redundancy Check.**

**FCS = Frame Check Sequence.**

These mechanisms help detect frame corruption.

If received data does not match the calculated error-check value, the frame is considered corrupted.

**Common Causes:**
- Damaged Ethernet cable.
- Electromagnetic interference.
- Faulty NIC.
- Faulty switch port.
- Duplex mismatch.

## 3. Duplex Mismatch

A duplex mismatch occurs when two connected devices operate with different duplex settings.

Example:

| Switch | PC |
|---|---|
| Full-Duplex | Half-Duplex |

**Symptoms:**
- Slow communication.
- Late collisions.
- CRC/FCS errors.
- Packet loss.
- Intermittent connectivity.

**Solution:** Configure both sides to use compatible speed and duplex settings, preferably auto-negotiation on both ends where supported.

## 4. Speed Mismatch

Speed mismatch occurs when connected interfaces cannot establish the expected compatible link speed.

Example:
- One side configured for 100 Mbps.
- Other side configured for 1 Gbps.

Depending on hardware and negotiation settings, the link may fail or operate at a lower supported speed.

**Solution:** Check supported speeds and ensure compatible configuration on both ends.

## 5. Common Interface Error Indicators

| Error | Meaning / Possible Cause |
|---|---|
| CRC | Frame corruption |
| Input Errors | Various receive-side errors |
| Output Errors | Transmit-side errors |
| Collisions | Half-duplex collisions |
| Late Collisions | Often duplex mismatch |
| Runts | Frames smaller than minimum Ethernet frame size |
| Giants | Oversized frames |
| FCS Errors | Frame Check Sequence failure |

### Cisco Troubleshooting Commands

```cisco
show interfaces
show interfaces gigabitEthernet 0/1
show interfaces status
show interfaces counters errors
show ip interface brief
```

### Example: Check Speed and Duplex

```cisco
show interfaces gigabitEthernet 0/1
```

Look for:
- Speed.
- Duplex.
- Input errors.
- CRC.
- Collisions.
- Output errors.

**Memory Trick:**
- CRC = Corrupted Frame.
- Collision = Simultaneous Transmission.
- Duplex Mismatch = Different Duplex Settings.
- Speed Mismatch = Incompatible Speed Settings.

---

# 1.5 Compare TCP to UDP

## TCP — Transmission Control Protocol

TCP is a connection-oriented transport-layer protocol that provides reliable, ordered delivery of a byte stream.

### Main Characteristics

- Connection-oriented.
- Three-way handshake.
- Acknowledgments.
- Sequence numbers.
- Retransmission of lost data.
- Flow control.
- Congestion control.
- Ordered delivery.

### TCP Three-Way Handshake

Before normal TCP data transfer, the endpoints establish a connection.

```text
       CLIENT                  SERVER
          |                       |
          |------ SYN ----------->|
          |                       |
          |<----- SYN-ACK --------|
          |                       |
          |------ ACK ----------->|
          |                       |
          |                  CONNECTION
          |                  ESTABLISHED
```

### Steps

1. SYN: Client requests a connection.
2. SYN-ACK: Server acknowledges and responds.
3. ACK: Client acknowledges the response.

Now data transfer can begin.

### Common TCP Applications

| Application | Common Port |
|---|---:|
| HTTP | 80 |
| HTTPS | 443 |
| SSH | 22 |
| FTP Control | 21 |
| SMTP | 25 |
| POP3 | 110 |
| IMAP | 143 |

*Note: HTTP/3 uses QUIC over UDP, so HTTPS is not exclusively TCP in modern networking.*

## UDP — User Datagram Protocol

UDP is a connectionless transport-layer protocol that sends datagrams without establishing a connection first.

### Main Characteristics

- Connectionless.
- No three-way handshake.
- No built-in acknowledgment.
- No built-in retransmission.
- No guaranteed delivery.
- No guaranteed ordering.
- Lower protocol overhead.

The application may implement its own reliability if needed.

### Common UDP Applications

| Application | Common Port |
|---|---:|
| DNS | 53 |
| DHCP Server | 67 |
| DHCP Client | 68 |
| TFTP | 69 |
| SNMP | 161 |
| NTP | 123 |

## TCP vs UDP Comparison

| Feature | TCP | UDP |
|---|---|---|
| Connection | Connection-Oriented | Connectionless |
| Handshake | Yes | No |
| Reliability | Built-in | No built-in delivery guarantee |
| Acknowledgment | Yes | No |
| Sequencing | Yes | No |
| Retransmission | Yes | No built-in retransmission |
| Flow Control | Yes | No built-in flow control |
| Overhead | Higher | Lower |
| Data Type | Byte Stream | Datagrams |
| Common Use | Web, SSH, File Transfer | DNS, DHCP, Voice, Streaming |

### Real-Life Analogy

**TCP = Registered Courier**
- Delivery confirmation.
- Tracks delivery.
- Retries when necessary.

**UDP = Ordinary Announcement**
- Sends immediately.
- Does not wait for delivery confirmation.
- Suitable when speed and timing matter.

**Memory Trick:**
- TCP = Reliable Delivery.
- UDP = Fast, Lightweight Delivery Without Built-in Reliability.

---

# 1.6 Configure and Verify IPv4 Addressing and Subnetting

## What is IPv4?

IPv4 = Internet Protocol Version 4.

It is a 32-bit logical addressing system used to identify devices on IP networks.

Example:

`192.168.10.100`

### IPv4 Structure

- 32 bits.
- Four octets.
- Each octet = 8 bits.
- Decimal range = 0–255.

Example:

`192.168.10.100`

### Network Portion vs Host Portion

An IPv4 address consists of:
- Network Portion.
- Host Portion.

The subnet mask or prefix length identifies the boundary.

Example:

`192.168.10.100/24`

- Network Bits = 24.
- Host Bits = 8.
- Subnet Mask = 255.255.255.0.

### Common Subnet Masks

| CIDR | Subnet Mask | Host Bits | Traditional Usable Hosts |
|---|---|---:|---:|
| /24 | 255.255.255.0 | 8 | 254 |
| /25 | 255.255.255.128 | 7 | 126 |
| /26 | 255.255.255.192 | 6 | 62 |
| /27 | 255.255.255.224 | 5 | 30 |
| /28 | 255.255.255.240 | 4 | 14 |
| /29 | 255.255.255.248 | 3 | 6 |
| /30 | 255.255.255.252 | 2 | 2 |

*Traditional usable-host counts exclude network and broadcast addresses. /31 and /32 are special cases.*

### Important Subnetting Formulas

| Calculation | Formula |
|---|---|
| IPv4 Bits | 32 |
| Host Bits | 32 − Prefix |
| Borrowed Bits | New Prefix − Parent Prefix |
| Total Subnets | 2^Borrowed Bits |
| Total IP Addresses | 2^Host Bits |
| Traditional Usable Hosts | 2^Host Bits − 2 |
| Block Size | 256 − Interesting Octet Mask |

### Banking Example

Treasury Department Network:

`192.168.10.0/24`

| Requirement | Value |
|---|---|
| Network Address | 192.168.10.0 |
| Default Gateway | 192.168.10.1 |
| PC1 | 192.168.10.10 |
| PC2 | 192.168.10.20 |
| Subnet Mask | 255.255.255.0 |
| Broadcast | 192.168.10.255 |

### Cisco Router Configuration

Suppose the router connects the Treasury network.

```cisco
enable
configure terminal

interface gigabitEthernet 0/0
ip address 192.168.10.1 255.255.255.0
no shutdown
exit

end
write memory
```

### PC Configuration

PC1:
- IP = 192.168.10.10
- Mask = 255.255.255.0
- Gateway = 192.168.10.1

PC2:
- IP = 192.168.10.20
- Mask = 255.255.255.0
- Gateway = 192.168.10.1

### Verification Commands

```cisco
show ip interface brief
show ip interface gigabitEthernet 0/0
show running-config
show ip route
```

### Connectivity Testing

From PC1:

```text
ping 192.168.10.1
ping 192.168.10.20
```

**Memory Trick:** IP + Mask + Gateway = Basic IPv4 Configuration.

---

# 1.7 Describe Private IPv4 Addressing

## What is a Private IPv4 Address?

A private IPv4 address is an address reserved for use inside private networks.

Private IPv4 addresses are not globally routable on the public Internet.

### Three Private IPv4 Ranges (RFC 1918)

| Class | Private Range | CIDR |
|---|---|---|
| A | 10.0.0.0 – 10.255.255.255 | 10.0.0.0/8 |
| B | 172.16.0.0 – 172.31.255.255 | 172.16.0.0/12 |
| C | 192.168.0.0 – 192.168.255.255 | 192.168.0.0/16 |

### Banking Example

| Department | Private Network |
|---|---|
| Treasury | 10.10.10.0/24 |
| Remittance | 172.16.10.0/24 |
| Trade | 192.168.10.0/24 |
| SWIFT | 10.20.10.0/24 |

These addresses can be used internally without obtaining a separate public IP for every device.

### Why Use Private IP Addresses?

1. Conserves public IPv4 addresses.
2. Allows internal addressing.
3. Supports network segmentation.
4. Reduces the need for public IP allocation.
5. Provides flexibility in network design.

### Private IP vs Public IP

| Private IP | Public IP |
|---|---|
| Used internally | Globally routable |
| Not routed on public Internet | Routable on public Internet |
| Reusable by different organizations | Must be globally coordinated |
| Often used with NAT for Internet access | Used for public Internet communication |

### Important NAT Connection

Private addresses are often translated to public addresses using NAT or PAT when communicating with the public Internet.

**Important:** Private IP addresses do not automatically provide security. Firewalls and access-control policies are still necessary.

**Memory Trick:** Private IP = Internal Network; Public IP = Internet-Routable Address.

---

# 1.8 Configure and Verify IPv6 Addressing and Prefix

## What is IPv6?

IPv6 = Internet Protocol Version 6.

IPv6 was developed to provide a much larger address space than IPv4.

### IPv6 Characteristics

- 128-bit address.
- Eight groups of hexadecimal numbers.
- Each group = 16 bits.
- Separated by colons.
- Supports very large address allocation.
- Uses multicast instead of broadcast.

### Example

`2001:0DB8:0000:0001:0000:0000:0000:0001`

Compressed:

`2001:DB8:0:1::1`

### IPv6 Compression Rules

**Rule 1:** Leading zeros in a hexadecimal group can be omitted.

Example:

`0DB8` → `DB8`

**Rule 2:** One consecutive sequence of all-zero groups can be replaced with `::` once in an address.

Example:

`2001:DB8:0:0:0:0:0:1`

Becomes:

`2001:DB8::1`

### IPv6 Prefix

A prefix identifies the network portion of an IPv6 address.

Example:

`2001:DB8:10:1::1/64`

- Prefix Length = 64 bits.
- Interface ID = 64 bits.

A /64 is the common LAN subnet size.

### Cisco IPv6 Configuration

**Step 1: Enable IPv6 Routing**

```cisco
enable
configure terminal
ipv6 unicast-routing
```

**Step 2: Configure Interface**

```cisco
interface gigabitEthernet 0/0
ipv6 address 2001:DB8:10:1::1/64
no shutdown
exit
```

**Step 3: Configure a Link-Local Address (Optional)**

```cisco
interface gigabitEthernet 0/0
ipv6 address FE80::1 link-local
```

**Step 4: Save Configuration**

```cisco
end
write memory
```

### Verification Commands

```cisco
show ipv6 interface brief
show ipv6 interface
show ipv6 route
show running-config
```

### IPv6 Connectivity Test

```cisco
ping 2001:DB8:10:1::10
```

**Memory Trick:** IPv4 = 32 Bits; IPv6 = 128 Bits.

---

# 1.9 Describe IPv6 Address Types

IPv6 supports different address types for different communication purposes.

## 1.9.a Unicast

Unicast means one-to-one communication.

One sender communicates with one destination interface.

There are three important unicast types.

### 1. Global Unicast Address (GUA)

Global Unicast addresses are globally routable IPv6 addresses.

Common global unicast allocation range:

`2000::/3`

Example:

`2001:DB8:10:1::10/64`

*2001:DB8 is a documentation prefix used for examples.*

**Purpose:** Communication across different networks and potentially the global Internet.

### 2. Unique Local Address (ULA)

Unique Local Addresses are designed for private IPv6 communication within an organization or limited interconnected sites.

Prefix:

`FC00::/7`

Locally assigned ULA addresses commonly use:

`FD00::/8`

Example:

`FD12:3456:789A:1::10/64`

**Purpose:** Internal organizational communication.

**Important:** ULA addresses are not intended to be globally routed on the public Internet.

### 3. Link-Local Address

Link-Local addresses are used for communication between devices on the same local link.

Prefix:

`FE80::/10`

Example:

`FE80::1`

### Characteristics

- Automatically configured or manually assigned.
- Used by IPv6 Neighbor Discovery.
- Used in Router Solicitation and Router Advertisement processes.
- Not forwarded by routers to other links.

### Comparison

| Feature | Global Unicast | Unique Local | Link-Local |
|---|---|---|---|
| Prefix | 2000::/3 | FC00::/7 | FE80::/10 |
| Scope | Global | Private/Site | Local Link |
| Internet Routing | Yes | No | No |
| Main Purpose | Global Communication | Internal Communication | Same-Link Communication |

**Memory Trick:**
- GUA = Global.
- ULA = Internal.
- Link-Local = Same Link.

---

## 1.9.b Anycast

### What is Anycast?

Anycast is an IPv6 addressing method where the same address is assigned to multiple interfaces, usually on different devices.

A packet is delivered to one of those interfaces, typically the topologically nearest one according to routing metrics.

### Example

Imagine a bank has DNS servers in Dhaka and Chattogram.

Both servers advertise the same anycast address.

A client sends a DNS request to that address.

The routing system directs the request to the appropriate nearest server.

### Characteristics

- Same IP address on multiple interfaces.
- One destination interface receives each packet.
- Routing determines which instance is reached.
- Improves availability and service distribution.

**Memory Trick:** Anycast = One-to-One of the Nearest Available Instances.

---

## 1.9.c Multicast

### What is Multicast?

Multicast is one-to-many or one-to-selected-group communication.

A packet is delivered to all interfaces that belong to the destination multicast group.

IPv6 Multicast Prefix:

`FF00::/8`

### Example

A router sends a message to all IPv6 routers on the local link.

Address:

`FF02::2`

### Important IPv6 Multicast Addresses

| Address | Meaning |
|---|---|
| FF02::1 | All Nodes on Local Link |
| FF02::2 | All Routers on Local Link |
| FF02::1:FF00:0/104 | Solicited-Node Multicast Prefix |

### Why IPv6 Uses Multicast Instead of Broadcast

IPv6 does not use broadcast addresses.

Functions traditionally associated with broadcast are handled using multicast and other IPv6 mechanisms.

**Memory Trick:** Multicast = One Sender to a Selected Group.

---

## 1.9.d Modified EUI-64

### What is Modified EUI-64?

Modified EUI-64 is a method of generating a 64-bit IPv6 interface identifier from a 48-bit MAC address.

### Why Is It Used?

It can help automatically construct the interface identifier portion of an IPv6 address.

### Step-by-Step Example

Given MAC Address:

`00:1A:2B:3C:4D:5E`

**Step 1: Divide the MAC into Two Halves**

```text
00:1A:2B | 3C:4D:5E
```

**Step 2: Insert FFFE in the Middle**

```text
00:1A:2B:FF:FE:3C:4D:5E
```

**Step 3: Flip the Universal/Local (U/L) Bit**

Change the seventh bit of the first octet.

`00` becomes `02`.

**Final Modified EUI-64 Interface ID:**

`021A:2BFF:FE3C:4D5E`

### Complete IPv6 Address

Suppose prefix:

`2001:DB8:10:1::/64`

Interface ID:

`021A:2BFF:FE3C:4D5E`

Final Address:

`2001:DB8:10:1:021A:2BFF:FE3C:4D5E/64`

### Cisco Configuration

```cisco
interface gigabitEthernet 0/0
ipv6 address 2001:DB8:10:1::/64 eui-64
no shutdown
```

Verification:

```cisco
show ipv6 interface brief
show ipv6 interface gigabitEthernet 0/0
```

**Important:** Modern IPv6 implementations often use stable or temporary privacy interface identifiers instead of MAC-derived EUI-64. Modified EUI-64 remains an important CCNA learning objective.

**Memory Trick:** Insert FFFE + Flip U/L Bit = Modified EUI-64.

---

# 1.10 Verify IP Parameters for Client OS

A network administrator must know how to check IP configuration on different operating systems.

The main parameters to verify are:

1. IPv4 Address.
2. IPv6 Address.
3. Subnet Mask / Prefix.
4. Default Gateway.
5. DNS Server.
6. Interface Status.

## A. Windows

### Command 1: Display IP Configuration

```cmd
ipconfig
```

Shows:
- IPv4 address.
- Subnet mask.
- Default gateway.
- IPv6 address.

### Command 2: Display Complete Configuration

```cmd
ipconfig /all
```

Shows:
- MAC address.
- DHCP status.
- DHCP server.
- DNS servers.
- Lease information.
- IP addresses.

### Command 3: Check Routing Table

```cmd
route print
```

### Command 4: Check ARP Table

```cmd
arp -a
```

### Command 5: Check DNS

```cmd
nslookup example.com
```

## B. macOS

### GUI Method

1. Open Apple Menu.
2. Open System Settings.
3. Select Network.
4. Select Wi-Fi or Ethernet.
5. Click Details.
6. Open TCP/IP to check IP and router.
7. Open DNS to check DNS servers.

### Terminal Commands

**Display Network Interfaces:**

```bash
ifconfig
```

**List Network Services:**

```bash
networksetup -listallnetworkservices
```

**Check Wi-Fi Configuration:**

```bash
networksetup -getinfo Wi-Fi
```

**Check DNS Servers:**

```bash
networksetup -getdnsservers Wi-Fi
```

**Check Default Route:**

```bash
route -n get default
```

*Replace Wi-Fi with the actual network service name if necessary.*

## C. Linux

### Command 1: Check IP Address

```bash
ip addr show
```

### Command 2: Check Routing Table

```bash
ip route
```

### Command 3: Check DNS Configuration

```bash
resolvectl status
```

### Command 4: Check Network Manager Details

```bash
nmcli device show
```

### Comparison Table

| Task | Windows | macOS | Linux |
|---|---|---|---|
| IP Address | ipconfig /all | ifconfig | ip addr show |
| Gateway/Routes | route print | route -n get default | ip route |
| DNS | ipconfig /all | networksetup -getdnsservers Wi-Fi | resolvectl status |
| MAC Address | ipconfig /all | ifconfig | ip link |
| DNS Test | nslookup | nslookup | nslookup |

**Memory Trick:** Windows = ipconfig; macOS = ifconfig/networksetup; Linux = ip.

---

# 1.11 Describe Wireless Principles

## 1.11.a Nonoverlapping Wi-Fi Channels

### What is a Wi-Fi Channel?

A Wi-Fi channel is a specific portion of radio frequency spectrum used by wireless devices to communicate.

### 2.4 GHz Wi-Fi Band

The commonly taught nonoverlapping 20/22-MHz channel plan uses:

**Channel 1, Channel 6 and Channel 11.**

| Channel | Center Frequency |
|---|---:|
| 1 | 2.412 GHz |
| 6 | 2.437 GHz |
| 11 | 2.462 GHz |

### Why Are They Important?

Neighboring access points using overlapping channels can interfere with each other.

Using nonoverlapping channels helps reduce adjacent-channel interference.

### Example: Three Bank Floors

| Floor | AP Channel |
|---|---|
| Floor 1 | Channel 1 |
| Floor 2 | Channel 6 |
| Floor 3 | Channel 11 |

### 5 GHz Wi-Fi

- Offers more channel options.
- Usually has less congestion than 2.4 GHz.
- Supports wider channels.
- Channel availability depends on regulatory domain.
- Some channels require Dynamic Frequency Selection (DFS).

### 6 GHz Wi-Fi

Wi-Fi 6E and newer technologies can use the 6-GHz band where supported and legally permitted.

**Important:** Available channels and allowed transmit power depend on the country's regulatory rules. Channel 1, 6 and 11 are a common 2.4-GHz plan, not a universal regulatory rule.

**Memory Trick:** 2.4 GHz = 1, 6, 11.

---

## 1.11.b SSID

### What is SSID?

**SSID = Service Set Identifier.**

SSID is the name used to identify a wireless network.

### Example

When you search for Wi-Fi, you may see:

- BANK-TREASURY.
- BANK-GUEST.
- BANK-EMPLOYEE.

These are SSIDs.

### How Does SSID Work?

1. AP broadcasts wireless network information.
2. Client searches available wireless networks.
3. User selects an SSID.
4. Client authenticates.
5. Client associates with the AP.
6. Wireless communication begins.

### Important Difference

| SSID | BSSID |
|---|---|
| Wireless network name | Identifies a specific Basic Service Set/AP radio |
| Human-readable identifier | Commonly the AP radio's MAC address |
| Can be used by multiple APs | Identifies an individual BSS |

**Important:** Hiding an SSID does not provide meaningful security.

**Memory Trick:** SSID = Wi-Fi Network Name.

---

## 1.11.c Radio Frequency (RF)

### What is RF?

**RF = Radio Frequency.**

RF refers to electromagnetic signals used for wireless communication.

Wi-Fi uses radio frequency signals to transmit and receive data.

### Important RF Concepts

**1. Frequency**

Number of wave cycles per second, measured in Hertz (Hz).

**2. Signal Strength**

Indicates the strength of the received wireless signal.

**3. Attenuation**

Reduction in signal strength as the signal travels.

**4. Interference**

Unwanted signals that affect wireless communication.

**5. RSSI**

Received Signal Strength Indicator.

**6. SNR**

Signal-to-Noise Ratio.

A higher SNR generally indicates a cleaner wireless signal.

### 2.4 GHz vs 5 GHz vs 6 GHz

| Feature | 2.4 GHz | 5 GHz | 6 GHz |
|---|---|---|---|
| Coverage | Generally Longer | Generally Shorter | Generally Shorter |
| Congestion | Often Higher | Often Lower | Depends on deployment |
| Channel Availability | Limited | More | More |
| Penetration | Generally Better | Lower | Lower |
| Common Use | Range and compatibility | Higher-capacity Wi-Fi | Modern high-capacity Wi-Fi |

Actual performance depends on transmit power, antennas, channel width, environment, device capabilities and regulations.

**Memory Trick:** RF = Wireless Signal Technology.

---

## 1.11.d Wireless Encryption

### What is Wireless Encryption?

Wireless encryption protects data transmitted between wireless devices and access points.

It helps prevent unauthorized parties from reading wireless traffic.

### Common Wireless Security Protocols

| Protocol | Encryption / Security | Status |
|---|---|---|
| WEP | RC4-based | Obsolete and insecure |
| WPA | TKIP | Legacy |
| WPA2 | AES-CCMP | Widely supported |
| WPA3 | SAE and stronger security options | Modern recommended option |

### WPA2

Uses AES-CCMP for strong wireless data protection.

Common modes:
- WPA2-Personal (Pre-Shared Key).
- WPA2-Enterprise (802.1X authentication).

### WPA3

Provides improved wireless security.

Important feature:
- SAE (Simultaneous Authentication of Equals) for WPA3-Personal.

WPA3-Enterprise supports enterprise authentication and stronger security options.

### Banking Example

A bank should not use an open Wi-Fi network for sensitive employee communication.

It should use appropriate enterprise wireless authentication and encryption.

**Recommended Enterprise Approach:**
- WPA2-Enterprise or WPA3-Enterprise.
- 802.1X authentication.
- RADIUS authentication server.
- Strong security policies.

### Memory Trick

- WEP = Old and Insecure.
- WPA = Legacy.
- WPA2 = AES.
- WPA3 = Modern Security.

---

# 1.12 Explain Virtualization Fundamentals

## What is Virtualization?

Virtualization is the process of creating virtual versions of computing or networking resources using software.

It allows multiple logical systems to share physical hardware.

Three important CCNA concepts:

1. Server Virtualization.
2. Containers.
3. VRF.

---

## 1.12.a Server Virtualization

### What is Server Virtualization?

Server virtualization allows one physical server to run multiple virtual machines (VMs).

Each VM behaves like an independent computer with its own operating system and resources.

### What is a Hypervisor?

A hypervisor is software that creates and manages virtual machines.

### Types of Hypervisors

**Type 1 — Bare-Metal Hypervisor**

Runs directly on physical server hardware.

Examples:
- VMware ESXi.
- Microsoft Hyper-V (hypervisor-based architecture).
- KVM-based virtualization platforms.

**Type 2 — Hosted Hypervisor**

Runs as software on top of a host operating system.

Examples:
- Oracle VirtualBox.
- VMware Workstation.

### Architecture

```text
          PHYSICAL SERVER
                 |
             HYPERVISOR
           /     |      \
          /      |       \
        VM1     VM2      VM3
        |        |        |
       OS       OS       OS
        |        |        |
      APP      APP      APP
```

### Banking Example

A bank has one powerful physical server.

Instead of purchasing separate physical servers for:
- DHCP.
- DNS.
- File Storage.
- Application Hosting.

It can run these services in separate virtual machines, subject to capacity and security requirements.

### Advantages

- Better hardware utilization.
- Reduced physical server count.
- Easier provisioning.
- Resource flexibility.
- Workload isolation.

**Memory Trick:** Server Virtualization = Many Virtual Servers on One Physical Server.

---

## 1.12.b Containers

### What is a Container?

A container is a lightweight software environment that packages an application and its required dependencies.

Containers use operating-system-level virtualization and normally share the host operating system kernel.

### How Containers Work

1. Application code is packaged.
2. Required dependencies are included.
3. Container image is created.
4. Container engine runs the image.
5. Application runs in an isolated environment.

### Container vs Virtual Machine

| Feature | Virtual Machine | Container |
|---|---|---|
| Virtualization | Hardware | Operating System |
| Guest OS | Each VM has its own guest OS | Shares host kernel |
| Size | Usually Larger | Usually Smaller |
| Startup | Generally Slower | Generally Faster |
| Resource Usage | Higher | Lower |
| Isolation | Separate OS/kernel boundary | OS-level process isolation |

### Example

A bank's application development team may run:
- One container for a web application.
- One container for an API.
- One container for a supporting service.

These can run on a virtualized server or physical host.

### Advantages

- Lightweight.
- Portable.
- Fast deployment.
- Efficient resource usage.
- Supports microservices.

**Memory Trick:**
- VM = Separate Guest OS.
- Container = Shared Host Kernel.

---

## 1.12.c Virtual Routing and Forwarding (VRF)

### What is VRF?

**VRF = Virtual Routing and Forwarding.**

VRF allows multiple separate routing tables to exist on one physical router or Layer 3 device.

It creates logically separated routing environments.

### Simple Explanation

One physical router can behave like multiple independent logical routers.

### Banking Example

A bank wants to separate:

- Treasury Network.
- Remittance Network.
- Guest Network.

A router or Layer 3 switch can use different VRFs to maintain separate routing tables for these environments.

### VRF Architecture

```text
          ONE PHYSICAL ROUTER
                   |
          +--------+--------+
          |        |        |
        VRF 1    VRF 2    VRF 3
          |        |        |
       Treasury Remittance Guest
       Routing   Routing   Routing
       Table     Table     Table
```

### Main Characteristics

- Separate routing tables.
- Logical network isolation.
- Multiple routing environments on one device.
- Supports overlapping IP address spaces across different VRFs.
- Used in service provider and enterprise segmentation.

### VRF vs VLAN

| Feature | VLAN | VRF |
|---|---|---|
| Main Purpose | Layer 2 segmentation | Layer 3 routing separation |
| Separation | Broadcast domains | Routing tables |
| Layer | Layer 2 | Layer 3 |
| Common Use | Department separation | Separate routing environments |

**Important:** VRF provides routing separation, not encryption. Firewall policies and other controls may still be needed.

**Memory Trick:** VRF = Multiple Logical Routers on One Physical Device.

---

# 1.13 Describe Switching Concepts

A switch forwards Ethernet frames based on MAC address information.

Four important concepts:

1. MAC Learning and Aging.
2. Frame Switching.
3. Frame Flooding.
4. MAC Address Table.

---

## 1.13.a MAC Learning and Aging

### What is MAC Learning?

MAC learning is the process through which a switch learns which MAC addresses are reachable through which ports.

### How Does MAC Learning Work?

1. A switch receives an Ethernet frame.
2. It reads the source MAC address.
3. It identifies the incoming port and VLAN.
4. It adds or updates the source MAC entry in its MAC address table.
5. It uses this information for future forwarding decisions.

### Example

Suppose:

- PC1 MAC = `AAAA.AAAA.AAAA`.
- PC2 MAC = `BBBB.BBBB.BBBB`.
- PC1 connects to Fa0/1.
- PC2 connects to Fa0/2.

When PC1 sends a frame, the switch learns:

`AAAA.AAAA.AAAA → Fa0/1`

When PC2 sends a frame, it learns:

`BBBB.BBBB.BBBB → Fa0/2`

### What is MAC Aging?

MAC aging is the process of removing old dynamic MAC address entries after a specified period of inactivity.

**Why Is It Needed?**

- Removes stale entries.
- Updates device location information.
- Keeps the MAC table current.
- Supports devices moving between switch ports.

### Important Concepts

- Dynamic MAC entries are learned automatically.
- Static MAC entries are configured manually.
- MAC aging applies to dynamic entries according to the configured aging behavior.

**Memory Trick:** Learning = Remember MAC Location; Aging = Forget Old MAC Location.

---

## 1.13.b Frame Switching

### What is Frame Switching?

Frame switching is the process of receiving an Ethernet frame, examining its destination MAC address and deciding how to forward it.

### How Does It Work?

1. Switch receives an Ethernet frame.
2. Reads source MAC address.
3. Learns the source MAC address.
4. Reads destination MAC address.
5. Searches the MAC address table.
6. Forwards, floods or filters the frame.

### Three Possible Actions

**1. Known Unicast**

If destination MAC exists in the MAC table, the switch forwards the frame only through the associated port (if it is not the incoming port).

**2. Unknown Unicast**

If destination MAC is unknown, the switch floods the frame within the same VLAN, except the incoming port.

**3. Same-Port Destination**

If the destination MAC is associated with the incoming port, the switch filters the frame rather than sending it back through the same port.

### Example

PC1 wants to send data to PC2.

The switch already knows that PC2 is connected to Fa0/2.

It forwards the frame only through Fa0/2.

**Memory Trick:** Switch Looks at Destination MAC and Selects the Correct Port.

---

## 1.13.c Frame Flooding

### What is Frame Flooding?

Frame flooding is the process of sending a received frame out of multiple eligible ports within the same VLAN, excluding the incoming port.

### When Does Flooding Occur?

1. Unknown Unicast.
2. Broadcast Frames.
3. Unknown Multicast Frames, subject to multicast handling and snooping.

### Banking Example

Suppose Treasury PC sends a frame to a destination MAC address that the switch has not learned yet.

The switch does not know which port contains the destination.

Therefore, it floods the frame to other eligible ports in the same VLAN.

### Important Flooding Rule

A Layer 2 switch does not normally flood an Ethernet frame to ports belonging to other VLANs.

### Known Unicast vs Unknown Unicast vs Broadcast

| Frame Type | Switch Action |
|---|---|
| Known Unicast | Forward to one destination port |
| Unknown Unicast | Flood within VLAN |
| Broadcast | Flood within VLAN |
| Unknown Multicast | Usually flood within VLAN unless controlled by snooping/policies |

**Memory Trick:** Unknown Destination = Flood; Known Destination = Forward.

---

## 1.13.d MAC Address Table

### What is a MAC Address Table?

A MAC address table is a database maintained by a Layer 2 switch that stores learned MAC addresses and their associated VLANs and ports.

It is also called:
- CAM Table.
- MAC Table.
- Forwarding Database.

### Example MAC Address Table

| VLAN | MAC Address | Type | Port |
|---|---|---|---|
| 10 | AAAA.AAAA.AAAA | Dynamic | Fa0/1 |
| 10 | BBBB.BBBB.BBBB | Dynamic | Fa0/2 |
| 20 | CCCC.CCCC.CCCC | Dynamic | Fa0/3 |
| 20 | DDDD.DDDD.DDDD | Static | Fa0/4 |

### Information Stored

1. VLAN ID.
2. MAC Address.
3. Entry Type.
4. Associated Switch Port.

### Important Cisco Commands

**Display All MAC Entries:**

```cisco
show mac address-table
```

**Display Dynamic Entries:**

```cisco
show mac address-table dynamic
```

**Display a Specific VLAN:**

```cisco
show mac address-table vlan 10
```

**Display a Specific MAC Address:**

```cisco
show mac address-table address AAAA.AAAA.AAAA
```

**Display MAC Aging Time:**

```cisco
show mac address-table aging-time
```

### Why Is the MAC Table Important?

- Helps switches forward frames correctly.
- Reduces unnecessary traffic.
- Helps troubleshoot connectivity.
- Shows which device is connected to which switch port.
- Helps identify MAC address movement and suspicious behavior.

### MAC Learning and Forwarding — Complete Process

```text
          PC1 SENDS FRAME
                 |
                 v
           SWITCH RECEIVES
                 |
                 v
        LEARNS SOURCE MAC
                 |
                 v
       CHECKS DESTINATION MAC
                 |
          +------+------+
          |             |
       KNOWN           UNKNOWN
          |             |
          v             v
       FORWARD         FLOOD
      ONE PORT      SAME VLAN PORTS
```

**Memory Trick:** MAC Table = Which MAC Address Is Connected to Which Switch Port?

---

# FINAL CCNA NETWORK FUNDAMENTALS REVISION

## 1. Network Components

| Component | Main Function |
|---|---|
| Router | Connects Different Networks |
| Layer 2 Switch | Forwards Frames Using MAC |
| Layer 3 Switch | Switches + Routes |
| NGFW | Advanced Network Security |
| IPS | Detects and Blocks Attacks |
| Access Point | Provides Wi-Fi |
| WLC | Manages Wireless APs |
| Catalyst Center | Network Automation and Management |
| Endpoint | Network-Connected Device |
| Server | Provides Network Services |
| PoE | Power + Data Through Ethernet |

## 2. Network Architectures

| Architecture | Key Concept |
|---|---|
| Two-Tier | Access + Collapsed Core |
| Three-Tier | Access + Distribution + Core |
| Spine-Leaf | Every Leaf Connects to Every Spine |
| WAN | Connects Distant Networks |
| SOHO | Small Integrated Network |
| On-Premises | Organization-Controlled Infrastructure |
| Cloud | Provider-Hosted Computing Resources |

## 3. Cabling and Interfaces

| Type | Remember |
|---|---|
| Single-Mode Fiber | Long Distance |
| Multimode Fiber | Shorter Distance |
| Copper | Electrical Signals |
| Shared Ethernet | Shared Medium, Collisions Possible in Half-Duplex |
| Point-to-Point | Dedicated Link |

## 4. Interface Problems

| Problem | Meaning |
|---|---|
| Collision | Simultaneous Transmission on Half-Duplex Shared Media |
| CRC | Frame Corruption |
| Duplex Mismatch | Different Duplex Settings |
| Speed Mismatch | Incompatible Speed Settings |
| Cable Fault | Physical Connection Problem |

## 5. TCP vs UDP

| TCP | UDP |
|---|---|
| Connection-Oriented | Connectionless |
| Reliable | No Built-in Delivery Guarantee |
| Handshake | No Handshake |
| Acknowledgment | No Built-in ACK |
| Higher Overhead | Lower Overhead |

## 6. IPv4

- IPv4 = 32 Bits.
- 1 Octet = 8 Bits.
- Private Ranges:
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 192.168.0.0/16
- Network Bits + Host Bits = 32.

## 7. IPv6

- IPv6 = 128 Bits.
- Eight Hexadecimal Groups.
- GUA = Global Communication.
- ULA = Private IPv6 Communication.
- Link-Local = Same Link.
- Anycast = Nearest Matching Interface.
- Multicast = Selected Group.
- Modified EUI-64 = Insert FFFE + Flip U/L Bit.

## 8. Wireless

- SSID = Wi-Fi Network Name.
- RF = Radio Frequency.
- 2.4 GHz = Common Channels 1, 6, 11.
- WPA2 = AES-CCMP.
- WPA3 = Modern Wireless Security.
- WLC = Centralized Wireless Management.

## 9. Virtualization

- Server Virtualization = Multiple VMs on One Physical Server.
- Container = Shares Host OS Kernel.
- VRF = Multiple Separate Routing Tables.

## 10. Switching

- MAC Learning = Learn Source MAC.
- MAC Aging = Remove Stale Dynamic Entries.
- Frame Switching = Forward Based on Destination MAC.
- Frame Flooding = Send to Eligible Ports in Same VLAN.
- MAC Table = MAC + VLAN + Port.

---

# FINAL MEMORY TRICK — NETWORK FUNDAMENTALS

**Router → IP**

**Layer 2 Switch → MAC**

**Layer 3 Switch → MAC + IP**

**NGFW → Security**

**AP → Wi-Fi**

**Controller → Centralized Management**

**PoE → Power + Data**

**Two-Tier → Access + Collapsed Core**

**Three-Tier → Access + Distribution + Core**

**Spine-Leaf → Data Center**

**SMF → Long Distance**

**MMF → Short Distance**

**TCP → Reliable**

**UDP → Lightweight**

**IPv4 → 32 Bits**

**IPv6 → 128 Bits**

**GUA → Global**

**ULA → Local/Private**

**Link-Local → Same Link**

**SSID → Wi-Fi Name**

**VRF → Separate Routing Tables**

**MAC Learning → Source MAC**

**Frame Flooding → Unknown Destination**

**MAC Table → MAC-to-Port Mapping**

---

# OFFICIAL TECHNICAL REFERENCES

The following official documentation and standards were used to prepare these notes. Use them for further study and technical verification.

### 1. Cisco CCNA Official Exam Topics
- [Cisco 200-301 CCNA Exam Topics](https://learningnetwork.cisco.com/s/ccna-exam-topics)
- [Official CCNA Exam Description PDF](https://learningcontent.cisco.com/documents/marketing/exam-topics/200-301-CCNA-v1.1.pdf)

### 2. Network Components and Security
- [Cisco — How Does a Router Work?](https://www.cisco.com/site/us/en/learn/topics/small-business/how-does-a-router-work.html)
- [Cisco — Next-Generation Firewall](https://www.cisco.com/site/us/en/learn/topics/security/what-is-a-next-generation-firewall.html)
- [Cisco — What Is an Access Point?](https://www.cisco.com/site/us/en/learn/topics/small-business/what-is-an-access-point.html)
- [Cisco — Catalyst Center](https://www.cisco.com/c/en/us/products/collateral/cloud-systems-management/dna-center/nb-06-dna-center-data-sheet-cte-en.html)
- [Cisco — PoE Configuration Guide](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/infra/poe/poe-configuration-guide/g-poe/c-poe.html)

### 3. Network Topology and Cabling
- [Cisco — Campus LAN and Wireless LAN Design Guide](https://www.cisco.com/c/en/us/td/docs/solutions/CVD/Campus/cisco-campus-lan-wlan-design-guide.html)
- [Cisco — Spine-Leaf Data Center Architecture](https://www.cisco.com/c/en/us/products/collateral/switches/nexus-9000-series-switches/white-paper-c11-743245.html)
- [Cisco — Optical Networking](https://www.cisco.com/site/us/en/learn/topics/networking/optical-networking.html)
- [Cisco — Ethernet Troubleshooting](https://www.cisco.com/en/US/docs/internetworking/troubleshooting/guide/tr1904.html)
- [Cisco — Duplex and Interface Error Troubleshooting](https://www.cisco.com/c/en/us/support/docs/lan-switching/ethernet/10561-3.html)

### 4. TCP, UDP and IPv4
- [Cisco — TCP, UDP and Transport Protocols](https://www.cisco.com/c/en/us/td/docs/iosxr/cisco8000/ipaddresses-and-services/configuration-guide/ip-addresses-and-services-config-cisco8000/transport-protocol-operations/tcp-udp-and-raw-transports.html)
- [RFC 1918 — Private IPv4 Addressing](https://www.rfc-editor.org/rfc/rfc1918.html)
- [Cisco — IPv4 Address Configuration](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipaddr_ipv4/configuration/xe-16-10/ipv4-xe-16-10-book/configuring_ipv4_addresses.html)

### 5. IPv6 Standards
- [RFC 4291 — IPv6 Addressing Architecture](https://www.rfc-editor.org/rfc/rfc4291.html)
- [RFC 4193 — Unique Local IPv6 Addresses](https://www.rfc-editor.org/rfc/rfc4193.html)
- [Cisco — IPv6 Addressing and Basic Connectivity](https://www.cisco.com/c/en/us/td/docs/ios/ipv6/configuration/guide/ipv6-xe-16-book-cat8000/m_ip6-addrg-bsc-con.html)
- [Cisco — Modified EUI-64 Configuration](https://www.cisco.com/c/en/us/td/docs/ios/ipv6/configuration/guide/ipv6-xe-16-book-cat8000/m_ip6-addrg-bsc-con.html)

### 6. Client Operating Systems
- [Microsoft — ipconfig Command](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/ipconfig)
- [Apple — Configure IP Address on Mac](https://support.apple.com/en-euro/guide/mac-help/mchlp2718/27/mac/27)
- [Linux — ip-address Manual](https://man7.org/linux/man-pages/man8/ip-address.8.html)
- [Linux — ip-route Manual](https://man7.org/linux/man-pages/man8/ip-route.8.html)

### 7. Wireless Networking
- [Cisco — 2.4 GHz Nonoverlapping Channels](https://www.cisco.com/c/en/us/support/docs/smb/wireless/CB-Wireless-Mesh/2069-tz-Changing-RF-Channels.html)
- [Cisco — Wireless RF Reference Guide](https://www.cisco.com/c/en/us/td/docs/wireless/controller/9800/technical-reference/wireless-rf-reference-guide.html)
- [Cisco — Wi-Fi Security](https://www.cisco.com/site/us/en/learn/topics/networking/what-is-wi-fi-security.html)
- [Cisco — WPA3 Security Configuration](https://www.cisco.com/c/en/us/td/docs/wireless/controller/9800/26-1/configuration-guide/wl-26-1-cg/wpa3.html)

### 8. Virtualization and Switching
- [Cisco — What Is Virtualization?](https://www.cisco.com/site/us/en/learn/topics/networking/what-is-virtualization.html)
- [Cisco — Virtual Routing and Forwarding](https://docs.manage.security.cisco.com/cdfmc/c_about_virtual_routers_and_vrf.html)
- [Docker — Containers vs Virtual Machines](https://docs.docker.com/learn/content/what-is-a-container/)
- [Cisco — MAC Learning, Forwarding and Aging](https://www.cisco.com/c/en/us/td/docs/switches/lan/c9000/lyr2-fwd/cdp-lldp-mac-udld/cdp-lldp-mac-udld-configuration-guide/configure-mac.html)

---

**END OF SECTION 1.0 — NETWORK FUNDAMENTALS**

**Study Recommendation:** Understand each concept first, then practise the associated Cisco commands in Packet Tracer. Prioritize subnetting, TCP/UDP, IPv6 address types, duplex troubleshooting, MAC learning and frame forwarding for practical CCNA preparation.
