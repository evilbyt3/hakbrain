---
title: "Intro to Cyber Threat Intel"
date: 2023-02-07
tags:
- writeups
---

## CTI 101
CTI can be defined as evidence-based knowledge about adversaries, including their indicators, tactics, motivations, and actionable advice against them. These can be utilised to protect critical assets and inform cybersecurity teams and management business decisions.

- **Data:** Discrete indicators associated with an adversary such as IP addresses, URLs or hashes.
- **Information:** A combination of multiple data points that answer questions such as “How many times have employees accessed tryhackme.com within the month?”
- **Intelligence:** The correlation of data and information to extract patterns of actions based on contextual analysis.

The primary goal of CTI is to understand the relationship between your operational environment & your adversary:
- Who's attacking you?
- What are their motivations?
- What are their capabilities?
- What artefacts and [[sheets/Indicators of Compromise (IOCs)]] should you look out for?

With these questions, threat intelligence would be gathered from different sources
- **Internal**
	- corporate security events & incident response reports
	- cyber awareness training reports
	- system logs & events
- **Community**
	- open web forums
	- dark web communities for cybercriminals
- **External**
	- threat intel feeds *(commercial / open-source)*
	- online marketplaces
	- public sources *(government data, publications, social media, financial & industrial assessments)*
 
## Classifications
- **Strategic Intel**: high-level intel that looks into an organization's threat landascape & maps out the risk areas based on trends, patterns & emerging threats that may impact buss decisions
- **Technical Intel**: looks into evidence / artefacts of attack used by an adversary. Incident reponse teams can use this data to create a baseline attack surface to analyze & develop defense mechanisms
- **Tactical Intel**: assesses adversaries' tactics, techniques & procedures. This can strengthen security controls and address vulns through real-time investigations
- **Operational Intel**: looks into an adversary’s specific motives and intent to perform an attack. Security teams can use this intel to understand critical assets available in the organization *(people, processes, technologies)* that may be targeted

## Lifecycle

