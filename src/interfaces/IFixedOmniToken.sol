// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IOmniToken.sol";

/**
 * @title IFixedOmniToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination via Polyhedra zkBridge.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings. Enforces zkBridge-only callbacks, source/peer validation, and replay protection.
 * @custom:source https://github.com/liqueth/ZKBridgeToken
 */
interface IFixedOmniToken is IOmniToken {
    event Cloned(address indexed holder, address indexed token, string name, string symbol);

    /**
     * @notice Initialize name/symbol, zkBridge endpoint, chain ID mappings, and mints the local chain’s initial supply.
     * @param holder Recipient of the initial mint on this chain.
     * @param name ERC-20 name.
     * @param symbol ERC-20 symbol.
     * @param mints Map EVM chain ids to amount to mint.
     */
    function clone(address holder, string memory name, string memory symbol, uint256[][] memory mints)
        external
        returns (address);

    /**
     * @notice Predict the address of a clone with the given parameters.
     * @dev Returns the address that would be created by cloning this contract with the given parameters.
     *      Useful for off-chain tools to know where a clone will be deployed.
     * @param holder Recipient of the initial mint on this chain.
     * @param name ERC-20 name.
     * @param symbol ERC-20 symbol.
     * @param mints Map EVM chain ids to amount to mint.
     * @return proxy The predicted address of the clone.
     * @return salt The salt used for the prediction.
     */
    function clonePrediction(address holder, string memory name, string memory symbol, uint256[][] memory mints)
        external
        view
        returns (address proxy, bytes32 salt);
}
