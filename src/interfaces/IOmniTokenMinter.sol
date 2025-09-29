// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Mint and burn OmniTokens.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IOmniTokenMinter {
    /// @notice Mint new tokens to a specified address.
    /// @dev Only callable by the contract owner.
    function mint(address to, uint256 amount) external;

    /// @notice Burn tokens from the caller's address.
    function burn(uint256 amount) external;

    /// @notice Emit when new tokens are minted.
    event Minted(address indexed to, uint256 amount);

    /// @notice Emit when tokens are burned.
    event Burned(uint256 amount);
}
