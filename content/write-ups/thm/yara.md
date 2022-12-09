---
title: YARA
tags:
- writeups
---

> _"The pattern matching swiss knife for malware researchers (and everyone else)"_

YARA is a tool that can be used to identify files that meet certain conditions. It is mainly in use by security researchers to classify malware.

- IOCs *(hashes, IP addresses, domain names, etc.)*
- when encountered ssomething unknown, that your sec stack might not detect, using [Other tools](#Other tools) you'll be able to add custom rules basde on your threat intellifence gathers or findings from an incident resp engagement *(forensics)*
- Rules: 
	- fairly trivial to pick up, hard to master *(only as effective as the understanding of searching for the right patterns)*
	- use rule on dir: `yara myrule.yar somedir`
	- more on [yara rules doc](https://yara.readthedocs.io/en/stable/writingrules.html)
	- [anatomy of a yara rule](anatomy of a yara rule)
		- ![[write-ups/images/Pasted image 20220607144651.png]]
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
	- 1
- Scan file 2. Does Loki detect this file as suspicious/malicious or benign?
	- Benign
- Inspect file 2. What is the name and version of this web shell?
	- b374k 3.2.3

### Creating yara rules with [yarGen](https://github.com/Neo23x0/yarGen)
- `strings <filename> | wc -l` reuturns `3580` lines for `file2`. This can be a pretty daunting task to do manually
- luckily we can use `yarGen` to generate a rule for us
	```bash
	python3 yarGen.py --update
	# generate rule
	python3 yarGen.py -m /home/cmnatic/suspicious-files/file2 --excludegood -o /home/cmnatic/suspicious-files/file2.yar
	# add custom rule to loki
	cp file2.yar ~/tools/loki/signature-base/yara
	vim file2.yar 	# explore generated yara rule
	loki 			# run loki 
	```

#### Answers
- From within the root of the suspicious files directory, what command would you run to test Yara and your Yara rule against file 2?
	- `yara file2.yar file2/1ndex.php`
- Did Yara rule flag file 2? (Yay/Nay)
	- Yay
- Copy the Yara rule you created into the Loki signatures directory.
- Test the Yara rule with Loki, does it flag file 2? (Yay/Nay)
	- Yay
- What is the name of the variable for the string that it matched on?
	- Zepto
- Inspect the Yara rule, how many strings were generated?
	- 20
- One of the conditions to match on the Yara rule specifies file size. The file has to be less than what amount?
	- 700KB

### Valhalla
- conduct searches based on a keyword, tag, ATT&CK technique, sha256, or rule name

#### Answers
- Enter the SHA256 hash of file 1 into Valhalla. Is this file attributed to an APT group? (Yay/Nay)
	- Yay
- Do the same for file 2. What is the name of the first Yara rule to detect file 2?
	- Webshell_b374k_rule1
- Examine the information for file 2 from Virus Total (VT). The Yara Signature Match is from what scanner?
	- THOR APT Scanner
- Enter the SHA256 hash of file 2 into Virus Total. Did every AV detect this as malicious? (Yay/Nay)
	- Nay
- Besides .PHP, what other extension is recorded for this file?
	- exe
- What JavaScript library is used by file 2?
	- Zepto
- Is this Yara rule in the default Yara file Loki uses to detect these type of hack tools? (Yay/Nay)
	- Nay


---

## References
- [Yara Github](https://github.com/virustotal/yara/releases)

## See Also
- [[write-ups/thm/isac]]
- [[write-ups/THM]]