---
title: "Pyramid of Pain"
date: 2023-01-05
tags:
- writeups
---

![](https://i.ibb.co/QYWXRSh/pop2.png)

This concept is being applied in order to improve the effectiveness of CTI *(Cyber Threat Intelligence)*, threat hunting & incident response exercises.

## Hash Values *(Trivial)*

- A hash value is a numeric value of a fixed length that uniquely identifies datai
- Is the result of a hashing algorithm, here's 3 most common:
	- **MD5 *(Message Digest - [RFC 1321](https://www.ietf.org/rfc/rfc1321.txt))*** : designed in 1992 & is a widely used cryptographic hash function with a 128-bit hash value. MD5 is **NOT** considered **cryptographically secure**. See [this](https://datatracker.ietf.org/doc/html/rfc6151) which mentions a nr of attacks against it, including hash collision
	- **SHA-2 *(Secure Hash Algorithm 2)*** : designed by [NIST](https://www.nist.gov/) & NSA in 2001 to replace  [SHA-1](https://tools.ietf.org/html/rfc3174). It has many variants & arguably the most common being SHA-256 - returns a hash value of 256-bits as a 64 digit hex nr
- A hash is not considered to be cryptographically secure if two files have the same hash value or digest
- Security analysts use hash values for various reasons:
	- to gain insight into a specific malware sample *(e.g entropy)*
	- as a way to uniquely identify & reference the malicious artifact
	- to see if data has been tampered with
- Online tools can be used to do hash lookups *([VirusTotal](https://www.virustotal.com/gui/file/63625702e63e333f235b5025078cea1545f29b1ad42b1e46031911321779b6be/community), [Metadefender Cloud - OPSWAT](https://metadefender.opswat.com/))*
	- keep in mind that as an attacker is trivial to modify the file by even a single bit which will produce a different hash
	- ![[write-ups/images/Pasted image 20230105121551.png]]

## IP Address *(Easy)*
- [[todo/IP Addressing & Subnetting|IP addresses]] are used to identify any device connected to a network
- we rely on them [[todo/IPv4|to send & receive the information]] over the network
- From a defense standpoint, knowledge of the IP addresses an adversary uses can be valuable
	- we can block, drop or deny inbound req from malicious IP addr
	- we can find geolocation information or correlate them to gather more intelligence of our adversary
- However, experienced attackers can bypass this by simply using a new [[todo/LANs & WANs|public IP address]] or use techniques such as [Fast Flux](https://unit42.paloaltonetworks.com/fast-flux-101/) - having multiple IP addresses associated with a domain name, which is constantly changing to make the comms between [[write-ups/thm/malware-intro|malware]] & C&C challenging to be discovered 
- [Any Run Malicious IP conns example](https://app.any.run/tasks/a66178de-7596-4a05-945d-704dbf6b3b90/)

## Domain Names *(Simple)*
- can be thought oas simply mapping an IP address to a string of text
- check [[DNS]] note & [DNS in detail](https://tryhackme.com/room/dnsindetail) room
- domain names can be more of a pain for attackers to change as they would need to purchase the domain, register it and modify DNS records *(unfortunetaly for defenders there's many DNS providers with loose standards which provide APIs to make it easier to change the domain)*
- [Punycode attack](https://www.jamf.com/blog/punycode-attacks/) -  is a way of converting words that cannot be written in ASCII, into a Unicode ASCII encoding. Used to trick the users to go on a malicious domain that seems legitimate
	- ![[write-ups/images/Pasted image 20230105123158.png]]
	- most browsers nowadays are pretty good @ translating the obfuscated chars into the full Punycode domain name
- to detect malicious domains, proxy logs OR web server logs can be used
- attackers also use [URL Shorteners](https://cofense.com/blog/url-shorteners-fraudsters-friend/) to hide malicious domains - a tool that creates a short and unique URL that will redirect to the specific website specified during the initial step of setting up the URL Shortener link
	- ![](https://i.ibb.co/rFhwNsw/terminal.png)

## Host Artifacts *(Annoying)*
- are the traces or observables that attackers leave on the system *(e.g [[write-ups/thm/windows-forensics-2#Evidence of Execution|evidence of execution]], registry values, attack patterns or [[sheets/Indicators of Compromise (IOCs)]], files dropped or anything exclusive to the current threat)*

## Network Artifacts *(Annoying)*
- a network artifact can be a user-agent string, C2 information, URI patterns in the HTTP POST requests
- they can be detected by monitoring your network with [[IPS & IDS Devices|IDS]] devices or logging from a source such as [[sheets/Snort]] *(will get `.pcap` files)* which can be further analyzed with tools like [[write-ups/thm/Brim]] , [[write-ups/thm/Zeek]]
- if detected & respond to the threat => attacker would need more time to go back and change his tactics or modify the tools => gives you more time to respond/detect upcoming threats OR remediate existing ones, thus makling their attempt to compromise the network more annoying
- an attacker might use a [User-Agent](https://datatracker.ietf.org/doc/html/rfc2616#page-145) string that hasn't been observed in your environment before or seems out of the ordinary
- [Common User-Agents found for the Emotet Trojan](https://www.mcafee.com/blogs/other-blogs/mcafee-labs/emotet-downloader-trojan-returns-in-force/)

## Tools *(Challenging)*
- at this stage we have levelled up our detection capabilities against the artifcats => attacker would most likely give up trying to break into your network or go back and try to create a new tool that serves the same purpose *(will require money investment to build a new tool, get training, etc)*
- Attackers would use the utilities to create malicious macro documents *(maldocs)* for spearphishing attempts, a backdoor that can be used to establish [C2 (Command and Control Infrastructure)](https://www.varonis.com/blog/what-is-c2/), any custom .EXE, and .DLL files, payloads, or password crackers.
- AV signatures, detection rules, [[write-ups/thm/yara]] rules can be great weapons to use against attackers @ this stage
- [MalwareBazaar](https://bazaar.abuse.ch/) and [Malshare](https://malshare.com/) are good resources when it comes to threat hunting & incident response
- Also, [SOC Prime Threat Detection Marketplace](https://tdm.socprime.com/) is a great platform where professionals share their detection rules for different threats *(including the latest CVE's being exploited in the wild)*
- [Fuzzy hashing](https://www.atomicmatryoshka.com/post/what-is-fuzzy-hashing) - match 2 files with minor differences based on the fuzzy hash values *([SSDeep](https://ssdeep-project.github.io/ssdeep/index.html))*

## TTPs *(Tough)*
- TTPs stand for Tactics, Techniques & Procedures *(includes the whole [MITRE](https://attack.mitre.org/) [ATT&CK Matrix](https://attack.mitre.org/))* - all the steps taken by an adversary to achieve his goal, starting from phishing attempts to persistence and data exfiltration
- If you can detect & respond to TTPs quickly, you leave the adversaries almost no chance to fight back
	- detect a [Pass-the-Hash](https://www.beyondtrust.com/resources/glossary/pass-the-hash-pth-attack) attack using Windows Event Log Monitoring and remediate it, you would be able to find the compromised host very quickly and stop the lateral movement inside your network
	- this leaves the attacker with 2 options: go back, do more training, reconfigure their tools OR give up & find another target

## Answers
- **TTP** 
	- ![[write-ups/images/Pasted image 20230105132749.png]]
- **Tools**
	- ![[write-ups/images/Pasted image 20230105132840.png]]
- **Network/Host Artifacts**
	- ![[write-ups/images/Pasted image 20230105132846.png]]
- **Domain Names**
	- ![[write-ups/images/Pasted image 20230105132854.png]]
- **IP Addresses**
	- ![[write-ups/images/Pasted image 20230105132859.png]]
- **Hash Values**
	- ![[write-ups/images/Pasted image 20230105132903.png]]


## Refs
- [room](https://tryhackme.com/room/pyramidofpainax)
- [DFIR Report](https://thedfirreport.com/)
- [Trellix Blog](https://www.trellix.com/en-us/about/newsroom/stories/research.html)
- [Akamai](https://www.akamai.com/blog?)

## See Also
- [[write-ups/SOC Level 1 Path]]
