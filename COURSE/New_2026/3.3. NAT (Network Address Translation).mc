


# Table of Contents (Quick Menu)

1. [What is NAT?](#1-what-is-nat)
2. [Why Do We Need NAT?](#2-why-do-we-need-nat)
3. [NAT in a Banking Network](#3-understand-nat-using-a-banking-network)
4. [Three Types of NAT](#4-three-types-of-nat)
5. [Static NAT — One-to-One](#5-static-nat--one-to-one-translation)
6. [Four Important NAT Terminologies](#6-four-important-nat-terminologies)
7. [Dynamic NAT — Public IP Pool](#7-dynamic-nat--one-to-one-from-a-public-ip-pool)
8. [PAT — NAT Overload](#8-pat--port-address-translation-nat-overload)
9. [Static NAT vs Dynamic NAT vs PAT](#9-static-nat-vs-dynamic-nat-vs-pat)
10. [NAT Packet Flow](#10-how-nat-works--packet-flow-step-by-step)
11. [Cisco NAT Configuration](#11-cisco-nat-configuration--practical-ccna-commands)
    - [Common Router Configuration](#a-common-router-configuration)
    - [Static NAT Configuration](#b-static-nat-configuration)
    - [Dynamic NAT Configuration](#c-dynamic-nat-configuration)
    - [PAT Configuration](#d-pat-configuration-nat-overload)
12. [NAT Verification Commands](#12-nat-verification--cisco-ios-commands)
13. [NAT Troubleshooting](#13-nat-troubleshooting--common-problems)
14. [DHCP + DNS + NAT Together](#14-how-dhcp-dns-and-nat-work-together)
15. [Common CCNA Exam Traps](#15-common-ccna-exam-traps)
16. [One-Minute NAT Revision Sheet](#16-one-minute-nat-revision-sheet)
17. [CCNA Practice Questions](#17-ccna-practice-questions)
18. [Final Learning Checklist](#18-final-learning-checklist)

---

## 1. What is NAT?

**NAT = Network Address Translation.**

NAT is a networking technique that translates IP addresses as packets pass between networks, commonly between a private internal network and a public network.

**Simple Explanation:** NAT changes the source or destination IP address of packets according to configured translation rules.

### Real-Life Analogy: Bank Security Gate

Imagine a bank with 200 employees.

- Every employee has an internal employee ID.
- External visitors cannot use those internal IDs to identify employees outside the bank.
- The bank uses an external communication system to represent internal employees.

| Banking Example | NAT Concept |
|---|---|
| Internal Employee ID | Private IP |
| External Communication ID | Public IP |
| Security Gate | NAT Router |
| Address Conversion | NAT Translation |
| Translation Record | NAT Translation Table |

**Memory Trick:**
- DHCP = Gives IP.
- DNS = Finds IP.
- NAT = Translates IP.

---

## 2. Why Do We Need NAT?

Imagine a bank has 200 computers across four departments.

- Treasury: 50 computers.
- Remittance: 50 computers.
- Trade: 50 computers.
- SWIFT: 50 computers.

All computers use private IP addresses internally.

But private IP addresses are not globally routable on the public internet.

NAT allows these computers to communicate with external networks using public IP addresses.

### Private IPv4 Address Ranges

| Class | Private IP Range |
|---|---|
| A | 10.0.0.0 – 10.255.255.255 |
| B | 172.16.0.0 – 172.31.255.255 |
| C | 192.168.0.0 – 192.168.255.255 |

These are the three RFC 1918 private address ranges.

### Why NAT Is Needed

1. **IPv4 Conservation:** Multiple private devices can share a limited number of public IPv4 addresses.
2. **Internet Connectivity:** Allows private network devices to communicate with public networks.
3. **Address Flexibility:** Internal addressing can change without necessarily changing external addressing.
4. **Address Separation:** Internal private addresses are not directly exposed as source addresses on external connections.

**Important:** NAT is not encryption or a replacement for a firewall. NAT alone does not guarantee network security.

---

## 3. Understand NAT Using a Banking Network

Let's build a simple example.

### Bank Internal Network

| Department | Private IP |
|---|---|
| Treasury | 192.168.10.10 |
| Remittance | 192.168.10.20 |
| Trade | 192.168.10.30 |
| SWIFT | 192.168.10.40 |

**NAT Router Public IP:** `198.51.100.2`

**Internet:** External website or server.

### Network Diagram

```text
       BANK PRIVATE NETWORK
       192.168.10.0/24

       Treasury   192.168.10.10
       Remittance 192.168.10.20
       Trade      192.168.10.30
       SWIFT      192.168.10.40
                    |
                    |
                NAT ROUTER
                198.51.100.2
                    |
                    |
                 INTERNET
                    |
                    |
             EXTERNAL SERVER
```

Suppose Treasury PC has:

`192.168.10.10`

It wants to access an external website.

The NAT router translates its private source IP into a public source IP, depending on the NAT method configured.

The external server sees the translated public address rather than the original private source address.

*Note: 198.51.100.0/24 and 203.0.113.0/24 are documentation-only public IPv4 ranges reserved for examples. They are not real production public IP allocations.*

---

## 4. Three Types of NAT

There are three main NAT types you must understand for CCNA.

| NAT Type | Mapping | Main Concept |
|---|---|---|
| Static NAT | 1 Private ↔ 1 Fixed Public | Permanent one-to-one |
| Dynamic NAT | 1 Private ↔ 1 Available Public | Temporary one-to-one from a pool |
| PAT | Many Private → 1 Public | Uses port numbers |

**Memory Trick:**

- Static = Fixed.
- Dynamic = Pool.
- PAT = Ports.

---

## 5. Static NAT — One-to-One Translation

**Definition:** Static NAT permanently maps one private IP address to one specific public IP address.

### Banking Example

Suppose the bank has an internal web server:

- Private IP = `192.168.10.10`
- Public IP = `203.0.113.10`

Static NAT creates this permanent mapping:

| Inside Local (Private) | Inside Global (Public) |
|---|---|
| 192.168.10.10 | 203.0.113.10 |

### How Does Static NAT Work?

1. An internal bank server has private IP `192.168.10.10`.
2. The administrator configures a public IP mapping.
3. An external user connects to `203.0.113.10`.
4. The NAT router translates the destination to `192.168.10.10`.
5. The internal server receives the request.
6. Reply packets are translated back to the public IP.

### Where Is Static NAT Used?

- Public-facing web servers.
- Email servers.
- Servers requiring a consistent public IP.
- Services requiring inbound connectivity.

**Memory Trick:** Static NAT = Fixed One-to-One Mapping.

**Important:** Static NAT alone does not guarantee external access. Appropriate routing, firewall rules and server services must also be configured.

---

## 6. Four Important NAT Terminologies

These terms are very important for CCNA examinations.

### A. Inside Local Address

The private IP address assigned to an internal device.

Example: `192.168.10.100`

### B. Inside Global Address

The public IP address representing an internal device to the outside network.

Example: `198.51.100.2`

### C. Outside Global Address

The actual IP address of the external device.

Example: `93.184.216.34`

### D. Outside Local Address

The IP address of the external device as represented to the internal network.

In ordinary source NAT/PAT, it is usually the same as the Outside Global address.

### Complete Comparison

| Term | Meaning | Example |
|---|---|---|
| Inside Local | Internal device's private IP | 192.168.10.100 |
| Inside Global | Public representation of internal device | 198.51.100.2 |
| Outside Local | External device's address as seen inside | 93.184.216.34 |
| Outside Global | Actual external device's IP | 93.184.216.34 |

**Memory Trick:**

- Inside = Your organization's network.
- Outside = External network.
- Local = Address as represented inside.
- Global = Address as represented outside.

### Visual Example

```text
       INSIDE LOCAL
       192.168.10.100
              |
              | NAT Translation
              v
       INSIDE GLOBAL
       198.51.100.2
              |
              |
       OUTSIDE NETWORK
              |
              v
       OUTSIDE GLOBAL
       93.184.216.34

       OUTSIDE LOCAL
       93.184.216.34
```

---

## 7. Dynamic NAT — One-to-One from a Public IP Pool

**Definition:** Dynamic NAT automatically assigns an available public IP address from a configured pool to an internal private IP address.

Unlike Static NAT, the mapping is temporary and created when needed.

### Banking Example

Suppose a bank has:
- 50 internal computers.
- Only 5 available public IP addresses.

Public IP Pool:

`203.0.113.10 – 203.0.113.14`

When internal computers need external communication, the router assigns an available public IP from the pool.

### Dynamic NAT Mapping

| Inside Local | Inside Global |
|---|---|
| 192.168.10.100 | 203.0.113.10 |
| 192.168.10.101 | 203.0.113.11 |
| 192.168.10.102 | 203.0.113.12 |
| 192.168.10.103 | 203.0.113.13 |
| 192.168.10.104 | 203.0.113.14 |

### Step-by-Step Process

1. Treasury PC `192.168.10.100` wants internet access.
2. Router checks its Dynamic NAT pool.
3. Router finds an available public IP.
4. It assigns `203.0.113.10`.
5. The router stores the mapping in its NAT translation table.
6. Return traffic uses the mapping to reach the correct internal computer.
7. When the translation expires or is removed, the public address can become available again.

### What Happens When All Public IPs Are Used?

Suppose all five public IPs are occupied.

A sixth computer requests internet access.

**Pool Exhausted:** The router cannot create another one-to-one mapping until an address becomes available.

### Advantages

- Automatically allocates public IP addresses.
- Reduces manual mapping.
- Public addresses are assigned when needed.

### Disadvantages

- Requires a pool of public IP addresses.
- Pool exhaustion prevents new mappings.
- Does not allow unlimited internal devices to share one public IP.

**Memory Trick:** Dynamic NAT = Temporary One-to-One Mapping from a Public Pool.

---

## 8. PAT — Port Address Translation (NAT Overload)

**PAT = Port Address Translation.**

PAT is also called NAT Overload.

**Definition:** PAT allows multiple internal private IP addresses to share one public IP address by using different source port numbers to identify connections.

### Banking Example

Imagine a bank has 200 employees, but only one public IP address for internet access.

Can all 200 computers access the internet?

**Yes — Using PAT.**

Why?

Because PAT uses different port numbers to distinguish connections.

### How Does PAT Work?

Suppose three bank computers access the same external website.

| Computer | Private IP | Source Port |
|---|---|---:|
| Treasury PC | 192.168.10.100 | 49152 |
| Remittance PC | 192.168.10.101 | 49152 |
| Trade PC | 192.168.10.102 | 49152 |

The router translates them using one public IP:

`198.51.100.2`

It assigns different translated source ports.

| Inside Local | Inside Global (PAT) |
|---|---|
| 192.168.10.100:49152 | 198.51.100.2:40001 |
| 192.168.10.101:49152 | 198.51.100.2:40002 |
| 192.168.10.102:49152 | 198.51.100.2:40003 |

### PAT Translation Table

| Protocol | Inside Global | Inside Local | Outside Global |
|---|---|---|---|
| TCP | 198.51.100.2:40001 | 192.168.10.100:49152 | 93.184.216.34:443 |
| TCP | 198.51.100.2:40002 | 192.168.10.101:49152 | 93.184.216.34:443 |
| TCP | 198.51.100.2:40003 | 192.168.10.102:49152 | 93.184.216.34:443 |

Notice:
- Public IP remains the same.
- Translated port numbers are different.
- Inside Local IP addresses are different.

This is how PAT distinguishes multiple connections.

### Advantages of PAT

1. Saves public IPv4 addresses.
2. Many internal computers can share one public IP.
3. Commonly used in homes, offices and enterprises.
4. Makes internet access more economical.

### Disadvantages

1. Requires translation table management.
2. Some applications may need special NAT traversal support.
3. Inbound connections require suitable port forwarding or static NAT/PAT configuration.
4. Port and translation resource limits still exist.

**Memory Trick:** PAT = Many Private IPs + One Public IP + Different Ports.

---

## 9. Static NAT vs Dynamic NAT vs PAT

| Feature | Static NAT | Dynamic NAT | PAT |
|---|---|---|---|
| Full Name | Static NAT | Dynamic NAT | Port Address Translation |
| Mapping | One-to-One | One-to-One | Many-to-One |
| Public IP | Fixed | From a pool | Usually one shared IP |
| Port Translation | Not normally needed | Not normally needed | Yes |
| Mapping Duration | Permanent | Temporary | Dynamic |
| Public IP Requirement | One per mapped device | Pool of public IPs | Can share one public IP |
| Common Use | Public servers | Temporary public mapping | Employee internet access |

### Banking Example

| Device | Private IP | NAT Method | Public IP |
|---|---|---|---|
| Public Web Server | 192.168.10.10 | Static NAT | 203.0.113.10 |
| Temporary User 1 | 192.168.10.100 | Dynamic NAT | 203.0.113.11 |
| Temporary User 2 | 192.168.10.101 | Dynamic NAT | 203.0.113.12 |
| Treasury PC | 192.168.10.110 | PAT | 198.51.100.2 |
| Remittance PC | 192.168.10.120 | PAT | 198.51.100.2 |

**Note:** These are separate NAT examples, not one combined configuration.

### At-a-Glance Memory Trick

- Static NAT = One Private → One Fixed Public.
- Dynamic NAT = One Private → One Available Public from Pool.
- PAT = Many Private → One Shared Public using Different Ports.

---

## 10. How NAT Works — Packet Flow Step by Step

Understanding packet flow is more important than memorizing commands.

Example:
- Treasury PC = `192.168.10.100`
- NAT Router Public IP = `198.51.100.2`
- Website Server = `93.184.216.34`
- Website Port = `443` (HTTPS)

### A. Outgoing Packet Flow

The Treasury computer wants to access an external website.

**Step 1: PC Creates a Packet**

Before NAT:

| Field | Value |
|---|---|
| Source IP | 192.168.10.100 |
| Source Port | 49152 |
| Destination IP | 93.184.216.34 |
| Destination Port | 443 |

**Step 2: Packet Reaches the NAT Router**

The PC sends the packet to its default gateway.

`192.168.10.1`

The router checks the NAT configuration and finds that the packet matches the translation rule.

**Step 3: NAT Translates the Source Address**

The router changes:

`192.168.10.100:49152`

Into:

`198.51.100.2:40001`

**Step 4: Packet Goes to the Internet**

After PAT:

| Field | Before NAT | After NAT |
|---|---|---|
| Source IP | 192.168.10.100 | 198.51.100.2 |
| Source Port | 49152 | 40001 |
| Destination IP | 93.184.216.34 | 93.184.216.34 |
| Destination Port | 443 | 443 |

The external website sees the public IP address.

**Step 5: Return Packet Arrives**

The website replies to:

`198.51.100.2:40001`

The NAT router checks its translation table.

**Step 6: Reverse Translation**

The router translates the destination back:

`198.51.100.2:40001`

Into:

`192.168.10.100:49152`

The original Treasury computer receives the reply.

### Complete PAT Packet Flow

```text
     TREASURY PC
192.168.10.100:49152
          |
          v
      NAT ROUTER
          |
          | Source Translation
          v
  198.51.100.2:40001
          |
          v
    INTERNET WEBSITE
    93.184.216.34:443
          |
          | Reply
          v
      NAT ROUTER
          |
          | Reverse Translation
          v
     TREASURY PC
192.168.10.100:49152
```

**Remember:**
- Outgoing = Source Translation.
- Return = Reverse Translation.

### B. Incoming Packet Flow — Static NAT

Suppose an external user wants to access the bank's public web server.

- Public IP = `203.0.113.10`
- Private Server IP = `192.168.10.10`
- Service = HTTPS, TCP 443.

Process:

1. External user sends a request to `203.0.113.10:443`.
2. NAT router receives the packet.
3. Router checks the Static NAT mapping.
4. Destination IP changes to `192.168.10.10`.
5. Packet reaches the internal web server.
6. Server replies.
7. Router translates the source back to `203.0.113.10`.

**Important:** Static NAT makes the mapping available, but an appropriate firewall policy must also permit the incoming connection.

---

## 11. Cisco NAT Configuration — Practical CCNA Commands

### A. Common Router Configuration

**Lab Topology:**

| Device | Interface | IP Address |
|---|---|---|
| R1 | G0/0 Inside | 192.168.10.1/24 |
| R1 | G0/1 Outside | 198.51.100.2/24 |
| ISP Router | Connected Interface | 198.51.100.1/24 |
| Treasury PC | NIC | 192.168.10.100/24 |
| Web Server | NIC | 192.168.10.10/24 |

For the public NAT pool examples, we will use:

`203.0.113.8/29`

- Network = `203.0.113.8`
- Usable Public IPs = `.9 – .14`
- Broadcast = `.15`

These are documentation-only IP addresses.

### Common Router Configuration

```cisco
enable
configure terminal
hostname R1

interface gigabitEthernet 0/0
ip address 192.168.10.1 255.255.255.0
ip nat inside
no shutdown
exit

interface gigabitEthernet 0/1
ip address 198.51.100.2 255.255.255.0
ip nat outside
no shutdown
exit

ip route 0.0.0.0 0.0.0.0 198.51.100.1

end
write memory
```

### Explanation of Important Commands

| Command | Meaning |
|---|---|
| `ip nat inside` | Identifies the internal-facing interface |
| `ip nat outside` | Identifies the external-facing interface |
| `ip route 0.0.0.0 0.0.0.0 ...` | Configures the default route toward ISP |
| `no shutdown` | Enables the interface |

**Important:** Check your router's actual interface names. Some models use G0/0/0 instead of G0/0.

### B. Static NAT Configuration

**Requirement:** Map the internal web server to a fixed public IP.

| Private IP | Public IP |
|---|---|
| 192.168.10.10 | 203.0.113.10 |

**Cisco IOS Commands:**

```cisco
configure terminal

ip nat inside source static 192.168.10.10 203.0.113.10

end
write memory
```

**Command Explanation:**

`ip nat inside source static`

Creates a permanent translation for an internal source address.

`192.168.10.10` = Inside Local (Private IP).

`203.0.113.10` = Inside Global (Public IP).

**Important ISP Requirement:** The ISP must route `203.0.113.8/29` toward R1's outside address `198.51.100.2`.

Example ISP route:

```cisco
ip route 203.0.113.8 255.255.255.248 198.51.100.2
```

A real deployment also needs appropriate firewall permission for the published service.

### C. Dynamic NAT Configuration

**Requirement:** Translate internal computers using a public IP pool.

Public Pool:

`203.0.113.10 – 203.0.113.14`

**Step 1: Create an ACL**

```cisco
access-list 1 permit 192.168.10.0 0.0.0.255
```

This identifies the internal source addresses eligible for NAT.

**Step 2: Create a Public IP Pool**

```cisco
ip nat pool BANK-PUBLIC 203.0.113.10 203.0.113.14 netmask 255.255.255.248
```

This defines five available public IP addresses.

**Step 3: Connect ACL to the NAT Pool**

```cisco
ip nat inside source list 1 pool BANK-PUBLIC
```

### Complete Dynamic NAT Configuration

```cisco
configure terminal

access-list 1 permit 192.168.10.0 0.0.0.255

ip nat pool BANK-PUBLIC 203.0.113.10 203.0.113.14 netmask 255.255.255.248

ip nat inside source list 1 pool BANK-PUBLIC

end
write memory
```

**Important:** The ISP must route the public pool to R1. This configuration is an alternative to the Static NAT example, not an instruction to use the same public IP simultaneously in both configurations.

**What if all five public IPs are occupied?**

New inside hosts cannot get a dynamic one-to-one translation until an address becomes available.

### D. PAT Configuration (NAT Overload)

**Requirement:** Allow multiple internal computers to share the router's outside interface IP address.

Public IP:

`198.51.100.2`

**Step 1: Create an ACL**

```cisco
access-list 1 permit 192.168.10.0 0.0.0.255
```

**Step 2: Configure PAT**

```cisco
ip nat inside source list 1 interface gigabitEthernet 0/1 overload
```

### Complete PAT Configuration

```cisco
configure terminal

access-list 1 permit 192.168.10.0 0.0.0.255

ip nat inside source list 1 interface gigabitEthernet 0/1 overload

end
write memory
```

### Understand the Command

| Command Part | Meaning |
|---|---|
| `ip nat inside source` | Translates internal source addresses |
| `list 1` | Uses ACL 1 to identify eligible devices |
| `interface gigabitEthernet 0/1` | Uses outside interface IP |
| `overload` | Allows multiple devices to share that public IP using ports |

**Golden Rule:** `overload` = PAT.

Without `overload`, the command does not specify PAT.

**Important Configuration Note:** Static NAT, Dynamic NAT and PAT are alternative NAT designs in these examples. Practice them separately, clearing or replacing previous NAT rules between labs. Do not blindly paste all three configurations together.

---

## 12. NAT Verification — Cisco IOS Commands

After configuring NAT, how do we know it is working?

### Command 1: Check NAT Translation Table

```cisco
show ip nat translations
```

Displays:
- Inside Local addresses.
- Inside Global addresses.
- Outside Local addresses.
- Outside Global addresses.
- Protocol and port information when applicable.

### Command 2: Check NAT Statistics

```cisco
show ip nat statistics
```

Displays:
- Total active translations.
- Static translations.
- Dynamic translations.
- NAT inside and outside interfaces.
- Pool statistics.

### Command 3: Check ACL

```cisco
show access-lists
```

Checks whether the ACL matches the intended internal IP addresses.

### Command 4: Check Interfaces

```cisco
show ip interface brief
```

Checks whether NAT inside and outside interfaces are operational.

### Command 5: Check Routing

```cisco
show ip route
```

Checks whether the router has a valid route toward the external network.

### Command 6: Debug NAT

```cisco
debug ip nat
```

Displays NAT translation activity.

**Warning:** Debugging can generate a large amount of output. Use it carefully, especially on production routers.

### Example NAT Translation Table

```text
Pro  Inside global          Inside local
tcp  198.51.100.2:40001     192.168.10.100:49152
tcp  198.51.100.2:40002     192.168.10.101:49152
```

This shows two internal computers sharing one public IP through different translated ports.

**Important:**
- Dynamic NAT and PAT translations normally appear after matching traffic is generated.
- Static NAT mappings can appear even before traffic is sent.

---

## 13. NAT Troubleshooting — Common Problems

Imagine a Treasury employee reports:

"I cannot access the internet."

The network administrator should investigate:

| Problem | Possible Cause | Solution |
|---|---|---|
| No NAT translation | ACL does not match source IP | Check ACL |
| NAT not working | Missing `ip nat inside` | Configure inside interface |
| NAT not working | Missing `ip nat outside` | Configure outside interface |
| No internet access | Missing default route | Configure default route |
| Dynamic NAT fails | Public pool exhausted | Add available public IPs |
| Wrong translation | Incorrect NAT mapping | Check NAT configuration |
| Static NAT inaccessible externally | ISP route or firewall issue | Check public routing and security rules |
| PC cannot communicate | Incorrect default gateway | Check PC IP configuration |
| Interface down | Interface shutdown | Use `no shutdown` |
| PAT not working | Missing `overload` | Add overload to NAT command |

### Important Troubleshooting Scenario

**Scenario:** Three computers have private IP addresses, but none can access the internet.

Check in this order:

1. Check PC IP configuration.
2. Check default gateway.
3. Check router interface status.
4. Check `ip nat inside` and `ip nat outside`.
5. Check ACL configuration.
6. Check NAT translation table.
7. Check default route.
8. Check ISP connectivity.

**Remember:** NAT needs correct interfaces, matching traffic, valid translations and working routing.

---

## 14. How DHCP, DNS and NAT Work Together

Imagine a new Treasury employee turns on their computer.

```text
          TREASURY COMPUTER
             192.168.10.100
                    |
                    v
                DHCP SERVER
                    |
                    | Provides:
                    | IP Address
                    | Subnet Mask
                    | Gateway
                    | DNS Server
                    |
                    v
                 DNS SERVER
                    |
                    | Resolves Domain Name
                    | into IP Address
                    |
                    v
                NAT ROUTER
                    |
                    | Translates Private
                    | Source IP to Public IP
                    |
                    v
                  INTERNET
                    |
                    v
              EXTERNAL SERVER
```

### Three Services at a Glance

| Service | Main Responsibility | Memory |
|---|---|---|
| DHCP | Assigns network configuration | Gives IP |
| DNS | Resolves domain names | Finds IP |
| NAT | Translates IP addresses | Changes IP |

**Golden Example:**

- DHCP tells the computer: "Your IP is 192.168.10.100."
- DNS tells the computer: "The website is at 93.184.216.34."
- NAT tells the external network: "This connection comes from 198.51.100.2."

**Note:** NAT translates packet addresses; it does not resolve website names. DNS resolution can happen before or independently of NAT translation.

---

## 15. Common CCNA Exam Traps

1. Static NAT = Permanent one-to-one mapping.
2. Dynamic NAT = Temporary one-to-one mapping using a public pool.
3. PAT = Many-to-one mapping using port numbers.
4. NAT is not the same as PAT.
5. `overload` is the keyword used for PAT in the Cisco IOS example.
6. `ip nat inside` identifies the internal-facing interface.
7. `ip nat outside` identifies the external-facing interface.
8. Inside Local = Private IP of internal host.
9. Inside Global = Public representation of internal host.
10. Outside Global = Actual public IP of external host.
11. NAT does not automatically provide firewall security.
12. Dynamic NAT can fail when the public pool is exhausted.
13. PAT allows many computers to share one public IP.
14. Static NAT is commonly used for servers requiring fixed public mappings.
15. NAT requires appropriate routing and matching traffic.

---

## 16. One-Minute NAT Revision Sheet

### NAT Cheat Sheet

| Topic | Remember |
|---|---|
| Full Form | Network Address Translation |
| Purpose | Translate IP addresses between networks |
| Static NAT | 1 Private ↔ 1 Fixed Public |
| Dynamic NAT | 1 Private ↔ 1 Public from Pool |
| PAT | Many Private → 1 Public using Ports |
| Inside Local | Internal Private IP |
| Inside Global | Public Representation of Internal IP |
| Outside Local | External IP as Seen Inside |
| Outside Global | Actual External IP |

### Important Cisco Commands

```cisco
ip nat inside
ip nat outside
ip nat inside source static
ip nat pool
ip nat inside source list 1 pool BANK-PUBLIC
ip nat inside source list 1 interface g0/1 overload
show ip nat translations
show ip nat statistics
show access-lists
show ip route
show ip interface brief
debug ip nat
```

### Golden Memory Trick

- Static = Fixed.
- Dynamic = Pool.
- PAT = Ports.
- Inside Local = Private.
- Inside Global = Public representation.
- `overload` = PAT.

---

## 17. CCNA Practice Questions

### Basic Questions

1. What is the full form of NAT?
2. Why is NAT required in IPv4 networks?
3. What is the difference between Private IP and Public IP?
4. What are the three main types of NAT?
5. What is PAT?

### Understanding Questions

6. Explain Static NAT with a banking example.
7. Explain Dynamic NAT with a public IP pool.
8. Why does Dynamic NAT fail when the public IP pool is exhausted?
9. How can multiple computers share one public IP using PAT?
10. Why does PAT use port numbers?
11. What is the difference between Inside Local and Inside Global?
12. What is the difference between Outside Local and Outside Global?
13. Is NAT a firewall? Explain.

### Practical Questions

14. Configure Static NAT for a server with private IP `192.168.10.10` and public IP `203.0.113.10`.
15. Configure Dynamic NAT using public pool `203.0.113.10–203.0.113.14`.
16. Configure PAT using the router's outside interface.
17. Which command displays active NAT translations?
18. Which command displays NAT statistics?
19. What happens if `ip nat inside` is missing?
20. A bank has 100 computers but only one public IP. Which NAT method is most suitable and why?

---

## 18. Final Learning Checklist

- [ ] Understand NAT and its purpose.
- [ ] Understand private and public IPv4 addresses.
- [ ] Understand Static NAT.
- [ ] Understand Dynamic NAT.
- [ ] Understand PAT / NAT Overload.
- [ ] Memorize the four NAT terminology definitions.
- [ ] Understand outgoing and incoming packet flow.
- [ ] Read a NAT translation table.
- [ ] Configure Static NAT in Cisco IOS.
- [ ] Configure Dynamic NAT in Cisco IOS.
- [ ] Configure PAT in Cisco IOS.
- [ ] Verify NAT using Cisco show commands.
- [ ] Troubleshoot common NAT failures.

### Final Learning Goal

Understand not only how NAT translates addresses, but also why each NAT method is selected and how to configure and troubleshoot it in a real Cisco network.

---

## Recommended Next Practical Lesson

**NAT Configuration in Cisco Packet Tracer**

We will build a bank network with:
- Treasury, Remittance and Trade computers.
- A Cisco router as the NAT gateway.
- An ISP router.
- An external web server.

We will configure and test Static NAT, Dynamic NAT and PAT separately, observe translation tables, and verify how internal devices communicate with external networks.
