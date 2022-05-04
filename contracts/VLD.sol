// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ValidNode is ERC20{
    constructor() ERC20("ValidNode", "VLD"){
        _mint(msg.sender, 1000000000 * (10 ** 18)); //1 billion tokens minted
    }
}