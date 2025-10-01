// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IOmniTokenProtoFactory} from "./interfaces/IOmniTokenProtoFactory.sol";
import {IMessagingConfig} from "./interfaces/IMessagingConfig.sol";
import {OmniToken} from "./OmniToken.sol";

/// @notice Factory to idempotently deploy new OmniToken implementations.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract OmniTokenProtoFactory is IOmniTokenProtoFactory {
    address constant NICKS_CREATE2_DEPLOYER = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    /// @inheritdoc IOmniTokenProtoFactory
    function create(IMessagingConfig config) external returns (address thing) {
        thing = createAddress(config);
        if (thing.code.length == 0) {
            thing = address(new OmniToken(config));
            emit Created(thing);
        }
    }

    /// @inheritdoc IOmniTokenProtoFactory
    function createAddress(IMessagingConfig config) public pure returns (address thing) {
        bytes memory args = abi.encode(config);
        bytes memory initCode = abi.encodePacked(type(OmniToken).creationCode, args);
        thing = create2Address(NICKS_CREATE2_DEPLOYER, 0x0, initCode);
    }

    function create2Address(address deployer, bytes32 salt, bytes memory initCode) public pure returns (address) {
        bytes32 initCodeHash = keccak256(initCode);
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, initCodeHash)))));
    }
}
