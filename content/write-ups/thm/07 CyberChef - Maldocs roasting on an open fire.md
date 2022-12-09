---
title: "07 CyberChef"
date: 2022-12-08
tags:
- writeups
---

## Story
In the previous task, we learned that McSkidy was indeed a victim of a spearphishing campaign that also contained a suspicious-looking document `Division_of_labour-Load_share_plan.doc`. McSkidy accidentally opened the document, and it's still unknown what this document did in the background. McSkidy has called on the in-house expert **Forensic McBlue** to examine the malicious document and find the domains it redirects to. Malicious documents may contain a suspicious command to get executed when opened, an embedded malware as a dropper (malware installer component), or may have some C2 domains to connect to

### Learning Objectives
-   What is CyberChef
-   What are the capabilities of CyberChef
-   How to leverage CyberChef to analyze a malicious document
-   How to deobfuscate, filter and parse the data

## Writeup

Load `Division_of_labour-Load_share_plan.doc` into cyberchef & import the below recipe to complete the task:
```
Strings('Single byte',258,'All printable chars (A)',false,false,false)
Find_/_Replace({'option':'Regex','string':'[\\[\\]\\n_]'},'',true,false,true,false)
From_Base64('A-Za-z0-9+/=',true,false)
Decode_text('UTF-16LE (1200)')
Find_/_Replace({'option':'Regex','string':'[\'()+\'"`]'},'',true,false,true,false)
Find_/_Replace({'option':'Regex','string':']b2H_'},'http',true,false,true,false)
Extract_URLs(false,false,false)
Split('@','\\n')
Defang_URL(true,true,true,'Valid domains and full URLs')
```

## Refs
- [CyberChef](https://cyberchef.org/)

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/06 Email Analysis - It's beginning to look a lot like phishing]] | [[write-ups/thm/08 Smart Contracts - Last Christmas I gave you my ETH]]
