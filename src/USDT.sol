// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract USDT is ERC20, ERC20Permit {
    constructor() ERC20("USDT", "USDT") ERC20Permit("USDT") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }

    function mint(address addr, uint amount) public{
        _mint(addr, amount * 10 ** decimals());
    }

}

