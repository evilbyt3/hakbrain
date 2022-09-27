---
title: "Technologies in the SOC"
date: 2022-09-28
tags:
- sheet
---

## SIEM

A security information and event management system aggregates & makes sense of all the data/logs that firewalls, network appliances, intrusion detection systems, and other devices generate.

![[sheets/images/Pasted image 20220928012038.png]]

They're used for multiple purposes to make the work of an [[sheets/People in the SOC|SOC analyst]] easier:
- Event collection, correlation, and analysis
- Security monitoring
- Security control
- Log management
- Vulnerability assessment
- Vulnerability tracking
- Threat intelligence


## SOAR
The security orchestration, automation and response is often paired together with a SIEM to complement each other's capabilities. SOAR platforms are similar to SIEMs in that they aggregate, correlate, and analyze alerts. 

However, SOARs take a step further by integrating threat intelligence and automating incident investigation and response workflows based on playbooks developed by the security team in order to automate the work of an Analyst.

![[sheets/images/Pasted image 20220928012100.png]]

They are capable to:
- Gather alarm data from each component of the system.
- Provide tools that enable cases to be researched, assessed, and investigated.
- Emphasize integration as a means of automating complex incident response workflows that enable more rapid response and adaptive defense strategies.
- Include pre-defined playbooks that enable automatic response to specific threats. Playbooks can be initiated automatically based on predefined rules or may be triggered by security personnel

This frees security personnel to address more pressing matters and high-end investigation and threat remediation by automation of [[sheets/Processes in the SOC|SOC workflows]]. Because SIEM systems necessarily produce more alerts than most SecOps teams can realistically investigate in order to conservatively capture as many potential exploits as possible.

## See Also
[[sheets/Security Opertions Center (SOC)]]