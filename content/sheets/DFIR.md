---
title: "DFIR"
date: 2023-01-30
tags:
- writeups
---

## DFIR 101

DFIR = Digital Forensics and Incident Response

### The Need 4 DFIR
- finding evidence of compromise in the network & differenciating between false alarms & actual incidents
- robustly remove the attacker, so their foothold & persistence from the network no longer remains
- identify the extent & timeframe of a breach *(helps in comm w relevant stakeholders)*
- finding the loopholes that lead to the breach. What needs to be changed to prevent such events in the future?
- understanding attacker behavior to pre-emptively block further intrusion attempts
- sharing info about the threat with the community

### Who performs it?
As the name suggests, DFIR requires expertise in both:
- Digital Forensics - These professionals are experts in identifying forensic artifacts or evidence of human activity in digital devices
- Incident Response - Incident responders are experts in cybersecurity and leverage forensic information to identify the activity of interest from a security perspective

DFIR proffesionals combine the best of the both worlds to achieve their goals *(often combined because they are highly interdependent)*.


## Basic Concepts

- **Artifacts**: are pieces of evidence that point to an activity performed on a system. They're collected to support a hypothesis or claim about the attacker activity *(e.g windows registry keys modification 4 persistence)*. They can be collected from the Endpoint or Server's file system, memory or network activity.
- **Evidence Preservation**: when performing DFIR we must maintain the integrity of the evidence we're collecting. Any forensic analysis can contaminate the evidence. Thus, the evidence is first collected & write-protected, following to make a copy which is used for analysis. This ensures that our original evidence remains safe. So if our copy under investigation gets corrupted we can always return & make a new copy from the evidence we had preserved
- **Chain of custody**: another critical aspect of maintaining integrity is to make sure the evidence is kept in secure custody. Any person not related to the investigation must not possess the evidence, or it will raise questions about the integrity of the data which weakens the case being built by adding unknown variables that can't be solved *(e.g a hard drive image being transferred from the person who took the image to the person who will perform the analysis, gets into the hands of a person who is not qualified to handle such evidence)*
- **Order of volatility**: digital evidence is often volatile *(i.e can be lost forever if not captured in time)*. Some sources are more volatile as compared to others: a hard drive is persistent storage and maintains data even if power is lost. In contrast RAM keeps data only as long as it remains powered on. Thus, it's vital to understand the order of volatility when performing DFIR: preserve the RAM before preserving the hard drive since we might lose data in the RAM if we don't prioritize it
- **Timeline creation**: now that we have collected the artifacts & maintained their integrity, we need to present them understandably to fully use the information contained in them. A timeline of events needs to be created for efficient & accurate analysis. This timeline of events puts all the activities in chronological order. Timeline creation provides perspective to the investigation and helps collate information from various sources to create a story of how things happened

![[write-ups/images/Pasted image 20230130134050.png]]


## Tools
- [Eric Zimmerman's tools](https://ericzimmerman.github.io/#!index.md) - can see practical exemples in [[write-ups/thm/windows-forensics-1]] & [[write-ups/thm/windows-forensics-2]]
- [KAPE](https://www.kroll.com/en/services/cyber-risk/incident-response-litigation-support/kroll-artifact-parser-extractor-kape) - [[todo/KAPE]] room
- [[write-ups/thm/autopsy]]
- [[write-ups/thm/volatility]]
- [[write-ups/thm/redline]]
- [[Velociraptor]]

## Incident Response Process

Per [NIST](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf):
1. Preparation
2. Detection & Analysis
3. Containment, Eradication & Recovery
4. Post-incident Activity

Per [SANS Incident Handler's handbook](https://www.sans.org/white-papers/33901/):
1. **Preparation**: be4 an incident happens we need to be ready in case of an incident: having the required people, processes, and technology to prevent and respond to incidents
2. **Identification**: An incident is identified through some indicators. These are further analyzed for False Positives, documented and communicated to the relevant stakeholders
4. **Containment**: the incident is contained & efforts are made to limit its effects. There can be short-term and long-term fixes for containing the threat based on forensic analysis of the incident that will be a part of this phase
5. **Eradication**: the threat is eradicated from the network. This has to be ensured by a proper forensic analysis to contain the threat before eradicating it: if the entry point of the threat actor into the network is not plugged, the threat will not be effectively eradicated, and the actor can gain a foothold again
6. **Recovery**: once the threat is removed from the network, the services that had been disrupted are brought back as they were before the incident happened
7. **Lessons Learned**:  a review of the incident is performed, the incident is documented, and steps are taken based on the findings from the incident to make sure that the team is better prepared for the next time an incident occurs

> **Note**: summarized as the acronym PICERL, making them easy to remember

## Refs
- [room](https://tryhackme.com/room/introductoryroomdfirmodule)

## See Also
- [[write-ups/THM]]
