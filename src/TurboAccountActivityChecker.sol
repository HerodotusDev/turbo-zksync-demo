// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ITurboAccountActivityChecker} from "./interfaces/ITurboAccountActivityChecker.sol";
import {ITurboSwap} from "./turbo/interfaces/ITurboSwap.sol";

import {Types} from "./turbo/Types.sol";

contract TurboAccountActivityChecker is ITurboAccountActivityChecker, Ownable {
    ITurboSwap public turboSwap;

    mapping(address => mapping(uint256 => mapping(uint256 => AccountState)))
        public accountsToState;

    error UnsupportedAccountType();

    constructor(address turboSwapProxy) Ownable(msg.sender) {
        turboSwap = ITurboSwap(turboSwapProxy);
    }

    function setTurboSwap(address newTurboSwap) external onlyOwner {
        require(newTurboSwap != address(0), "Invalid address");

        turboSwap = ITurboSwap(newTurboSwap);
    }

    /// Proves whether an EOA was active or inactive between a period of blocks
    /// @param account The account to check (EOA)
    /// @param startBlock The start block (inclusive)
    /// @param endBlock  The end block (inclusive)
    function proveAccountActivity(
        uint256 chainId,
        address account,
        uint256 startBlock,
        uint256 endBlock
    ) external {
        // Check if the account is an EOA
        if (isContract(account)) {
            revert UnsupportedAccountType();
        }

        // Read account nonce at startBlock

        bytes32 nonceStart = turboSwap.accounts(
            chainId,
            startBlock,
            account,
            Types.AccountFields.NONCE
        );

        // Read account nonce at endBlock
        bytes32 nonceEnd = turboSwap.accounts(
            chainId,
            endBlock,
            account,
            Types.AccountFields.NONCE
        );

        if (nonceStart == nonceEnd) {
            // If the nonce is the same, the account was inactive
            accountsToState[account][startBlock][endBlock] = AccountState
                .INACTIVE;
        } else {
            // If the nonce is different, the account was active
            accountsToState[account][startBlock][endBlock] = AccountState
                .ACTIVE;
        }
    }

    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function getAccountState(
        address account,
        uint256 startBlock,
        uint256 endBlock
    ) external view returns (AccountState) {
        // Check if the account is an EOA
        if (isContract(account)) {
            revert UnsupportedAccountType();
        }
        return accountsToState[account][startBlock][endBlock];
    }
}
