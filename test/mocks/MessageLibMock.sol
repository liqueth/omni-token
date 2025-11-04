// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {
    IMessageLib,
    SetConfigParam,
    MessageLibType
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLib.sol";

/// @notice A minimal, do-nothing implementation of ISendLib for testing.
contract MessageLibMock is IMessageLib {
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {}

    function setConfig(address _oapp, SetConfigParam[] calldata _config) external {}

    function getConfig(uint32 _eid, address _oapp, uint32 _configType) external view returns (bytes memory config) {}

    function isSupportedEid(uint32 _eid) external view returns (bool) {}

    // message libs of same major version are compatible
    function version() external view returns (uint64 major, uint8 minor, uint8 endpointVersion) {}

    function messageLibType() external view returns (MessageLibType) {}
}
