---
title: "2. Fallout"
tags: 
- writeups
---

![[write-ups/images/fallback_contract.png]]

-   notice that the constructor of the smart contract is misspelled: `Fal1out()` => made available as a public function
-   can be also seen in ABI: `console.table(contract.abi)`
-   so just call it & claim ownership: `await contract.Fal1out()`

## Takeaways
-  you might say that this was to silly to happen in the wilderness of the real world. Well... not quite, it happen with [Rubix](https://www.rubix.net/), where the company changed its name from 'Dynamic Pyramid' to 'Rubixi' but somehow they didn't rename the constructor method of its contract:
    
    ```solidity
    contract Rubixi {
      address private owner;
      function DynamicPyramid() { owner = msg.sender; }
      function collectAllFees() { owner.transfer(this.balance) }
      ...
    ```
    
    -   as such, an attacker could call the old constructor & claim ownership
-   Practice test driven development
-   [Use security analysis tools](https://consensys.github.io/smart-contract-best-practices/security_tools/), which are usually free and good at finding simple human errors

## See Also
- [[write-ups/Ethernaut Wargame]]