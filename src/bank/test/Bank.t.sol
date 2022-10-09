// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/src/Test.sol";

import {MintableToken} from "../../mocks/MintableToken.sol";
import {WETH} from "../../mocks/WETH.sol";

import {RoleStore} from "../../role/RoleStore.sol";
import {Bank} from "../Bank.sol";

contract BankTest is Test {
    RoleStore roleStore;
    Bank bank;

    receive() external payable {}

    function setUp() public {
        roleStore = new RoleStore();
        bank = new Bank(roleStore);

        roleStore.grantRole(address(this), keccak256("CONTROLLER"));
    }

    /// @notice Should transfer tokens out of the contract for a given token contract
    // ? Should this function revert when entering itself as receiver ?
    function testTransferOut(address receiver, uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(receiver != address(0));
        vm.assume(receiver != address(bank));

        MintableToken token = new MintableToken();
        token.mint(address(bank), amount);

        bank.transferOut(address(token), amount, receiver);

        assertEq(token.balanceOf(receiver), amount);
    }

    /// @notice Should convert and transfer WETH to ETH to receiver
    // ? Why this function can handle token transfer if there is already normal transferOut ?
    // ? Should the convertion of the tokens be handled by a router contract to make contracts lighter ?
    function testWethTransferOut(address receiver, uint256 amount) public {
        vm.assume(amount > 0);
        vm.assume(receiver != address(0));
        vm.assume(receiver != address(bank));

        WETH weth = new WETH();
        vm.deal(address(weth), amount);
        weth.mint(address(bank), amount);

        bank.transferOut(address(weth), address(weth), amount, receiver, true);

        assertEq(receiver.balance, amount);
    }
}
