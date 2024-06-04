// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from 'forge-std/Script.sol';
import {console2} from 'forge-std/console2.sol';

import {TurboTester} from '../src/TurboTester.sol';
import {HeaderProperty} from '../src/turbo/interfaces/ITurboSwap.sol';

contract TurboTesterDeployer is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint('PRIVATE_KEY');
    vm.startBroadcast(deployerPrivateKey);

    TurboTester tester = new TurboTester(
      vm.envAddress('TURBO_SWAP_PROXY_ADDRESS')
    );

    // TurboTester tester = TurboTester(
    //   0xFb05ebDAb087fe8C8adCB232329275678902b9ac
    // );

    // Log deployed contract address
    console2.logAddress(address(tester));

    // Storage slots
    // TurboTester.StorageSlotIntent[]
    //   memory storageSlotIntents = new TurboTester.StorageSlotIntent[](1);
    // TurboTester.StorageSlotIntent memory storageSlotIntent = TurboTester
    //   .StorageSlotIntent({
    //     chainId: block.chainid,
    //     blockNumber: block.number,
    //     account: address(0x062C7cCF0963B3040419B0B5C469278649cc52C7),
    //     slot: bytes32(0)
    //   });
    // storageSlotIntents[0] = storageSlotIntent;

    // Header properties (timestamp)
    // TurboTester.HeaderIntent[]
    //   memory headerIntents = new TurboTester.HeaderIntent[](1);
    // TurboTester.HeaderIntent memory headerIntent = TurboTester.HeaderIntent({
    //   chainId: block.chainid,
    //   blockNumber: 5914976,
    //   property: HeaderProperty.GAS_USED
    // });
    // headerIntents[0] = headerIntent;

    // // Encode above call to bytes
    // bytes memory data = abi.encodeWithSelector(
    //   tester.multiProve.selector,
    //   TurboTester.ProvingIntent({
    //     storageSlotIntent: new TurboTester.StorageSlotIntent[](0),
    //     accountIntent: new TurboTester.AccountIntent[](0),
    //     headerIntent: headerIntents
    //   })
    // );

    // // Log the encoded data
    // console2.logBytes(data);

    vm.stopBroadcast();
  }
}
