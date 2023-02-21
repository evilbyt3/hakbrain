---
title: "New Hire Old Artifacts"
date: 2023-01-08
tags:
- writeups
---

**Scenario**: You are a SOC Analyst for an MSSP (managed Security Service Provider) company. A newly acquired customer (Widget LLC) was recently onboarded with the managed Splunk service. The sensor is live, and all the endpoint events are now visible.  

Widget LLC has some concerns with the endpoints in the Finance Dept, especially an endpoint for a recently hired Financial Analyst. The concern is that there was a period (December 2021) when the endpoint security product was turned off, but an official investigation was never conducted. 

Your manager has tasked you to sift through the events of Widget LLC's Splunk instance to see if there is anything that the customer needs to be alerted on.



**A Web Browser Password Viewer executed on the infected machine. What is the name of the binary? Enter the full path.**

First I had to change the date range: from 1st of Dec 2021 through Jan 31, 2022. Afterwards, I just searched for the keyword `password` & got 117 events: all related to a Web Browser Password Viewer with a strange binary:

![[write-ups/images/Pasted image 20230108131323.png]]


**What is listed as the company name?**

If we expand all 31 lines we get our Company:

![[write-ups/images/Pasted image 20230108131503.png]]

**Another suspicious binary running from the same folder was executed on the workstation. What was the name of the binary? What is listed as its original filename?**

![[write-ups/images/Pasted image 20230108141501.png]]




**The binary from the previous question made two outbound connections to a malicious IP address. What was the IP address? Enter the answer in a defang format.**

```
Image="C:\\Users\\Finance01\\AppData\\Local\\Temp\\IonicLarge.exe" DestinationIp="2.56.59.42"
2[.]56[.]59[.]42
```

[Virustotal](https://www.virustotal.com/gui/ip-address/2.56.59.42)

**The same binary made some change to a registry key. What was the key path?**

![[write-ups/images/Pasted image 20230108143113.png]]

**Some processes were killed and the associated binaries were deleted. What were the names of the two binaries?**

![[write-ups/images/Pasted image 20230108143316.png]]

**The attacker ran several commands within a PowerShell session to change the behaviour of Windows Defender. What was the last command executed in the series of similar commands?**

![[write-ups/images/Pasted image 20230108143720.png]]

**Based on the previous answer, what were the four IDs set by the attacker? Enter the answer in order of execution**

```
powershell.exe host="DESKTOP-H1ATIJC" defender 
ThreatIDDefaultAction_Ids=
```

**Another malicious binary was executed on the infected workstation from another AppData location. What was the full path to the binary?**
```
*.exe
| top limit=200 Image
```

**What were the DLLs that were loaded from the binary from the previous question?**
```
Image="C:\\Users\\Finance01\\AppData\\Roaming\\EasyCalc\\EasyCalc.exe"
check OriginalFileName field
```


## Refs
- [room](https://tryhackme.com/room/newhireoldartifacts)

## See Also
- [[write-ups/THM]]
- [[write-ups/thm/splunk-101]]
- [[write-ups/thm/splunk-2]]
