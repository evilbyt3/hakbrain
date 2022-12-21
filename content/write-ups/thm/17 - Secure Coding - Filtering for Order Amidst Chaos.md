---
title: "17 - Secure Coding - Filtering for Order Amidst Chaos"
date: 2022-12-19
tags:
- writeups
---

## Story
After handling unrestricted file uploads and SQLi vulnerabilities, McSkidy continued to review Santa's web applications. She stumbled upon user-submitted inputs that are unrecognizable, and some are even bordering on malicious! She then discovered that Santa's team hadn't updated these web applications in a long time, as they clearly needed more controls to filter misuse. Can you help McSkidy research and learn a useful technique to handle that in the future?

## Notes

### Regex 101


| []         | Char Set: matches any single character/range of characters inside                       |
| ---------- | --------------------------------------------------------------------------------------- |
| .          | Wildcard: matches any character                                                         |
| *          | Star / Asterisk Quantifier: matched the preceding token zero or more times              |
| +          | Plus Quantifier: matches the preceding token one or more times                          |
| {min, max} | Curly Brace Quantifier: specifies how many times the preceding token can be repeated    |
| ()         | Groupings: groups a specific part of the regex for better management                    |
| \\         | Escape: escapes the regex operator so it can be matched                                 |
| ?          | Optional: specified that the preceding token is optional                                |
| ^          | Anchor Beginning: specifies that the consequent token is at the beginning of the string |
| $          | Anchor Ending: specifies that the preceding token is at the end of the string                                                                                        |


## Practical
- filtering usernames:
	- ![[Pasted image 20221219155627.png]]
- filtering emails
	- ![[Pasted image 20221219160036.png]]
	- ![[Pasted image 20221219160303.png]]
- filtering URLs
	- ![[Pasted image 20221219160803.png]]

## Refs
- [Official Walkthrough]()
- [RegExp QuickStart](https://www.regular-expressions.info/quickstart.html)

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/16 Secure Coding - SQLi's the king, the carolers sing]] | [[write-ups/thm/18 Sigma - Lumberjack Lenny learns new rules]]
