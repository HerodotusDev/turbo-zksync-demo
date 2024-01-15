// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {ITurboSwap} from "../src/turbo/interfaces/ITurboSwap.sol";

import {ITurboAccountActivityChecker} from "../src/interfaces/ITurboAccountActivityChecker.sol";
import {TurboAccountActivityChecker} from "../src/TurboAccountActivityChecker.sol";

contract TurboAccountActivityChecker_Test is Test {
    TurboAccountActivityChecker public activityChecker;

    ITurboSwap public turboSwap;

    address public account = makeAddr("alice");

    function setUp() public {
        address turboSwapProxyAddress = vm.envAddress(
            "TURBO_SWAP_PROXY_ADDRESS"
        );

        turboSwap = ITurboSwap(turboSwapProxyAddress);

        activityChecker = new TurboAccountActivityChecker(address(turboSwap));
    }

    function test_proveAccountActivity() public {
        vm.startPrank(account);

        activityChecker.proveAccountActivity(1, account, 1, 2);

        ITurboAccountActivityChecker.AccountState state = activityChecker
            .getAccountState(account, 1, 2);
        assertTrue(state == ITurboAccountActivityChecker.AccountState.INACTIVE);

        vm.stopPrank();
    }
}
