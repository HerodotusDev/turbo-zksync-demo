// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {ITurboSwap} from "./turbo/interfaces/ITurboSwap.sol";
import {HeaderProperty} from "./turbo/interfaces/ITurboSwap.sol";

import {Types} from "./turbo/Types.sol";

contract TurboHeaderChecker {
    ITurboSwap public immutable turboSwap;

    mapping(uint256 => mapping(uint256 => mapping(HeaderProperty => bytes32)))
        public headerProperties;

    mapping(uint256 => mapping(uint256 => mapping(HeaderProperty => bool)))
        public isProven;

    error NotProven();

    constructor(address turboSwapProxy) {
        turboSwap = ITurboSwap(turboSwapProxy);
    }

    // Proves a header property for a given block number
    /// @param property The header property to prove
    /// @param blockNumber The header block number to prove
    function proveHeaderProperty(
        uint256 chainId,
        uint256 blockNumber,
        HeaderProperty property
    ) external {
        bytes32 provenProperty = turboSwap.headers(
            chainId,
            blockNumber,
            property
        );

        // Store the proven property to this contract storage
        headerProperties[chainId][blockNumber][property] = provenProperty;
        isProven[chainId][blockNumber][property] = true;
    }

    // Retrieves a header property for a given block number
    /// @param property The header property to retrieve
    /// @param blockNumber The header block number to retrieve
    function getHeaderProperty(
        uint256 chainId,
        uint256 blockNumber,
        HeaderProperty property
    ) external view returns (bytes32) {
        if (!isProven[chainId][blockNumber][property]) {
            revert NotProven();
        }

        return headerProperties[chainId][blockNumber][property];
    }
}
