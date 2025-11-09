// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IUintToAddressCloner} from "./IUintToAddressCloner.sol";

/// @notice Map a single predictable contract address to a chain‑specific address.
/// @dev This deterministic lookup pattern enables the creation of immutable contracts
/// at deterministic addresses even if they depend on initialization data that varies by chain.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IAddressLookup is IUintToAddressCloner {
    /// @return local address for the current chain.
    function value() external view returns (address local);
}
