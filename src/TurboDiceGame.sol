// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

import {ITurboSwap, HeaderProperty} from './turbo/interfaces/ITurboSwap.sol';

/**
 * @title TurboDiceGame / Turbo Showcase | RANDAO + Storage Slots Proofs
 * @author Herodotus Dev Ltd
 * @notice Play a dice game leveraging RANDAO and storage slot proofs access
 */
contract TurboDiceGame is Ownable {
  mapping(address => uint256) public earnedPoints;

  mapping(bytes32 => bool) public claimed;

  ITurboSwap public turboProxy;

  uint256 public turboDiceCommitterChainId;
  address public turboDiceCommitter;

  uint256 public POINTS_PER_CORRECT_GUESS = 100;

  uint160 constant offset = uint160(0x1111000000000000000000000000000000001111); // L1 -> L2 address offset

  struct Commitment {
    address account;
    uint88 targetBlock;
    uint8 prediction;
  }

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

  constructor(
    address _turboProxy,
    uint256 _originChainId,
    address _turboDiceCommitter
  ) Ownable(msg.sender) {
    turboProxy = ITurboSwap(_turboProxy);

    turboDiceCommitterChainId = _originChainId;
    turboDiceCommitter = _turboDiceCommitter;
  }

  /**
   * rollDie - Roll a die and update the player's points
   * @param targetBlockNumber The target block number to roll the dice for
   * @param commitmentSlot The exact storage slot of the commitment in TurboDiceCommitter
   */
  function rollDie(uint256 targetBlockNumber, bytes32 commitmentSlot) external {
    require(targetBlockNumber > 0, 'Invalid target block number');
    require(!claimed[commitmentSlot], 'Commitment already claimed');

    // Get the commitment from the TurboDiceCommitter contract
    bytes32 commitmentValue = turboProxy.storageSlots(
      turboDiceCommitterChainId,
      targetBlockNumber,
      turboDiceCommitter,
      commitmentSlot
    );

    // Decode the commitment
    Commitment memory commitment = extractCommitment(commitmentValue);

    // Extract RANDAO from commitment's block header
    bytes32 randao = turboProxy.headers(
      turboDiceCommitterChainId,
      targetBlockNumber,
      HeaderProperty.MIX_HASH
    );
    if (randao != bytes32(0)) {
      require(
        targetBlockNumber == commitment.targetBlock,
        'Target block number mismatch'
      );

      // Compute the dice roll from RANDAO
      uint256 diceRoll = (uint256(randao) % 6) + 1;

      address l2Account = applyL1ToL2Alias(commitment.account);

      // Update the player's points
      if (diceRoll == commitment.prediction) {
        earnedPoints[l2Account] += POINTS_PER_CORRECT_GUESS;
        emit RightGuess(l2Account, targetBlockNumber, diceRoll);
      } else {
        emit WrongGuess(l2Account, targetBlockNumber, diceRoll);
      }

      // Mark the commitment as claimed
      claimed[commitmentSlot] = true;
    }
  }

  function extractCommitment(
    bytes32 encodedCommitment
  ) private pure returns (Commitment memory) {
    Commitment memory commitment;
    commitment.prediction = uint8(bytes1(encodedCommitment));
    commitment.targetBlock = uint88(bytes11(encodedCommitment << 8));
    commitment.account = address(uint160(uint256(encodedCommitment)));

    return commitment;
  }

  function applyL1ToL2Alias(
    address l1Address
  ) public pure returns (address l2Address) {
    unchecked {
      l2Address = address(uint160(l1Address) + offset);
    }
  }

  function setTurboProxy(address _turboProxy) external onlyOwner {
    turboProxy = ITurboSwap(_turboProxy);
  }

  function setTurboDiceCommitter(
    address _turboDiceCommitter
  ) external onlyOwner {
    turboDiceCommitter = _turboDiceCommitter;
  }

  function setPointsPerCorrectGuess(uint256 _points) external onlyOwner {
    POINTS_PER_CORRECT_GUESS = _points;
  }
}
