// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Map a global immutable contract address existing on many chains
/// to a local immutable address unique to each individual chain.
/// @author Paul Reinholdtsen
interface IOmniMap {
    /// @notice Return the chain‑specific address.
    function local() external view returns (address);
}
