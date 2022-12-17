---
title: "14 Web Apps - I'm dreaming of secure web apps"
date: 2022-12-17
tags:
- writeups
---

## Story
Elf McSkidy was sipping her coffee when she saw on her calendar that it was time to review the web application’s security. An internal web application is being developed to be used internally and manage the cyber security team. She calls Elf Exploit McRed and asks him to check the in-development web application for common vulnerabilities. Elf Exploit McRed discovers that the local web application suffers from an Insecure Direct Object References (IDOR) vulnerability.

### Learning Objectives
- Web Applications
- The Open Web Application Security Project (OWASP) Top 10
- IDOR

## Practical

Upon loggin in we get to `http://10.10.47.238:8080/users/101.html`
![[Pasted image 20221217050543.png]]

Changing it to `102` we get another user:
![[Pasted image 20221217050621.png]]

We can do the same for listing all the profile images @ `http://10.10.47.238:8080/images/100.png`. Writing a simple bash script to list & retrieve all images gives us the flag:

```bash
#!/bin/bash

```

![[Pasted image 20221217050821.png]]

## Refs
- [Official Walkthrough]()
- [OWASP Top 10](https://owasp.org/Top10/)
- [Corridor room](https://tryhackme.com/room/corridor)

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/13 Packet Analysis - Simply having a wonderful pcap time]] | [[write-ups/thm/15 Secure Coding - Santa is looking for a Sidekick]]
