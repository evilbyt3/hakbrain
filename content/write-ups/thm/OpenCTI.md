---
title: "OpenCTI"
date: 2023-02-08
tags:
- writeups
---

[Open-sourced platform](https://www.filigran.io/en/products/opencti/) designed to provide organisations with the means to manage [[write-ups/thm/Intro to Cyber Threat Intel|CTI]] through the storage, analysis, visualization and presentation of threat campaigns, malware and [[sheets/Indicators of Compromise (IOCs)]]

**Objective**: create a comprehensive tool that allows users to capitalize on technical and non-technical information while developing relationships between each piece of information and its primary source *(also see [[Mitre ATT&CK]])*

## Data Model
![](https://tryhackme-images.s3.amazonaws.com/user-uploads/5fc2847e1bbebc03aa89fbf2/room-content/9c6b6cdef9163efb5e89483802a65d37.png)

The highlights are:
- [GraphQL API](https://graphql.org/) - connects clients to the database and the messaging system
- Write workers - python programs utilized to write queries asynchronously from the [RabbitMQ](https://www.rabbitmq.com/) messaging system
- [Connectors](https://github.com/OpenCTI-Platform/connectors) - other set of python procs used to ingest, enrich or export data on the platform. They provide the app with a robust net of integrated systems & frameworks to create threat intelligence relations => allowing users to improve their defense tactics


| Class              | Description                                      | Examples                  |
| ------------------ | ------------------------------------------------ | ------------------------- |
| **External Input** | Ingests data from external sources               | CVE, MISP, TheHive, MITRE |
| **Stream**         | Consumes platform data stream                    | History, [Tanium](https://www.tanium.com/)           |
| **Enrichment**     | Takes in new OpenCTI entities from user req      | Observable enrichment     |
| **Import File**    | Extracts info from uploaded reports              | PDFs, [STIX2](https://oasis-open.github.io/cti-documentation/stix/gettingstarted.html) Import        |
| **Export File**    | Exports info from OpenCTI into diff file formats | CSV, STIX2, PDF                          |

## Short Overview

- **Analysis**: contains the input entities in reports analysed and associated external references. Allow for easier identification of the source of information by analysts. Can contribute *(w notes & external resources)* for knowledge enrichment
- **Events**:  involving suspicious and malicious activities across their organisational network. Can record findings and enrich in-house [[write-ups/thm/Intro to Cyber Threat Intel|threat inteligence]] by creating associations for the incidents
- **Observations**: technical elements, detection rules and artifacts identified during a cyber attack. Typically, where [[sheets/Indicators of Compromise (IOCs)]] are gathered which assist analysts in mapping out threat events during a hunt
- **Threats**: all information classified as threatening to an organisation or information would be classified here: threat actors, intrusion set *(TTPs, tools, malware samples & infrastructure used)* and campaigns *(series of attacks taking place within a given period and against specific victims initiated by APTs)*
- **Arsenal**: lists all items related to an attack and any legitimate tools identified from the entities *(e.g malware, attack patterns: TTPs, course of action: MITRE maps, tools, vulnerabilities)*
- **Entities**: categorizes all entities based on operational sectors, countries, organisations and individuals. This information allows for knowledge enrichment on attacks, organisations or intrusion set

## Practical

**What is the name of the group that uses the *4H RAT* malware?**
![[write-ups/images/Pasted image 20230208052353.png]]

**What [[write-ups/thm/Cyber Kill Chain|kill-chain]] execution phase is linked with the *Command-Line Interface* Attack Pattern?**

![[write-ups/images/Pasted image 20230208053334.png]]

![[write-ups/images/Pasted image 20230208053343.png]]

**What Intrusion sets are associated with the Cobalt Strike malware with a Good confidence level?**

![[write-ups/images/Pasted image 20230208053821.png]]

![[write-ups/images/Pasted image 20230208053837.png]]

### Investigative Scenario
As a SOC analyst, you have been tasked with investigations on malware and APT groups rampaging through the world. Your assignment is to look into the [CaddyWiper](https://www.welivesecurity.com/2022/03/15/caddywiper-new-wiper-malware-discovered-ukraine/) malware and [APT37](https://attack.mitre.org/groups/G0067/) group. Gather information from OpenCTI to answer the following questions.

Searching [CaddyWiper into OpenCTI](http://10.10.37.58:8080/dashboard/search/CaddyWiper?) yields the following report

![[write-ups/images/Pasted image 20230208054437.png]]

So we encountered this before in the organization in March 2022. Taking a deeper look @ the attack patterns under the `Knowledge` tab:

![[write-ups/images/Pasted image 20230208054826.png]]

Notice that it uses [Native API](https://attack.mitre.org/techniques/T1106/) technique for the Execution phase of the [[write-ups/thm/Cyber Kill Chain]]. 

![[write-ups/images/Pasted image 20230208055312.png]]

Digging deeper we can determine how many malware connections are linked to this technique in our organization:

![[write-ups/images/Pasted image 20230208055321.png]]

**Which 3 tools were used by the Attack Technique in 2016?**
Under the Native API technique `Knowledge > Tools` tab:

![[write-ups/images/Pasted image 20230208055519.png]]

**What country is APT37 associated with?**
![[write-ups/images/Pasted image 20230208055648.png]]

**Which Attack techniques are used by the group for initial access?**

![[write-ups/images/Pasted image 20230208055748.png]]
## Refs
- [room](https://tryhackme.com/room/opencti)
- [Awesome Knowledge Base in Notion](https://filigran.notion.site/OpenCTI-Public-Knowledge-Base-d411e5e477734c59887dad3649f20518)

## See Also
- [[write-ups/THM]]
- [[write-ups/thm/Intro to Cyber Threat Intel]]
- [[write-ups/thm/misp]]
- [TheHive Project](https://tryhackme.com/room/thehiveproject)
