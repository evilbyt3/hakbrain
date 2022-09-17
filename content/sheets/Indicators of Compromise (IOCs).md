---
title: "Indicators of Compromise (IOCs)"
tags:
- sheets
---
You can think of Indicators of Compromise as pieces of information that can be used to detect suspicious or malicious cyber activity. 

IOCs are quantified by traces left by adversaries *(e.g domains, IPs, files, strings, hashes, etc)*. The blue team can then, utilize these IOCs to build detections and analyze behavior.

## Creating IOCs
Tools which might aid in creation:
- [winmd5free](https://www.winmd5.com/)
- `strings`
- IOC Editors: [Fireeye](https://www.fireeye.com/services/freeware/ioc-editor.html) / [Mandiant](https://www.mandiant.com/resources/openioc-basics)

## See Also
- [[write-ups/thm/isac]]
- [[write-ups/thm/misp]]
- [[write-ups/thm/yara]]