---
title: "10 Hack a game - You're a mean one, Mr Yeti"
date: 2022-12-14
tags:
- writeups
---

## Story
Santa's team have done well so far. The elves, blue and red combined, have been securing everything technological all around. The Bandit Yeti, unable to hack a thing, decided to go for eldritch magic as a last resort and trapped Elf McSkidy in a video game during her sleep. When the rest of the elves woke up, their leader was nowhere to be found until Elf Recon McRed noticed one of their screens, where Elf McSkidy's pixelated figure could be seen. By the screen, an icy note read: **"Only by winning the unwinnable game shall your dear Elf McSkidy be reclaimed"**.

Without their chief, the elves started running in despair. How could they run a SOC without its head? The game was rigged, and try after try, the elves would lose, no matter what. As struck by lightning, Elf Exploit McRed stood up from his chair and said to the others: **"If we can't win it, we'll hack it!"**.

### Learning Objectives 
- Learn how data is stored in memory in games or other applications.
- Use simple tools to find and alter data in memory.
- Explore the effects of changing data in memory on a running game.

## Notes
- Installing [Cetus](https://github.com/Qwokka/Cetus):
	- Download [latest release](https://github.com/Qwokka/Cetus/releases)
	- Unpack zip file: `unzip Cetus_v1.03.1.zip`
	- [Install extension with Chrome](https://stackoverflow.com/a/24577660): navigate to `chrome://extensions`, enable developer mode & `Load unpacked extension`
- Let's have a look @ the game:
	- ![[write-ups/images/Pasted image 20221214081719.png]]
- Guessing the guard's number: Upon interacting with the guard he proposes a deal where we need to guess the number between 1 and 99999999 that he thinks about 
	- we get prompted to enter the nr, so I just took a random guess
	- ![[write-ups/images/Pasted image 20221214081908.png]]
	- afterwards we find his number, in this case `6875008`
	- ![[write-ups/images/Pasted image 20221214081940.png]]
	- we can make use of this number's memory address so that we can observe any changes when the guard "thinks" of another one, that way we can read minds :0
	- achieving that is quite easy with Cetus: we need to look for an integer that is = to `6875008` & bookmark its memory address *(`0x0004ea34`)*
	- ![[write-ups/images/Pasted image 20221214082355.png]]
	- we can validate the address by converting the hex value `0x0068e780` to an integer
	- ![[Pasted image 20221214082716.png]]
	- now that we know we have the right address, I just re-iterated the interaction with the guard. This time, however, we can "read his mind", convert from hex to int & answer correctly
	- ![[Pasted image 20221214082942.png]]
	- ![[Pasted image 20221214083018.png]]
- Passing the bridge. Once the gates open we find ourselves on a bridge full of snowball cannons. I've tried going through them, but without success. So if we don't have gaming skills, let's test our hacking ones :P
	- there are basically 2 ways we can cross the bridge
		- find a way to change our position *(i.e x & y coordinates)*
		- become invincible *(i.e health is not changed when hit by cannon)* or regain health on impact
	- the intented way is to use something called **differential search** which is a way to look for memory positions based on specific **variations on the value**, rather than the value itself. Using this method we can locate the address of where our health is stored & freeze its value => invincibility achieved
	- Let's give it a try
		1. search with an empty value => total nr of memory addresses mapped by the game
			- ![[Pasted image 20221214084222.png]]
		2. we get a total of `16777216` results. that's quite a lot, so let's filter it by taking damage once from the cannon & searching for any address that changed it's value since our last search
			- ![[Pasted image 20221214084943.png]]
		4. `0x0004b4a4` sticks out as the most appropiate address which could store our health based on its value. Let's validate this by bookmarking that address & go to take damage 1 more time:
			- ![[Pasted image 20221214085044.png]]
		5. notice the change of `0x0004b4a4` from `85` to `70` *(each hit deals 15 damage)* . now that we know where our health is we can manually modify it with `Write Watch` back to 100 or just `Freeze` & become invincible. I choose the latter obviously. 
		6. once we're past we meet Bandit Yeti which spelss a snowball shooting cloud that follows us. However since we're invincible it's pretty useless
			- ![[Pasted image 20221214085423.png]]
		7. after he begs for our mercy, we get the flag
			- ![[Pasted image 20221214085507.png]]



## Refs
- ...

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/09 Pivoting - Dock the halls]] | [[write-ups/thm/11 Memory Forensics - Not all gifts are nice]]
