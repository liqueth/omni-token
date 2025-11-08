// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {
    IMessageLib,
    SetConfigParam,
    MessageLibType
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLib.sol";
import {console} from "forge-std/Test.sol";

/// @notice A minimal, do-nothing implementation of ISendLib for testing.
contract MessageLibMock is IMessageLib {
    mapping(uint32 => bytes) eidToConfig;

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {}

    function setConfig(address _oapp, SetConfigParam[] calldata _config) external {
        console.log("Setting config for oapp %s", _oapp);
        _oapp; // unused
        for (uint256 i = 0; i < _config.length; i++) {
            console.log("  eid %s", _config[i].eid);
            eidToConfig[_config[i].eid] = _config[i].config;
        }
    }

    function getConfig(uint32 _eid, address _oapp, uint32 _configType) external view returns (bytes memory config) {}

    function isSupportedEid(uint32 _eid) external view returns (bool yes) {
        yes = eidToConfig[_eid].length != 0;
        console.log("MessageLibMock.isSupportedEid", _eid, yes);
        yes = true;
    }

    // message libs of same major version are compatible
    function version() external view returns (uint64 major, uint8 minor, uint8 endpointVersion) {}

    function messageLibType() external view returns (MessageLibType) {}
}
