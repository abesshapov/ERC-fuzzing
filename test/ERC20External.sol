pragma solidity ^0.8.0;

import {ShiToken} from "../src/ShiToken.sol";
import {ITokenMock} from "lib/properties/contracts/ERC20/external/util/ITokenMock.sol";
import {PropertiesConstants} from "lib/properties/contracts/util/PropertiesConstants.sol";
import {CryticERC20ExternalBasicProperties} from "lib/properties/contracts/ERC20/external/properties/ERC20ExternalBasicProperties.sol";
import {CryticERC20ExternalBurnableProperties} from "lib/properties/contracts/ERC20/external/properties/ERC20ExternalBurnableProperties.sol";
import {CryticERC20ExternalMintableProperties} from "lib/properties/contracts/ERC20/external/properties/ERC20ExternalMintableProperties.sol";

contract ERC20ExternalHarness is
    CryticERC20ExternalBasicProperties,
    CryticERC20ExternalBurnableProperties,
    CryticERC20ExternalMintableProperties
{
    constructor() {
        token = ITokenMock(address(new ShiTokenMock(true)));
    }
}

contract ShiTokenMock is ShiToken, PropertiesConstants {
    bool public isMintableOrBurnable;
    uint256 public initialSupply;

    constructor(bool _isMintableOrBurnable) {
        _mint(USER1, INITIAL_BALANCE);
        _mint(USER2, INITIAL_BALANCE);
        _mint(USER3, INITIAL_BALANCE);
        _mint(msg.sender, INITIAL_BALANCE);

        initialSupply = totalSupply();
        isMintableOrBurnable = _isMintableOrBurnable;
    }
}
