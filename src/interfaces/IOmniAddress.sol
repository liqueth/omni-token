// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Map a single predictable contract address to a chain‑specific address.
/// @dev This deterministic lookup pattern enables the creation of immutable contracts
/// at deterministic addresses even if they depend on initialization data that varies by chain.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IOmniAddress {
    /// @return local address for the current chain.
    function value() external view returns (address local);
}
