// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/// @notice Test for and revert on common errors.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
library Assertions {
    /// @notice Revert if actual is not expected.
    /// @param actual address.
    /// @param expected address.
    function assertEqual(address actual, address expected) public pure {
        if (actual != expected) {
            revert ActualNotExpected(actual, expected);
        }
    }

    error ActualNotExpected(address actual, address expected);
}
