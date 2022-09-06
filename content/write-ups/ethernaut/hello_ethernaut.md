---
title: "0. Hello Ethernaut"
tags:
- writeups
---

- `help()` to see functions
- get instance, check `contract`
## Solving
```javascript
await contract.info()
await contract.info1()
await contract.info2("hello")
await contract.infoNum() // 42
await contract.info42()
await contract.theMethodName() // method 7123949
await contract.method7123949()
await contract.password() // ethernaut0
await contract.authenticate("ethernaut0")
// submit level instance & proc tx
```
- smart contract code
	```solidity
	// SPDX-License-Identifier: MIT
	pragma solidity ^0.6.0;

	contract Instance {

	  string public password;
	  uint8 public infoNum = 42;
	  string public theMethodName = 'The method name is method7123949.';
	  bool private cleared = false;

	  // constructor
	  constructor(string memory _password) public {
		password = _password;
	  }

	  function info() public pure returns (string memory) {
		return 'You will find what you need in info1().';
	  }

	  function info1() public pure returns (string memory) {
		return 'Try info2(), but with "hello" as a parameter.';
	  }

	  function info2(string memory param) public pure returns (string memory) {
		if(keccak256(abi.encodePacked(param)) == keccak256(abi.encodePacked('hello'))) {
		  return 'The property infoNum holds the number of the next info method to call.';
		}
		return 'Wrong parameter.';
	  }

	  function info42() public pure returns (string memory) {
		return 'theMethodName is the name of the next method.';
	  }

	  function method7123949() public pure returns (string memory) {
		return 'If you know the password, submit it to authenticate().';
	  }

	  function authenticate(string memory passkey) public {
		if(keccak256(abi.encodePacked(passkey)) == keccak256(abi.encodePacked(password))) {
		  cleared = true;
		}
	  }

	  function getCleared() public view returns (bool) {
		return cleared;
	  }
	}
	```

## Takeaways
- all functions & variables stored on the blockchain are viewable by the public
- Thus, never store sensitive data *(i.e password)* directly inside a smart contract *(not even as `private` vars even)*

## See Also
- [[write-ups/Ethernaut Wargame]]