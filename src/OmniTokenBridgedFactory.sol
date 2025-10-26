// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IOmniTokenBridgedFactory} from "./interfaces/IOmniTokenBridgedFactory.sol";
import {IOFTProto} from "./interfaces/IOFTProto.sol";
import {OmniTokenBridged} from "./OmniTokenBridged.sol";
import {Assertions} from "./Assertions.sol";

/// @notice Factory to idempotently deploy new Bridge implementations.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract OmniTokenBridgedFactory is IOmniTokenBridgedFactory {
    using Assertions for address;

    /// @inheritdoc IOmniTokenBridgedFactory
    function create(IOFTProto.Config memory config, IOFTProto bridgeFactory) external returns (address expected) {
        expected = createAddress(config, bridgeFactory);
        if (expected.code.length == 0) {
            address(new OmniTokenBridged{salt: 0x0}(config, bridgeFactory)).assertEqual(expected);
            emit Created(expected);
        }
    }

    /// @inheritdoc IOmniTokenBridgedFactory
    function createAddress(IOFTProto.Config memory config, IOFTProto bridgeFactory)
        public
        view
        returns (address expected)
    {
        bytes memory args = abi.encode(config, bridgeFactory);
        bytes memory initCode = abi.encodePacked(type(OmniTokenBridged).creationCode, args);
        expected = create2Address(address(this), 0x0, initCode);
    }

    function create2Address(address deployer, bytes32 salt, bytes memory initCode) public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, keccak256(initCode))))));
    }
}
