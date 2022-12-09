---
title: Redline
tags:
- writeups
---

## Standard Collector Analysis

- What is the suspicious scheduled task that got created on the victim's computer?
	- ![[write-ups/images/Pasted image 20220628184747.png]]
- Find the message that the intruder left for you in the task.
	- `THM-p3R5IStENCe-m3Chani$m`
- There is a new System Event ID created by an intruder with the source name "THM-Redline-User" and the Type "ERROR". Find the Event ID # + Provide the message for the Event ID.
	- ![[write-ups/images/Pasted image 20220628185056.png]]
	- `546` / `Someone cracked my password. Now I need to rename my puppy-++-`
- It looks like the intruder downloaded a file containing the flag for Question 8. Provide the full URL of the website + Provide the full path to where the file was downloaded to including the filename.
	- ![[write-ups/images/Pasted image 20220628185334.png]]
- Provide the message the intruder left for you in the file.
	- navigate to `C:\Program Files (x86)\Windows Mail\SomeMailFolder\flag.txt` locally & open the file => `THM{600D-C@7cH-My-FR1EnD}`

## IOC Search Collector Analysis
- [OpenIOC Editor](https://fireeye.market/apps/211404) by FireEye

- **Scenario**: You are assigned to do a threat hunting task at Osinski Inc. They believe there has been an intrusion, and the malicious actor was using the tool to perform the lateral movement attack, possibly a ["pass-the-hash" attack](https://secureteam.co.uk/articles/information-assurance/what-is-a-pass-the-hash-attack/).
	- **Task**: Can you find the file planted on the victim's computer using IOC Editor and Redline IOC Search Collector?
	- **File Strings:** 
		- `20210513173819Z0w0=`
		- `<?<L<T<g=`
	- **File Size (Bytes)**:
		- 834936
- create a new IOC:
	- ![[write-ups/images/Pasted image 20220629182217.png]]
- open `C:\Users\Administrator\Documents\Analysis\Sessions\AnalysisSession1` in Redline & run an IOC report with the created file
	- ![[write-ups/images/Pasted image 20220629181805.png]]
- plug the MD5 hash into virustotal
	- ![[write-ups/images/Pasted image 20220629181834.png]]
- answers
	- ![[write-ups/images/Pasted image 20220629181854.png]]

## Endpoint Investigation
**Scenario**: A Senior Accountant, Charles, is complaining that he cannot access the spreadsheets and other files he has been working on. He also mentioned that his wallpaper got changed with the saying that his files got encrypted. This is not good news!

- Find the Windows Defender service; what is the name of its service DLL?
	- in `Windows Services`
	- ![[write-ups/images/Pasted image 20220629183232.png]]
- The user manually downloaded a zip file from the web. Can you find the filename?
	- 
- Provide the filename of the malicious executable that got dropped on the user's Desktop.
	- `File system` & filter by `charles -> Desktop`
	- ![[write-ups/images/Pasted image 20220629184540.png]]
- Provide the MD5 hash for the dropped malicious executable.
	- ![[write-ups/images/Pasted image 20220629184638.png]]
- What is the name of the ransomware?
	- [cerber](https://blog.malwarebytes.com/threat-analysis/2016/03/cerber-ransomware-new-but-mature/)

---

## References

## See Also
- [[write-ups/THM]]