// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/26_DoubleEntryPoint.sol"; 

contract MyDetectionBot is IDetectionBot {
    address private vault;
    
    constructor(address _vault) {
        vault = _vault;
    }

    function handleTransaction(address user, bytes calldata msgData) external override {

        bytes4 selector;
        address origSender;

        assembly {
            let cleanSelector := shr(224, calldataload(msgData.offset))
            selector := calldataload(msgData.offset)
            origSender := calldataload(add(msgData.offset, 68))
        }
        if(selector == bytes4(keccak256("delegateTransfer(address,uint256,address)")) && origSender == vault){
            IForta(msg.sender).raiseAlert(user);
        }
    }
}

contract DoubleEntryPointTest is Test {
    LegacyToken legacyToken;
    DoubleEntryPoint det;
    CryptoVault vault;
    Forta forta;
    
    address owner = address(0x999);
    address player = address(0x1337);
    address attacker = address(0x666);

    function setUp() public {
        vm.startPrank(owner);
        
        legacyToken = new LegacyToken();
        vault = new CryptoVault(owner); 
        forta = new Forta();
        
        det = new DoubleEntryPoint(
            address(legacyToken),
            address(vault),
            address(forta),
            player
        );
        
        vault.setUnderlying(address(det));
        legacyToken.delegateToNewContract(det);
        
        vm.stopPrank();
    }

    function testDefense() public {
        vm.startPrank(player);
        
        MyDetectionBot bot = new MyDetectionBot(address(vault));
        forta.setDetectionBot(address(bot));
        
        vm.stopPrank();

        vm.startPrank(attacker);
        
        vm.expectRevert("Alert has been triggered, reverting");
        
        vault.sweepToken(IERC20(address(legacyToken)));
        
        vm.stopPrank();
    }
}