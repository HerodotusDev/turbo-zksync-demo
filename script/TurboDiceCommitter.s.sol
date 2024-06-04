// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from 'forge-std/Script.sol';
import {console2} from 'forge-std/console2.sol';

import {TurboDiceCommitter} from '../src/TurboDiceCommitter.sol';

contract TurboDiceCommitterDeployer is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);

    TurboDiceCommitter diceCommitter = new TurboDiceCommitter();

    // Log deployed contract address
    console2.logAddress(address(diceCommitter));

    vm.stopBroadcast();
  }
}
