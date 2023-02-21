---
title: "Cyber Kill Chain"
date: 2023-01-07
tags:
- writeups
---


## Reconnaissance

| Adversary Tactics | SOC Defense |
| ----------------- | ----------- |
|                   |             |


## Weaponization
- [Intro to Macros and VBA For Script Kiddies - by TrustedSec](https://www.trustedsec.com/blog/intro-to-macros-and-vba-for-script-kiddies/).

## Delivery
Attacker has to choose the method of transmitting the payload/malware:
- **Phising email** : after [[#Reconnaissance]] craft a malicious email that would target either a specific person (spearphishing attack) or multiple people in the company *(e.g attacker might learn from LinkedIN that Nancy from sales is constantly liking posts from Scott, a service delivery manager & assume that they both communicate through email => craft email using Scott's first/last name, making the domain similar to the targeted company & send fake *"Invoice" mail to Nancy)*
- **Distributing infected USB drives** : in public places like coffeships, parking lots, on the street *(e.g print the company's logo on [the USB & mail them to the company pretending to be a customer sendind USBs as gifts](https://www.csoonline.com/article/3534693/cybercriminal-group-mails-malicious-usb-dongles-to-targeted-companies.html))*
- **Watering Hole Attack** : a targeted attack designed to aim at a specific group of people by compromising the website they are usually visiting and then redirecting them to the malicious website of an attacker's choice *(e.g malicious pop-up asking to download a fake Browser extension)*


## Exploitation
To gain access to a system, the attacker needs to exploit a vulnerability. After gaining access, the malicious actor can exploit software, system or server-based vulnerabilities to escalate privs or [move laterally](https://www.crowdstrike.com/cybersecurity-101/lateral-movement/) through the network.
- victim triggers the exploit by opening an email attachment or clicking a malicious link
- using a [0-day exploit](https://www.fireeye.com/current-threats/what-is-a-zero-day-exploit.html)
- exploit software, hardware or even human vulns 
- an attacker triggers the exploit for a found vulnerability in the company's server

## Installation
Once an attacker gains access to a network, he would want to preserve the access if he loses connection or if he's detected & got his initial access removed. That's when he might install a [persistent backdoor](https://www.offensive-security.com/metasploit-unleashed/persistent-backdoors/)

Persistence can be achieved through:
- installing a [web shell](https://www.microsoft.com/en-us/security/blog/2021/02/11/web-shell-attacks-continue-to-rise/) on the webserver
- installing a backdoor on the victim's machine *(e.g with [meterpreter](https://www.offensive-security.com/metasploit-unleashed/meterpreter-backdoor/))*
- creating or modifyiung [Windows services](https://attack.mitre.org/techniques/T1543/003/) with tools such as `sc.exe` & [Req](https://attack.mitre.org/software/S0075/) to modify service configs. Can also [masquerade](https://attack.mitre.org/techniques/T1036/) the malicious payload using a known service name related to the legitimate OS
- adding the entry to the "run keys" for the malicious payload in the [Registry or the Startup Folder](https://attack.mitre.org/techniques/T1547/001/)
- can also use the **[Timestomping](https://attack.mitre.org/techniques/T1070/006/)** technique to avoid detection by the forensic investigator and also to make the malware appear as a part of a legitimate program

## Command & Control
After getting persistence setup, the actor opens up a C2 channel through the malware to remotely control & manipulate the victim *(C&C or C2 Beaconing)* - the infected host will consistently communicate with the C2 server

Most common C2 channels used:
- in the past [IRC]() was used but modern security solutions can easily detect malicious IRC traffic
- HTTP *(port 80)* & HTTPS *(port 443)* commonly used as it blends the malicious traffic with the legitimate one & can help evade firewalls
- DNS - comms are made through DNS requests to a server belonging to an attacker *(also known as [[DNS Tunneling]])*

> **Note**: another compromised host can be the owner of the C2 infrastructure


## Actions on Objectives
- Collect the credentials from users.
- Perform privilege escalation (gaining elevated access like domain administrator access from a workstation by exploiting the misconfiguration).
- Internal reconnaissance (for example, an attacker gets to interact with internal software to find its vulnerabilities).
- Lateral movement through the company's environment.
- Collect and exfiltrate sensitive data.
- Deleting the backups and shadow copies. Shadow Copy is a Microsoft technology that can create backup copies, snapshots of computer files, or volumes. 
- Overwrite or corrupt data.


## Refs
- [room](https://tryhackme.com/room/cyberkillchainzmt)

## See Also
- [Windows Persistence Room](https://tryhackme.com/room/windowslocalpersistence)
- [[write-ups/THM]]
