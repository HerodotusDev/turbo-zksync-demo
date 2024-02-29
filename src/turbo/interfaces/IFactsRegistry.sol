// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {Types} from "../Types.sol";

interface IFactsRegistry {
    function proveAccount(
        address account,
        uint16 accountFieldsToSave,
        Types.BlockHeaderProof calldata headerProof,
        bytes calldata accountTrieProof
    ) external;

    function proveStorage(
        address account,
        uint256 blockNumber,
        bytes32 slot,
        bytes calldata storageSlotTrieProof
    ) external;

    function verifyAccount(
        address account,
        Types.BlockHeaderProof calldata headerProof,
        bytes calldata accountTrieProof
    )
        external
        view
        returns (
            uint256 nonce,
            uint256 accountBalance,
            bytes32 codeHash,
            bytes32 storageRoot
        );

    function verifyStorage(
        address account,
        uint256 blockNumber,
        bytes32 slot,
        bytes calldata storageSlotTrieProof
    ) external view returns (bytes32 slotValue);

    function accountField(
        address account,
        uint256 blockNumber,
        Types.AccountFields field
    ) external view returns (bytes32);

    function accountStorageSlotValues(
        address account,
        uint256 blockNumber,
        bytes32 slot
    ) external view returns (bytes32);
}
