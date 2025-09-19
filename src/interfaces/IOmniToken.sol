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
}
