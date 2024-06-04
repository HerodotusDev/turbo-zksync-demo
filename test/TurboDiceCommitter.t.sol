// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console2} from 'forge-std/Test.sol';

import {TurboDiceCommitter} from '../src/TurboDiceCommitter.sol';

contract TurboDiceCommitter_Test is Test {
  TurboDiceCommitter public diceCommitter;

  event NewCommitment(
    address indexed account,
    uint256 targetBlockNumber,
    uint256 prediction
  );

  function setUp() public {
    diceCommitter = new TurboDiceCommitter();
  }

  function testCommitInvalidGuess(uint256 guess) public {
    vm.assume(guess == 0 || guess > 6);

    vm.expectRevert('Invalid number');
    diceCommitter.commitGuess(guess);
  }

  function testCommitGuess(uint256 guess) public {
    vm.assume(guess >= 1 && guess <= 6);

    vm.expectEmit(true, true, true, true);
    emit NewCommitment(
      address(this),
      block.number + diceCommitter.MIN_BLOCK_DISTANCE(),
      guess
    );
    diceCommitter.commitGuess(guess);

    // Retrieve the commitment and check the values
    (address account, uint88 targetBlock, uint8 prediction) = diceCommitter
      .viewCommitment(
        address(this),
        block.number + diceCommitter.MIN_BLOCK_DISTANCE()
      );

    assertEq(account, address(this));
    assertEq(
      targetBlock,
      uint88(block.number + diceCommitter.MIN_BLOCK_DISTANCE())
    );
    assertEq(prediction, uint8(guess));
  }
}
