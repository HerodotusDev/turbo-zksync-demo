// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console2} from "forge-std/Test.sol";

import {ITurboSwap} from "../src/turbo/interfaces/ITurboSwap.sol";

import {TurboHeaderChecker} from "../src/TurboHeaderChecker.sol";
import {HeaderProperty} from "../src/turbo/interfaces/ITurboSwap.sol";

contract TurboHeaderChecker_Test is Test {
    TurboHeaderChecker public headerChecker;

    ITurboSwap public turboSwap;

    function setUp() public {
        address turboSwapProxyAddress = vm.envAddress(
            "TURBO_SWAP_PROXY_ADDRESS"
        );

        turboSwap = ITurboSwap(turboSwapProxyAddress);

        headerChecker = new TurboHeaderChecker(address(turboSwap));
    }

    // TODO: implement
    // function test_proveHeaderProperty() public {
    // }

    function test_revertProveHeaderActivity() public {
        vm.expectRevert("TurboSwap: Header property not set");
        headerChecker.proveHeaderProperty(
            block.chainid,
            42,
            HeaderProperty.PARENT_HASH
        );
    }
}
