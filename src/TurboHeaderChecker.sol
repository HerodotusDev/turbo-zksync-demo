// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ITurboSwap} from "./turbo/interfaces/ITurboSwap.sol";
import {HeaderProperty} from "./turbo/interfaces/ITurboSwap.sol";

import {Types} from "./turbo/Types.sol";

contract TurboHeaderChecker is Ownable {
    ITurboSwap public turboSwap;

    mapping(uint256 => mapping(uint256 => mapping(HeaderProperty => bytes32)))
        public headerProperties;

    mapping(uint256 => mapping(uint256 => mapping(HeaderProperty => bool)))
        public isProven;

    error NotProven();

    constructor(address turboSwapProxy) Ownable(msg.sender) {
        turboSwap = ITurboSwap(turboSwapProxy);
    }

    function setTurboSwap(address turboSwapProxy) external onlyOwner {
        turboSwap = ITurboSwap(turboSwapProxy);
    }

    // Proves a header property for a given block number
    /// @param property The header property to prove
    /// @param blockNumber The header block number to prove
    function proveHeaderProperty(
        uint256 chainId,
        uint256 blockNumber,
        HeaderProperty property
    ) public {
        bytes32 provenProperty = turboSwap.headers(
            chainId,
            blockNumber,
            property
        );

        // Store the proven property to this contract storage
        headerProperties[chainId][blockNumber][property] = provenProperty;
        isProven[chainId][blockNumber][property] = true;
    }

    // Proves multiple headers properties for different block numbers
    /// @param properties The header properties to prove
    /// @param blockNumbers The header block numbers to prove
    function proveHeaderProperties(
        uint256 chainId,
        HeaderProperty[] calldata properties,
        uint256[] calldata blockNumbers
    ) external {
        require(
            properties.length == blockNumbers.length,
            "TurboHeaderChecker: properties and blockNumbers length mismatch"
        );

        for (uint256 i = 0; i < properties.length; i++) {
            proveHeaderProperty(chainId, blockNumbers[i], properties[i]);
        }
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
