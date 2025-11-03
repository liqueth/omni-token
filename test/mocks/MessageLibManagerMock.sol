// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {
    IMessageLibManager,
    SetConfigParam
} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";

/// @title MessagingChannelMock
/// @notice A minimal, do-nothing implementation of IMessagingChannel for testing.
contract MessageLibManagerMock is IMessageLibManager {
    function registerLibrary(address _lib) external {}

    function isRegisteredLibrary(address _lib) external view returns (bool) {}

    function getRegisteredLibraries() external view returns (address[] memory) {}

    function setDefaultSendLibrary(uint32 _eid, address _newLib) external {}

    function defaultSendLibrary(uint32 _eid) external view returns (address) {}

    function setDefaultReceiveLibrary(uint32 _eid, address _newLib, uint256 _timeout) external {}

    function defaultReceiveLibrary(uint32 _eid) external view returns (address) {}

    function setDefaultReceiveLibraryTimeout(uint32 _eid, address _lib, uint256 _expiry) external {}

    function defaultReceiveLibraryTimeout(uint32 _eid) external view returns (address lib, uint256 expiry) {}

    function isSupportedEid(uint32 _eid) external view returns (bool) {}

    function isValidReceiveLibrary(address _receiver, uint32 _eid, address _lib) external view returns (bool) {}

    /// ------------------- OApp interfaces -------------------
    function setSendLibrary(address _oapp, uint32 _eid, address _newLib) external {}

    function getSendLibrary(address _sender, uint32 _eid) external view returns (address lib) {}

    function isDefaultSendLibrary(address _sender, uint32 _eid) external view returns (bool) {}

    function setReceiveLibrary(address _oapp, uint32 _eid, address _newLib, uint256 _gracePeriod) external {}

    function getReceiveLibrary(address _receiver, uint32 _eid) external view returns (address lib, bool isDefault) {}

    function setReceiveLibraryTimeout(address _oapp, uint32 _eid, address _lib, uint256 _gracePeriod) external {}

    function receiveLibraryTimeout(address _receiver, uint32 _eid)
        external
        view
        returns (address lib, uint256 expiry)
    {}

    function setConfig(address _oapp, address _lib, SetConfigParam[] calldata _params) external {}

    function getConfig(address _oapp, address _lib, uint32 _eid, uint32 _configType)
        external
        view
        returns (bytes memory config)
    {}
}
