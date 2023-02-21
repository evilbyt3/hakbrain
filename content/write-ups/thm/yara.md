---
title: YARA
tags:
- writeups
---

> _"The pattern matching swiss knife for malware researchers (and everyone else)"_

YARA is a tool that can be used to identify files that meet certain conditions. It is mainly in use by security researchers to classify malware.
- can identify information based on both binary and textual patterns, such as hexadecimal and strings contained within a file
- [[sheets/Indicators of Compromise (IOCs)]] *(hashes, IP addresses, domain names, etc.)*
- when encountered something unknown, that your sec stack might not detect, using [[#Other tools]] you'll be able to add custom rules based on your [[write-ups/thm/Intro to Cyber Threat Intel|threat intelligence]] gathers or findings from an incident resp engagement *(forensics)*
## Rules
![[write-ups/images/Pasted image 20220607144651.png]]
- fairly trivial to pick up, hard to master *(only as effective as the understanding of searching for the right patterns)*
- use rule on dir: `yara myrule.yar somedir`
- more on [yara rules doc](https://yara.readthedocs.io/en/stable/writingrules.html)
## Integrating w other libs
- [Cuckoo Sandbox](https://cuckoosandbox.org/): automated malware analysis environment - generate rules based on behavior
- [Python's PE Module](https://pypi.org/project/pefile/): python module which allows to play around with the windows [Portable Executable *(PE)*](Portable Executable *(PE)*) structure
	- behaviours such as cryptography or worming can be largely identified without reverse engineering or execution of the sample
## Other tools
- [Loki](https://github.com/Neo23x0/Loki): open source IOC *(Indicator of Compromise)* scanner by [Florian Roth](https://github.com/Neo23x0)
- [Thor](https://www.nextron-systems.com/thor-lite/): multi-platform IOC & YARA scanner 
- [Fenrir](https://github.com/Neo23x0/Fenrir): simple bash IOC scanner *(nowadays ca be ran even on Windows)*
- [YaYa](https://github.com/EFForg/yaya): Yet Another Yara Automaton - _manage multiple YARA rule repositories_
- [yarGen](https://github.com/Neo23x0/yarGen): yarGen is a generator for YARA rules
- [yarAnalyzer](https://github.com/Neo23x0/yarAnalyzer): Yara Rule Analyzer and Statistics
- [Valhalla](https://valhalla.nextron-systems.com/): web front-end for a curated db of yara rules

## Write-up
### What is Yara?
```bash
touch somefile
echo "rule examplerule { condition: true }" > my1strule
yara my1strule.yar somefile
```
- `yara --update`
- check the `yara/signature-base/` folder for examples
- What is the name of the base-16 numbering system that Yara can detect?
	- hex
- Would the text "Enter your Name" be a string in an application? (Yay/Nay)
	- Yay
### Using LOKI and its Yara rule set

- [b374k shell](https://github.com/b374k/b374k): PHP Webshell with handy features
- **scenario**: You are the security analyst for a mid-size law firm. A co-worker discovered suspicious files on a web server within your organization. These files were discovered while performing updates to the corporate website. The files have been copied to your machine for analysis. The files are located in the `suspicious-files` directory. Use Loki to answer the questions below.
	- ![[write-ups/images/Pasted image 20220607150705.png]]

#### Answers
- Scan file 1. Does Loki detect this file as suspicious/malicious or benign?
	- Suspicious
- What Yara rule did it match on?
	- webshell_metaslsoft
- What does Loki classify this file as?
	- Web Shell
- Based on the output, what string within the Yara rule did it match on?
	- Str1
- What is the name and version of this hack tool?
	- b374k 2.2
- Inspect the actual Yara file that flagged file 1. Within this rule, how many strings are there to flag this file?
	```bash
	rule webshell_metaslsoft {
	meta:
		description = "Web Shell - file metaslsoft.php"
		license = "Detection Rule License 1.1 https://github.com/Neo23x0/signature-base/blob/master/LICENSE"
		author = "Florian Roth (Nextron Systems)"
		date = "2014/01/28"
		score = 70
		hash = "aa328ed1476f4a10c0bcc2dde4461789"
	strings:
		$s7 = "$buff .= \"<tr><td><a href=\\\"?d=\".$pwd.\"\\\">[ $folder ]</a></td><td>LINK</t"
	condition:
		all of them

	```
	- 1
- Scan file 2. Does Loki detect this file as suspicious/malicious or benign?
	- Benign
- Inspect file 2. What is the name and version of this web shell?
	- ![[write-ups/images/Pasted image 20230208041715.png]]

### Creating yara rules with [yarGen](https://github.com/Neo23x0/yarGen)

> "_The main principle is the creation of yara rules from strings found in malware files while removing all strings that also appear in goodware files. Therefore yarGen includes a big goodware strings and opcode database as ZIP archives that have to be extracted before the first use_."

- notice that we didn't detect 1 file previously: `1ndex.php`, creating a new rule might improve our defense by detecting such attacks
- `strings <filename> | wc -l` reuturns `3580` lines for `file2`. This can be a pretty daunting task to do manually
- luckily we can use `yarGen` to generate a rule for us
	```bash
	python3 yarGen.py --update
	# generate rule
	python3 yarGen.py -m /home/cmnatic/suspicious-files/file2 --excludegood -o /home/cmnatic/suspicious-files/file2.yar

	/*
	   YARA Rule Set
	   Author: yarGen Rule Generator
	   Date: 2023-02-08
	   Identifier: file2
	   Reference: https://github.com/Neo23x0/yarGen
	*/
	
	rule webshell_b374k_323{
	   meta:
	      description = "file2 - file 1ndex.php"
	      author = "yarGen Rule Generator"
	      reference = "https://github.com/Neo23x0/yarGen"
	      date = "2023-02-08"
	      hash1 = "53fe44b4753874f079a936325d1fdc9b1691956a29c3aaf8643cdbd49f5984bf"
	   strings:
	      $x1 = "var Zepto=function(){function G(a){return a==null?String(a):z[A.call(a)]||\"object\"}function H(a){return G(a)==\"function\"}fun" ascii
	      $s2 = "$cmd = execute(\"taskkill /F /PID \".$pid);" fullword ascii
	      $s3 = "$cmd = trim(execute(\"ps -p \".$pid));" fullword ascii
	      $s4 = "return (res = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? (res[1]) : null;" fullword ascii
	      $s5 = "$buff = execute(\"wget \".$url.\" -O \".$saveas);" fullword ascii
	      $s6 = "$buff = execute(\"curl \".$url.\" -o \".$saveas);" fullword ascii
	      $s7 = "(d=\"0\"+d);dt2=y+m+d;return dt1==dt2?0:dt1<dt2?-1:1},r:function(a,b){for(var c=0,e=a.length-1,g=h;g;){for(var g=j,f=c;f<e;++f)0" ascii
	      $s8 = "$cmd = execute(\"kill -9 \".$pid);" fullword ascii
	      $s9 = "$cmd = execute(\"tasklist /FI \\\"PID eq \".$pid.\"\\\"\");" fullword ascii
	      $s10 = "execute(\"tar xf \\\"\".basename($archive).\"\\\" -C \\\"\".$target.\"\\\"\");" fullword ascii
	      $s11 = "ngs.mimeType||xhr.getResponseHeader(\"content-type\")),result=xhr.responseText;try{dataType==\"script\"?(1,eval)(result):dataTyp" ascii
	      $s12 = "execute(\"tar xzf \\\"\".basename($archive).\"\\\" -C \\\"\".$target.\"\\\"\");" fullword ascii
	      $s13 = "$body = preg_replace(\"/<a href=\\\"http:\\/\\/www.zend.com\\/(.*?)<\\/a>/\", \"\", $body);" fullword ascii
	      $s14 = "$buff = execute(\"lwp-download \".$url.\" \".$saveas);" fullword ascii
	      $s15 = "$buff = execute(\"lynx -source \".$url.\" > \".$saveas);" fullword ascii
	      $s16 = "$check = strtolower(execute(\"perl -h\"));" fullword ascii
	      $s17 = "$check = strtolower(execute(\"java -help\"));" fullword ascii
	      $s18 = "$check = strtolower(execute(\"javac -help\"));" fullword ascii
	      $s19 = "$check = strtolower(execute(\"ruby -h\"));" fullword ascii
	      $s20 = "/* Zepto v1.1.2 - zepto event ajax form ie - zeptojs.com/license */" fullword ascii
	   condition:
	      uint16(0) == 0x3f3c and filesize < 700KB and
	      1 of ($x*) and 4 of them
	}

	# add custom rule to loki
	cp file2.yar ~/tools/loki/signature-base/yara
	vim file2.yar 	# explore generated yara rule
	loki 			# run loki 
	```
- [more](https://www.bsk-consulting.de/2015/02/16/write-simple-sound-yara-rules/) [about](https://www.bsk-consulting.de/2015/10/17/how-to-write-simple-but-sound-yara-rules-part-2/) [it](https://www.bsk-consulting.de/2016/04/15/how-to-write-simple-but-sound-yara-rules-part-3/) series
- other useful tool: [yarAnalyzer](https://github.com/Neo23x0/yarAnalyzer/)

#### Answers
- From within the root of the suspicious files directory, what command would you run to test Yara and your Yara rule against file 2?
	- `yara file2.yar file2/1ndex.php`
- Did Yara rule flag file 2? (Yay/Nay)
	- ![[write-ups/images/Pasted image 20230208043720.png]]
- Test the Yara rule with Loki, does it flag file 2? (Yay/Nay)
	- ![[write-ups/images/Pasted image 20230208044031.png]]
- What is the name of the variable for the string that it matched on?
	- Zepto
- Inspect the Yara rule, how many strings were generated?
	- 20
- One of the conditions to match on the Yara rule specifies file size. The file has to be less than what amount?
	- 700KB

### Valhalla


> "_Valhalla boosts your detection capabilities with the power of thousands of hand-crafted high-quality YARA rules._"

- an online Yara feed created and hosted by [Nextron-Systems](https://www.nextron-systems.com/valhalla/) *(Florian R0th tool saga)*
- conduct searches based on a keyword, tag, ATT&CK technique, sha256, or rule name

Picking up from our scenario, at this point, you know that the 2 files are related. Even though Loki classified the files are suspicious, you know in your gut that they are malicious. Hence the reason you created a Yara rule using yarGen to detect it on other web servers. But let's further pretend that you are not code-savvy (FYI - not all security professionals know how to code/script or read it). You need to conduct further research regarding these files to receive approval to eradicate these files from the network.

Time for some [[write-ups/thm/Intro to Cyber Threat Intel|threat intelligence]] using [Valhalla](https://valhalla.nextron-systems.com/)

#### Answers
- Enter the SHA256 hash of file 1 into Valhalla. Is this file attributed to an APT group? (Yay/Nay)
	- ![[write-ups/images/Pasted image 20230208044702.png]]
- Do the same for file 2. What is the name of the first Yara rule to detect file 2?
	- ![[write-ups/images/Pasted image 20230208044743.png]]
- Examine the information for file 2 from [Virus Total](https://www.virustotal.com/gui/file/5479f8cd1375364770df36e5a18262480a8f9d311e8eedb2c2390ecb233852ad). The Yara Signature Match is from what scanner?
	- THOR APT Scanner
- Enter the SHA256 hash of file 2 into Virus Total. Did every AV detect this as malicious? (Yay/Nay)
	- Nay
- Besides .PHP, what other extension is recorded for this file?
	- exe
- What JavaScript library is used by file 2?
	- [Zepto](https://zeptojs.com/)
- Is this Yara rule in the default Yara file Loki uses to detect these type of hack tools? (Yay/Nay)
	- Nay


---

## References
- [Yara Github](https://github.com/virustotal/yara/releases)

## See Also
- [[write-ups/thm/isac]]
- [[write-ups/THM]]