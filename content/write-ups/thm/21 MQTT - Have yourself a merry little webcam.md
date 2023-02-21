---
title: "21 MQTT - Have yourself a merry little webcam"
date: 2022-12-22
tags:
- writeups
---

## Story
After investigating the web camera implant through hardware and firmware reverse engineering, you are tasked with identifying and exploiting any known vulnerabilities in the web camera. Elf Mcskidy is confident you won't be able to compromise the web camera as it seems to be up-to-date, but we will investigate if off-the-shelf exploits are even needed to take back control of the workshop.

### Learning Objectives
- Explain the Internet of Things, why it is important, and if we should be concerned about their danger.
- Understand the difference between an IoT-specific protocol and other network service protocols.
- Understand what a publish/subscribe model is and how it interacts with IoT devices.
- Analyze and exploit the behavior of a vulnerable IoT device.

## Notes

### Internet of Things *(IoT)*
Defines a categorization of just that, *"things"*: the term can be used broadly as *"a device that sends and receives data to communicate with other devices and systems"* *(e.g thermostats, web cameras, smart fridges, smart locks)*

**What makes them important or warrants that we study them?**
1. IoT devices tend to be lightweight => functionality and features are limited to only essentials. Because of that modern features may be left out or overlooked, one of the most concerning being security
2. are interconnected and often involve no human interaction => designed to communicate data effectively but also negotiate a secure means of communication
3. designed to all be interconnected: if device $A$ is using $x$ protocol & device $B$ uses $y$ protocol there might be compatibility issues. In the case of security, devices which are incompatible could fall back to insecure communication

#### Protocols
Any protocol used by an IoT device for machine-to-machine, machine-to-gateway, or machine-to-cloud communication. Its objective is to provide efficient, reliable & secure data communication. Break up into 2 types:
1. **IoT data protocol**: relies on the [[todo/cyberops/OSI & TCPIP Models#TCP/IP Model|TCP/IP Model]] *([[HTTP]] can be used as the backbone)*
2. **IoT network protocol**: relies on wireless technology - rather tahn relying on traditional TCP, it uses WiFi, Bluetooth, ZigBee & Z-Wave to transfer data between entities

![[write-ups/images/Pasted image 20221222191602.png]]


| Protocol                                   | Comm Method     | Description                                                                              |
| ------------------------------------------ | --------------- | ---------------------------------------------------------------------------------------- |
| MQTT - Message Queuing Telemetry Transport | Middleware      | lightweight, relies on publish/subscribe model to send & rcv msgs                        |
| CoAP - Contrained Application Protocol     | Middleware      | translates [[HTTP]] comms to a usable comm medium 4 devices                              |
| AMQP - Advanced Messaging Queuing          | Middleware      | acts as a transactional protocol to receive, queue & store msgs/payloads between devices |
| DDS  - Data Distribution Service           | Middleware      | scalable, it relieves on a publish/subscribe model                                       |
| [[HTTP]]                                   | Device 2 Device | all know about it                                                                        |
| WebSocket                                  | Device 2 Device | client-server model over [[TCP]]                                                                                         |


#### Publish / Subscribe Model

![[write-ups/images/Pasted image 20221222191649.png]]

1. publisher sends msg to broker
2. broker continues relaying the message until a new message is published
3. subscriber can attempt to connect to broker in order to recv msgs

To ensure integrity *(one publisher should not overwrite another)*, a broker can store multiple messages from different publishers using **topics**: 
- a semi-arbitrary value pre-negotiated by the publisher and subscriber and sent along with a message
- commonly takes the form of `<name>/<id>/<function>`

2 publishers sending messages associated with topics:

![[write-ups/images/Pasted image 20221222192001.png]]

several subscribers receiving msgs from separate topics

![[write-ups/images/Pasted image 20221222192008.png]]

> **NOTE**: the _asynchronous_ nature of this communication; the publisher can publish at any time, and the subscriber can subscribe to a topic to see if the broker relaid message



## Practical


## Refs
- 

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/20 Firmware - Binwalkin around the Christmas tree]] | [[write-ups/thm/22 Attack Surface Reduction - Threats are failing all around me]]
- [[sheets/RTSP CCTV Cam Testing]]
