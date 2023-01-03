---
title: "Brim"
date: 2023-01-03
tags:
- writeups
---

## What is Brim?
![[write-ups/images/Pasted image 20230103115120.png]]

A desktop app which processes pcap & log files, with a primary focus on providing search & analytics.

Can handle 2 types of data as input:
- Packet capture files: created w tcpdump, wireshark, tshark
- Log files: structured log files like [[write-ups/thm/Zeek]]

Tech stack:
- [[write-ups/thm/Zeek]]: log generating engine
- Zed Language: querying language
- ZND Data Format: data storage format that supports saving streams
- Electron & React: cross-platform UI

**Why Brim?**
Reduces the time and effort spent processing pcap files and investigating the log files by providing a simple and powerful GUI application.

## Queries

Unique DNS queries: `_path=="dns" | count() by query | sort -r`
Unique Network Connections: `_path=="conn" | cut id.orig_h, id.resp_p, id.resp_h | sort | uniq -c | sort -r`
Investigating the most active ports might reveal silent/well-hidden anomalies: `_path=="conn" | cut id.orig_h, id.resp_h, id.resp_p, service | sort id.resp_p | uniq -c | sort -r`
Long connections can reveal backdoors: `_path=="conn" | cut id.orig_h, id.resp_p, id.resp_h, duration | sort -r duration`
Connection Received Data: `_path=="conn" | put total_bytes := orig_bytes + resp_bytes | sort -r total_bytes | cut uid, id, orig_bytes, resp_bytes, total_bytes`
Get IP subnets: `_path=="conn" | put classnet := network_of(id.resp_h) | cut classnet | count() by classnet | sort -r`
File Activity: `filename!=null | cut _path, tx_hosts, rx_hosts, conn_uids, mime_type, filename, md5, sha1`
Geolocation data on connections: `_path=="conn" | cut geo.resp.country_code, geo.resp.region, geo.resp.city | sort -r`
Suricata alerts by src & dst: `event_type=="alert" | alerts := union(alert.category) by src_ip, dest_ip`
Suspicious hostnames: `_path=="dhcp" | cut host_name. domain`
Suspicious IP addresses: `_path=="conn" | put classnet := network_of(id.resp_h) | cut classnet | count() by classnet | sort -r`
SMB activity: `_path=="dce_rpc" OR _path=="smb_mapping" OR _path=="smb_files"`
Known patterns: `event_type=="alert" or _path=="notice" or _path=="signatures"`
Look for known MITRE ATT&CK techniques: `event_type=="alert" | cut alert.category, alert.metadata.mitre_technique_name, alert.metadata.mitre_technique_id, alert.metadata.mitre_tactic_name | sort | uniq -c`


## Malware C2 Detection

Loaded `task6-malware-c2.pcap` in Brim:

![[write-ups/images/Pasted image 20230103124334.png]]

Taking a look @ the most frequently communicated hosts:

![[write-ups/images/Pasted image 20230103124604.png]]

We see a lot of DNS & HTTP traffic from `10.22.5.4` & `104.168.44.45`. Let's take a closer look @ DNS:

![[write-ups/images/Pasted image 20230103124748.png]]

Throwing `hashingold.top` into [VirusTotal](https://www.virustotal.com/gui/domain/hashingold.top/relations) reveals some more possible malicious IP addresses: 

![[write-ups/images/Pasted image 20230103125120.png]]

I also looked @ the HTTP traffic before narrowing down the investigation with the found malicious IP addresses:

![[write-ups/images/Pasted image 20230103125239.png]]

Notice the `GET /download/4564.exe` from the `104.168.44.45` IP. This is probably a piece of malware dropped into our network. Again, making use of [VirusTotal](https://www.virustotal.com/gui/ip-address/104.168.44.45) to check the IP addressed we assumed as malicious. We see that the ip is linked with a [file](https://www.virustotal.com/gui/file/94053dfbc06bc7124129dd51fabf67f7f3738109d6dc11d0b4bb785f0e93c0b6) *(same as our `.exe`)*, once we investigate the file we discover that these 2 findings are associated with [CobaltStrike](https://www.cobaltstrike.com/) - our findings most probably represent the C2 comms.

Querying for Suricata logs to gather low hanging fruits reveal the overall malicious activities:

![[write-ups/images/Pasted image 20230103125931.png]]

I was curious to find the total nr of CobaltStrike connections using port 443:

![[write-ups/images/Pasted image 20230103130804.png]]

That's quite a lot. Note that adversaries using CobaltStrike are usually skilled threats and don't rely on a single C2 channel. Thus, let's try to find out the other C2 channels used by looking through the Suricata alerts

![[write-ups/images/Pasted image 20230103131800.png]]


Looking @ the logs we see a new C2 channel on `159.89.171.14` on port `80` using the [IcedID](https://www.cisecurity.org/insights/white-papers/security-primer-icedid) malware

## Crypto Mining

Opening up our `pcap` in Brim:

![[write-ups/images/Pasted image 20230103132336.png]]

First thing I looked @ the most used ports:

![[write-ups/images/Pasted image 20230103132606.png]]

So `3333` & `4444` are some of the most common used ports, this is quite strange & might indicate some peculiar activity. Let's investigate further by looking @ the transferred data bytes:

![[write-ups/images/Pasted image 20230103132843.png]]

While the result proves massive traffic originating from the suspicious IP addr *(`192.168.1.100`)* we don't have many supportive logs to correlate our findings & detect accompanying activities. Thus I decided to look @ suricata logs which might shed some light on the malicious activity:

![[write-ups/images/Pasted image 20230103133203.png]]

Ok so we're most definitely investigating a CryptoMiner inside our network *(which can exhaust network resources & pose as a possible backdoor)*. Let's try to find out the mining server by listing the associated connection logs with our suspicious IP address on port `9999` or `4444`:

![[write-ups/images/Pasted image 20230103134410.png]]

Getting one of the dest IPs into [VirusTotal](https://www.virustotal.com/gui/ip-address/103.3.62.64/relations) reveal their mining server pools. We can do a more exhaustive list by going through all of them


### Questions

**How many connections used port 19999?**
![[write-ups/images/Pasted image 20230103135104.png]]

**What is the name of the service used by port 6666?**
![[write-ups/images/Pasted image 20230103135041.png]]

**What's the amount of transfered bytes to `10.201.172.235:8888`?**
![[write-ups/images/Pasted image 20230103134959.png]]

**What is the detected MITRE tactic id?**
![[write-ups/images/Pasted image 20230103135206.png]]




## Refs
- [room](https://tryhackme.com/room/brim)

## See Also
- [Masterminds room](https://tryhackme.com/room/mastermindsxlq)
