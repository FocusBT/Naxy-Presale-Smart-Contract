// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Naxy} from "../src/Naxy.sol";

contract NaxyTest is Test {
    Naxy public naxy;

    function setUp() public {
        naxy = new Naxy();
        naxy.setNumber(0);
    }

    function test_Increment() public {
        naxy.increment();
        assertEq(naxy.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        naxy.setNumber(x);
        assertEq(naxy.number(), x);
    }
}
