---
title: "22 Attack Surface Reduction - Threats are failing all around me"
date: 2022-12-23
link: 
tags:
- writeups
---

## Story
McSkidy wants to improve the security posture of Santa's network by learning from the recent attempts to disrupt Christmas. As a first step, she plans to implement low-effort, high-value changes that improve the security posture significantly.

### Learning Objectives
- Understand what an attack vector is.
- Understand the concept of the attack surface.
- Some practical examples of attack surface reduction techniques that McSkidy can utilize to strengthen Santa's network.

## Notes

### Attack Vectors
An attack vector is a tool, technique, or method used to attack a computer system or network. Mapping attack vectors to the physical world woul be the weapons adversary use *(swords, arrows, etc)*. Here's some examples of digital attack vectors:
- phishing emails
- DoS / DDoS attacks
- web drive-by attacks
- unpatched vulnerability exploitation

### Attack Surface
The surface area of the victim of an attack that can be impacted by an attack vector and cause damage. n cybersecurity, the attack surface will generally contain the following:
- an email server
- an internet-facing web server
- end-user machines that people use to connect to the network
- humans can be manipulated and tricked into giving control of the network to an attacker through social engineering

### Attack Surface Reduction
The attack surface can't be eliminated, thus it can only be reduced.

In cybersecurity, the most secure computer is the one that is shut down and its cables removed.

#### Examples
- **Close the ranks**: Santa's website was defaced earlier. When investigating that attack, McSkidy found that an SSH port was open on the server hosting the website. This led to the attacker using that open port to gain entry. McSkidy closed this port
- **Put up shields**: Although the open SSH port was protected by a password, the password was not strong enough to resist a brute-forcing attempt. McSkidy implemented a stronger password policy to make brute-forcing difficult. Moreover, a timeout would lock a user out after five incorrect password attempts, making brute-force attacks more expensive and less feasible.
- **Control information-flow**: McSkidy was informed by her team about the GitHub repository that contained sensitive information, including some credentials. This information could be an attack vector to target Santa's infrastructure. This information was made private to block this attack vector. Moreover, best practices were established to ensure credentials and other sensitive information are not committed to GitHub repositories
- **Beware of deception**: Another attack vector used to intrude into Santa's network was phishing emails. McSkidy identified that no phishing protection was enabled, which led to all such emails landing in the inbox of Santa's employees. McSkidy enabled phishing protection on Santa's email server to filter out spoofed and phishing emails. All emails identified as phishing or spoofed were dropped and didn't reach the inbox of Santa's employees.
- **Prepare for countering human error**: The phishing email that targeted Santa's employees contained a document containing malicious macros. To mitigate the risk of malicious macro-based documents compromising Santa's infrastructure, McSkidy disabled macros on end-user machines used by Santa's employees to avoid malicious macro-based attacks.
- **Strengthen every soldier**: McSkidy wanted the attack surface reduced from every endpoint's point of view. So far, she had taken steps to strengthen the network as a whole. For strengthening each endpoint, she took help from [Microsoft's Attack Surface Reduction rules](https://learn.microsoft.com/en-us/microsoft-365/security/defender-endpoint/attack-surface-reduction-rules-reference?view=o365-worldwide). Though these rules were built into the Microsoft Defender for Endpoint product, she took help from these rules and created a similar set of rules for her own EDR platform.
- **Made the defense invulnerable**: To further strengthen the infrastructure, McSkidy carried out a vulnerability scan highlighting some vulnerabilities in the internet-facing infrastructure. McSkidy patched these vulnerabilities found on Santa's internet-facing infrastructure to avoid exploitation.

## Refs
- ...

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/21 MQTT - Have yourself a merry little webcam]] | [[]]
