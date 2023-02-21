---
title: "Wireshark Tricks"
date: 2023-01-10
tags:
- sheet
---

Topic:: [[Forensics]] | 

---

## **Wireshark Operations Room**

**Find all Microsoft IIS servers. What is the number of packets that did not originate from "port 80"?**
![[write-ups/images/Pasted image 20230110152805.png]]

**Find all Microsoft IIS servers. What is the number of packets that have "version 7.5"?**

![[write-ups/images/Pasted image 20230110153137.png]]

**What is the total number of packets that use ports 3333, 4444 or 9999?**

![[write-ups/images/Pasted image 20230110153317.png]]

**What is the number of packets with "even TTL numbers"?**

![[write-ups/images/Pasted image 20230110153533.png]]

**Change the profile to "Checksum Control". What is the number of "Bad TCP Checksum" packets?**

`Edit -> Configuration Profiles`

![[write-ups/images/Pasted image 20230110154129.png]]


``


## Filtering

### Bookmarks & Profiles

### Advanced



| Filter     | Type          | Description                                      | Example                   | Workflow                                                | Usage                           |
| ---------- | ------------- | ------------------------------------------------ | ------------------------- | ------------------------------------------------------- | ------------------------------- |
| `contains` | comparison op | search a value inside packets *(case-sensitive)* | find all *Apache servers* | list all http pkts where `server` field contains Apache | `http.server contains "Apache"` |
| `matches`  |               |                                                  |                           |                                                         |                                 |
| `in`       |               |                                                  |                           |                                                         |                                 |
| `upper`    |               |                                                  |                           |                                                         |                                 |
| `lower`    |               |                                                  |                           |                                                         |                                 |
| `string`   |               |                                                  |                           |                                                         |                                 |

## Use Statistics

- **Resolved Addresses**: identify mapped IP addr from DNS & MAC addr
	- ![[write-ups/images/Pasted image 20230110144203.png]]
- **Protocol Hierarchy**: get a break down of all available protocols in a tree view based on packet counters / percentages. Useful for an overview of what you have to deal with & focus on the events of interest 
	- ![[write-ups/images/Pasted image 20230110144519.png]]
- **Conversations & Endpoints**: see session traffic between 2 hosts & identify unique endpoints of interest 
	- enable ip & port name resolution *(`Edit --> Preferences --> Name Resolution`)*
	- enable ip geolocation mapping - needs the [GeoIP db](): provide it to wireshark @ `Edit --> Preferences --> Name Resolution --> MaxMind database directories`
	- ![[write-ups/images/Pasted image 20230110145328.png]]



## Refs
- [Wireshark Module THM](https://tryhackme.com/module/wireshark)
## See Also
- [[write-ups/THM]]
