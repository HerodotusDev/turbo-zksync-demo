// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console2} from 'forge-std/Test.sol';

import {ITurboSwap, HeaderProperty} from '../src/turbo/interfaces/ITurboSwap.sol';
import {Types} from '../src/turbo/Types.sol';
import {IFactsRegistry} from '../src/turbo/interfaces/IFactsRegistry.sol';

import {TurboDiceGame} from '../src/TurboDiceGame.sol';
import {TurboDiceCommitter} from '../src/TurboDiceCommitter.sol';

contract MockTurboSwap is ITurboSwap {
  mapping(uint256 => mapping(uint256 => mapping(address => mapping(bytes32 => bytes32))))
    internal _storageSlots;

  mapping(uint256 => mapping(uint256 => mapping(HeaderProperty => bytes32)))
    internal _headers;

  function seedStorageSlot(
    uint256 chainId,
    uint256 blockNumber,
    address account,
    bytes32 slot,
    bytes32 value
  ) external {
    _storageSlots[chainId][blockNumber][account][slot] = value;
  }

  function seedHeader(
    uint256 chainId,
    uint256 blockNumber,
    HeaderProperty property,
    bytes32 value
  ) external {
    _headers[chainId][blockNumber][property] = value;
  }

  function storageSlots(
    uint256 chainId,
    uint256 blockNumber,
    address account,
    bytes32 slot
  ) external view returns (bytes32) {
    return _storageSlots[chainId][blockNumber][account][slot];
  }

  function headers(
    uint256 chainId,
    uint256 blockNumber,
    HeaderProperty property
  ) external view returns (bytes32) {
    return _headers[chainId][blockNumber][property];
  }

  function factsRegistries(
    uint256 chainId
  ) external pure returns (IFactsRegistry) {
    chainId;
    return IFactsRegistry(address(0));
  }

  function accounts(
    uint256 chainId,
    uint256 blockNumber,
    address account,
    Types.AccountFields field
  ) external pure returns (bytes32) {
    chainId;
    blockNumber;
    account;
    field;
    revert('Not implemented');
  }
}

