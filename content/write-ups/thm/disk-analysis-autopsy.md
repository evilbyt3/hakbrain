---
title: Disk Analysis Autopsy
tags:
- writeups
---

- What is the MD5 hash of the E01 image?
	- ![[write-ups/images/Pasted image 20220630082254.png]]
- What is the computer account name?
	- ![[write-ups/images/Pasted image 20220630070635.png]]
- List all the user accounts. (alphabetical order)
	- ![[write-ups/images/Pasted image 20220630070904.png]]
- Who was the last user to log into the computer?
	- ![[write-ups/images/Pasted image 20220630071004.png]]
	- sivaapriya
- What was the IP address of the computer?
	- ![[write-ups/images/Pasted image 20220630071342.png]]
- What was the MAC address of the computer? (XX-XX-XX-XX-XX-XX)
	- ![[write-ups/images/Pasted image 20220630071852.png]]
	- 08-00-27-2c-c4-b9 & [lookup](https://rst.im/oui/0800272CC4B9)
- Name the network cards on this computer.
	- ![[write-ups/images/Pasted image 20220630072913.png]]
- What is the name of the network monitoring tool?
	- ![[write-ups/images/Pasted image 20220630073013.png]]
- A user bookmarked a Google Maps location. What are the coordinates of the location?
	- ![[write-ups/images/Pasted image 20220630073213.png]]
- A user had a file on her desktop. It had a flag but she changed the flag using PowerShell. What was the first flag?
	- we find this in shreya's desktop
	- ![[write-ups/images/Pasted image 20220630075221.png]]
	- so i decided to check the powershell history for that user: `shreya -> AppData -> Roaming -> Microsoft -> Windows -> PowerShell -> PSReadLine -> ConsoleHost_history.txt`
	- ![[write-ups/images/Pasted image 20220630075432.png]]
- The same user found an exploit to escalate privileges on the computer. What was the message to the device owner?
	- we know from the prev discovery in `exploit.ps1` that the answer is: `Flag{I-hacked-you}`
	- they've got a nice ref to the [privesc technique](https://www.youtube.com/watch?v=C9GfMfFjhYI)
- 2 hack tools focused on passwords were found in the system. What are the names of these tools? (alphabetical order)
	- we see that the `H4S4N` user downloaded mimikatz
	- ![[write-ups/images/Pasted image 20220630075852.png]]
	- I also looked in the detection history of Windows Defender: `ProgramData/Microsoft/Windows Defender/Scans/History/Service/DetectionHistory`
	- & found `lazagna.exe` + `mimilove.exe`
	- ![[write-ups/images/Pasted image 20220630080257.png]]
- There is a YARA file on the computer. Inspect the file. What is the name of the author?
	- keywork search on `.yar` =>
	- ![[write-ups/images/Pasted image 20220630080725.png]]
	- so by navigating to `H4S4N/Downloads/mimikatz_trunk.zip` we get our yara rule file
	- ![[write-ups/images/Pasted image 20220630081307.png]]
	- Benjamin DELPY gentilkiwi
- One of the users wanted to exploit a domain controller with an MS-NRPC based exploit. What is the filename of the archive that you found? *(include the spaces in your answer)*
	- @ first I thought that the suspicious `kill the memory/kill.py` script in sivapriya's desktop has anything to do with it, but I didn't find anything useful so I started looking elsewhere
	- with a quick google search on `MS-NRPC based exploit` we find that the exploit is [ZeroLogon](https://www.crowdstrike.com/blog/cve-2020-1472-zerologon-security-advisory/) => so I did a keyword search for it & found this archive
	- ![[write-ups/images/Pasted image 20220630082101.png]]

---

## References

## See Also
- [[write-ups/thm/autopsy]]
- [[write-ups/THM]]
