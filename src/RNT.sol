// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RNT is ERC20 {
    constructor() ERC20("RNT Token", "RNT") {
        _mint(msg.sender, 20000 ether);
    }
}