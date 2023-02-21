---
title: "The Hive Project"
date: 2023-02-10
tags:
- writeups
---

## Notes
- [TheHive Project](https://thehive-project.org/): a scalable, [open-source](https://github.com/TheHive-Project/TheHive) and freely available Security Incident Response Platform
- operates under the guidance of 3 core functions: collaborate, elaborate, act
- rich feature set & allows multiple integrations:
	- case/task management
	- alert triage
	- observable enrichment with [Cortex](https://github.com/TheHive-Project/Cortex/)
	- active response
	- custom dashboards & data viz
	- built-in [[write-ups/thm/misp]] integration
- other notable links:  [DigitalShadows2TH](https://github.com/TheHive-Project/DigitalShadows2TH) & [ZeroFox2TH](https://github.com/TheHive-Project/Zerofox2TH) -- from [DigitalShadows](https://www.digitalshadows.com/) and [ZeroFox](https://www.zerofox.com/) respectively


## Practical
**Scenario**: You have captured network traffic on your network after suspicion of data exfiltration being done on the network. This traffic corresponds to FTP connections that were established. Your task is to analyse the traffic and create a case on TheHive to facilitate the progress of an investigation. If you are unfamiliar with using [[write-ups/thm/Wireshark Tricks]], please check out [this room](https://tryhackme.com/room/wireshark) first and come back to complete this task.

> *PCAP Source*: _IntroSecCon CTF 2020_


### PCAP Analysis
Opened `pcap` in wireshark gets us some FTP traffic. Filtered for login attempts:

![[write-ups/images/Pasted image 20230210021224.png]]

If we go back, we see that `anonymous` login was first tried, but failed. In the case of the `pi` user it worked tho

![[write-ups/images/Pasted image 20230210021415.png]]

Then, it looks like some sort of exfiltration of a single file `/home/pi/flag.txt` by executing `RETR` -- [see FTP commands doc](https://en.wikipedia.org/wiki/List_of_FTP_commands) 4 the other

### Opening a case in TheHive

Now we can open a new case & fill in the details of our investigation by `+ New Case`:

![[write-ups/images/Pasted image 20230210022246.png]]





## Refs
- [room](https://tryhackme.com/room/thehiveproject)

## See Also
- [[write-ups/THM]]
- [[write-ups/thm/OpenCTI]]
- [[todo/Wazuh]]
