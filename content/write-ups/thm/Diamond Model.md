---
title: "Diamond Model"
date: 2023-02-02
tags:
- writeups
---

[As described by its creators](https://www.activeresponse.org/wp-content/uploads/2013/07/diamond.pdf), the Diamond Model is composed of 4 core features: adversary, infrastructure, capability, and victim, and establishes the fundamental atomic element of any intrusion activity.

**Why it's helpful & should learn about it?**
- provides various opportunities to integrate intelligence in real-time for: 
	- network defence
	- automating correlation across events
	- classifying events with confidence into adversary campaigns
	- forecasting adversary operations while planning mitigation strats 
- help you identify the elements of an intrusion
- ability to analyze APTs
- help explain to other people who are non-technical about what happened during an event

## Elements

### Adversary
- an actor or organization responsible for utilizing a capability against the victim to achieve their intent
- is likely to be empty for most events – at least at the time of discovery
- essential to understand the diff between:
	- **adversary operator**: "hacker" / person(s) conducting the attack
	- **adversary customer**: the entity that stands to benefit from the activity conducted in the intrusion *(may be the same person or an separate person / group)*
- the above will help you understand intent, attribution, adaptability, and persistence by framing the relationship betweeen an adversary & victim pair

### Victim 
- the target of the adversary *(e.g organization, person, email addr, IP addr, domain)*
- **victim personae**: are the people and organizations being targeted and whose assets are being attacked and exploited
- **victim assets**: are the attack surface and include the set of systems, networks, email addresses, hosts, IP addresses, social networking accounts, etc., to which the adversary will direct their capabilities

### Capability
- highlights the adversary’s tactics, techniques, and procedures *(TTPs)*
- **capability capacity**: all of the vulnerabilities and exposures that the individual capability can use
- **adversary arsenal**: a set of capabilities that belong to an adversary - the combined capacities of an adversary's capabilities

### Infrastructure
- the physical or logical interconnections that the adversary uses to deliver a capability or maintain control of capabilities *(e.g command & control & the results from the victim: i.e data exfil)*
- infrastructure can be IP addr, domain names, malicious USB devices
- **Type 1 Infra**: infrastructure controlled or owned by the adversary
- **Type 2 Infra**: infrastructure controlled by an intermediary *(might or not be aware of it)*. It has the purpose of obfuscating the source and attribution of the activity *(compromised email acc, web servers)*
- **Service Providers**: organizations that provide services considered critical for the adversary availability of Type 1 and Type 2 Infrastructures *(i.e domain registrars, webmail providers)*
### Event Meta Features
- **Timestamp**: is the date and time of the event - are essential to help determine the patterns and group the malicious activity
- **Phase**: "Every malicious activity contains two or more phases which must be successfully executed in succession to achieve the desired result." - one example of such framework is [[write-ups/thm/Cyber Kill Chain]] 
- **Result**: while the results/post-conditions of an attack will not be always known, it's helpful to capture them:
	- success / failure / unknown
	- can be related to the [[todo/cyberops/CIA Triad]]
	- documenting all of the post-conditions resulting from the event *(e.g information gathered in recon, password/data exfil)*
- **Direction**: describe host-based and network-based events - the Diamond Model of Intrusion Analysis defines 7 potential values: Victim-to-Infrastructure, Infrastructure-to-Victim, Infrastructure-to-Infrastructure, Adversary-to-Infrastructure, Infrastructure-to-Adversary, Bidirectional or Unknown
- **Methodology**: will allow an analyst to describe the general classification of intrusion *(e.g DDoS, breach, port scan, phising)*
- **Resources**: every intrusion event needs one or more external resources to be satisfied to succeed
	- software *(e.g OS, virtulization software, frameworks)*
	- knowledge *(e.g how to use Metasploit)*
	- information *(e.g username/password to masquerade)*
	- hardware *(e.g servers, workstations, routers)*
	- funds *(e.g money to purchase domains)*
	- facilities *(e.g electricity / shelter)*
	- access *(e.g net path from the source host to the victim, net access from the ISP)*

## Practice Analysis
based on this [case study](https://media.kasperskycontenthub.com/wp-content/uploads/sites/43/2016/05/20081514/E-ISAC_SANS_Ukraine_DUC_5.pdf)

|             |                                                                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Adversary   | The incident response team has determined that a group of notorious underground hackers named APT2166 are responsible for the attack |
| Timeline    | The attack occured on 2021-10-23 @ 15:45:00                                                                                                                                     |
| Victim      | The attackers targeted the Information Technology (IT) systems of the corporation                                                                                                                                  |
| Resources   | The attackers used a recent malware campaign known as OneTrick to ransomware the corporation’s servers                                                                                                                                     |
| Result      | The attackers stole data from the corporation and sold it on an underground hacking forum                                                                                                                                     |
| Capability  | The attackers gained access using legitimate credentials that were gained as a result of a phishing attack                                                                                                                                     |
| Methodology | Once the attackers gained access to the network, they pivoted to the internal databases and file shares                                                                                                                                     |
| Phase       | The attacker’s steps can be followed using the phases of what Cyber Kill Chain model? -- Lockheed Martin                                                                                                                                     |

## Refs
- [room](https://tryhackme.com/room/diamondmodelrmuwwg42)
- [official paper](https://www.activeresponse.org/wp-content/uploads/2013/07/diamond.pdf)

## See Also
- [[write-ups/THM]]
