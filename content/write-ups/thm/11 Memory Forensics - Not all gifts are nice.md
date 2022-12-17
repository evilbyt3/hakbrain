---
title: "11 Memory Forensics - Not all gifts are nice"
date: 2022-12-14
tags:
- writeups
---

## Story 
The elves in Santa's Security Operations Centre (SSOC) are hard at work checking their monitoring dashboards when Elf McDave, one of the workshop employees, knocks on the door. The elf says, _"I've just clicked on something and now my workstation is behaving in all kinds of weird ways. Can you take a look?"._

Elf McSkidy tasks you, Elf McBlue, to investigate the workstation. Running down to the workshop floor, you see a command prompt running some code. Uh oh! This is not good. You immediately create a memory dump of the workstation and place this dump onto your employee-issued USB stick, returning to the SSOC for further analysis.

_You plug the USB into your workstation and begin your investigation._


## Notes

### Memory Forensics
- Memory forensics is the analysis of the volatile memory that is in use when a computer is powered on.
- Computers use dedicated storage devices called Random Access Memory *(RAM)* to remember what is being performed on the computer @ the time
- RAM is extremely quick, thus is the preffered option. But it's limited in that it deletes upon shutdown compared with hard drives
- taking a snapshot of the RAM can reveal running processes, network connections, etc
- this is useful when it comes to malware, since its common for malicious code to attempt to hide from the user by injecting itself in runnning processes 
- by analysing the memory, we can discover exactly what the malware was doing, who it was contacting, and so forth

### Practical
- we're provided with a memory dump called `workstation.vmem`
- we can analyze it using [[write-ups/thm/volatility]] which is a known tool used to analyse memory dumps taken from Windows, Linux and Mac OS devices. It can:
	- list all procs that were running @ the time of the capture
	- lsit active / closed network connections
	- use [[write-ups/thm/yara]] rules to search for indicators of malware
	- retrieved hashed passwords, clipboard contents & cmd prompt output
	- much more
- to get a better idea of what we have to deal with I ran `python3 vol.py -f workstation.vmem windows.info` which revealed more about the OS *(e.g Windows 10)*
	- ![[Pasted image 20221214091923.png]]
- let's take a look at what processes were running by executing the `windows.pslist` cmd. Upon inspection I noticed a peculiar file called `mysterygift.exe`
	- ![[Pasted image 20221214092206.png]]
- to dump the contents of this binary we must use the `windows.dumpfiles` plugin providing a PID. From our previous cmd we know that ours is `2040`:
	- ![[Pasted image 20221214092621.png]]
- there are 16 files related to our `mysterygift`, much of them DLLs. Looking in our current folder we can see all of our files dumped & ready for further inspection
	- ![[Pasted image 20221214092835.png]]




## Refs
- [Officail Walkthrough](https://www.youtube.com/watch?v=RsJR2z_agiY)
- [volatility plugins](https://volatility3.readthedocs.io/en/latest/volatility3.plugins.html)
- [Digital Forensics & Incident Response module](https://tryhackme.com/module/digital-forensics-and-incident-response)

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/10 Hack a game - You're a mean one, Mr Yeti]] | [[write-ups/thm/12 Malware Analysis - Forensic McBlue to the REVscue!]]
