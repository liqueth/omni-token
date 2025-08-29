// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IOmniConfig.sol";

interface IEndpointConfig is IOmniConfig {
    error UnsupportedDestinationChain(uint256 chain);

    function blocker() external returns (address);
    function endpoint() external returns (address);
    function executor() external returns (address);
    function sender() external returns (address);
    function chainToEndpoint() external returns (address);
    function chainToEndpoint(uint256 chain) external returns (uint32 eid);
}
