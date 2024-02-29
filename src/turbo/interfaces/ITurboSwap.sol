// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {Types} from "../Types.sol";

import {IFactsRegistry} from "../interfaces/IFactsRegistry.sol";

enum HeaderProperty {
    PARENT_HASH,
    UNCLE_HASH,
    COINBASE,
    STATE_ROOT,
    TRANSACTIONS_ROOT,
    RECEIPTS_ROOT,
    LOGS_BLOOM,
    DIFFICULTY,
    BLOCK_NUMBER,
    GAS_LIMIT,
    GAS_USED,
    TIMESTAMP,
    EXTRA_DATA,
    MIX_HASH,
    NONCE,
    BASE_FEE_PER_GAS,
    WITHDRAWALS_ROOT,
    BLOB_GAS_USED,
    EXCESS_BLOB_GAS,
    PARENT_BEACON_BLOCK_ROOT
}

interface ITurboSwap {
    function factsRegistries(
        uint256 chainId
    ) external returns (IFactsRegistry factsRegistry);

    function storageSlots(
        uint256 chainId,
        uint256 blockNumber,
        address account,
        bytes32 slot
    ) external returns (bytes32);

    function accounts(
        uint256 chainId,
        uint256 blockNumber,
        address account,
        Types.AccountFields field
    ) external returns (bytes32);

    function headers(
        uint256 chainId,
        uint256 blockNumber,
        HeaderProperty property
    ) external returns (bytes32);
}
