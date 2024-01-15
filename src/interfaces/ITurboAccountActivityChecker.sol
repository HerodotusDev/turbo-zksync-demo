// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.23;

interface ITurboAccountActivityChecker {
    enum AccountState {
        UNCHECKED,
        ACTIVE,
        INACTIVE
    }

    function proveAccountActivity(
        uint256 chainId,
        address account,
        uint256 startBlock,
        uint256 endBlock
    ) external;

    function getAccountState(
        address account,
        uint256 startBlock,
        uint256 endBlock
    ) external view returns (AccountState);
}
