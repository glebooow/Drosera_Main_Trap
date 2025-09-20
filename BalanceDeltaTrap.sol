// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory);
}

contract BalanceDeltaTrap is ITrap {
    // TODO: Replace with the address you want to monitoring
    address public constant target = 0x0000000000000000000000000000000000000001;
    uint256 public constant thresholdWei = 1e15; // 0.001 ETH

    function collect() external view override returns (bytes memory) {
        return abi.encode(target.balance, block.timestamp);
    }

    // data[0] = newest, data[1] = previous
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) {
            return (false, abi.encode("insufficient_data"));
        }

        (uint256 currBal, uint256 currTs) = abi.decode(data[0], (uint256, uint256));
        (uint256 prevBal, uint256 prevTs) = abi.decode(data[1], (uint256, uint256));

        uint256 diff = currBal > prevBal ? currBal - prevBal : prevBal - currBal;
        if (diff < thresholdWei) {
            return (false, abi.encode(""));
        }

        string memory msgStr = string(
            abi.encodePacked(
                "Balance change detected: prev=",
                _u(prevBal),
                " curr=",
                _u(currBal),
                " diff=",
                _u(diff),
                " ts_prev=",
                _u(prevTs),
                " ts_curr=",
                _u(currTs)
            )
        );

        // Return an ABI-encoded string that matches the responder signature.
        return (true, abi.encode(msgStr));
    }

    // utility: uint256 -> string
    function _u(uint256 v) internal pure returns (string memory) {
        if (v == 0) return "0";
        uint256 n = v;
        uint256 d;
        while (n != 0) {
            d++;
            n /= 10;
        }
        bytes memory b = new bytes(d);
        while (v != 0) {
            d--;
            b[d] = bytes1(uint8(48 + (v % 10)));
            v /= 10;
        }
        return string(b);
    }
}
