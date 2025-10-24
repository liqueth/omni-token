// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IOFTMinterProtoFactory} from "./interfaces/IOFTMinterProtoFactory.sol";
import {IMessagingConfig} from "./interfaces/IMessagingConfig.sol";
import {OFTMinterDeterministic} from "./OFTMinterDeterministic.sol";
import {Assertions} from "./Assertions.sol";

/// @notice Factory to idempotently deploy new OFTMinterDeterministic implementations.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract OFTMinterProtoFactory is IOFTMinterProtoFactory {
    using Assertions for address;

    /// @inheritdoc IOFTMinterProtoFactory
    function create(IMessagingConfig config) external returns (address expected) {
        expected = createAddress(config);
        if (expected.code.length == 0) {
            address(new OFTMinterDeterministic{salt: 0x0}(config)).assertEqual(expected);
            emit Created(expected);
        }
    }

    /// @inheritdoc IOFTMinterProtoFactory
    function createAddress(IMessagingConfig config) public view returns (address expected) {
        bytes memory args = abi.encode(config);
        bytes memory initCode = abi.encodePacked(type(OFTMinterDeterministic).creationCode, args);
        expected = create2Address(address(this), 0x0, initCode);
    }

    function create2Address(address deployer, bytes32 salt, bytes memory initCode) public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, keccak256(initCode))))));
    }
}
