// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IOmniRef {
    /// @notice Revert when the current chain is not supported.
    error UnsupportedChain();
    /// Returns the chain‑specific address for this chain.

    function target() external view returns (address);
}
