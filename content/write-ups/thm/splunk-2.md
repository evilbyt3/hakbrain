---
title: Splunk 2
tags:
- writeups
---

**BOTSv2 Github**: [https://github.com/splunk/botsv2](https://github.com/splunk/botsv2)

In this exercise, you assume the persona of Alice Bluebird, the analyst who successfully assisted Wayne Enterprises and was recommended to Grace Hoppy at Frothly (_a beer company_) to assist them with their recent issues.

## 100
- find amber's ip addr: `index="botsv2" sourcetype="pan:traffic" amber`
	- ![[write-ups/images/Pasted image 20220615160908.png]]
- filter HTTP traffic based on the found ip: `index="botsv2" 10.0.2.101 sourcetype="stream:HTTP"`
- filter out the noise by removing the duplicatess *(`dedup`)* & format in a `table`: `index="botsv2" sourcetype="stream:http" 10.0.2.101 | dedup site | table site`
	- ![[write-ups/images/Pasted image 20220615161055.png]]
- we know Amber works in the *beer* industry: `index="botsv2" sourcetype="stream:http" 10.0.2.101 *beer* | dedup site | table site`
	- ![[write-ups/images/Pasted image 20220615161259.png]]
- now that we have the competitor website we can search for all traffic from Amber to it & look for an image: `index="botsv2" sourcetype="stream:http" 10.0.2.101 berkbeer.com | table uri_path`
	- ![[write-ups/images/Pasted image 20220615161602.png]]
- we know that Amber found the CEO & sent him an email
	- firstly we need the Amber's email: `index="botsv2" sourcetype="stream:smtp" amber`
		- ![[write-ups/images/Pasted image 20220615161854.png]]
	- now we can search for any communication w the competitor: `index="botsv2" sourcetype="stream:smtp" aturing@froth.ly berkbeer.com`
		- ![[write-ups/images/Pasted image 20220615162236.png]]
		- ![[write-ups/images/Pasted image 20220615162323.png]]
		- ![[write-ups/images/Pasted image 20220615162650.png]]
- so Amber contacted the CEO *(Martin Berk)* & suggested to discuss about a possible future collaboration as she was feeling insecure about her current job -> Martin Berk responded by telling her he's open to discuss, but he'll also like to have Bernhard on the call. Furthermore, Bernard asked Amber if she had a personal email to reach her. Which she responded with in a base64 encoded email in which she gave her personal email + an attached document
	- ![[write-ups/images/Pasted image 20220615163341.png]]
	- ![[write-ups/images/Pasted image 20220615163402.png]]


## 200
- get the tor version Amber was running: `index="botsv2" amber tor | reverse`
	- ![[write-ups/images/Pasted image 20220615164406.png]]
- determine the public IP address for brewertalk.com and the IP address performing a web vulnerability scan against it
- find out the public IPv4 addr of the server running `www.bewertalk.com`: `index="botsv2" brewertalk.com | dedup src_ip | table src_ip`
	- ![[write-ups/images/Pasted image 20220615165221.png]]
	- ![[write-ups/images/Pasted image 20220615165137.png]]
- the `45.77.65.211` iss hitting the hardest so we can assume that is the originator of the web vuln scan
- `index="botsv2" src_ip="45.77.65.211"` to see all traffic & filter by `uri_path` in **Interesting Fields**
	- ![[write-ups/images/Pasted image 20220615165808.png]]
- filtering by the newly identified attacked `uri_path` we can see what SQL function is being abused: `index="botsv2" src_ip="45.77.65.211" uri_path="/member.php"`
	- ![[write-ups/images/Pasted image 20220615170028.png]]
- identify the cookie value that was transmitted as part of an XSS attack. The user has been identified as Kevin. 
	- `index="botsv2" kevin cookie` => `mybb[lastvisit]=1502408189`
		- ![[write-ups/images/Pasted image 20220615170916.png]]
	- the attacker used the stolen CSRF token to perform a [homograph attack](https://blog.malwarebytes.com/101/2017/10/out-of-character-homograph-attacks-explained/)
	- quering by it: `index="botsv2" 1bc3eab741900ab25c98eee86bf20feb`
		- ![[write-ups/images/Pasted image 20220615171544.png]]

## 300
- Mallory's critical PowerPoint presentation on her MacBook gets encrypted by ransomware on August 18. What is the name of this file after it was encrypted?
	- `index="botsv2" mallory` would yield the single MacBook host: `maclory-air13`
	- since we're looking for a PowerPoint presentation we can add common file extenstions: `index="botsv2" host="maclory-air13"  (*.ppt OR *.pptx)`
	- ![[write-ups/images/Pasted image 20220615173509.png]]
- There is a Games of Thrones movie file that was encrypted as well. What season and episode is it?
	- `index="botsv2" host="maclory-air13" sourcetype="ps" *.crypt got` OR `index="botsv2"  got (*.crypt)`
	- ![[write-ups/images/Pasted image 20220615180844.png]]
- Kevin Lagerfield used a USB drive to move malware onto kutekitten, Mallory's personal MacBook. She ran the malware, which obfuscates itself during execution. Provide the vendor name of the USB drive Kevin likely used. Answer Guidance: Use time correlation to identify the USB drive.
	- search for usb activity for kutekitten: `index="botsv2" kutekitten usb`
	- ![[write-ups/images/Pasted image 20220616140829.png]]
	- got the `vendor id` & with a simple google search we find that `Alcor Micro Corp.` is the answer
- What programming language is at least part of the malware from the question above written in?
	- staarted looking for files inside the `mkreusen` user: `index="botsv2" kutekitten "\\/Users\\/mkraeusen"`
	- found interesting field: `target_path` & filtered by it
	- ![[write-ups/images/Pasted image 20220616174446.png]]
	- got the hash of the file & uploaded to [VirusTotal](https://www.virustotal.com/gui/file/befa9bfe488244c64db096522b4fad73fc01ea8c4cd0323f1cbdee81ba008271/detection)
		- ![[write-ups/images/Pasted image 20220616174542.png]]
	- on the Details page we see that it's written in `perl` & it was first seen in the wild in `2017-01-17 19:09:06 UTC`
	- the malware is a [Mac backdoor used to spy on users](https://blog.malwarebytes.com/threat-analysis/2017/01/new-mac-backdoor-using-antiquated-code/) which was active for 10 years upon detection
- The malware infecting kutekitten uses dynamic DNS destinations to communicate with two C&C servers shortly after installation. What is the fully-qualified domain name (FQDN) of the first (alphabetically) of these destinations?
	- also from [VirusTotal](https://www.virustotal.com/gui/file/befa9bfe488244c64db096522b4fad73fc01ea8c4cd0323f1cbdee81ba008271/relations) report we know the C&C DNS desstinations
	- ![[write-ups/images/Pasted image 20220616181540.png]]


## 400
- A Federal law enforcement agency reports that Taedonggang often spear phishes its victims with zip files that have to be opened with a password. What is the name of the attachment sent to Frothly by a malicious Taedonggang actor?
	- so we know the extension `.zip` & that the malware is sspreaad through spear phising, let's start there: `index="botsv2" sourcetype="stream:smtp" *.zip`
	- we get back 6 events & by taking a quick look we can see that the attackers use the `invoice.zip` file attachment to infect the user
- What is the password to open the zip file?
	- taking a look @ the initial email
	- ![[write-ups/images/Pasted image 20220616182308.png]]
	- or: `index="botsv2" sourcetype="stream:smtp" *.zip "attach_filename{}"="invoice.zip" "password"`
- The Taedonggang APT group encrypts most of their traffic with SSL. What is the "SSL Issuer" that they use for the majority of their traffic? Answer guidance: Copy the field exactly, including spaces.
	- we can get find the `invoice.zip` file encoded in base64 in one of the events
	- download it & decode: `cat invoice_b64 | base64 -d > invoice.zip`
	- unzip the file to get the document: `unzip invoice.zip`
	- ![[write-ups/images/Pasted image 20220616185502.png]]
	- got the SHA256 hash: `sha256sum invoice.doc` > `d8834aaa5ad6d8ee5ae71e042aca5cab960e73a6827e45339620359633608cf1`
	- uploading it to [VirusTotal](https://www.virustotal.com/gui/file/d8834aaa5ad6d8ee5ae71e042aca5cab960e73a6827e45339620359633608cf1/details) & [HybridAnalysis](https://www.hybrid-analysis.com/sample/d8834aaa5ad6d8ee5ae71e042aca5cab960e73a6827e45339620359633608cf1) gets us a list of C&C ips
	- ![[write-ups/images/Pasted image 20220616185624.png]]
	- now we can query any tcp traffic on that ip: `index="botsv2" sourcetype="stream:tcp" 45.77.65.211` to find the SSL issuer
	- ![[write-ups/images/Pasted image 20220616185807.png]]
- What unusual file *(for an American company)* does `winsys32.dll` cause to be downloaded into the Frothly environment?
	- `index="botsv2" winsys32.dll`
	- ![[write-ups/images/Pasted image 20220616185959.png]]
	- `index="botsv2" sourcetype="stream:ftp"`
	- ![[write-ups/images/Pasted image 20220616190959.png]]
	- since the only method for downloading something is `RETR` I filtered by it: `index="botsv2" sourcetype="stream:ftp" method=RETR`
	- ![[write-ups/images/Pasted image 20220616191046.png]]
	- the only susspicious file is `나는_데이비드를_사랑한다.hwp`
- What is the first and last name of the poor innocent sap who was implicated in the metadata of the file that executed PowerShell Empire on the first victim's workstation? Answer example: John Smith
	- looking @ the metadata of the `invoice.doc` we find the Author
	- ![[write-ups/images/Pasted image 20220616192213.png]]
- Within the document, what kind of points is mentioned if you found the text?
	- `CyberEastEggs` as we saw in a prev image
- To maintain persistence in the Frothly network, Taedonggang APT configured several Scheduled Tasks to beacon back to their C2 server. What single webpage is most contacted by these Scheduled Tasks? 
	- usually adverssariess use `schtasks.exe` to lunch scheduled tasks: `index="botsv2" schtasks.exe`
	- to narrow down our results I only looked @ sysmon logs: `index="botsv2" schtasks.exe sourcetype="XmlWinEventLog:Microsoft-Windows-Sysmon/Operational"` & focused on the day of the incident: `August 24 2017` => only 5 events
	- from there we get the command that sets up the scheduled task
		```powershell
		C:\Windows\system32\schtasks.exe" /Create /F /RU system /SC DAILY /ST 10:51 /TN Updater /TR "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NonI -W hidden -c \"IEX ([Text.Encoding]::UNICODE.GetString([Convert]::FromBase64String((gp HKLM:\Software\Microsoft\Network debug).debug)))\
		```
	- we can see that it uses the `HKLM:\Software\Microsoft\Network` registry key to make a web request so I filtered by it: `index="botsv2" source="winregistry"  "Software\\Microsoft\\Network"` => getting the base64 encoded value
	- ![[write-ups/images/Pasted image 20220616195011.png]]


---

## References
- [room](https://tryhackme.com/room/splunk2gcd5)
- [Hybrid Analysis](https://www.hybrid-analysis.com/)
- [Any.run](https://app.any.run/)
- [Diamon Model for Intrustion Analysis](https://www.activeresponse.org/wp-content/uploads/2013/07/diamond.pdf)

## See Also
- [[write-ups/thm/splunk-101]]
- [[write-ups/THM]]
