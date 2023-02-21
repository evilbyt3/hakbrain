---
title: "Malbuster"
date: 2023-01-28
tags:
- writeups
---

**Scenario**: You are currently working as a Malware Reverse Engineer for your organisation. Your team acts as a support for the SOC team when detections of unknown binaries occur. One of the SOC analysts triaged an alert triggered by binaries with unusual behaviour. Your task is to analyse the binaries detected by your SOC team and provide enough information to assist them in remediating the threat.


**What is the architecture of `malbuster_1` binary?**

![[write-ups/images/Pasted image 20230128220344.png]]

**What is the MD5 hash of `malbuster_1`?**

![[write-ups/images/Pasted image 20230128221311.png]]

**Using the hash, what is the number of detections of `malbuster_1` in VirusTotal?**

[Virustotal scan](https://www.virustotal.com/gui/file/000415d1c7a7a838ba2ef00874e352e8b43a57e2f98539b5908803056f883176/detection)

**Based on VirusTotal detection, what is the malware signature of `malbuster_2` according to Avira?**

With [VirusTotal](https://www.virustotal.com/gui/file/ace3a5e5849c1c00760dfe67add397775f5946333357f5f8dee25cd4363e36b6/detection) we get `HEUR/AGEN.1202219` which doesn't work. So I just submitted the sample to [OPSWAY MetaDefender](https://metadefender.opswat.com/results/file/ace3a5e5849c1c00760dfe67add397775f5946333357f5f8dee25cd4363e36b6/hash/multiscan) which gave me the answer: `TR/AD.AgentTesla.Jplkg`

**`malbuster_2` imports the function `_CorExeMain`. From which DLL file does it import this function?**


## Refs
- [room](https://tryhackme.com/room/malbuster)
- [MalwareBazar](https://bazaar.abuse.ch/)
- [remnux](https://docs.remnux.org/)
- [flarevm](https://github.com/mandiant/flare-vm)
- [metadefender](https://metadefender.opswat.com/)
- [intezer analyze](https://analyze.intezer.com/)

## See Also
- [[write-ups/THM]]
