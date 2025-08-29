// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IOmniConfig.sol";

interface IVerifierConfig is IOmniConfig {
    function dvn() external returns (address);
    function id() external returns (string memory);
}
