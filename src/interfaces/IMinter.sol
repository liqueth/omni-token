// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Mint and burn tokens.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IMinter {
    /// @notice Mint new tokens to a specified address.
    /// @dev Only callable by the contract owner.
    function mint(address to, uint256 amount) external;

    /// @notice Burn tokens from the caller's address.
    function burn(address from, uint256 amount) external;

    /// @notice Emit when new tokens are minted.
    event Minted(address indexed to, uint256 amount);

    /// @notice Emit when tokens are burned.
    event Burned(address indexed from, uint256 amount);

    /// @notice Error thrown when a non-minter attempts to mint or burn tokens.
    error UnauthorizedMinter(address caller);
}
