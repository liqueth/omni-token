// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IBridgeFactory} from "./interfaces/IBridgeFactory.sol";
import {IMessagingConfig} from "./interfaces/IMessagingConfig.sol";
import {OFTMinter} from "./OFTMinter.sol";
import {Assertions} from "./Assertions.sol";

/// @notice Factory to idempotently deploy new OFTMinter implementations.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract BridgeFactory is IBridgeFactory {
    using Assertions for address;

    /// @inheritdoc IBridgeFactory
    function create(IMessagingConfig config) external returns (address expected) {
        expected = createAddress(config);
        if (expected.code.length == 0) {
            address(new OFTMinter{salt: 0x0}(config)).assertEqual(expected);
            emit Created(expected);
        }
    }

    /// @inheritdoc IBridgeFactory
    function createAddress(IMessagingConfig config) public view returns (address expected) {
        bytes memory args = abi.encode(config);
        bytes memory initCode = abi.encodePacked(type(OFTMinter).creationCode, args);
        expected = create2Address(address(this), 0x0, initCode);
    }

    function create2Address(address deployer, bytes32 salt, bytes memory initCode) public pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), deployer, salt, keccak256(initCode))))));
    }
}
