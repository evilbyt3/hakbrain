---
title: "18 Sigma - Lumberjack Lenny learns new rules"
date: 2022-12-19
tags:
- writeups
---

## Story
Compromise has been confirmed within the Best Festival Company Infrastructure, and tests have been conducted in the last couple of weeks. However, Santa’s SOC team wonders if there are methodologies that would help them perform threat detection faster by analysing the logs they collect. Elf McSkidy is aware of Sigma rules and has tasked you to learn more and experiment with threat detection rules.

### Attack Scenario
Elf McBlue obtained logs and information concerning the attack on the Best Festival Company by the Bandit Yeti. Through the various analysis of the previous days, it was clear that the logs pointed to a likely attack chain that the adversary may have followed and can be mapped to the Unified Kill Chain. Among the known phases of the UKC that were observed include the following:
-   **Persistence**: The adversary established persistence by creating a local user account they could use during their attack.
-   **Discovery**: The adversary sought to gather information about their target by running commands to learn about the processes and software on Santa’s devices to search for potential vulnerabilities.
-   **Execution**: Scheduled jobs were created to provide an initial means of executing malicious code. This may also provide them with persistence or be part of elevating their privileges.

Additionally, here are the [[Mitre ATT&CK]] techniques & IOCs identified

| Attack Technique                                                 | [[sheets/Indicators of Compromise (IOCs)]]                                                                                                                                                                   |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [Account Creation](https://attack.mitre.org/techniques/T1136/)   | EventID: 4720 <br> Service: Security                                                                                                                                                                         |
| [Software Discovery](https://attack.mitre.org/techniques/T1518/) | Category: proc creation <br> EventID: 1 <br> Service: [[sysmon]] <br> Image: `C:\Windows\System32\reg.exe` <br> CmdLine: `reg query “HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer” /v svcVersion` |
| [Scheduled Task](https://attack.mitre.org/techniques/T1053/005/) | Category: proc creation <br> EventID: 1 <br> Service: [[write-ups/thm/sysmon]] <br> Image: `C:\Windows\System32\schtasks.exe` <br> Parent Image: `C:\Windows\System32\cmd.exe` <br> CmdLine: `schtasks /create /tn "T1053_005_OnLogon" /sc onlogon /tr "cmd.exe /c calc.exe"`                                                                                                                                                                                                             |


## Notes


### [sigma](https://github.com/SigmaHQ/sigma): generic signature format for [[SIEM]] systems
- uses [YAML](http://yaml.org/)
- developed to satisfy the following scenarios:
	- make detection methods and signatures shareable alongside [[sheets/Indicators of Compromise (IOCs)|IOCs]] and [[write-ups/thm/yara]] rules
	- write SIEM searches that avoid vendor lock-in 
	- share signatures with [[write-ups/thm/Red Team Threat Intel|threat intelligence]] communities
	- write custom detection rules for malicious behaviour based on specific conditions
- sigma rules are converted to fit the desired SIEM query, and in our case, it should be known that they are being transformed into Elastic Queries on the backend
- useful tools
	- [pySigma](https://github.com/SigmaHQ/pySigma): python lib to parse & convert Sigma rules into queries
	- [uncoder.io](https://uncoder.io/): web-based Sigma converter for numerous SIEM & EDR platforms

## Practical

![[write-ups/images/Pasted image 20221219215948.png]]

![[write-ups/images/Pasted image 20221219221432.png]]

![[write-ups/images/Pasted image 20221219222353.png]]


## Refs
- [Oficial Walkthrough](https://www.youtube.com/watch?v=4Zqd_FlkEu8)
- [Sigma](https://github.com/SigmaHQ/sigma)

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/17 - Secure Coding - Filtering for Order Amidst Chaos]] | [[]]
