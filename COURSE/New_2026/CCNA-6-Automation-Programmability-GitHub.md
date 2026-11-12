# CCNA 200-301: Domain 6.0 Automation and Programmability (10%)

All IPs come from documentation ranges (192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24). Replace every `<PLACEHOLDER>` with your own secret. Product names and syntax change between versions, so check your platform's documentation.

---

## Table of Contents (Clickable GitHub Menu)

- [6.1 How Automation Impacts Network Management](#61-how-automation-impacts-network-management)
  - [Technical explanation](#technical-explanation)
  - [Banking example](#banking-example)
  - [IOS commands](#ios-commands)
  - [Analogy](#analogy)
  - [Troubleshooting](#troubleshooting)
- [6.2 Traditional Networks vs Controller-Based Networking](#62-traditional-networks-vs-controller-based-networking)
  - [Technical explanation](#technical-explanation-1)
  - [Banking example](#banking-example-1)
  - [IOS commands](#ios-commands-1)
  - [Analogy](#analogy-1)
  - [Troubleshooting](#troubleshooting-1)
- [6.3 Controller-Based, Software-Defined Architecture (Overlay, Underlay, Fabric)](#63-controller-based-software-defined-architecture-overlay-underlay-fabric)
  - [Technical explanation](#technical-explanation-2)
  - [6.3.a Separation of control plane and data plane](#63a-separation-of-control-plane-and-data-plane)
  - [6.3.b Northbound and southbound APIs](#63b-northbound-and-southbound-apis)
  - [Banking example](#banking-example-2)
  - [IOS commands](#ios-commands-2)
  - [Analogy](#analogy-2)
  - [Troubleshooting](#troubleshooting-2)
- [6.4 AI (Generative and Predictive) and Machine Learning in Network Operations](#64-ai-generative-and-predictive-and-machine-learning-in-network-operations)
  - [Technical explanation](#technical-explanation-3)
  - [Banking example](#banking-example-3)
  - [IOS commands](#ios-commands-3)
  - [Analogy](#analogy-3)
  - [Troubleshooting](#troubleshooting-3)
- [6.5 REST-Based APIs (Authentication, CRUD, HTTP Verbs, Data Encoding)](#65-rest-based-apis-authentication-crud-http-verbs-data-encoding)
  - [Technical explanation](#technical-explanation-4)
  - [Banking example](#banking-example-4)
  - [IOS commands](#ios-commands-4)
  - [Analogy](#analogy-4)
  - [Troubleshooting](#troubleshooting-4)
- [6.6 Configuration Management: Ansible and Terraform (plus Puppet and Chef)](#66-configuration-management-ansible-and-terraform-plus-puppet-and-chef)
  - [Technical explanation](#technical-explanation-5)
  - [Configuration examples](#configuration-examples)
  - [Banking example](#banking-example-5)
  - [IOS commands](#ios-commands-5)
  - [Analogy](#analogy-5)
  - [Troubleshooting](#troubleshooting-5)
- [6.7 Components of JSON-Encoded Data](#67-components-of-json-encoded-data)
  - [Technical explanation](#technical-explanation-6)
  - [Banking example](#banking-example-6)
  - [IOS commands](#ios-commands-6)
  - [Analogy](#analogy-6)
  - [Troubleshooting](#troubleshooting-6)
- [Exam tips](#exam-tips)
- [References](#references)

---
## 6.1 How Automation Impacts Network Management

### Technical explanation

Automation replaces manual, device-by-device CLI work with repeatable, code-driven workflows.

| Impact | What it means |
|---|---|
| **Consistency** | The same template is pushed everywhere, which reduces **configuration drift** |
| **Speed and scale** | Hundreds of devices changed in minutes |
| **Fewer human errors** | Typos and missed steps largely disappear |
| **Compliance and audit** | Desired state is stored as code, so deviations are detectable |
| **Faster troubleshooting** | Telemetry and scripts gather data automatically |
| **Version control** | Changes live in **Git** with history, review, and rollback |
| **Idempotency** | Running the same automation twice leaves the same result and makes no extra changes |

**Risk:** a bad template or script is also applied at scale, so test in a lab and stage the rollout. Keep a **source of truth** (inventory, IP plan, variables) and make humans review changes.

**Automation mechanisms on the device (IOS):**
- **EEM applets** react to events such as syslog messages.
- **Config archive and rollback** restore a known-good config.
- **Guest shell and Python** on IOS XE run scripts on the device.
- **Model-driven programmability** (NETCONF/RESTCONF with YANG) provides structured APIs.

### Banking example

A bank has 120 branch routers and must change the NTP and syslog servers before an audit. Manually that is 120 SSH sessions with typo risk. With a tested playbook, the change is pushed to a pilot of 5 branches, verified, then applied to the rest, with a report showing which devices differ from policy.

### IOS commands

```
! ---- Config archive and rollback ----
archive
 path flash:archive/BR-RTR1
 maximum 10
 write-memory                      ! archive on each "write memory"
show archive
show archive config differences flash:archive/BR-RTR1-1 system:running-config
configure replace flash:archive/BR-RTR1-1 list    ! preview
configure replace flash:archive/BR-RTR1-1 force

! ---- EEM applet (on-box automation) ----
event manager applet WAN-DOWN
 event syslog pattern "Interface GigabitEthernet0/1, changed state to down"
 action 1.0 syslog msg "WAN uplink down - check failover"
show event manager policy registered
```

### Analogy

Manual CLI is a **teller writing every transaction by hand**. Automation is the **core-banking batch job**: the same instruction is applied to every account, with logs and the ability to reverse a bad batch.

### Troubleshooting

- **Automation changed something unexpected:** review the diff or `--check` output first, then roll back with `configure replace`.
- **Config drift:** compare running config to the template and re-run the automation.
- **Script works in the lab but fails in production:** different OS version, platform, or credentials.
- **Everything broke at once:** the change was pushed to all devices without a pilot group.

---

## 6.2 Traditional Networks vs Controller-Based Networking

### Technical explanation

| | **Traditional** | **Controller-based** |
|---|---|---|
| Control plane | **Distributed** (every device runs OSPF, STP, etc.) | **Centralized** (the controller computes policy and paths) |
| Configuration | CLI, device by device | Central GUI or API, policy pushed to devices |
| Management | SSH, SNMP, syslog | Northbound and southbound **APIs** |
| Policy | Per-device ACLs and QoS | **Intent-based**: describe the outcome and the controller applies it |
| Consistency | Depends on the engineer | Template-driven |
| Visibility | Per-device tools | Single pane of glass, **assurance** and analytics |
| Failure of the manager | No central dependency | If the controller fails, devices **keep forwarding** with their last-known config, but you lose central changes and analytics |

**Three planes:**
- **Data plane:** forwards frames and packets (the FIB, ASICs).
- **Control plane:** builds the forwarding tables (routing protocols, STP, ARP).
- **Management plane:** how admins reach the device (SSH, SNMP, NETCONF).

**Cisco controllers (exam context):**

| Product | Domain |
|---|---|
| **Cisco Catalyst Center** (formerly **DNA Center**) | Campus LAN/WLAN, SD-Access, automation, assurance |
| **Cisco SD-WAN** (Catalyst SD-WAN Manager, formerly vManage) | WAN |
| **Cisco ACI (APIC)** | Data center |
| **Cisco Meraki Dashboard** | Cloud-managed networks |
| **Wireless LAN controller** | Wireless (CAPWAP) |

**Catalyst Center workflow:** **Design** (sites, IP pools) → **Policy** → **Provision** → **Assurance**.

### Banking example

A bank opens 20 new branches a year. In a traditional design, engineers hand-configure each switch, VLAN, ACL, and QoS policy. With a controller, the branch is defined once as a **template and policy**, new switches are discovered and provisioned automatically, and **assurance** flags a degraded WAN link before customers complain.

### IOS commands

Device preparation so a controller can discover and manage a switch or router:

```
username admin privilege 15 secret <ADMIN-PASS>
ip domain name bank.example
crypto key generate rsa modulus 2048
ip ssh version 2
line vty 0 15
 login local
 transport input ssh
snmp-server community <SNMP-RO> ro
netconf-yang                        ! model-driven programmability (TCP 830)
ip http secure-server               ! for RESTCONF/HTTPS APIs
```

Verification:

```
show running-config | include netconf|snmp|ssh
show ip ssh
show netconf-yang sessions
```

### Analogy

Traditional networking is **every branch manager running the branch by their own rules**. Controller-based networking is **head office issuing one policy manual**, with each branch still operating its own doors (the data plane) day to day.

### Troubleshooting

- **Controller can't discover a device:** SSH/SNMP/NETCONF credentials wrong or missing, no IP reachability, or ACLs block management traffic.
- **Device shows "unmanaged":** credentials changed after discovery; update them in the controller.
- **Drift between controller and device:** a local CLI change bypassed the controller. Re-provision or make changes only through the controller.
- **Controller outage:** devices keep forwarding, so restore the controller and resume central management.

---

## 6.3 Controller-Based, Software-Defined Architecture (Overlay, Underlay, Fabric)

### Technical explanation

| Term | Meaning |
|---|---|
| **Underlay** | The physical network and its IP routing (switches, links, IGP such as **IS-IS** in SD-Access). It only needs to provide simple, resilient IP reachability |
| **Overlay** | Virtual network built **on top** of the underlay with tunnels (**VXLAN** in SD-Access). It carries user traffic, segmentation, and policy |
| **Fabric** | The combination of overlay and underlay, managed as one logical network |

**Cisco SD-Access fabric:**

| Plane | Technology |
|---|---|
| Control plane | **LISP** (maps endpoint identity to location) |
| Data plane | **VXLAN** |
| Policy plane | **Cisco TrustSec** (security group tags, SGT) |

**Fabric roles:**
- **Fabric edge:** connects endpoints.
- **Control plane node:** holds the LISP map-server/map-resolver database.
- **Border node:** connects the fabric to outside networks.
- **Intermediate node:** underlay transit only.

VXLAN adds about 50 bytes of overhead, so the **underlay MTU must be larger** (SD-Access commonly uses jumbo frames).

### 6.3.a Separation of control plane and data plane

- In a **traditional** switch or router, each device runs its own control plane and forwards its own traffic.
- In **SDN**, the **control plane (decision logic) is centralized** in a controller. The devices keep the **data plane**, which only forwards. The controller programs forwarding behavior, and **user traffic does not pass through the controller**.
- Pure SDN (for example **OpenFlow**) moves nearly all control to the controller. Cisco's implementations are usually **hybrid**, where devices still run protocols such as IS-IS or LISP and the controller handles policy and automation.

### 6.3.b Northbound and southbound APIs

```
   Apps / scripts / ITSM / portals
              |  Northbound API  (REST, HTTPS + JSON)
        +-----------------+
        |   Controller    |
        +-----------------+
              |  Southbound API  (NETCONF, RESTCONF, SSH/CLI, SNMP, gRPC/gNMI, OpenFlow, OpFlex)
        Routers / switches / APs
```

| | **Northbound** | **Southbound** |
|---|---|---|
| Direction | Controller **to applications** | Controller **to network devices** |
| Used by | Automation scripts, dashboards, orchestration | The controller itself |
| Typical protocols | **REST over HTTPS, JSON** | **NETCONF, RESTCONF, SSH, SNMP, OpenFlow, OpFlex** |

Mnemonic: northbound goes **up** to the applications, southbound goes **down** to the devices.

### Banking example

The bank's campus fabric keeps ATM-management, teller, and corporate Wi-Fi traffic in separate **virtual networks (VNs)**, with SGT-based policies (for example, "teller group may reach core-banking servers, guests may not") instead of hundreds of IP ACLs. The change-management portal calls the controller's **northbound REST API** to open a requested access policy, and the controller uses **southbound** protocols to push it to the devices.

### IOS commands

Verification is platform-dependent (examples from SD-Access-capable Catalyst switches):

```
show isis neighbors                 ! underlay adjacencies
show ip route                       ! underlay reachability
show lisp session                   ! LISP control-plane sessions
show cts role-based sgt-map all     ! SGT assignments
show cts role-based permissions     ! group-based policy matrix
show interfaces <int> | include MTU
show running-config | section netconf
```

### Analogy

- **Underlay** is the **road network** (physical roads).
- **Overlay** is the **armored-courier service** running on those roads, with its own routes and rules.
- **Fabric** is the **whole logistics company**: roads and couriers managed together.
- The **controller** is dispatch headquarters, and the **data plane** is the trucks. HQ plans and gives instructions, but the **cargo never goes through HQ**.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| Overlay works for small packets, large transfers fail | **Underlay MTU** too small for the VXLAN overhead |
| Endpoint can't reach other fabric hosts | Underlay adjacency or routing problem, or endpoint not registered with the control plane node |
| Policy not applied | SGT not assigned (authentication failure), or contract/policy not provisioned |
| Fabric edge loses connectivity to the control plane node | Underlay path or MTU issue |
| Controller unreachable | Existing forwarding continues, but provisioning and assurance stop |
| API call to the controller fails | Token expired, wrong URL, or missing permissions (see 6.5) |

---

## 6.4 AI (Generative and Predictive) and Machine Learning in Network Operations

### Technical explanation

| Term | Meaning | Network example |
|---|---|---|
| **Machine learning (ML)** | Algorithms that learn patterns from data instead of fixed rules | Baseline normal traffic, detect deviations |
| **Predictive AI** | ML models that analyze historical and live data to **forecast or classify** | Predict link saturation, device failure, or Wi-Fi performance problems; **anomaly detection** |
| **Generative AI** | Models (e.g. LLMs) that **create new content**: text, code, config | Draft a configuration from a plain-English request, summarize logs, answer troubleshooting questions |
| **Training data / telemetry** | Quality data feeds the model | Streaming telemetry, NetFlow, syslog, SNMP, wireless analytics |

**ML types:** **supervised** (labeled data), **unsupervised** (finds clusters or outliers without labels), **reinforcement** (learns by reward).

| | **Predictive AI** | **Generative AI** |
|---|---|---|
| Output | A prediction, score, or alert | New text, code, or config |
| Question answered | "What is likely to happen?" | "Create or explain this" |
| Main risk | False positives, poor data | **Hallucination** (confident wrong answers), data leakage |

**Operational guidance:**
- Treat AI output as a **suggestion**: review and test it before applying it to production (human in the loop).
- Keep **sensitive data** (customer data, passwords, internal topology) out of public AI tools.
- Good data is a prerequisite: better telemetry means better predictions.

### Banking example

- **Predictive:** the model learns that a branch WAN link saturates on salary days, so capacity is raised before the next month-end, and it flags **unusual traffic** from an ATM segment as a possible compromise.
- **Generative:** during an incident, an assistant summarizes thousands of syslog lines into a timeline and drafts a ticket update. An engineer reviews any suggested configuration in a lab before use, and the bank's policy forbids pasting customer data or credentials into external tools.

### IOS commands

AI does not run on the CLI, but the **data that feeds it** comes from the device:

```
! Streaming telemetry (model-driven)
telemetry ietf subscription 101
 encoding encode-kvgpb
 filter xpath /interfaces-ios-xe-oper:interfaces/interface/statistics
 source-address 10.255.0.1
 stream yang-push
 update-policy periodic 6000
 receiver ip address 192.0.2.90 57500 protocol grpc-tcp

show telemetry ietf subscription all
show flow monitor
show logging
```

Telemetry configuration varies by platform and version.

### Analogy

Predictive AI is a **weather forecaster** reading patterns to say a storm is coming. Generative AI is a **very fast junior writer** who drafts a report or a plan: useful, but a senior engineer must check every claim.

### Troubleshooting

- **Too many false alerts:** the baseline period is too short or unrepresentative; tune thresholds.
- **Predictions are poor:** missing or inconsistent data (wrong timestamps, so fix NTP from 4.2).
- **AI suggested a configuration that doesn't work:** check platform/version syntax and test in a lab (hallucination).
- **Data privacy concerns:** use approved internal tools and sanitize or avoid sensitive inputs.
- **Model drift:** network behavior changed (new application, new branch), so the model needs retraining.

---

## 6.5 REST-Based APIs (Authentication, CRUD, HTTP Verbs, Data Encoding)

### Technical explanation

**REST** (Representational State Transfer) is an architectural style for web APIs.

**Characteristics:**
- **Client-server** separation
- **Stateless**: each request carries everything the server needs
- **Cacheable** responses
- **Uniform interface**: resources identified by URIs and manipulated with standard HTTP methods
- **Layered** system
- Usually over **HTTPS (TCP 443)**

**CRUD to HTTP verb mapping (memorize):**

| CRUD | HTTP verb | Meaning |
|---|---|---|
| **Create** | **POST** | Create a new resource |
| **Read** | **GET** | Retrieve data |
| **Update** | **PUT** (replace) / **PATCH** (modify part) | Change an existing resource |
| **Delete** | **DELETE** | Remove a resource |

**URL anatomy:**

```
https://192.0.2.1/restconf/data/ietf-interfaces:interfaces?depth=2
 |        |               |                                  |
protocol  host       path (resource)                      query parameters
```

A request also has **headers** (`Content-Type`, `Accept`, `Authorization`) and a **body** (for POST/PUT/PATCH).

**Common status codes:**

| Code | Meaning |
|---|---|
| 200 | OK |
| 201 | Created |
| 204 | Success, no content |
| 400 | Bad request (malformed) |
| 401 | **Unauthorized** (not authenticated) |
| 403 | **Forbidden** (authenticated but not allowed) |
| 404 | Not found |
| 405 | Method not allowed |
| 415 | Unsupported media type |
| 429 | Too many requests |
| 500 / 503 | Server error / unavailable |

**Authentication types:**

| Type | How it works | Note |
|---|---|---|
| **Basic** | `Authorization: Basic <base64(user:pass)>` | Base64 is **encoding, not encryption**; use only over HTTPS |
| **Bearer token** | Authenticate once, then send `Authorization: Bearer <token>` | Tokens expire |
| **API key** | Key in a header or query string | Simple; protect it like a password |
| **OAuth 2.0** | Token issued by an authorization server with scopes | Delegated access, common for cloud APIs |
| **Session cookie / custom token** | Cisco Catalyst Center issues a token (sent as `X-Auth-Token`) | Typical vendor pattern |

**Data encoding:** **JSON** (most common), **XML**, and **YAML** (used mostly for configuration files and playbooks).

**Related model-driven protocols:**
- **YANG** describes the data model.
- **NETCONF** uses SSH (TCP 830) and XML.
- **RESTCONF** uses HTTPS and JSON/XML and maps REST verbs to YANG data.

### Banking example

The NOC dashboard asks the controller `GET /network-device` for the health of all branch routers using a bearer token. The service-desk system creates a temporary maintenance window using `POST`, and an automation job updates an interface description with `PATCH`. All calls use **HTTPS**, and tokens are short-lived and stored in a vault.

### IOS commands

Enable RESTCONF on an IOS XE device:

```
ip http secure-server
ip http authentication local
restconf
username apiuser privilege 15 secret <API-PASS>

show platform software yang-management process
show running-config | include restconf|http
```

Example requests:

```
# Read (GET)
curl -k -u apiuser:<API-PASS> \
  -H "Accept: application/yang-data+json" \
  https://192.0.2.1/restconf/data/ietf-interfaces:interfaces

# Catalyst Center: get a token, then call the API
curl -k -X POST -u admin:<PASS> https://192.0.2.100/dna/system/api/v1/auth/token
curl -k -H "X-Auth-Token: <TOKEN>" \
  https://192.0.2.100/dna/intent/api/v1/network-device
```

Python:

```python
import requests, urllib3
urllib3.disable_warnings()   # lab only; use valid certificates in production

url = "https://192.0.2.1/restconf/data/ietf-interfaces:interfaces/interface=GigabitEthernet1"
headers = {"Accept": "application/yang-data+json"}
r = requests.get(url, auth=("apiuser", "<API-PASS>"), headers=headers, verify=False)
print(r.status_code)
print(r.json())
```

### Analogy

A REST API is a **bank counter service window**:
- You say **what you want** (verb) and **which account** (URL).
- The clerk keeps **no memory** of your last visit (stateless), so you show your ID every time (authentication).
- **GET** = view a statement, **POST** = open an account, **PUT/PATCH** = update details, **DELETE** = close the account.
- JSON is the **standard paper form** both sides understand.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| **401** | Wrong or missing credentials, expired token |
| **403** | Account lacks permission (privilege level, role) |
| **404** | Wrong URL or resource path, or API not enabled |
| **405** | Verb not supported for that resource |
| **415 / 400** | Missing or wrong `Content-Type`, or malformed JSON body |
| Connection refused or timeout | `restconf`/HTTPS not enabled, ACL blocking TCP 443, routing |
| SSL certificate error | Self-signed certificate; install a trusted cert (don't leave `verify=False` in production) |
| Intermittent failures after some time | Token expired: request a new one |
| 429 | Rate limiting; slow down or batch requests |

---

## 6.6 Configuration Management: Ansible and Terraform (plus Puppet and Chef)

### Technical explanation

Configuration management tools define the **desired state** and enforce it consistently.

| Tool | Model | Agent? | Language | Transport/port | Main use |
|---|---|---|---|---|---|
| **Ansible** | **Push** | **Agentless** | **YAML** playbooks (Jinja2 templates) | SSH (22), NETCONF, or device APIs | Configure devices, orchestrate tasks |
| **Terraform** | Declarative **provisioning** | Agentless, uses provider APIs | **HCL** | HTTPS to provider APIs | **Infrastructure as Code**: cloud networks, VMs, controllers |
| **Puppet** | **Pull** | **Agent** | Puppet DSL (manifests) | TCP **8140** to the master | Server and device configuration |
| **Chef** | **Pull** | **Agent** | **Ruby** DSL (recipes/cookbooks) | HTTPS to the Chef server | Server and device configuration |

**Ansible concepts:**
- **Inventory:** the list of devices and groups.
- **Playbook:** ordered tasks written in YAML.
- **Module:** a unit of work (e.g. `cisco.ios.ios_config`).
- **Idempotent:** a module changes a device only if it differs from the desired state.
- **Variables** and **Jinja2 templates** generate per-device configs.

**Terraform concepts:**
- **Provider:** plugin for a platform (cloud, ACI, Meraki, etc.).
- **Resource:** the thing to create.
- **State file:** Terraform's record of what it manages.
- **Workflow:** `terraform init` → `plan` (preview) → `apply` (execute) → `destroy`.
- It is **declarative**: you describe the end state and Terraform works out the steps.

**Ansible vs Terraform in one line:** Ansible is mainly for **configuring** systems, and Terraform is mainly for **provisioning** infrastructure.

### Configuration examples

`inventory.ini`:

```
[branch_routers]
BR-RTR1 ansible_host=192.0.2.11
BR-RTR2 ansible_host=192.0.2.12

[branch_routers:vars]
ansible_connection=ansible.netcommon.network_cli
ansible_network_os=cisco.ios.ios
ansible_user=automation
ansible_become=yes
ansible_become_method=enable
```

`baseline.yml`:

```yaml
---
- name: Branch router baseline
  hosts: branch_routers
  gather_facts: false
  tasks:
    - name: Set NTP and syslog servers
      cisco.ios.ios_config:
        lines:
          - ntp server 192.0.2.1
          - logging host 192.0.2.60
          - logging trap warnings
        save_when: modified
```

Run it:

```
ansible-playbook -i inventory.ini baseline.yml --check --diff   # dry run
ansible-playbook -i inventory.ini baseline.yml
```

Terraform example (a cloud DR network):

```hcl
resource "aws_vpc" "dr_site" {
  cidr_block = "10.60.0.0/16"
  tags = { Name = "bank-dr-vpc" }
}
```

```
terraform init
terraform plan
terraform apply
```

Store passwords and keys in a vault or environment variables, not in playbooks or `.tf` files. Terraform state can contain secrets, so secure it.

### Banking example

- **Ansible** pushes the approved baseline (NTP, syslog, SSH, banner) to all branch routers and audits for drift weekly.
- **Terraform** builds the disaster-recovery environment in the cloud the same way each time, so the DR site can be rebuilt or torn down from code after a test.

### IOS commands

Device-side checks before and after automation:

```
show running-config | include ntp|logging
show ip ssh
show archive config differences
show netconf-yang sessions
show clock
```

### Analogy

- **Ansible** is a **checklist inspector who visits each branch** (push, no resident staff).
- **Puppet and Chef** are **a resident compliance officer at each branch** who periodically checks with head office (agent, pull).
- **Terraform** is the **architect's blueprint**: describe the building once, and it can be built, changed, or demolished to match the plan.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| Ansible "unreachable" | SSH not enabled, wrong IP, credentials, or ACL |
| "Command not found" or auth errors on the device | Wrong `ansible_network_os` or connection type, missing `become` (enable) |
| YAML parse error | **Indentation** (use spaces, not tabs) or a missing colon |
| Task always shows "changed" | Config lines don't match how the device normalizes them (not idempotent as written) |
| `terraform plan` shows unexpected destroy | State drift or a changed resource name; review before `apply` |
| State lock error | Another run in progress, or a stale lock |
| Credentials leaked in Git | Move secrets to a vault, rotate them, and clean the history |
| Puppet/Chef agent not reporting | Agent/master connectivity (TCP 8140 for Puppet), certificate trust, time skew |

---

## 6.7 Components of JSON-Encoded Data

### Technical explanation

**JSON** (JavaScript Object Notation) is lightweight, human-readable, and the usual data format for APIs.

| Component | Syntax | Example |
|---|---|---|
| **Object** | `{ }` containing key/value pairs | `{ "name": "Gi1" }` |
| **Key** | A string in **double quotes** | `"name"` |
| **Value** | String, number, boolean, null, object, or array | |
| **Array** | `[ ]`, an ordered list of values | `["10", "20"]` |
| **String** | Double quotes | `"WAN to HQ"` |
| **Number** | No quotes | `1500` |
| **Boolean** | `true` or `false` (lowercase, no quotes) | `true` |
| **Null** | `null` | `null` |

**Syntax rules (exam favorites):**
- Keys and string values use **double quotes**, never single quotes.
- Pairs are separated by **commas**, and keys from values by a **colon**.
- **No trailing comma** after the last item.
- **No comments** are allowed.
- Names are **case-sensitive**.
- Objects and arrays can be **nested**.

**Example (IOS XE RESTCONF-style interface data):**

```json
{
  "ietf-interfaces:interface": {
    "name": "GigabitEthernet1",
    "description": "WAN to Head Office",
    "type": "iana-if-type:ethernetCsmacd",
    "enabled": true,
    "ietf-ip:ipv4": {
      "address": [
        { "ip": "203.0.113.2", "netmask": "255.255.255.252" }
      ]
    }
  }
}
```

**Reading it:**
- The top level is an **object** with one key.
- `"enabled": true` is a **boolean**.
- `"address"` is an **array** containing one object.
- The IP is reached by going through the interface object, then `ipv4`, then `address`, then item 0, then `ip`. In Python this is `data["ietf-interfaces:interface"]["ietf-ip:ipv4"]["address"][0]["ip"]` and returns `"203.0.113.2"`.

**Comparison:**

| | **JSON** | **XML** | **YAML** |
|---|---|---|---|
| Structure | Braces and brackets | Tags | Indentation |
| Readability | Good | Verbose | Best |
| Comments | No | Yes | Yes |
| Typical use | REST APIs | NETCONF, legacy | Ansible, config files |

### Banking example

A monitoring API returns the health of an ATM branch router as JSON: device name, an array of interfaces, and a boolean for link status. An automation script reads `"enabled": false` on the WAN interface and raises a ticket.

### IOS commands

JSON is validated off the device, but you can retrieve it from one:

```
# Pretty-print / validate on your workstation
python -m json.tool interface.json
cat interface.json | jq '.["ietf-interfaces:interface"].name'

# Pull JSON from a device
curl -k -u apiuser:<API-PASS> -H "Accept: application/yang-data+json" \
  https://192.0.2.1/restconf/data/ietf-interfaces:interfaces
```

On the device:

```
show running-config | section restconf
show platform software yang-management process
```

### Analogy

JSON is a **structured account-opening form**: `{ }` is the form, each label (key) has a filled-in answer (value), and `[ ]` is the "list of joint holders". One missing quote or comma and the clerk rejects the whole form.

### Troubleshooting

| Symptom | Likely cause |
|---|---|
| "Expecting property name" or parse error | **Trailing comma**, missing comma, or unquoted key |
| Single quotes rejected | JSON requires double quotes |
| `True`/`False` rejected | Booleans must be lowercase (`true`/`false`) |
| Script gets a `KeyError` | Wrong key name or case, or the data is nested deeper than expected |
| Index error on an array | Empty array or wrong index (arrays start at 0) |
| 400/415 from an API | Invalid JSON body or missing `Content-Type: application/json` |
| Comments in the file break parsing | JSON does not support comments |

---

## Exam tips

- **Automation** gives consistency, speed, and fewer errors, but a bad change also spreads fast.
- **Traditional = distributed control plane. SDN/controller-based = centralized control plane**, while the **data plane stays on the devices**.
- **Northbound API** connects the controller to apps (REST/JSON). **Southbound API** connects the controller to devices (NETCONF, RESTCONF, SSH, SNMP, OpenFlow).
- **Underlay** = physical IP network. **Overlay** = virtual tunnels (VXLAN). **Fabric** = both together. SD-Access: **LISP** (control), **VXLAN** (data), **TrustSec** (policy).
- **CRUD:** Create = **POST**, Read = **GET**, Update = **PUT/PATCH**, Delete = **DELETE**.
- **401** = not authenticated, **403** = not allowed, **404** = not found.
- **Basic auth is encoded, not encrypted.** REST is **stateless** and usually runs over HTTPS.
- **Ansible** = push, agentless, YAML. **Puppet and Chef** = pull, agent-based (Puppet DSL, Ruby). **Terraform** = declarative, HCL, provisioning, with a state file.
- **Predictive AI** forecasts, **generative AI** creates content, and generative output must be reviewed.
- **JSON:** objects `{}`, arrays `[]`, double-quoted keys, no trailing commas, no comments.

---

## References

I haven't live-checked links, so search these titles on the named sites.

1. Cisco, **CCNA 200-301 Exam Topics** (Domain 6.0 Automation and Programmability), Cisco Learning Network / cisco.com.
2. Wendell Odom, **CCNA 200-301 Official Cert Guide, Vol. 2**, Cisco Press (SDN, controller-based networking, REST, JSON, Ansible/Terraform chapters).
3. Cisco, **Catalyst Center (formerly DNA Center) User and Developer Guides**, and the **Cisco SD-Access Design/Deployment Guides**.
4. Cisco, **Programmability Configuration Guide** (NETCONF, RESTCONF, YANG, model-driven telemetry), IOS XE documentation.
5. Cisco **DevNet** (developer.cisco.com): CCNA Automation learning labs and API references.
6. **RFC 7426**, *Software-Defined Networking: Layers and Architecture Terminology*.
7. **RFC 8040**, *RESTCONF Protocol*; **RFC 6241**, *NETCONF*; **RFC 7950**, *YANG 1.1*.
8. **RFC 8259**, *The JSON Data Interchange Format*.
9. **RFC 9110**, *HTTP Semantics*; **RFC 7617**, *HTTP Basic Authentication*; **RFC 6749** and **RFC 6750**, *OAuth 2.0* and *Bearer Token Usage*.
10. Roy Fielding, *Architectural Styles and the Design of Network-based Software Architectures* (doctoral dissertation, 2000), the origin of REST.
11. **RFC 7348**, *VXLAN*; **RFC 9300**, *The Locator/ID Separation Protocol (LISP)*.
12. Ansible documentation (docs.ansible.com), including the **cisco.ios** collection; HashiCorp **Terraform** documentation (developer.hashicorp.com/terraform).
13. Puppet and Chef official documentation (for the agent-based, pull comparison).
14. **NIST AI Risk Management Framework (AI RMF 1.0, NIST AI 100-1)**, for responsible use of AI in operations.
15. Cisco, **IOS XE Command Reference** (`archive`, `configure replace`, `event manager`, `restconf`, `netconf-yang`, `telemetry`).

That completes Domains 3 to 6. I can add Domains 1.0 and 2.0 in the same style, or turn the full set into a Word/PDF study sheet or a mixed practice quiz.