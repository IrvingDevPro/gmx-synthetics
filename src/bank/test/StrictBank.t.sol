// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/src/Test.sol";

import {MintableToken} from "../../mocks/MintableToken.sol";

import {RoleStore} from "../../role/RoleStore.sol";
import {StrictBank} from "../StrictBank.sol";

contract StrictBankTest is Test {
    RoleStore roleStore;
    StrictBank strictBank;

    receive() external payable {}

    function setUp() public {
        roleStore = new RoleStore();
        strictBank = new StrictBank(roleStore);

        roleStore.grantRole(address(this), keccak256("CONTROLLER"));
    }

    /// @notice Should record the new balance and return amount token received
    // ? Should this function accept amount parameter as it used only by controlled controller contracts ?
    function testTransferIn(uint256 amount) public {
        MintableToken token = new MintableToken();
        token.mint(address(strictBank), amount);

        assertEq(strictBank.recordTransferIn(address(token)), amount);
        assertEq(strictBank.tokenBalances(address(token)), amount);
    }
}
