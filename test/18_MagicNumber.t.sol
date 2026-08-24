// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/18_MagicNumber.sol";

contract MagicNumberTest is Test {
    MagicNum public magicNum;

    function setUp() public {
        magicNum = new MagicNum();
    }

    function testExploit() public {
        bytes memory bytecode = hex"600a600c600039600a6000f3602a60005260206000f3"; 
        address solver;
        assembly {
            solver := create(0, add(bytecode, 0x20), mload(bytecode))
        }

       require(solver != address(0), "Solver deployment failed");

        magicNum.setSolver(solver);

        // Check that the contract size is <= 10 bytes
        uint256 solverSize = solver.code.length;
        assertLe(solverSize, 10, "Runtime code is larger than 10 bytes!");
        console.log("Deployed bytecode size:", solverSize, "bytes");

        // Check that it returns 42 (0x2a) when called
        (bool success, bytes memory data) = solver.staticcall(
            abi.encodeWithSignature("whatIsTheMeaningOfLife()")
        );
        
        assertTrue(success, "Function call failed");
        
        uint256 meaningOfLife = abi.decode(data, (uint256));
        
        assertEq(meaningOfLife, 42, "Did not return 42!");
        console.log("Returned meaning of life is:", meaningOfLife);
    }
}
