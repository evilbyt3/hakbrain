---
title: "CyberOps Skill Assessment"
date: 2023-02-27
link: 
tags:
- writeups
---

## Gather Basic Information

**Identify time frame of the Pushdo trojan attack, including the date and approximate time**

From the Squil alerts, first contact was at: `2017-06-27 13:38:34 -- 2017-06-27 13:44:32``

![[write-ups/images/Pasted image 20230227145727.png]]

**List the alerts noted during this time frame associated with the trojan.**
```bash
ET CURRENT_EVENTS WinHttpRequest Downloading EXE
ET POLICY PE EXE or DLL Windows file download HTTP
ET POLICY PE EXE or DLL Windows file download HTTP
ET CURRENT_EVENTS Terse alphanumeric executable downloader high likelihood of being hostile
ET POLICY PE EXE or DLL Windows file download HTTP
ET POLICY External IP Lookup Domain (myip.opendns .com in DNS lookup)
ET TROJAN Backdoor.Win32.Pushdo.s Checkin
ET TROJAN Pushdo.S CnC response
ET POLICY TLS possible TOR SSL traffic
```

**List the internal IP addresses and external IP addresses involved.**

```bash
Internal: 192[.]168[.]1[.]96
External: 
	- 119[.]28[.]70[.]207
	- 145[.]131[.]10[.]21
	- 143[.]95[.]151[.]192
	- 208[.]67[.]222[.]222
	- 198[.]1[.]85[.]250
	- 62[.]210[.]140[.]158
	- 208[.]83[.]223[.]34
