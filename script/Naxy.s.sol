// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Naxy} from "../src/Naxy.sol";

contract NaxyScript is Script {
    Naxy public naxy;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        naxy = new Naxy();

        vm.stopBroadcast();
    }
}
