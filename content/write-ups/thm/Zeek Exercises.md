---
title: "Zeek Exercises"
date: 2023-01-01
tags:
- writeups
---

## Anomalous DNS

Generate log files from pcap: `zeek -Cr dns-tunneling.pcap`. We're asked to check the nr of DNS records linked to [[IPv6]] addresses => [AAAA Records](https://www.whatsmydns.net/dns-lookup/aaaa-records)

![[write-ups/images/Pasted image 20230101175651.png]]

Looking at `conn.log` we can determine what's the longest connection duration by looking @ the `duration` field:

![[write-ups/images/Pasted image 20230101180217.png]]


Getting back to `dns.log`: notice that a log of domain queries are made on the `<subdomain>.cisco-update.com`:

![[write-ups/images/Pasted image 20230101180450.png]]

Parsing this with some bash magic we can find the nr of unique domain queries:

![[write-ups/images/Pasted image 20230101183627.png]]

We can notice the enourmous amount of DNS queries sent to the `cisco-update.com` subdomains. This is quite abnormal & it indicate that data is exfiltrated *(total DNS queries = 7247 of which 6983 are to cisco)*

![[write-ups/images/Pasted image 20230101184006.png]]

Investigating further I looked in `conn.log` to determine who did all of these strange queries:

![[write-ups/images/Pasted image 20230101184213.png]]

## Phising
Looking @ the generated `http.log` reveals that 3 files we're retrieved, from which 2 seem suspicious *(`.exe` & `.doc`)*:

![[write-ups/images/Pasted image 20230101185942.png]]

I took note of the ip & domain in defanged format: `10[.]6[.]27[.]102`, `smart-fax[.]com`. Going further, we can make use of Zeek's scripting language to extract the files & get the hashes for the files:

![[write-ups/images/Pasted image 20230101190610.png]]

With this information we can plug the md5 hash to [virustotal](https://www.virustotal.com/gui/file/f808229aa516ba134889f81cd699b8d246d46d796b55e13bee87435889a054fb) in order to get a better idea of what we're up against. By skimming through the info there, we learn that the `doc` file is most probably decepting the user into allowing VBA to run which allows it to drop an exe file.

Since we have also extracted the `knr.exe` file we can [look into that](https://www.virustotal.com/gui/file/749e161661290e8a2d190b1a66469744127bc25bf46e5d0c6f2e835f4b92db18/relations) as well. Commonly seen as `PleaseWaitWindow.exe` is most probably a variant of [NetWire](https://resources.infosecinstitute.com/topic/netwire-malware-what-it-is-how-it-works-and-how-to-prevent-it-malware-spotlight/). One of the contacted domain names is `hopto[.]org`

## Log4J

Use provided script on our pcap to generate logs: `zeek -Cr log4shell.pcapng detection-log4j.zeek`. Looking @ `signatures.log` we see that we have 3 hits:

![[write-ups/images/Pasted image 20230101192049.png]]

Furthermore, checking the `http.log` we find that [[nmap]] was used to scan for the vulnerability

![[write-ups/images/Pasted image 20230101192501.png]]

Along with the exploit file *(`ExploitQ8v7ygBW4i.class`)* & this peculiar user-agent:

![[write-ups/images/Pasted image 20230101192553.png]]

Because we used the [cve-2021-44228](https://github.com/corelight/cve-2021-44228) zeek package we also have generated a `log4j.log` file. Taking a look @ it might reveal the commands executed:

![[write-ups/images/Pasted image 20230101193114.png]]


## Refs
- [room](https://tryhackme.com/room/zeekbroexercises)

## See Also
- [[write-ups/thm/Zeek]]
