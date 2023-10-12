// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Core.sol";

contract deploy is Script {

    function run() public {
        vm.startBroadcast();
        Core c = new Core();
        console2.log("run");
        vm.stopBroadcast();
    }
}
