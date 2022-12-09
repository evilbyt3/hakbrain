---
title: OpenVAS
tags:
- writeups
---

## Write-up
- Install: `docker run -d -p 443:443 --name openvas mikesplain/openvas`
- IMG of report

- **Scenario**: you are assigned to a routine vulnerability management pipeline as a SOC analyst. Your automated pipeline has already pulled a scan on the server, it is up to you to analyze and identify risk in this report.
### Answers
- When did the scan start in Case 001?
	- Feb 28, 00:04:46
- When did the scan end in Case 001?
	- Feb 28, 00:21:02
- How many ports are open in Case 001?
	- 3
- How many total vulnerabilities were found in Case 001?
	- 5
- What is the highest severity vulnerability found? (MSxx-xxx)
	- MS17-010
- What is the first affected OS to this vulnerability?
	- Microsoft Windows 10 x32/x64 Edition
- What is the recommended vulnerability detection method?
	- Send the crafted SMB transaction request with fid = 0 and check the response to confirm the vulnerability


---

## References
- [THM room](https://tryhackme.com/room/openvas)
- [About GVM 10 Arch](https://community.greenbone.net/t/about-gvm-10-architecture/1231)
- [Greenbone](https://www.greenbone.net/) & [github](https://github.com/greenbone)

## See Also
- [[write-ups/THM]]
