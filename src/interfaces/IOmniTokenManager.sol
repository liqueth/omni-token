// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Manage operational aspects of an OmniToken.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
interface IOmniTokenManager {
    /// @notice Sets the gas limit used by the token receiver
    /// @dev See https://docs.layerzero.network/v2/tools/sdks/options#lzreceive-option.
    /// @param newLimit The new gas limit value.
    function setReceiverGasLimit(uint128 newLimit) external;

    /// @return currentGasLimit used by the token receiver.
    function receiverGasLimit() external view returns (uint128 currentGasLimit);

    /// @notice Emit when the receiver gas limit is updated.
    /// @param newLimit The new gas limit value.
    event ReceiverGasLimitUpdated(uint128 newLimit);
}
