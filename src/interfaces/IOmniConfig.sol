// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IOmniConfig {
    error UnsupportedChain();

    function chains() external returns (uint256[] memory);
}
