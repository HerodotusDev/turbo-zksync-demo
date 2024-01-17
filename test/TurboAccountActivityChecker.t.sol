// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {ITurboSwap} from "../src/turbo/interfaces/ITurboSwap.sol";

import {ITurboAccountActivityChecker} from "../src/interfaces/ITurboAccountActivityChecker.sol";
import {TurboAccountActivityChecker} from "../src/TurboAccountActivityChecker.sol";

contract TurboAccountActivityChecker_Test is Test {
    TurboAccountActivityChecker public activityChecker;

    ITurboSwap public turboSwap;

    function setUp() public {
        address turboSwapProxyAddress = vm.envAddress(
            "TURBO_SWAP_PROXY_ADDRESS"
        );

        turboSwap = ITurboSwap(turboSwapProxyAddress);

        activityChecker = new TurboAccountActivityChecker(address(turboSwap));
    }

    function test_proveAccountActivity() public {
        address account = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
        vm.startPrank(account);

        uint256 startBlock = 10361998;
        uint256 endBlock = 10361999;

        activityChecker.proveAccountActivity(
            block.chainid, // 5
            account,
            startBlock,
            endBlock
        );

        ITurboAccountActivityChecker.AccountState state = activityChecker
            .getAccountState(account, startBlock, endBlock);
        assertTrue(state == ITurboAccountActivityChecker.AccountState.INACTIVE);

        vm.stopPrank();
    }

    function test_uncheckedAccount() public {
        ITurboAccountActivityChecker.AccountState unknownState = activityChecker
            .getAccountState(
                makeAddr("bob"),
                UINT256_MAX - 10,
                UINT256_MAX - 9
            );
        assertTrue(
            unknownState == ITurboAccountActivityChecker.AccountState.UNCHECKED
        );
    }

    function test_revertProveAccountActivity() public {
        vm.expectRevert("ERR_VALUE_IS_NULL");
        // Accessing an invalid fact must make the call revert.
        activityChecker.proveAccountActivity(
            block.chainid, // 5
            makeAddr("ghost"),
            0,
            1
        );
    }
}
