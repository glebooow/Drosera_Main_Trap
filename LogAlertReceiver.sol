// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LogAlertReceiver {
    event BalanceAlert(string message, address indexed trap, uint256 timestamp);

    function logBalanceChange(string calldata message) external {
        emit BalanceAlert(message, msg.sender, block.timestamp);
    }
}
