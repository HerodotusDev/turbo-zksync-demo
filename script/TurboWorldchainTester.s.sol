// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from 'forge-std/Script.sol';
import {console2} from 'forge-std/console2.sol';

import {TurboWorldchainTester} from '../src/TurboWorldchainTester.sol';

contract TurboWorldchainTesterDeployer is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);

    TurboWorldchainTester tester = new TurboWorldchainTester(
      vm.envAddress('TURBO_SWAP_PROXY_ADDRESS')
    );

    console2.logAddress(address(tester));

    vm.stopBroadcast();
  }
}
