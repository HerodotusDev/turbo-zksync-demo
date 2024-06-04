// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TurboDiceCommitter / Turbo Showcase | RANDAO + Storage Slots Proofs
 * @author Herodotus Dev Ltd
 * @notice Commit guesses for upcoming dice rolls on an L2 dice game
 */
contract TurboDiceCommitter {
  mapping(address => mapping(uint256 => Commitment)) public commitments; // Address => Block Number => Commitment

  struct Commitment {
    address account;
    uint88 targetBlock;
    uint8 prediction;
  }

  uint256 public constant MIN_BLOCK_DISTANCE = 10; // Minimum distance between commit and reveal

  event NewCommitment(
    address indexed account,
    uint256 targetBlockNumber,
    uint256 prediction
  );

  /**
   * commitGuess - Commit a guess for an upcoming dice roll
   * @param _number Number to commit (guess 1-6)
   */
  function commitGuess(uint256 _number) external {
    require(_number >= 1 && _number <= 6, 'Invalid number');

    uint256 targetBlock = block.number + MIN_BLOCK_DISTANCE;
    commitments[msg.sender][targetBlock] = Commitment(
      msg.sender,
      uint88(targetBlock),
      uint8(_number)
    );

    emit NewCommitment(msg.sender, targetBlock, _number);
  }

  /**
   * viewCommitment - View a commitment for a given account and target block
   * @param _account The account to view the commitment for
   * @param _block The target block to view the commitment for
   */
  function viewCommitment(
    address _account,
    uint256 _block
  ) external view returns (address, uint88, uint8) {
    return (
      commitments[_account][_block].account,
      commitments[_account][_block].targetBlock,
      commitments[_account][_block].prediction
    );
  }
}
