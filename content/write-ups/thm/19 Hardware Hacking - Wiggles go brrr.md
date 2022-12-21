---
title: "19 Hardware Hacking - Wiggles go brrr"
date: 2022-12-21
tags:
- writeups
---

## Story
Elf McSkidy was doing a regular sweep of Santa's workshop when he discovered a hardware implant! The implant has a web camera attached to a microprocessor and another chip. It seems like someone was planning something malicious... We must try to understand what this implant was trying to do! We will deal with the microprocessor and the web camera in future tasks; for now, let's try to uncover what that other chip is being used for.

### Learning Objectives
- How data is sent via electrical wires in low-level hardware
- Hardware communication protocols
- How to analyse hardware communication protocols
- Reading USART data from a logic capture

## Notes

### USART
- Universal Synchronous/Asynchronous Receiver-Transmitter communication OR serial communication
- incredibly popular protocol in microprocessors due to its simplicity
- uses 2 wires *(connect the transmit port from one device to the receive port from the other device)*
	1. one to transmit data *(TX)* from device $A$ to $B$
	2. the other one to receive data *(RX)* on device $A$ from $B$ 
- there's no clock syncronising the comms betweend e devices => they have to agree to the configuration of comms:
	- **Communication speed**: also called the baud rate or bit rate and dictates how fast bytes of data can be sent. Agreeing to a specific rate tells each device how fast it should sample the data to get accurate information *(if both devices support the same rate, the you're good)*
	- **Bits per transmission**: normally set to 8 bits = 1 byte, but it can be configured to something else
	- **Stop & Start bits**: no clock => $A$ has to send a signal to be $B$ before it can send or end a data transmission. Those bits dictate how this is done
	- **Parity bits**: since there can be errors in the communication, these bits are used to detect/correct such errors
- once the 2 devices are synced, they can start communicating. Here's an example of how the ASCII char `S` would be transmitted:
	- ![[write-ups/images/Pasted image 20221221024055.png]]
- there's no way to determine if the devices are ready for comms, to solve this USART conns will use 2 additional lines
	- **Clear to Send *(CTS)***: ready to receive
	- **Request to Send *(RTS)**: ready to transmit
- to agree upon what voltage level is a binary *(1 or 2)*, a 3rd wire **Ground *(GND)** is required to sync the voltage between devices

### SPI
- Serial Peripheral Interface: mainly used or communication between microprocessors and small peripherals *(sensor, SD card)*
- unlike [[USART]] who has the clock built into the TX & RX lines, this uses a separate clock wire which comes with advantages:
	- separating the clock *(SCK)* from the data *(DATA)* line allows for synchronous communication => faster & more realiable
- trade-off: +1 wire, but we hain speed & reliability boost
- sending `S` using SPI
	- ![[write-ups/images/Pasted image 20221221024754.png]]

## Practical

Rogue implamnt circuit diagram:

![[write-ups/images/Pasted image 20221221025302.png]]

Microprocessor connected to an [ESP32] chip which allow for comms over WiFi & mobile networks => implant definitely communicating with someone else. We can try to intercept & further analyze the signals and be able to see what commands/info is transmitting.

But before some info on the wires:
- black wire *(GND)* & red wire *(VIN)* connected pins provide power to the chip
- green *(receive: RX0)* & purple *(transmit: TX0)* connected pins are used for communication using the [[USART]] protocol

By hooking up a [Logic Analyzer](https://www.saleae.com/) to the green & purple wires we can dump the data inside the signals.


### Analyzing the Logic

Using [Logic 2](https://support.saleae.com/logic-software/sw-download) we can take a look at our dump:

![[write-ups/images/Pasted image 20221221030635.png]]

D0 & D1 refer to the digital channels while A0 & A1 to the analogue data from the probers. If we zoom in on one of the thick lines from D1 you can actually see bits *(on/off)*

![[write-ups/images/Pasted image 20221221030859.png]]

Also notice how the analogue voltage data corresponds to the digital signal that is seen. Let's try extracting the data since we know it's using [[USART]]. First we have to configure the `Async Serial` for both channels: 1 & 0. Luckily they give us the configuration: data rate transfer, parity bits & frames

![[write-ups/images/Pasted image 20221221031242.png]]

### Extracting the data

Once saved, we can see the data

![[write-ups/images/Pasted image 20221221031343.png]]

We see an initialization sequence `\xF7\xFE\xE0n\xFF\xFE\0` & then 3 lines of data:
`ACK REBOOT`, `CMDX195837` & `9600`. This doesn't make any sense because we're looking @ only  1 side of the data. To see the bigger picture we need to add another `Async Analyzer` to do the same for `Channel 0`

![[write-ups/images/Pasted image 20221221031936.png]]

It looks like the following happened here:
- microprocessor is establishing a session with the ESP32 device to allow comms 
- asks for the ESP32 to reboot its connection to the control server
- ESP32 is happy to oblige but requests a security code to allow the connection to the control server
- once security code is sent, the ESP32 allows the microprocessor to change the bit rate to 9600
- once the bit rate is changed the rest of the data is gibberish

Lucily for us we can just update the baud rate to `9600` on Channel 0 analyzer & retrieve it:

![[write-ups/images/Pasted image 20221221032528.png]]


## Refs
- 

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/18 Sigma - Lumberjack Lenny learns new rules]] | [[write-ups/thm/20 Firmware - Binwalkin around the Christmas tree]]
