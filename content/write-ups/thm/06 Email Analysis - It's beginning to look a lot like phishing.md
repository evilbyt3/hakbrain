
2 main concerns:
- security: identifying suspicious/spam/malicious emails
- performance: identifying delivery & delay issues in emails

## [[Phising]]

-  will usually appear to come from a trusted source, whether that's a person or a business.
- include content that tries to tempt or trick people into downloading software, opening attachments, or following links to a bogus website.
- more on [phising module THM](https://tryhackme.com/module/phishing)

## Does it still matter? xD

-  academic research and technical reports highlight that they're still quite common
- also used in pentesting / red teaming
-  is still an important skill to have

### Analyzing

- Tools
	- [emlAnalyzer](https://pypi.org/project/eml-analyzer/)
	- [emailrep.io](https://emailrep.io/)
	- [VirusTotal]()
	- [inquest](https://labs.inquest.net/)
	- [ipinfo](https://ipinfo.io/)
	- [urlscan](https://urlscan.io/)
	- [Browserling](https://www.browserling.com/)
	- [wannabrowse](https://www.wannabrowser.net/)
	- [Talos](https://talosintelligence.com/reputation)
	- [yara-rules](https://github.com/InQuest/yara-rules)
- [header]() 

| Field                       | Details |
| --------------------------- | ------- |
| From                        |         |
| To                          |         |
| Date                        |         |
| Subject                     |         |
| Domain Key & DKIM Signature |         |
| SPF                         |         |
| Message-ID                  |         |
| MIME-Version                |         |
|                             |         |

- checklist



