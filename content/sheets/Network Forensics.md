---
title: "Network Forensics"
date: 2022-12-29
tags:
- sheet
---

Topic:: [[Blue Team]] | 

---

A specific subdomain of the Forensics domain, and it focuses on network traffic investigation. Network Forensics discipline covers the work done to access information transmitted by listening and investigating live and recorded traffic, gathering evidence/artefacts and understanding potential problems.

The investigation tries to answer the 5W:
- Who *(src ip & port)*
- What *(data/payload)*
- Where *(dst ip & port)*
- When *(time & data)*
- Why *(how/what happened)*

### Use-Cases

|                                            |                                                                                                                                                                                                         |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Network Discovery**                      | discovering the network to overview devices, rogue hosts & network load                                                                                                                                 |
| **Packets Reassembling**                   | to investigate the traffic flow *(helpful in unencrypted traffic)*                                                                                                                                      |
| **Data Leakeage Detection**                | reviewing packet transfer rates for each host / dst address helps detect possible data exfil                                                                                                            |
| **Anomaly / Malicious Activity Detection** | reviewing overall network load by focusing on used ports, src & dst addresses helps detect possible malicious activities along with vulns *(covers the correlation of indicators & hypotheses as well)* |
| **Policy / Regulation Compliance Control** | reviewing overall network behavior helps detect policy/regulation compliance                                                                                                                                                                                                        |

### Advantages

- **Availability of network-based evidence in the wild**: capturing network traffic is collecting evidence *(easier than other types of evidence collections such as logs & [[sheets/Indicators of Compromise (IOCs)]])*
- **Ease of data/evidence collection without creating noise**: working with network traffic is easier than investigating events by EDRs, EPPs & log systems. Sniffing doesn't create much noise & is not destructible 
- **It's hard to destroy the network evidence, as it is the transferred data**: the evidence is the traffic itself, it is impossible to do anything without creating network noise. Still is possible to hide artifacts by encrypting, tunneling & manipulating the packets
- **Availability of log sources**: logs provide valuable information which helps to correlate the chain of events and support the investigation hypothesis. Having log files is easy if the attacker/threat/malware didn't erase/destroy them
- **It's possible to garther evidence for memory & non-residential malicious activities**: malware/threat might reside in the memory to avoid detection. However the series of cmds & connections live in the network. Thus, we can detect non-residential threats with network forensics tools and tactics

### Challenges

- **Deciding what to do**: 
- **Sufficient data/evidence collection on the network**
- **Short data capture**
- **The unavailability of full-packet capture on suspicious events**
- **Encrypted traffic**
- **GDPR & Privacy concerns**
- **Nonstandard port usage**
- **Time zone issues**
- **Lack of logs**



## Refs
- [networkminer THM room](https://tryhackme.com/room/networkminer)
## See Also
- [[Forensics]]
