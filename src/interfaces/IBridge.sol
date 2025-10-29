// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {MessagingReceipt, OFTReceipt} from "@layerzerolabs/oft-evm/contracts/oft/interfaces/IOFT.sol";

/// @notice Simple interface for sending tokens to another chain.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IBridge {
    error TransferFailed(address token, address from, address to, uint256 amount);
    error UnsupportedDestinationChain(uint256 chain);

    /// @return actual bridge that actually does the bridging.
    function actualBridge() external view returns (IBridge actual);

    /// @return whether it is possible to send this token to another chain.
    function bridgeable(uint256 chainId) external view returns (bool whether);

    /// @notice Return the native fee required to bridge to a destination chain.
    /// @dev A simplifying wrapper around IOFT.quoteSend that sets the recipient to `msg.sender` on the destination chain.
    /// @param to The recipient.
    /// @param toChain Destination chain ID.
    /// @param amount The amount of tokens to send.
    /// @return fee Estimated native value (wei) the caller should send with {bridge}.
    /// @return amountNoDust amount rounded down to prevent dust loss due to bridge rounding errors.
    function bridgeFee(address to, uint256 toChain, uint256 amount)
        external
        view
        returns (uint256 fee, uint256 amountNoDust);

    /// @notice Send 'amount' of this token to the same token at the same address on `toChain`.
    /// @dev Requires sufficient native gas to be supplied to pay for cross-chain message delivery as determined by {bridgeFee}.
    /// Implementented as a simplifying wrapper of IOFT.send that sets the recipient to `msg.sender` on the destination chain.
    /// @param to The recipient.
    /// @param toChain The destination chain ID (see `chainId` mapping).
    /// @param amount The amount of tokens to send.
    function bridge(address to, uint256 toChain, uint256 amount)
        external
        payable
        returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt);
}
