## Step-by-step breakdown of performed actions

### Step 1: Project setup

Setup forge project:

```
forge init .
```

Install echidna:

```
pip3 install echidna
```

Install necessary dependecies:

```
forge install crytic/properties
forge install OpenZeppelin/openzeppelin-contracts
```

Build project:

```
forge build
```
---

### Step 2: Create custom token smart contract

A contract is derived from ERC20 and ERC20Burnable.

```
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract ShiToken is ERC20, ERC20Burnable {
    constructor() ERC20("ShiToken", "SHT") {}

    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }

    function transfer(
        address to,
        uint256 value
    ) public virtual override(ERC20) returns (bool) {
        _transfer(_msgSender(), to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual override(ERC20) returns (bool) {
        _transfer(from, to, value);
        return true;
    }

    function burnFrom(
        address account,
        uint256 value
    ) public virtual override(ERC20Burnable) {
        _spendAllowance(account, _msgSender(), value);
        _burn(account, value);
    }
}
```

**For now, there are no mistakes in the smart contract code.**

---

### Step 3: Correct contract fuzzing

Define tests and configuration files for internal and external fuzzing ([tests](test) directory).

Run internal and external fuzzing:

```
echidna ./test/ERC20Internal.sol --contract ERC20InternalHarness --config ./test/internal-config.yaml

echidna ./test/ERC20External.sol --contract ERC20ExternalHarness --config ./test/external-config.yaml
```

Initially, the results of fuzzing suggest that checks are passing.

---

### Step 4: Breaking the contract logic

To check if fuzzing will highlight the mistakes of the contract, the following functions were implemented incorrectly:

```
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
```

The mistakes are made in the aforementioned functions overrides:

- minting results in excessive tokens launch;
- transfer functions are wrong due to excessive tokens transfer;
- token burning is invalid due to excessive allowance spending.

Now, rerun fuzzing with the same commands:

```
echidna ./test/ERC20Internal.sol --contract ERC20InternalHarness --config ./test/internal-config.yaml

echidna ./test/ERC20External.sol --contract ERC20ExternalHarness --config ./test/external-config.yaml
```

The results suggest, that tests related to broken functions now fail.
