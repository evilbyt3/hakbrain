---
title: "16 Secure Coding - SQLi's the king, the carolers sing"
date: 2022-12-17
tags:
- writeups
---

## Story
Set to have all their apps secured, the elves turned towards the one Santa uses to manage the present deliveries for Christmas. Elf McSkidy asked Elf Exploit and Elf Admin to assist you in clearing the application from SQL injections. When presented with the app's code, both elves looked a bit shocked, as none of them knew how to make any sense of it, let alone fix it. **"We used to have an Elf McCode, but he founded a startup and helps us no more"**, said Admin.

After a bit of talk, it was decided. The elves returned carrying a pointy hat and appointed you as the new Elf McCode. Congratulations on your promotion!


## Practical

with `id=-1 union all select null,null,username,password,null,null,null from users`

![[write-ups/images/Pasted image 20221217073420.png]]

### Patching

![[write-ups/images/Pasted image 20221217075731.png]]

Thanks robot :D, now I also modified the query on planned delieveries to use `intval` & we get the flag: 

![[write-ups/images/Pasted image 20221217075823.png]]

![[write-ups/images/Pasted image 20221217075851.png]]

Going in `login.php` we get this code:

![[write-ups/images/Pasted image 20221217075922.png]]

Seems like we need to do pretty much the same, but let's have a little more fun with [chatGPT]() & see if it can help us:

![[write-ups/images/Pasted image 20221217080220.png]]

Wow it even recognized that it's vulnerable without me telling it, recommending a more secure implementation. Quite impressive AI-pal



## Refs
- [Official Walkthrough](https://www.youtube.com/watch?v=iv02-Oi0TvM)
- [SQL Injection Room](https://tryhackme.com/room/sqlinjectionlm)

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/15 Secure Coding - Santa is looking for a Sidekick]] | [[]]
