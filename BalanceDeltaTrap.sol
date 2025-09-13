// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract BalanceDeltaTrap is ITrap {
    address public constant target = "";
    uint256 public constant thresholdWei = 1e15;

    function collect() external view override returns (bytes memory) {
        uint256 bal = target.balance;
        uint256 ts = block.timestamp;
        return abi.encode(bal, ts);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, abi.encodePacked("Insufficient data - need previous and current snapshots"));
        }

        (uint256 prevBal, uint256 prevTs) = abi.decode(data[0], (uint256, uint256));
        (uint256 currBal, uint256 currTs) = abi.decode(data[1], (uint256, uint256));

        uint256 diff = currBal > prevBal ? currBal - prevBal : prevBal - currBal;

        if (diff >= thresholdWei) {
            bytes memory msgBytes = abi.encodePacked(
                "Balance change detected: prev=",
                _uintToString(prevBal),
                " curr=",
                _uintToString(currBal),
                " diff=",
                _uintToString(diff),
                " ts_prev=",
                _uintToString(prevTs),
                " ts_curr=",
                _uintToString(currTs)
            );
            return (true, msgBytes);
        }

        return (false, abi.encodePacked(""));
    }

    function _uintToString(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";
        uint256 temp = v;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (v != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(v % 10)));
            v /= 10;
        }
        return string(buffer);
    }
}
