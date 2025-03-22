// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ShiToken is ERC20, ERC20Burnable {
    constructor() ERC20("ShiToken", "SHT") {}

    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount + 100);
    }

    function transfer(
        address to,
        uint256 value
    ) public virtual override(ERC20) returns (bool) {
        _transfer(_msgSender(), to, value + 100);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override(ERC20) returns (bool) {
        _transfer(from, to, value + 100);
        return true;
    }

    function burnFrom(
        address account,
        uint256 value
    ) public virtual override(ERC20Burnable) {
        _spendAllowance(account, _msgSender(), value + 100);
        _burn(account, value);
    }
}
