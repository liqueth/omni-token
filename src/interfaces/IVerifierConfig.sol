// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IOmniConfig.sol";

/**
 * @title IVerifierConfig
 * @notice Interface for immutable configuration exposing the verifier details used in
 *         an omnichain messaging protocol.
 * @dev General problem:
 *      Cross-chain applications need to know which verifier (e.g., DVN or similar
 *      data validation node) is responsible for attesting to message correctness,
 *      and how to identify that verifier consistently across chains. If this
 *      information were off-chain or mutable, it would undermine trust in the system.
 *
 *      This interface defines the minimal read-only surface that a verifier
 *      configuration contract must expose. Implementations deploy deterministically
 *      at a predictable address on every supported chain and return immutable data.
 */
interface IVerifierConfig is IOmniConfig {
    /**
     * @notice Return the verifier’s on-chain address (e.g., a DVN contract).
     * @dev This address is immutable after deployment and is the authoritative
     *      point of contact for verification logic on the current chain.
     * @return The verifier contract address for this configuration.
     */
    function dvn() external returns (address);

    /**
     * @notice Return the canonical identifier string for this verifier.
     * @dev The identifier is a human-readable or protocol-wide unique string
     *      (e.g., “axelar”, “bitgo”, “animoca-blockdaemon”) that consumers can
     *      use to recognize which verifier this config represents.
     * @return id A string identifier for the verifier.
     */
    function id() external returns (string memory);
}
