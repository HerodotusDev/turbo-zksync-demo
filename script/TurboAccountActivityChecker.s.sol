// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.23;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";

import {TurboAccountActivityChecker} from "../src/TurboAccountActivityChecker.sol";

contract TurboAccountActivityCheckerDeployer is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        TurboAccountActivityChecker checker = new TurboAccountActivityChecker(
            vm.envAddress("TURBO_SWAP_PROXY_ADDRESS")
        );

        console2.log(
            "Deployed TurboAccountActivityChecker at address: %s",
            address(checker)
        );

        vm.stopBroadcast();
    }
}
