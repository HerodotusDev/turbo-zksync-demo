// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

import {ITurboSwap} from './turbo/interfaces/ITurboSwap.sol';
import {Types} from './turbo/interfaces/ITurboSwap.sol';
import {HeaderProperty} from './turbo/interfaces/ITurboSwap.sol';

contract TurboTester is Ownable {
  uint256 public simpleSlot = 42; // Can be used to easily test simple storage slot proofs

  struct StorageSlotIntent {
    uint256 chainId;
    uint256 blockNumber;
    address account;
    bytes32 slot;
  }

  struct AccountIntent {
    uint256 chainId;
    uint256 blockNumber;
    address account;
    Types.AccountFields field;
  }

  struct HeaderIntent {
    uint256 chainId;
    uint256 blockNumber;
    HeaderProperty property;
  }

  struct ProvingIntent {
    StorageSlotIntent[] storageSlotIntent;
    AccountIntent[] accountIntent;
    HeaderIntent[] headerIntent;
  }

  ITurboSwap public turboProxy;

  event StorageSlotProved(
    uint256 chainId,
    uint256 blockNumber,
    address account,
    bytes32 slot,
    bytes32 value
  );

  event AccountProved(
    uint256 chainId,
    uint256 blockNumber,
    address account,
    Types.AccountFields field,
    bytes32 value
  );

  event HeaderProved(
    uint256 chainId,
    uint256 blockNumber,
    HeaderProperty property,
    bytes32 value
  );

  constructor(address _turboProxy) Ownable(msg.sender) {
    turboProxy = ITurboSwap(_turboProxy);
  }

  function setTurboProxy(address _turboProxy) external onlyOwner {
    turboProxy = ITurboSwap(_turboProxy);
  }

  function multiProve(ProvingIntent calldata intent) external {
    // Defer proofing of all requested storage slots to Turbo
    for (uint256 i = 0; i < intent.storageSlotIntent.length; i++) {
      StorageSlotIntent calldata storageSlotIntent = intent.storageSlotIntent[
        i
      ];
      bytes32 value = turboProxy.storageSlots(
        storageSlotIntent.chainId,
        storageSlotIntent.blockNumber,
        storageSlotIntent.account,
        storageSlotIntent.slot
      );

      emit StorageSlotProved(
        storageSlotIntent.chainId,
        storageSlotIntent.blockNumber,
        storageSlotIntent.account,
        storageSlotIntent.slot,
        value
      );
    }

    // Defer proofing of all requested accounts to Turbo
    for (uint256 i = 0; i < intent.accountIntent.length; i++) {
      AccountIntent calldata accountIntent = intent.accountIntent[i];
      bytes32 value = turboProxy.accounts(
        accountIntent.chainId,
        accountIntent.blockNumber,
        accountIntent.account,
        accountIntent.field
      );

      emit AccountProved(
        accountIntent.chainId,
        accountIntent.blockNumber,
        accountIntent.account,
        accountIntent.field,
        value
      );
    }

    // Defer proofing of all requested headers to Turbo
    for (uint256 i = 0; i < intent.headerIntent.length; i++) {
      HeaderIntent calldata headerIntent = intent.headerIntent[i];
      bytes32 value = turboProxy.headers(
        headerIntent.chainId,
        headerIntent.blockNumber,
        headerIntent.property
      );

      emit HeaderProved(
        headerIntent.chainId,
        headerIntent.blockNumber,
        headerIntent.property,
        value
      );
    }
  }
}
