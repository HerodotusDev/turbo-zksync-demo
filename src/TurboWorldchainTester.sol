// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';

import {ITurboSwap} from './turbo/interfaces/ITurboSwap.sol';

import {Types} from './turbo/Types.sol';

contract TurboWorldchainTester is Ownable {
  ITurboSwap public turboSwap;

  event AccountBalanceProven(
    uint256 chainId,
    address account,
    uint256 blockNumber,
    bytes32 accountBalance
  );

  event AccountERC20BalanceProven(
    uint256 chainId,
    address account,
    address token,
    uint256 blockNumber,
    bytes32 accountBalance
  );

  mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
    public accountsToBalance;

  mapping(address => mapping(uint256 => mapping(uint256 => bool)))
    public accountsToBalanceSet;

  mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
    public accountsToERC20Balance;

  mapping(address => mapping(uint256 => mapping(uint256 => bool)))
    public accountsToERC20BalanceSet;

  constructor(address turboSwapProxy) Ownable(msg.sender) {
    turboSwap = ITurboSwap(turboSwapProxy);
  }

  function setTurboSwap(address newTurboSwap) external onlyOwner {
    require(newTurboSwap != address(0), 'Invalid address');

    turboSwap = ITurboSwap(newTurboSwap);
  }

  // Proves an account balance at a specific block
  /// @param chainId The origin chain ID
  /// @param account The account to check (EOA)
  /// @param blockNumber The start block (inclusive)
  function proveAccountBalance(
    uint256 chainId,
    address account,
    uint256 blockNumber
  ) external {
    bytes32 accountBalance = turboSwap.accounts(
      chainId,
      blockNumber,
      account,
      Types.AccountFields.BALANCE
    );

    accountsToBalance[account][chainId][blockNumber] = uint256(accountBalance);
    accountsToBalanceSet[account][chainId][blockNumber] = true;

    emit AccountBalanceProven(chainId, account, blockNumber, accountBalance);
  }

  // Proves an account ERC-20 balance of a given token at a specific block
  /// @param chainId The origin chain ID
  /// @param account The account to check
  /// @param token The ERC-20 token address
  /// @param blockNumber The block number to check
  /// @param balanceOfSlot The ERC-20 balanceOf slot
  function proveERC20AccountBalance(
    uint256 chainId,
    address account,
    address token,
    uint256 blockNumber,
    bytes32 balanceOfSlot
  ) external {
    bytes32 accountERC20Balance = turboSwap.storageSlots(
      chainId,
      blockNumber,
      token,
      balanceOfSlot
    );

    accountsToERC20Balance[account][chainId][blockNumber] = uint256(
      accountERC20Balance
    );
    accountsToERC20BalanceSet[account][chainId][blockNumber] = true;

    emit AccountERC20BalanceProven(
      chainId,
      account,
      token,
      blockNumber,
      accountERC20Balance
    );
  }

  function getAccountBalance(
    address account,
    uint256 chainId,
    uint256 blockNumber
  ) external view returns (uint256) {
    require(
      accountsToBalanceSet[account][chainId][blockNumber],
      'Account balance not set'
    );
    return accountsToBalance[account][chainId][blockNumber];
  }

  function getERC20AccountBalance(
    address account,
    uint256 chainId,
    uint256 blockNumber
  ) external view returns (uint256) {
    require(
      accountsToERC20BalanceSet[account][chainId][blockNumber],
      'Account ERC-20 balance not set'
    );
    return accountsToERC20Balance[account][chainId][blockNumber];
  }
}
