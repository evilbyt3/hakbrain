---
title: "08 Smart Contracts - Last Christmas I gave you my ETH"
date: 2022-12-08
tags:
- writeups
---

## Story
After it was discovered that Best Festival Company was now on the blockchain and attempting to mint their cryptocurrency, they were quickly compromised. Best Festival Company lost all its currency in the exchange because of the attack. It is up to you as a red team operator to discover how the attacker exploited the contract and attempt to recreate the attack against the same target contract.

### Learning Objectives
-   Explain what smart contracts are, how they relate to the blockchain, and why they are important.
-   Understand how contracts are related, what they are built upon, and standard core functions.
-   Understand and exploit a common smart contract vulnerability.

## What is a Blockchain ?
- a blockchain is a digital database or ledger distributed among nodes of a peer-to-peer network
- due to its decentralized nature, each peer is expected to maintain the integrity of the blockchain. If one member of the network attempted to modify a blockchain maliciously, other members would compare it to their blockchain
- cryptography is employed to negotiate transactions and provide utility to the blockchain
- while historically, it has been used as a financial technology, it's recently expanded into many other industries and applications
- what does it mean for security? if we ignore the core blockchain tech, which relies on cryptography & instead focus on how data is transferred & negotiated we may find the answer concerning.

## Smart Contracts

- is a program stored on a blockchain that runs when pre-determined conditions are met. Several languages, such as Solidity, Vyper, and Yul, have been developed to facilitate the creation of contracts *(even with traditional programming languages such as Rust and JavaScript)*
- most commonly used as the backbone of DeFi *(Decentralized Finance)* apps to support a cryptocurrency on a blockchain
- DeFi applications facilitate currency exchange between entities; a smart contract defines the details of the exchange

### Functionality
- it greatly contrasts with core object-oriented programming concepts
- commonly has several functions that act similarly to accessors and mutators, such as checking balance, depositing, and withdrawing currency
- once a contract is deployed on a blockchain, another contract can then use its functions to call or execute the functions we just defined 
- ![[write-ups/images/Pasted image 20221208211253.png]]

### How vulnerabilities occur
- most smart contract vulnerabilities arise due to logic issues or poor exception handling which arise in functions when conditions are insecurely implemented

> **NOTE**: see [[Ethernaut Wargame]] for more examples

## Re-entrancy Attack
- re-entrancy occurs when a malicious contract uses a fallback function to continue depleting a contract's total balance due to flawed logic after an initial withdraw function occurs
- arises from how transfers of value are handled on Ethereum: ETH treats user &  smart contracts the same => both can make a call to a smart contract to receive a transfer of Ether

### Seen in the wild
- [**Fei Protocol**](https://halborn.com/explained-the-fei-protocol-hack-april-2022/)**:** In April 2022, the Fei protocol was the victim of an ~$80 million hack that was made possible by its use of third-party code containing re-entrancy vulnerabilities.
- [**Paraluni**](https://halborn.com/explained-the-paraluni-hack-march-2022/)**:** A March 2022 hack of the Paraluni smart contract exploited a re-entrancy vulnerability and poor validation of untrusted user input to steal ~$1.7 million in tokens.
- [**Grim Finance**](https://halborn.com/explained-the-grim-finance-hack-december-2021/)**:** In December 2021, a re-entrancy vulnerability in Grim Finance’s safeTransferFrom function was exploited for ~$30 million in tokens.
- [**SIREN Protocol**](https://halborn.com/explained-the-siren-protocol-hack-september-2021/)**:** A re-entrancy vulnerability in the SIREN protocol’s AMM pool smart contracts was exploited in September 2021 for ~$3.5 million in tokens.
- [**CREAM Finance**](https://halborn.com/explained-the-cream-finance-hack-august-2021/)**:** In August 2021, an attacker took advantage of a re-entrancy vulnerability in CREAM Finance’s integration of AMP tokens to steal approximately $18.8 million in tokens.

### Protection
- use the check-effects-interaction code pattern, where state updates are performed before the value transfer that they record
- ensure all state changes happen before calling external contracts
- use function modifiers that prevent re-entrancy
- did not undergo a security audit before the launch of the vulnerable code => do security audits
- example of re-entracy guard
	```solidity
	// SPDX-License-Identifier: MIT
	pragma solidity ^0.8.13;

	contract ReEntrancyGuard {
	    bool internal locked;
	
	    modifier noReentrant() {
	        require(!locked, "No re-entrancy");
	        locked = true;
	        _;
	        locked = false;
	    }
	}
	```
  

## Practical

- We're given 2 files: `EtherStore` & `Attack.sol`
	- ![[write-ups/images/Pasted image 20221209043019.png]]
	- ![[write-ups/images/Pasted image 20221209042834.png]]

We're recommended to use the [Remix IDE](https://remix.ethereum.org/) as a playground to deploy & interact with our contracts. Once they're both compiled we can:
- Deploy `EtherStore`
- Deposit 1 Ether from 2 separate accounts into it *(calling `deposit()`)*
	- checking the total balance of `EtherStore` should be 2 now *(call `getBalance()`)*
	- ![[write-ups/images/Pasted image 20221209043701.png]]
- Deploy `Attack.sol` with the address of `EtherStore` 
	- ![[write-ups/images/Pasted image 20221209043919.png]]
- Call `Attack.attack()` sending 1 Ether with another account
- Profit & get the flag ! You'll get 3 Ether back *(2 stolen from the 2 accounts + 1 Ether sent from the contract)* 
	- ![[write-ups/images/Pasted image 20221209044204.png]]

### Wait how that happened ?
`Attack.sol` was able to call `EtherStore.withdraw` multiple times before it finished executing. Let's take a look @ how funcions were called:
- `Attack.attack`
- `EtherStore.deposit`
- `EtherStore.withdraw`
- `Attack fallback` *(receives 1 Ether)*
- `EtherStore.withdraw`
- `Attack.fallback`  *(receives 1 Ether)*
- `EtherStore.withdraw`
- `Attack fallback` *(receives 1 Ether)*

Notice when we get the flag is displayed 3 times, every time our `Attack` fallback function is called which triggered the `EtherStore.withdraw` that contains `console.log()`

## Tools
- [ziion](https://www.ziion.org/)
- [remix IDE](https://remix.ethereum.org/)

## Refs
- [What is a re-entracy attack Helborn](https://halborn.com/what-is-a-re-entrancy-attack/)
- [solidity-by-example](https://solidity-by-example.org/)
- [Reentrancy | Hack Solidity (0.6)](https://www.youtube.com/@smartcontractprogrammer)]

## See Also
- [[write-ups/thm/Advent of Cyber 2022]]
- [[write-ups/thm/07 CyberChef - Maldocs roasting on an open fire]] | [[]]
