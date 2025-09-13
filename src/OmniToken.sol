// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./interfaces/IMessagingConfig.sol";
import "./interfaces/IOmniTokenCloner.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@layerzerolabs/oft-evm-upgradeable/contracts/oft/OFTUpgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

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
        console.log("OmniToken constructor");
        prototype = address(this);
        _appConfig = appConfig;
        console.log("OmniToken constructor b");
        _disableInitializers();
        console.log("OmniToken constructor end");
    }

    function __OmniToken_init(Config memory config) public initializer {
        console.log("__OmniToken_init a");
        //__OFT_init(config.name, config.symbol, config.owner);
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

        console.log("__OmniToken_init b");

        IUintToUint endpointMapper = IUintToUint(_appConfig.endpointMapper());
        IUintToUint.KeyValue[] memory c2e = endpointMapper.keyValues();
        for (uint256 i = 0; i < c2e.length; i++) {
            uint256 chain = c2e[i].key;
            if (chain != block.chainid) {
                uint256 eid = c2e[i].value;
                //setPeer(uint32(eid), bytes32(uint256(uint160(address(this)))));
            }
        }
    }

    function cloneAddress(Config memory config) public view returns (address token, bytes32 salt) {
        salt = keccak256(abi.encode(config));
        token = Clones.predictDeterministicAddress(prototype, salt);
    }

    function clone(Config memory config) public returns (address token, bytes32 salt) {
        if (address(this) != prototype) {
            console.log("clone a");
            return OmniToken(prototype).clone(config);
        }

        (token, salt) = cloneAddress(config);
        console.log("clone b");
        if (address(token).code.length == 0) {
            console.log("clone c");
            token = Clones.cloneDeterministic(address(this), salt);
            console.log("clone d");
            OmniToken(token).__OmniToken_init(config);
            console.log("clone e");
            emit Cloned(config.owner, address(token), config.name, config.symbol);
        }
    }
}
