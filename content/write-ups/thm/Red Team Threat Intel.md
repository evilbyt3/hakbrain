---
title: "Red Team Threat Intel"
date: 2022-09-14
url: https://tryhackme.com/room/redteamthreatintel
tags:
- writeups
---

## Threat Intelligence 101
Threat Intelligence *(TI)* or Cyber Threat Intelligence *(CTI)* is evidence-based knowledge about adversaries *(including TTPs motivations, and actionable advice against them)*

It can be consumed *(to take action upon data)* by collecting [[sheets/Indicators of Compromise (IOCs)|Indicators of Compromise (IOCs)]] and TTPs *(**T**actics, **T**echniques, and **P**rocedures)* commonly distributed & maintained by [[write-ups/thm/isac|ISACs (Information and Sharing Analysis Centers)]]

## How does the Red Team uses Threat Intel?
The red team will leverage CTI to aid in adversary emulation and support evidence of an adversary's behaviors. To aid in consuming CTI & collecting TTPs, we might often use frameworks such as [[Mitre ATT&CK]], [TIBER-EU](https://www.crest-approved.org/membership/tiber-eu/) and [OST Map](https://www.intezer.com/ost-map/). These will collect known TTPs & categorize them based on:
- Threat Group
- Kill Chain Phase
- Tactic
- Objective/Goal

Thus, the red team can select on what are they interested in emulating by identifying all the TTPs categorized with their chosen adversary and map them to a known [[todo/Red Team Fundamentals#Structure Cyber Kill Chains|cyber kill chain]]. 

> **Note**: Leveraging TTPs is used as a planning technique rather than something a team will focus during engagement

During the execution of an engagement, the red team will use this to craft tooling, modify traffic and behavior, and emulate the targeted adversary.

## TTP Mapping on [APT 39](https://attack.mitre.org/groups/G0087/)
`APT39` is a cyber-espionage group run by the Iranian ministry, known for targeting a wide variety of industries. Loading in it [ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/) helps us visualize each TTP and categorize its place in the kill chain

![[write-ups/images/Pasted image 20220914005131.png]]

## Other Red Team Applications of CTI
CTI can also be used during engagement execution, emulating the adversary's behavioral characteristics

### C2 Traffic Manipualtion
We can use CTI to identify adversaries' traffic and modify our C2 traffic to emulate it. One such example is [malleable profiles](https://www.cobaltstrike.com/help-malleable-c2). Information to be implemented in the profile can be gathered from [[write-ups/thm/isac|ISACs]] and collected [[sheets/Indicators of Compromise (IOCs)|IOCs]] or from packet captures, including:
- Host Headers
- POST URIs
- Server Responses & Headers

Once all the traffic has been gathered, it can aid a red team to make their traffic similar to the targeted adversary.

### Malware and Tooling
Another behavioral use of CTI is analyzing behavior and actions of an adversaries' malware and tools to develop your offensive tooling that emulates similar behaviors or has similar vital indicators

If an adversary is using a custom dropper, the red team can emulate it by:
- Identifying traffic
- Observing syscalls & API calls
- Identifying overall dropper behavior and objective
- Tampering with file signatures and IOCs

## Creating a Threat Intel Driven Campaign
Planning it:
1.  Identify framework and general kill chain
2.  Determine targeted adversary
3.  Identify adversary's TTPs and IOCs
4.  Map gathered threat intelligence to a kill chain or framework
5.  Draft and maintain needed engagement documentation
6.  Determine and use needed engagement resources (tools, C2 modification, domains, etc.)

**Scenario**: team has already decided to use the Lockheed Martin cyber kill chain to emulate [APT 41](https://attack.mitre.org/groups/G0096/) as the adversary that best fits the client's objectives and scope
- plugging our APT in [ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator//#layerURL=https%3A%2F%2Fattack.mitre.org%2Fgroups%2FG0096%2FG0096-enterprise-layer.json) gives us this 
	- ![[write-ups/images/Pasted image 20220914011852.png]]
- they provide us with the mapping of [Lockheed Martin Cyber Kill Chain](https://www.lockheedmartin.com/en-us/capabilities/cyber/cyber-kill-chain.html) to [MITRE](https://www.mitre.org/)
	- ![[write-ups/images/Pasted image 20220914011727.png]]
- now matching each technique to our cyber kill chain yielded this results for me
	- ![[write-ups/images/Pasted image 20220914011933.png]]
- What web shell is APT41 known to use?
	- [ASPXSpy](https://attack.mitre.org/software/S0073)
	- ![[write-ups/images/Pasted image 20220914012558.png]]
- What LOLBAS (**L**iving **O**ff **T**he **L**and **B**inaries and **S**cripts) tool does APT 41 use to aid in file transfers?
	- [certutil](https://attack.mitre.org/software/S0160/)
	- ![[write-ups/images/Pasted image 20220914012829.png]]
- What tool does APT 41 use to mine and monitor SMS traffic?
	- [MessageTap](https://attack.mitre.org/software/S0443/)
	- ![[write-ups/images/Pasted image 20220914013225.png]]

For more info about this APT & its capabilities check [this madiant paper](https://www.mandiant.com/resources/blog/apt41-initiates-global-intrusion-campaign-using-multiple-exploits)

---

## Refs
- [TIBER-EU whitepaper](https://www.ecb.europa.eu/pub/pdf/other/ecb.tiber_eu_framework.en.pdf)

## See Also
- [[write-ups/THM]]
- [[write-ups/thm/misp]]
- [[write-ups/thm/yara]]