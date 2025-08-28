// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice a base class for storing immutable configuration data at a predictable address across chains.
contract OmniConfig {
    error UnsupportedChain();

    uint256 public immutable version;
    uint256[] internal _chains;

    function chains() external view returns (uint256[] memory) {
        return _chains;
    }
}
