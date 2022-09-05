---
title: ISAC
tags:
- writeups
---

Information Sharing and Analysis Centers *(ISACs)*, are used to share and exchange various Indicators of Compromise *(IOCs: MD5s, Ips, YARA rules)* to obtain threat intelligence

## What is Threat Intelligence *(TI)*
- TI or Cyber Threat Intelligence *(CTI)* is used to map thee threat landscape & their Tactics, Techniques & Procedures *(TTP)* which typically revolve around APT groups *(known or new)*
- data -> analyzed & actionable -> threat intel
	- it needs context in order to become intel
- CTI is used by corporations to share knowledge about emerging threats *(keep in mind that adveraries change their TTPs all the time => TI ladscape is constantly changing)*
- vendors/corps will share this knowledge base of intel in Information Sharing & Analysis Centers *(ISACs)*
- broken up  in 3 diff types
	1. Strategic: assist senior management make informed decisions specifically about the security budget and strategies
	2. Tactical: interacts with the TTPs and attack models to identify adversary attack patterns.
	3. Operational: interact with IOCs and how the adversaries operationalize

## What are ISACs
> "Information Sharing and Analysis Centers (ISACs) are member-driven organizations, delivering all-hazards threat and mitigation information to asset owners and operators" - National Council of ISACs

- Maintain situational awareness by sharing and collaborating to maintain CTI, through a [National Council of ISACs](https://www.nationalisacs.org/) *(see [members](https://www.nationalisacs.org/member-isacs-3))*
- ISACs
	- [US-CERT](https://us-cert.cisa.gov/)
	- [AlienVault OTX](https://otx.alienvault.com/)
	- [ThreatConnect](https://threatconnect.com/)
	- [MISP](https://www.misp-project.org/)
	- [ThreatConnect](https://threatconnect.com/)


## Using AlientVault OTX to gather TI
- **Overview of a Pulse**: can consist of a description, tags, indicator types *(file hash, Yara, IP, domain, etc.)*, and threat infrastructure *(country of origin)*. OTX uses pulses as their indicators. A majority of pulses are community-created and maintained. Not all pulses are legit or may contain inaccurate information. Always verify and analyze the indicators used before using them for CTI

### Looking @ the [Xanthe - Docker aware miner](https://otx.alienvault.com/pulse/5fc6767d4cca089129062db9)
- ![[write-ups/images/Pasted image 20220608000446.png]]
	- `reference` section can be used to verify & get further background info on the indicators/pulse
	- `description` gives a brief idea of what the pulse is & how it was gathered 
	- `ATT&CK IDs` can be used to quickly identify what TTPss are being used & familiarize yourself with them by using the [Mitre](../../sheets/Mitre.md) tools
- ![[write-ups/images/Pasted image 20220608000925.png]]
	- the Indicator Overview will give you a very brief statistical representation of the indicators within the pulse as well as threat infrastructure
- ![[write-ups/images/Pasted image 20220608000957.png]]
	- `Type`: the type of indicator *(URL, File Hash, IP, Domain, etc.)*
	- `Indicator`: the indicator itself
	- `Added`: date added, pulses can be updated this can be useful to track the pulses history
	- `Active`: shows, whether the indicator is still seen in the wild and active, can be useful when selecting pulses to use.
	- `Related Pulses`: shows pulses that share the same indicator, can be useful to cross-check indicators.
	- `Extra Information (Advanced)`: these are the advanced options including Dynamic Analysis, Network Activity, and YARA rules.
### Finding Pulses
Based on:
- malware: [LoveLetter](https://otx.alienvault.com/malware/%23fp539598-VBS%2FLoveLetter/)
	- allows you to very quickly find IOCs and rules for a specific strain of malware
	- malware authors are constantly working to change and mitigate indicators and signatures, be aware that indicators change when looking for specific indicators
	- includes: features of the malware, related pulses, process visualization, and file samples if available.
- adversaries: [Stealth Mango & Tangelo](https://otx.alienvault.com/adversary/ Stealth Mango and Tangelo )
- industry: [Finance](https://otx.alienvault.com/industry/Finance)



## Creating IOCs
Tools can help with the creation:
- [winmd5free](https://www.winmd5.com/)
- `strnings`
- IOC Editors: [Fireeye](https://www.fireeye.com/services/freeware/ioc-editor.html) / [Mandiant](https://www.mandiant.com/resources/openioc-basics)

### `cerber.exe` - ransomware
- rdp into windows client: `rdesktop -u Jon -p <password> <ip>:<port>`
- `MD5 hash` of `.exe`: `8b6bc16fd137c09a08b02bbe1bb7d670`
- `.\strings.exe`
	- found possible IOCs *(e.g Ips, BTC addr, uniq function  names, etc)*:
		```bash
		11111kicu4p3050f55f298b5211cf2bb82200aa00bdce0bf
		2222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
		ieeWWWURRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRUWWWeei
		qnleeeWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWeeelnq
		2222222GwwwwG222222
		66222288wwww8822226
		77777889wwww9887777
		##$$$$$$$##
		a>77777@AwwwwA@@7777
		WRRRTUUUwvvwUUURRWW
		WWWWWWUUUywwyeUWWWWWW!)
		rrnddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddnrr
		===@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@=@@@==
		<supportedOS Id="{1f676c76-80e1-4239-95bb-83d0f6d0da78}"/>
		<supportedOS Id="{4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38}"/>
		<supportedOS Id="{35138b9a-5d96-4fbd-8e2d-a2440225f93a}"/>
		```

---

## References
- [The Zoo Malware Repo](https://github.com/ytisf/theZoof)
- [APT Groups & Ops](https://docs.google.com/spreadsheets/u/1/d/1H9_xaxQHpWaa4O_Son4Gx0YOIzlcBWMsdvePFX68EKU/pubhtml)

## See Also
- [[write-ups/THM]]