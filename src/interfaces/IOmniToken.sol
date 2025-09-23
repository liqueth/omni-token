// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {MessagingReceipt, OFTReceipt} from "@layerzerolabs/oft-evm/contracts/oft/interfaces/IOFT.sol";

/// @notice Omnichain ERC-20 that burns on the source chain and mints on the destination.
/// @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
///      and chain ID mappings.
/// @custom:source https://github.com/liqueth/omni-token
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IOmniToken is IERC20Metadata {
    error UnsupportedDestinationChain(uint256 chain);

    /// @return whether it is possible to send this token to another chain.
    function bridgeable(uint256 chainId) external view returns (bool whether);

    /// @notice Return the native fee required to bridge to a destination chain.
    /// @dev A simplifying wrapper around IOFT.quoteSend that sets the recipient to `msg.sender` on the destination chain.
    /// @param toChain Destination zkBridge chain ID.
    /// @param amount The amount of tokens to send.
    /// @return fee Estimated native value (wei) the caller should send with {bridge}.
    function bridgeQuote(uint256 toChain, uint256 amount) external view returns (uint256 fee);

    /// @notice Send `amount` of tokens to `toChain`.
    /// @dev Requires sufficient native gas to be supplied to pay for cross-chain message delivery as determined by {bridgeQuote}.
    /// Implementented as a simplifying wrapper of IOFT.send that sets the recipient to `msg.sender` on the destination chain.
    /// @param toChain The destination chain ID (see `chainId` mapping).
    /// @param amount The amount of tokens to send.
    function bridge(uint256 toChain, uint256 amount)
        external
        payable
        returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt);
}
