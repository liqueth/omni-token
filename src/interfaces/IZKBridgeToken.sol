// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title IZKBridgeToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination via Polyhedra zkBridge.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings. Enforces zkBridge-only callbacks, source/peer validation, and replay protection.
 * @custom:source https://github.com/liqueth/ZKBridgeToken
 */
interface IZKBridgeToken is IERC20Metadata {
    error AlreadyReceived(bytes32 messageHash);
    error SenderIsNotBridge(address sender);
    error SentFromDifferentAddress(address fromAddress);
    error UnsupportedDestinationChain(uint256 chain);
    error UnsupportedSourceChain(uint16 zkChain);

    event BridgeInitiated(address indexed holder, uint256 indexed chain, uint256 amount, uint64 nonce);
    event BridgeFinalized(address indexed holder, uint256 indexed chain, uint256 amount, uint64 nonce);

    /**
     * @notice Initializes name/symbol, zkBridge endpoint, chain ID mappings, and mints the local chain’s initial supply.
     * @param holder Recipient of the initial mint on this chain.
     * @param name ERC-20 name.
     * @param symbol ERC-20 symbol.
     * @param mints Map EVM chain ids to amount to mint.
     */
    function clone(address holder, string memory name, string memory symbol, uint256[][] memory mints)
        external
        returns (IZKBridgeToken);

    /**
     * @notice Burn tokens here and send a cross-chain message to mint on the destination chain.
     * @dev Reverts if the destination is unsupported or the attached fee is insufficient.
     *         Emits a BridgeInitiated event on success.
     * @param toChain Destination EVM `chainid`.
     * @param fee Token amount to bridge (in smallest units).
     */
    function bridge(uint256 toChain, uint256 fee) external payable;

    /**
     * @notice Returns the native fee required to bridge to a destination chain.
     * @dev Proxies the zkBridge fee estimator; some endpoints use a destination gas limit to quote fees.
     * @param toChain Destination zkBridge chain ID.
     * @return fee Estimated native value (wei) the caller should send with {bridge}.
     */
    function bridgeFeeEstimate(uint256 toChain) external returns (uint256 fee);
}
