// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title IOmniToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings.
 * @custom:source https://github.com/liqueth/omni-token
 */
interface IOmniToken is IERC20Metadata {
    error AlreadyReceived(bytes32 messageHash);
    error SenderIsNotBridge(address sender);
    error SentFromDifferentAddress(address fromAddress);
    error UnsupportedDestinationChain(uint256 chain);
    error UnsupportedSourceChain(uint16 zkChain);

    event Cloned(address indexed owner, address indexed token, string name, string symbol);

    /**
     * @notice Return the canonical prototype used as both implementation and factory for clone deployments.
     * @dev The returned address is the code-bearing contract that minimal proxies (EIP-1167/OpenZeppelin Clones)
     *      delegate to. Treat it as stateless logic; do not send funds here. Useful for tooling and off-chain
     *      introspection to know which logic/factory this instance points to.
     * @return Address of the prototype (implementation + factory).
     */
    function prototype() external view returns (address);

    /**
     * @return whether it is possible to send this token to another chain.
     */
    function canBridgeTo(uint256 chainId) external view returns (bool);

    /**
     * @notice Return the native fee required to bridge to a destination chain.
     * @dev Proxies the zkBridge fee estimator; some endpoints use a destination gas limit to quote fees.
     * @param toChain Destination zkBridge chain ID.
     * @param amount The amount of tokens to send.
     * @return fee Estimated native value (wei) the caller should send with {bridge}.
     */
    function bridgeQuote(uint256 toChain, uint256 amount) external view returns (uint256 fee);

    /**
     * @notice Send `amount` of tokens to `toChain`.
     * @dev Burns tokens on the source chain and sends a LayerZero message to mint on the destination chain.
     *      Requires sufficient native gas to be supplied to pay for cross-chain message delivery.
     * @param toChain The destination chain ID (see `chainId` mapping).
     * @param amount The amount of tokens to send.
     */
    function bridge(uint256 toChain, uint256 amount) external payable;
}