![](https://tryhackme-images.s3.amazonaws.com/user-uploads/5fc2847e1bbebc03aa89fbf2/room-content/556cfb96c241e5260574a2e113f10305.png)

### Direction
Every threat intel program needs to have objectives defined, involving identifying the following params:
- information assets & buss procs that require defending
- potential impact to be experienced on losing the assets or through process interruptions
- sources of data to be used towards protection
- tools & resources required to defend the assets

This phase also allows security analysts to pose questions related to investigating incidents

### Collection
Once objectives have been defined, security analysts will gather the required data to address them. Accomplished by using commercial, private and open-source resources available 

> Note: Due to the volume of data analysts usually face, it's recommended to automate this phase as much as possible in order to provide time for triaging incidents

### Processing
Raw logs, vulnerability information, malware and network traffic usually come in different formats and may be disconnected when used to investigate an incident. This phase ensures that the data is extracted, sorted, organised, correlated with appropriate tags and presented visually in a usable and understandable format to the analysts. SIEMs are valuable tools for achieving this and allow quick parsing of data.

### Analysis
Once the information aggregation is complete, security analysts must derive insights. Decisions to be made may involve:
- investigating a potential threat through uncovering indicators & attack patterns
- defining an action plan to avert an attack & defend the infrastructure
- strengthening security controls or justifying investment for additional resources

### Dissemination
Different organisational stakeholders will consume the intelligence in varying languages and formats. For example, C-suite members will require a concise report covering trends in adversary activities, financial implications and strategic recommendations. At the same time, analysts will more likely inform the technical team about the threat IOCs, adversary TTPs and tactical action plans.

### Feedback
The final phase covers the most crucial part, as analysts rely on the responses provided by stakeholders to improve the threat intelligence process and implementation of security controls. Feedback should be regular interaction between teams to keep the lifecycle working.


## Standards & Frameworks

- [[Mitre ATT&CK]]: 
- [TAXII](https://oasis-open.github.io/cti-documentation/taxii/intro): 
- [STIX](https://oasis-open.github.io/cti-documentation/stix/intro): 
- [[write-ups/thm/Cyber Kill Chain]]
- [[write-ups/thm/Diamond Model]]
- Notable threat reports: [Mandiant](https://www.mandiant.com/resources), [Recorded Future](https://www.recordedfuture.com/resources/global-issues) and [AT&TCybersecurity](https://cybersecurity.att.com/)

## Tools
- [urlscan.io](https://urlscan.io/): automate the process of browsing and crawling through websites to record activities and interactions *(e.g domain registrars, http requests, ip, links, certs, ASN)*
- [abuse.ch](https://abuse.ch/): developed to identify and track malware and botnets through several operational platforms
	- **Malware Bazaar:**  A resource for sharing malware samples.
	- **Feodo Tracker:**  A resource used to track botnet command and control (C2) infrastructure linked with Emotet, Dridex and TrickBot.
	- **SSL Blacklist:**  A resource for collecting and providing a blocklist for malicious SSL certificates and JA3/JA3s fingerprints.
	- **URL Haus:**  A resource for sharing malware distribution sites.
	- **Threat Fox:**  A resource for sharing indicators of compromise (IOCs).
- [PhishTool](https://www.phishtool.com/): seeks to elevate the perception of [[todo/Phising Analysis Tools|phishing]] as a severe form of attack and provide a responsive means of email security. Through [[write-ups/thm/06 Email Analysis - It's beginning to look a lot like phishing|email analysis]], sec teams can uncover email [[sheets/Indicators of Compromise (IOCs)]], prevent breaches & provide [[Forensics]] reports that could be used in phishing containment and training engagement
- [Cisco Talos Intelligence](https://talosintelligence.com/):  provide actionable intelligence, visibility on indicators, and protection against emerging threats through data collected from their products *(check [whitepaper](https://www.talosintelligence.com/docs/Talos_WhitePaper.pdf) for more)*
	- **Threat Intelligence & Interdiction:** Quick correlation and tracking of threats provide a means to turn simple IOCs into context-rich intel.
	- **Detection Research:** Vulnerability and malware analysis is performed to create rules and content for threat detection.
	- **Engineering & Development:** Provides the maintenance support for the inspection engines and keeps them up-to-date to identify and triage emerging threats.
	- **Vulnerability Research & Discovery:** Working with service and software vendors to develop repeatable means of identifying and reporting security vulnerabilities.
	- **Communities:** Maintains the image of the team and the open-source solutions.
	- **Global Outreach:** Disseminates intelligence to customers and the security community through publications.


## Practical

**Scenario**: You are a SOC Analyst. Several suspicious emails have been forwarded to you from other coworkers. You must obtain details from each email to triage the incidents reported.

### Case I
Uploading the file in [[#Tools|PhisTool]] yields more digestible information:

![[write-ups/images/Pasted image 20230208022331.png]]

**What organisation is the attacker trying to pose as in the email?**
Seems like a quite deceptive built LinkedIn phising page masquerading as a notification email -- giving it urgency

**What IOCs can be retrieved?**
We can determine some [[sheets/Indicators of Compromise (IOCs)]] from [[todo/Phising Analysis Tools|analysing the email]]'s header: 
```bash
# retrieved from Email1.eml headers
From: "Patrick Cook" <darkabutla@sc500.whpservers.com>
To: "cabbagecare@hotsmail.com" <cabbagecare@hotsmail.com>
Date: Tue, 29 Mar 2022 15:39:22 +0000 (UTC)
Subject: You have 5 new message
X-Sender-IP: 204.93.183.11   # Defanged: 204[.]93[.]183[.]11
```

I also used [PhishTool](https://app.phishtool.com) to get information in a more web user-friendly environment

![[write-ups/images/Pasted image 20230208023616.png]]

One thing to note though is the absence of attachments which indicates that the user would get compromised by accessing an URL instead:

![[write-ups/images/Pasted image 20230208023738.png]]

Further analysis on the domain, IP and servers associated with them must be done to identify *who is attacking us?** *(possible threat actors)*. 

**Can you scope the threat actor landscape using CTI tools?**

To dig deeper, we can use tools like [Shodan](https://www.shodan.io/host/204.93.183.11) to see what ports & services are currently running. Also, uploading it in [Talos](https://talosintelligence.com/reputation_center/lookup?search=204.93.183.11) might reveal even more intel about the attacker's capabilities

![[write-ups/images/Pasted image 20230208024309.png]]

Taking a look at the `whois` lookup can reveal even more about the history @ associated domains *(our attacker's infrastructure)*

![[write-ups/images/Pasted image 20230208024434.png]]

### Case II
You are a SOC Analyst. Several suspicious emails have been forwarded to you from other coworkers. You must obtain details from each email to triage the incidents reported.

Taking a look @ `Email2.eml`:

![[write-ups/images/Pasted image 20230208024908.png]]

First thing is to note the [[sheets/Indicators of Compromise (IOCs)]]
```bash
From: LeHuong-accounts@gmail.com  # used legitimate gmail acc to spread malware?
To: chris.lyons@supercarcenterdetroit.com # victim
Date: 08:14 pm, Dec 14th 2017
IP: 134[.]19[.]187[.]230
Domain: hyp07-nl-ams.gowhitelabel.com
```

Looks like a simple invoice note on a payment *(prob trying to hide as an internal correspondence between departments)*. Given that there's no URL redirection, instead a ZIP file is attached

![[write-ups/images/Pasted image 20230208025345.png]]

[VirusTotal](https://www.virustotal.com/gui/file/435bfc4c3a3c887fd39c058e8c11863d5dd1f05e0c7a86e232c93d0e979fdb28/details) is pretty confident this is stealer trojan. Also plugging it in [Talos](https://talosintelligence.com/sha_searches) awards it a 100 score of being malicious:

![[write-ups/images/Pasted image 20230208030206.png]]


Downloading the file & trying to unzip it requires a password:
![[write-ups/images/Pasted image 20230208025703.png]]

### Case III

![[write-ups/images/Pasted image 20230208030514.png]]

Looking just like an inoffensive purchase order invoice, indicating the user to open   `Sales_Receipt 5606.xls` containing macros:

![[write-ups/images/Pasted image 20230208030702.png]]

Plugging the hashes in [VirusTotal](https://www.virustotal.com/gui/file/b8ef959a9176aef07fdca8705254a163b50b49a17217a4ff0107487f59d4a35d) & [Talos](https://talosintelligence.com/sha_searches) immediately gives us more red alerts

![[write-ups/images/Pasted image 20230208030924.png]]

- [sample download](https://malshare.com/sample.php?action=detail&hash=e63deaea51f7cc2064ff808e11e1ad55)
- [sandbox analysis](https://app.docguard.io/b8ef959a9176aef07fdca8705254a163b50b49a17217a4ff0107487f59d4a35d/results/dashboard)

Seems like we're dealing with the [Dridex](https://attack.mitre.org/software/S0384/) banking trojan

> Note: ofc more in-depth analysis can be performed by analyzing the macro

## Refs
- [room](https://tryhackme.com/room/cyberthreatintel)

## See Also
- [[write-ups/THM]]
- [[Phising Module]]
- htb forensics challenge analyzing macro
