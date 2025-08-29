// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @notice Base interface for omnichain configuration contracts.
 * @dev General problem:
 *      Cross-chain applications require reliable knowledge of how each supported chain
 *      is wired — which identifiers and addresses to use locally, and which peer chains
 *      are supported at all. If this information is scattered off-chain or maintained
 *      through mutable registries, applications become fragile, hard to audit, and
 *      dependent on trusted updaters.
 *
 *      Subclasses of this interface solve that problem by acting as immutable,
 *      on-chain sources of configuration. They provide a predictable contract address
 *      that other contracts can query to learn what version of the configuration is in
 *      effect and which chains are supported, without requiring any privileged party
 *      to maintain or update the data after deployment.
 */
interface IOmniConfig {
    /// @notice Revert when the current chain is not supported.
    error UnsupportedChain();

    /// @notice Return the version number of this configuration.
    function version() external returns (uint256);

    /// @notice Return the list of supported native chain IDs.
    function chains() external returns (uint256[] memory);
}
