---
title: Splunk101
tags:
- writeups
---

- Splunk is not only used for security; it's used for data analysis, DevOps, etc
- [Installing Splunk](https://docs.splunk.com/Documentation/Splunk/8.1.2/SearchTutorial/InstallSplunk)

## [What is a SIEM ?](https://www.varonis.com/blog/what-is-siem/)
**Security Information and Event Management** is a software solution that provides a central location to collect log data from multiple sources within your environment. This data is aggregated and normalized, which can then be queried by an analyst.

3 critical capabilities for a SIEM:
1. Thread Detection
2. Investigation
3. Time to respond

Other features might include:
- Basic security monitoring
- Advanced threat detection
- Forensics & incident response
- Log collection
- Normalization
- Notifications and alerts
- Security incident detection
- Threat response workflow

## [Sigma Rules](https://github.com/SigmaHQ/sigma)
> "_Sigma is a generic and open signature format that allows you to describe relevant log events in a straightforward manner. The rule format is very flexible, easy to write and applicable to any type of log file. The main purpose of this project is to provide a structured form in which researchers or analysts can describe their once developed detection methods and make them shareable with others_"

Some supported target SIEMs:

- [Splunk](https://www.splunk.com/)
- [Microsoft Defender Advanced Threat Protection](https://www.microsoft.com/en-us/microsoft-365/windows/microsoft-defender-atp)
- [Azure Sentinel](https://azure.microsoft.com/en-us/services/azure-sentinel/)
- [ArcSight](https://software.microfocus.com/en-us/products/siem-security-information-event-management/overview)
- [QRadar](https://www.ibm.com/products/qradar-siem)

Some projects/products that use Sigma:
- [MISP](https://www.misp-project.org/index.html)
- [THOR](https://www.nextron-systems.com/thor/)
- [Joe Sandbox](https://www.joesecurity.org/)

- Usage: `./sigmac -t splunk -c tools/config/generic/sysmon.yml ./rules/windows/process_creation/win_susp_whoami.yml`
	- or web tool by [Florian Roth](https://socprime.com/leadership/florian-roth/):  [Uncoder.io](https://uncoder.io/)

---

## References

## See Also
- [[write-ups/THM]]
- [[write-ups/thm/splunk-2]]