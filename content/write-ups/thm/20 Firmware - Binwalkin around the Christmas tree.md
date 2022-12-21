---
title: "20 Firmware - Binwalkin around the Christmas tree"
date: 2022-12-21
tags:
- writeups
---

## Story
We can now learn more about the mysterious device found in Santa's workshop. Elf Forensic McBlue has successfully been able to find the `device ID`. Now that we have the hardware `device ID`, help Elf McSkidy reverse the encrypted firmware and find interesting endpoints for IoT exploitation.

### Learning Objectives
- What is firmware reverse engineering
- Techniques for extracting code from the firmware
- Extracting hidden keys from an encrypted firmware
- Modifying and rebuilding a firmware

## Notes

### Firmware Reverse Engineering
- Every embedded system *(cameras, routers, smart watches, locks, etc)* have pre-installed firmware which has its own set of instructions running on the hardware's processor
- enables the **hardware to communicate with other software running on the device**
- REing is working your way back through the code to figure our how it was built & what it does
- combine the 2 & firmware RE is extracting the source-code from the firmware's binary file & verifying that the code does not carry out any malicious functionality *(e.g undesired network comm calls)*
- usually done for security reasons to ensure the safe usage of devices that may have critical vulnerabilities leading to possible exploitation or data leakage *(e.g smart watch harvesting all incoming messages, emails, etc to an IP without any indication to the user)*

#### Reversing Steps
1. Obrain the firmware from the vendor website OR extract it from the device to perform analysys
2. Figure out the binary file's type *(bare metal or OS based)*
3. The firmware might be either encrypted or packed
	- if encrypted more challenging to analyse since it needs tricky workarounds
	- e.g as reversing the previous non-encrypted releases of the firmware OR performing hardware attacks like [Side Channel Attacks (SCA)](https://en.wikipedia.org/wiki/Side-channel_attack) to fetch the encryption keys
4. Once the firmware is decrypted/unpacked, different techniques & tools are used to perform analysis based on type

#### Static Analysis
Involves an essential examination of the binary file contents, performing its reverse engineering, and reading the assembly instructions to understand the functionality. Here's some tools
- **[BinWalk](https://github.com/ReFirmLabs/binwalk):**  extracts code snippets inside any binary by searching for signatures against many standard binary file formats *(zip, tar, exe, ELF, etc)*.  The common objective of using this tool is to extract a file system *(e.g Squashfs, yaffs2, Cramfs, ext*fs, jffs2)* embedded in the firmware binary which has all the application code running on the device
- **[Firmware ModKit (FMK)](https://www.kali.org/tools/firmware-mod-kit/)**: extracts the firmware using `binwalk` and outputs a directory with the firmware file system. Once the code is extracted, a developer can modify desired files and repack the binary file with a single command
- **[FirmWalker](https://github.com/craigz28/firmwalker)**:  Searches through the extracted firmware file system for unique strings and directories like `etc/shadow`, `etc/passwd`, `etc/ssl`, special keywords like `admin, root, password`, etc., vulnerable binaries like `ssh, telnet, netcat` etc.

#### Dynamic Analysis
Involves running the firmware code on actual hardware and observing its behaviour through emulation and hardware/ software based debugging. One of the significant advantages of dynamic analysis is to analyse unintended network communication for identifying data theft. Some tools:
- **[Qemu](https://www.qemu.org/)**: virtualization software / emulator that enables working on cross-platform environments *(for archs like Advanced RISC Machines (ARM), microprocessors without Interlocked Pipelined Stages (MIPS))*
- **[Gnu DeBugger (GDB)](https://www.sourceware.org/gdb/)**[:](https://www.sourceware.org/gdb/) dynamic debugging tool for emulating a binary and inspecting its memory and registers


## Practical

![[write-ups/images/Pasted image 20221221040806.png]]

- `bin`: contains the firmware binary
- `firmware-mod-kit`: contains the script to extract & modify the firmware

### Verifying encryption

Going into the `bin` folder let's check if the binary `firmwarev2.2-encrypted.gpg` is encrypted through [file entropy analysis](https://fsec404.github.io/blog/Shanon-entropy/):

![[write-ups/images/Pasted image 20221221041057.png]]

We see that the file is probably encrypted due to the increased randomness

### Finding unencrypted version

McSkidy found an older version of the same firmware. Access it in the `bin-unsigned` folder. We want to find the encryption keys used in the older version in order to decrypt the original one & reverse engineer it: 

![[write-ups/images/Pasted image 20221221041430.png]]

We see that it's a TP-Link device & can find all the firmware parts in the `fmk/` folder

#### Retrieving encryption keys

![[write-ups/images/Pasted image 20221221041619.png]]

Since the original firmware is [[gpg]] protected, we know that we have to find a public, private key pair. We can use `grep -ir key` to look for them:

![[write-ups/images/Pasted image 20221221041823.png]]

Now that we have the keys, we still need the paraphrase used with the private key in order to decrypt our gpg encrypted file:

![[write-ups/images/Pasted image 20221221041947.png]]

#### Decrypting the firmware

Let's import the keys:

```bash
gpg --import fmk/rootfs/gpg/private.key
gpg --import fmk/rootfs/gpg/public.key
ubuntu@machine:~bin-unsigned$
```


Then go back in `bin` & decrypt our firmware:
```bash
cd ../../bin
gpg firmwarev2.2-encrypted.gpg
```

Now we can just extract the code using `FMK`:

![[write-ups/images/Pasted image 20221221042340.png]]

Now looking @ our extracted firmware code we find our flag:

![[write-ups/images/Pasted image 20221221042446.png]]

Further analysis on the `Camera` folder in the next chall.

## Refs
- [Official Walkthrough](https://www.youtube.com/watch?v=1qc7C4h36ZQ)

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/19 Hardware Hacking - Wiggles go brrr]] | [[]]