contract TurboDiceGame_Test is Test {
  TurboDiceCommitter public diceCommitter;
  TurboDiceGame public diceGame;

  MockTurboSwap public mockTurboSwap;

  event RightGuess(
    address indexed account,
    uint256 blockNumber,
    uint256 result
  );

  event WrongGuess(
    address indexed account,
    uint256 blockNumber,
    uint256 result
  );

  event NewCommitment(
    address indexed account,
    uint256 targetBlockNumber,
    uint256 prediction
  );

  function setUp() public {
    mockTurboSwap = new MockTurboSwap();

    diceCommitter = new TurboDiceCommitter();

    diceGame = new TurboDiceGame(
      address(mockTurboSwap),
      11155111, // Origin chain ID
      address(diceCommitter)
    );
  }

  function testCommitInvalidDieRoll() public {
    vm.expectRevert('Invalid target block number');
    diceGame.rollDie(0, bytes32(0));
  }

  function testWinningDieRoll() public {
    vm.roll(6013862);
    vm.startPrank(0x4Be583d467B7737019148f2CCdc24cB28387cf5e);

    // Commit guess
    diceCommitter.commitGuess(5);

    // Fetch commitment
    (address account, uint88 targetBlock, uint8 prediction) = diceCommitter
      .viewCommitment(
        address(0x4Be583d467B7737019148f2CCdc24cB28387cf5e),
        block.number + diceCommitter.MIN_BLOCK_DISTANCE()
      );

    assertEq(account, address(0x4Be583d467B7737019148f2CCdc24cB28387cf5e));
    assertEq(targetBlock, 6013872);
    assertEq(prediction, 5);

    TurboDiceCommitter.Commitment memory commit = TurboDiceCommitter.Commitment(
      account,
      targetBlock,
      prediction
    );

    bytes32 storageKey = getStorageLocationForKey(
      commit.account,
      commit.targetBlock,
      0 // Slot index (`commitments` is the first, hence 0)
    );

    mockTurboSwap.seedStorageSlot(
      diceGame.turboDiceCommitterChainId(),
      commit.targetBlock,
      address(diceCommitter),
      storageKey,
      bytes32(
        hex'0500000000000000005bc3b04be583d467b7737019148f2ccdc24cb28387cf5e'
      )
    );

    mockTurboSwap.seedHeader(
      diceGame.turboDiceCommitterChainId(),
      commit.targetBlock,
      HeaderProperty.MIX_HASH,
      bytes32(
        hex'4c4fa2f84764ef902af6aa86f7833eca948cea561ee0ee99a25688849a3bdfa2'
      )
    );

    // zkSync address mapping
    address l2Address = diceGame.applyL1ToL2Alias(
      address(0x4Be583d467B7737019148f2CCdc24cB28387cf5e)
    );
    uint256 pointsBefore = diceGame.earnedPoints(address(l2Address));
    assertEq(pointsBefore, 0);

    vm.expectEmit(true, true, true, true);
    emit RightGuess(l2Address, commit.targetBlock, 5);
    diceGame.rollDie(commit.targetBlock, storageKey);
    uint256 pointsAfter = diceGame.earnedPoints(address(l2Address));
    assertEq(pointsAfter, pointsBefore + diceGame.POINTS_PER_CORRECT_GUESS());

    // Commitment should be marked as claimed
    vm.expectRevert('Commitment already claimed');
    diceGame.rollDie(commit.targetBlock, storageKey);

    vm.stopPrank();
  }

  function testLosingDieRoll() public {
    vm.roll(6013862);
    vm.startPrank(0x4Be583d467B7737019148f2CCdc24cB28387cf5e);

    // Commit guess
    diceCommitter.commitGuess(6);

    // Fetch commitment
    (address account, uint88 targetBlock, uint8 prediction) = diceCommitter
      .viewCommitment(
        address(0x4Be583d467B7737019148f2CCdc24cB28387cf5e),
        block.number + diceCommitter.MIN_BLOCK_DISTANCE()
      );

    assertEq(account, address(0x4Be583d467B7737019148f2CCdc24cB28387cf5e));
    assertEq(targetBlock, 6013872);
    assertEq(prediction, 6);

    TurboDiceCommitter.Commitment memory commit = TurboDiceCommitter.Commitment(
      account,
      targetBlock,
      prediction
    );

    bytes32 storageKey = getStorageLocationForKey(
      commit.account,
      commit.targetBlock,
      0 // Slot index (`commitments` is the first, hence 0)
    );

    mockTurboSwap.seedStorageSlot(
      diceGame.turboDiceCommitterChainId(),
      commit.targetBlock,
      address(diceCommitter),
      storageKey,
      bytes32(
        hex'0600000000000000005bc3b04be583d467b7737019148f2ccdc24cb28387cf5e'
      )
    );

    mockTurboSwap.seedHeader(
      diceGame.turboDiceCommitterChainId(),
      commit.targetBlock,
      HeaderProperty.MIX_HASH,
      bytes32(
        hex'4c4fa2f84764ef902af6aa86f7833eca948cea561ee0ee99a25688849a3bdfa2'
      )
    );

    // zkSync address mapping
    address l2Address = diceGame.applyL1ToL2Alias(
      address(0x4Be583d467B7737019148f2CCdc24cB28387cf5e)
    );
    uint256 pointsBefore = diceGame.earnedPoints(address(l2Address));
    assertEq(pointsBefore, 0);

    vm.expectEmit(true, true, true, true);
    emit WrongGuess(l2Address, commit.targetBlock, 5);
    diceGame.rollDie(commit.targetBlock, storageKey);
    uint256 pointsAfter = diceGame.earnedPoints(address(l2Address));
    assertEq(pointsAfter, 0);

    // Commitment should be marked as claimed
    vm.expectRevert('Commitment already claimed');
    diceGame.rollDie(commit.targetBlock, storageKey);

    vm.stopPrank();
  }

  function getStorageLocationForKey(
    address account,
    uint256 blockNumber,
    uint256 slotIndex
  ) public pure returns (bytes32) {
    // Compute the storage slot for the outer mapping
    bytes32 outerSlot = keccak256(abi.encode(account, slotIndex));

    // Compute the storage slot for the inner mapping
    bytes32 innerSlot = keccak256(abi.encode(blockNumber, outerSlot));

    return innerSlot;
  }
}
