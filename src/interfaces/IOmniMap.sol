// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Map a single predictable contract address to many unique chain local addresses.
/// @author Paul Reinholdtsen
interface IOmniMap {
    /// @notice Return the chain‑specific address.
    function local() external view returns (address);
}
