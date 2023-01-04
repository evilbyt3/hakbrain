---
title: "MasterMinds"
date: 2023-01-04
tags:
- writeups
---
## Infection 1

## Infection 2

![[write-ups/images/Pasted image 20230104140730.png]]

First we should determine the victim IP address, I did that by looking for known malicious patterns

![[write-ups/images/Pasted image 20230104141224.png]]

**Provide the IP address the victim made the POST connections to**
![[write-ups/images/Pasted image 20230104141456.png]]

**How many POST connections were made to the IP address in the previous question?**
This is an easy one, just count the nr of POST req you found in the last question :P

**Provide the domain where the binary was downloaded from**
We know that every time we want to download something we `GET` right? So just modify a little bit our prev query & it reveals our domain & malicious exe

![[write-ups/images/Pasted image 20230104141854.png]]

We can also answer the next 2 questions with this query: 
- downloade binary uri: `/jollion/apines.exe`
- ip address 4 the domain: `45.95.203.28`

**There were 2 Suricata "A Network Trojan was detected" alerts. What were the source and destination IP addresses?**

First I looked @ all the Suricata alerts *(`event_type=="alert"`)* & filtered by `alert.category`:

![[write-ups/images/Pasted image 20230104142444.png]]

Note that the same suspicious IP address from the domain identified earlier is present here as well.

**Taking a look at .top domain in HTTP requests, provide the name of the stealer (Trojan that gathers information from a system) involved in this packet capture using [URLhaus Database](https://urlhaus.abuse.ch/).**

Searching our malicious domain - `hypercustom.top` on the database yields this: 
![[write-ups/images/Pasted image 20230104142918.png]]

It seems that we confront with the [Redline Stealer](https://resources.infosecinstitute.com/topic/redline-stealer-malware-full-analysis/)

## Infection  3

This time it looks like we have a much bigger packet capture

![[write-ups/images/Pasted image 20230104143242.png]]

Finding the victim's IP address is trivial @ this point... *(hint: check id.orig_h)*

**Provide three C2 domains from which the binaries were downloaded**

We know that the binaries were most probably sent over http. So I looked @ all the http traffic from the victim IP containing an `.exe`:

![[write-ups/images/Pasted image 20230104143720.png]]

There we go, we have our russian C2 domains now 

**Provide the IP addresses for all three domains in the previous question**
Answer is in the prev query 

**How many unique DNS queries were made to the domain associated from the first IP address from the previous answer?**

![[write-ups/images/Pasted image 20230104144029.png]]

**How many binaries were downloaded from the above domain in total?**

![[write-ups/images/Pasted image 20230104144105.png]]

**Provided the user-agent listed to download the binaries**
![[write-ups/images/Pasted image 20230104144146.png]]

**Provide the amount of DNS connections made in total for this packet capture**
![[write-ups/images/Pasted image 20230104144214.png]]

**With some OSINT skills, provide the name of the worm using the first domain you have managed to collect from Question 2.**
The domain they're reffering is `afhoahegue.ru`. We can search for more info on  [VirusTotal](https://www.virustotal.com/gui/domain/afhoahegue.ru/details), but I found more information with just a simple google search. It seems that we were hit by the [Phorphiex/Trik Botnet](https://appriver.com/blog/phorphiextrik-botnet-campaign-leads-to-multiple-infections-ransomware-banking-trojan-cryptojacking) - a Ransomware / Banking Trojan

## Refs
- [room](https://tryhackme.com/room/mastermindsxlq)

## See Also
- [[write-ups/thm/Brim]]
