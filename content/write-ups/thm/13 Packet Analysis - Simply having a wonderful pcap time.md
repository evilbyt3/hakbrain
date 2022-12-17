---
title: "13 Packet Analysis - Simply having a wonderful pcap time"
date: 2022-12-16
tags:
- writeups
---

## Story
After receiving the phishing email on Day 6 and investigating malware on Day 12, it seemed everything was ready to go back to normal. However, monitoring systems started to show suspicious traffic patterns just before closing the case. Now Santa's SOC team needs help in analysing these suspicious network patterns.

### Learning Objectives
- Learn what traffic analysis is and why it still matters.
- Learn the fundamentals of traffic analysis.
- Learn the essential Wireshark features used in case investigation.
- Learn how to assess the patterns and identify anomalies on the network.
- Learn to use additional tools to identify malicious addresses and conduct further analysis.
- Help the Elf team investigate suspicious traffic patterns.

## Notes

### Packet Analysis
- packets are the most basic unit of the network data transferred over the network
- packet analysis is the process of extracting, assessing and identifying network patterns such as connections, shares, commands and other network activities, like logins, and system failures, from the prerecorded traffic files

#### Why it matters?
- network traffic is a pure and rich data source since it provides statistics about the normal behavior of a network
- identifying and investigating network patterns in-depth can help to detect threats & improve the performance of the network
- most network-based detection mechanisms and notification systems ingest and parse packet-level information to create alerts and statistical data *(most red/blue/purple teaming exercises are optimized with packet-level analysis)*
- even encoded/encrypted network data still provides value by pointing to an odd, weird, or unexpected pattern or situation, highlighting that packet analysis still matters

#### Points to consider

| Point                                      | Details                                                                                                                                                                                                          |
| ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Network & standard protocols knowledge     | an analyst must know how the protocols work and which protocol provides particular information that needs to be used for analysis. Also knowing the normal & abnormal network behaviors / patterns is beneficial |
| Familiarity with attack & defense concepts | can't detect what you don't know => must know how attacks are conducted to identify what's happening & decide where to look                                                                                      |
| Practical experience with analysis tools   | can't burn down the haystack to find a needle. You must use varios tools to extract & investigate particular information from packet bytes                                                                       |

#### Checklist Example

| Check             | Details                                                                                                                                                                                             |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Hypothesis        | should know what to look for before starting an analysis                                                                                                                                            |
| Packet Statistics | helps in seeing the big picture in terms of protocols, endpoints & conversations                                                                                                                    |
| Known Services    | what services are known to be used in everyday operations *(e.g web browsing, file sharing, mailing)*. Sometimes adversaries use known services for their benegit, so know what "normal" looks like |
| Unknown Services  | potential red flags, if something feels off an analyst should know how to research unknown protocols and services                                                                                   |
| Known Patterns    | know the most common and recent case patterns to successfully detect the anomalies at first glance                                                                                                  |
| Environment       | what is the nature and dynamics of the working environment? *(e.g IP address blocks, hostname, username struct, used services, external resources, maintanance schedules, avg traffic load)*                                                                                                                                                                                                    |

#### Questions to answer
- Which IP addresses are in use?
- Has a suspicious IP address been detected?
- Has suspicious port usage been detected?
- Which port numbers and services are in use?
- Is there an abnormal level of traffic on any port or service?

**DNS**
- Which domain addresses are communicated?
- Do the communicated domain addresses contain unusual or suspicious destinations? 
- Do the DNS queries look unusual, suspicious or malformed?

**HTTP**
- Which addresses are communicated?
- Is there any resource share event between addresses?
- If there is a file share event, which addresses hosts which files?
- Do the user-agent fields look unusual, suspicious or malformed?

**[[sheets/Indicators of Compromise (IOCs)|Indicators of compromise]]**
- What are the shared files in the network?
- Does the hash reputation marked as suspicious or malicious?
- Which domain hosts the suspicious/malicious file?

## Practical

![[Pasted image 20221217043643.png]]

![[Pasted image 20221217043723.png]]

`3389` is usually used for RDP

trying to extract all domain names w `tshark` from the capture is yielding this:
![[Pasted image 20221217044138.png]]

we can [defang]() the domains using [CyberChef](https://cyberchef.org/#recipe=Defang_URL(true,true,true,'Valid%20domains%20and%20full%20URLs')&input=Y2RuLmJhbmRpdHlldGkudGhtCmJlc3RmZXN0aXZhbGNvbXBhbnkudGht)

looking @ http traffic we observe that `10.10.29.186` `GET`s 2 files hosted @ `cdn.bandityeti.thm`:

![[Pasted image 20221217044809.png]]
I also noticed that the `user-agent` on `favicon.ico` is set as [nim](https://github.com/nim-lang/Nim) 

![[Pasted image 20221217045146.png]]

By going to `File > Export Objects > HTTP` we can extract the malicious executable `mysterygift.exe` & calculate its sha256 hash

![[Pasted image 20221217045345.png]]
![[Pasted image 20221217045401.png]]

Searching it on [VirusTotal](https://www.virustotal.com/gui/file/0ce160a54d10f8e81448d0360af5c2948ff6a4dbb493fe4be756fc3e2c3f900f) we can get more information about the executable from the community. Looking at the `Behavior` tab we can learn more such as IP addr used, registry actions, process tree & Mitre ATT&CK Tactics And Techniques

![[Pasted image 20221217045906.png]]

### Adding rules

---

## Refs
- [Oficial Walkthrough](https://www.youtube.com/watch?v=rSyR8YFbOlI)
- [Network Security & Traffic Analysis module](https://tryhackme.com/module/network-security-and-traffic-analysis)

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/12 Malware Analysis - Forensic McBlue to the REVscue!]] | [[write-ups/thm/14 Web Apps - I'm dreaming of secure web apps]]
