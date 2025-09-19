// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IMessagingConfig.sol";
import "./interfaces/IOmniTokenCloner.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@layerzerolabs/oft-evm-upgradeable/contracts/oft/OFTUpgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {IMessageLib} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLib.sol";

/**
 * @title OmniToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination via Polyhedra zkBridge.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings. Enforces zkBridge-only callbacks, source/peer validation, and replay protection.
 * @custom:source https://github.com/liqueth/omni-token
 */
contract OmniToken is OFTUpgradeable, IOmniTokenCloner {
    address public immutable prototype;
    IMessagingConfig internal immutable _appConfig;

    constructor(IMessagingConfig appConfig) OFTUpgradeable(appConfig.endpoint().value()) {
        prototype = address(this);
        _appConfig = appConfig;
        _disableInitializers();
    }

    function __OmniToken_init(Config memory config) public initializer {
        __OFT_init(config.name, config.symbol, config.owner);
        __Ownable_init(msg.sender);
        uint256[][] memory mints = config.mints;
        for (uint256 i = 0; i < mints.length; i++) {
            uint256 chain = mints[i][0];
            uint256 mint = mints[i][1];
            if (chain == block.chainid) {
                if (mint > 0) {
                    _mint(config.owner, mint);
                }
            }
        }

        address sender = _appConfig.sender().value();
        address receiver = _appConfig.receiver().value();
        ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(_appConfig.endpoint().value());

        IUintToUint endpointMapper = IUintToUint(_appConfig.endpointMapper());
        IUintToUint.KeyValue[] memory c2e = endpointMapper.keyValues();
        for (uint256 i = 0; i < c2e.length; i++) {
            uint256 chain = c2e[i].key;
            if (chain != block.chainid) {
                uint32 eid = uint32(c2e[i].value);
                if (IMessageLib(sender).isSupportedEid(eid) && IMessageLib(receiver).isSupportedEid(eid)) {
                    endpoint.setSendLibrary(address(this), eid, sender);
                    endpoint.setReceiveLibrary(address(this), eid, receiver, 0);
                    setPeer(eid, bytes32(uint256(uint160(address(this)))));
                }
            }
        }

        transferOwnership(config.owner);
    }

    function cloneAddress(Config memory config) public view returns (address token, bytes32 salt) {
        salt = keccak256(abi.encode(config));
        token = Clones.predictDeterministicAddress(prototype, salt);
    }

    function clone(Config memory config) public returns (address token, bytes32 salt) {
        if (address(this) != prototype) {
            return OmniToken(prototype).clone(config);
        }

        (token, salt) = cloneAddress(config);
        if (address(token).code.length == 0) {
            token = Clones.cloneDeterministic(address(this), salt);
            OmniToken(token).__OmniToken_init(config);
            emit Cloned(config.owner, address(token), config.name, config.symbol);
        }
    }
}