```

## Learn about the Exploit

### Analyze the infected host
**Based on the alerts, what is the IP and MAC addresses of the infected computer? Based on the MAC address, what is the vendor of the NIC chipset? *(Hint: NetworkMiner or internet search)***

Analyzing the first event *(id = `5410`)* with NetworkMiner reveals more info:
- Compromised host
	- IP: `192.168.1.96`
	- MAC: `00:15:C5:DE:C7:3B`
	- Vendor: `Dell Inc`
- Malicious `.exe` was downloaded from `matied.com` with IP: `119.28.70.207`

![[write-ups/images/Pasted image 20230227151720.png]]

**Based on the alerts, when *(date and time in UTC)* and how was the PC infected? (Hint: Enter the command date in the terminal to determine the time zone for the displayed time)**

Taking a deeper look at the exchange of data between these 2 hosts:

![[write-ups/images/Pasted image 20230227152451.png]]

We retrieve a file `gerv.gun` at `2017-06-27 13:38:32 UTC`. This is most probably the malware executed through the Pushdo trojan

**How did the malware infect the PC? Use an internet search as necessary.**

The user at PC host `192.168.1.96` accessed a malicious domain *(`matied.com`)* and with the use of Pushdo trojan malware was installed *(`gerv.gun`)*. [Pushdo](https://malpedia.caad.fkie.fraunhofer.de/details/win.pushdo) is classified as a "downloader", meaning that it's only purpose is to stay hidden and dowload & install additional malicious software.

Apparently the sophistication lies in the control server:
- when executed, the malware reports back to one of the several control server IPs hard-coded in it
- the c&c server listens on port 80 and pretends to be an Apache webserver, any improperly formatted request made to it answering with: `Looking for blackjack and hookers?` *(the text is simply a misdirection to mask the true nature of it)*
- if the HTTP request contains the following parameters, one or more executables will be delivered via HTTP. The malware to be downloaded is determined by the value of `s_underscore` part of the URL
- ![](https://content.secureworks.com/-/media/Images/Insights/Resources/Threat%20Analysis/038%20pushdo/pushdo-req-params.ashx?la=en&modified=20151123210941&hash=EB0060A94FC1C02A885EB4AA82A856D2)
- additionaly, the Pushdo controller also uses the GeoIP database in conjuction with a whitelist & blacklist country codes to enable the attacker to limit distribution on chosen countries OR to target a specific country

### Examining the exploit

**Based on the alerts associated with HTTP GET request, what files were downloaded? List the malicious domains observed and the files downloaded.**

Applying the same methodology as before for all the alerts downloading a file over HTTP *(ids = 5415, 5420, 5422)* we got the following:
- `GET /gerv.gun` : `matied.com` @ `119.28.70.207`
- `GET /oud/throw.exe` : `lounge-haarstudio.nl` @ `145.131.10.21`
- `GET /wp.exe` : `vantagepointtechnologies.com` @ `143.95.151.192`

**Determine and record the SHA256 hash for the downloaded files that probably infected the computer?**

| executable  | sha256 hash                                                      |
| ----------- | ---------------------------------------------------------------- |
| `gerv.gun`  | 0931537889c35226d00ed26962ecacb140521394279eb2ade7e9d2afcf1a7272 |
| `wp.exe`    | 79d503165d32176842fe386d96c04fb70f6ce1c8a485837957849297e625ea48 |
| `throw.exe` | 94a0a09ee6a21526ac34d41eabf4ba603e9a30c26e6a1dc072ff45749dfb1fe1 |

![[write-ups/images/Pasted image 20230227160207.png]]

**Navigate to [www.virustotal.com](http://www.virustotal.com/) input the SHA256 hash to determine if these were detected as malicious files. Record your findings, such as file type and size, other names, and target machine. You can also include any information that is provided by the community posted in VirusTotal**

- `gerv.gun` - [VT report](https://www.virustotal.com/gui/file/0931537889c35226d00ed26962ecacb140521394279eb2ade7e9d2afcf1a7272)
	- detected by 60 vendors
	- file size & type: 236KB Win32 EXE
	- other names
		```bash
		gerv.gun.octet-stream
		gerv.gun[9].octet-stream
		gerv.gun[3].octet-stream
		gerv.gun.exe
		HTTP-FG0jno3bJLiIzR4hrh.exe
		gerv.gun
		test
		tmp523799.697
		tmp246975.343
		tmp213582.420
		extract-1498570714.111294-HTTP-FG0jno3bJLiIzR4hrh.exe
		0931537889c35226d00ed26962ecacb140521394279eb2ade7e9d2afcf1a7272.bin
		vector.tui
		```
	- [Hybrid Analysis Sandbox Report](https://www.hybrid-analysis.com/sample/0931537889c35226d00ed26962ecacb140521394279eb2ade7e9d2afcf1a7272?environmentId=100)
- `wp.exe` - [VT report](https://www.virustotal.com/gui/file/79d503165d32176842fe386d96c04fb70f6ce1c8a485837957849297e625ea48)
	- detected by 59 vendors
	- file size & type: 300.5KB Win32 EXE
	- other names
		```bash
		wp.exe
		wp.http
		wp[1].exe
		wp.dat
		wp[4].exe
		HTTP-FiS6Ty18r3jnk9xajj.exe
		malware
		test2
		wp.bin
		wp.exe.x-msdownload
		4da48f6423d5f7d75de281a674c2e620.virobj
		test_3
		```
	- [hybrid analysis report](https://www.hybrid-analysis.com/sample/79d503165d32176842fe386d96c04fb70f6ce1c8a485837957849297e625ea48?environmentId=100)
- `throw.exe` - [VT report](https://www.virustotal.com/gui/file/94a0a09ee6a21526ac34d41eabf4ba603e9a30c26e6a1dc072ff45749dfb1fe1)
	- detected by 63 vendors
	- file size & type: 323KB Win32 EXE
	- other names
		```bash
		taswexuahoft.exe
		Pedals
		Pedals.exe
		trow.exe
		trow.http
		trow1(1).exe
		trow(3).exe
		MalwareDownload
		trow.dat
		trow(1).exe
		trow[2].exe
		trow[1].exe
		HTTP-FfmePA13Dx2LcgCLd.exe
		trow.bin
		bad
		test3
		2017-06-28_18-18-14.exe
		bma2beo4.exe
		```
	- [cutwail botnet](https://malwarebreakdown.wordpress.com/2017/06/28/rig-ek-at-188-225-78-135-delivers-pushdo-cutwail-botnet-and-relst-campaign-still-pushing-chthonic/)

**Examine other alerts associated with the infected host during this timeframe and record your findings**

- `ET POLICY External IP Lookup Domain (myip.opendns.com in DNS lookup)` - indicates that the host `192.168.1.96` performed a DNS lookup through an external *(i.e malicious)* domain at ip `208.67.222.222`. This events was most probably how the Pushdo trojan initially got into our network
- `ET TROJAN pushdo.S CnC response` - the control server of the Pushdo Trojan responded from `62.210.140.158` to our infected host
- `ET POLICY TLS possible TOR SSL traffic` - it seems like the malware uses TOR routing to conceal it's location/IP by using hidden services

### Report Findings
**Summarizes your findings based on the information you have gathered from the previous parts, summarize your findings.**

A Windows host with IP `192.168.1.96` accidentally *(or deliberately)* performed a DNS query through a malicious domain and got infected with the Pushdo trojan. This trojan pretends to be an Apache webserver, listening on port 80 and it's primary focus is to further download additional malware. 

In the examined PC, 3 malicious files were downloaded: `gerv.gun`, `wp.exe` and `throw.exe`. By taking the hash for each file & checking them on virustotal, we determined that indeed our network got infected & further action must be taken to contain, eliminate and patch it.




## Refs
- 

## See Also
- ...
