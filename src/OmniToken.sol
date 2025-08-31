// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IOmniToken.sol";
import "./EndpointConfig.sol";
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
contract OmniToken is OFTUpgradeable, IOmniToken {
    struct Config {
        uint256[][] mints;
        string name;
        address owner;
        string symbol;
    }

    address internal _prototype;
    bytes internal _cloneData;
    EndpointConfig internal _appConfig;

    constructor(EndpointConfig appConfig) OFTUpgradeable(address(appConfig.endpoint())) {
        _prototype = address(this);
        _appConfig = appConfig;
        _disableInitializers();
    }

    function initialize(Config memory config) public initializer {
        //__OFT_init(config.name, config.symbol, config.owner);
        _prototype = msg.sender;
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
    }

    function clonePrediction(Config memory config) public view returns (address token, bytes32 salt) {
        salt = keccak256(abi.encode(config));
        token = Clones.predictDeterministicAddress(_prototype, salt, _prototype);
    }

    function clone(Config memory config) public returns (address token, bytes32 salt) {
        if (address(this) != _prototype) {
            return OmniToken(_prototype).clone(config);
        }

        (token, salt) = clonePrediction(config);
        if (address(token).code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            OmniToken(address(token)).initialize(config);
        }

        emit Cloned(config.owner, address(token), config.name, config.symbol);
    }

    function cloneEncoded(bytes memory cloneData_) public returns (address token, bytes32 salt) {
        (Config memory config) = abi.decode(cloneData_, (Config));
        (token, salt) = clone(config);
    }

    /// @inheritdoc IOmniToken
    function prototype() external view returns (address) {
        return _prototype;
    }

    function chains() external view returns (uint256[] memory) {
        return _appConfig.chains();
    }

    /// @inheritdoc IOmniToken
    function cloneData() external view returns (bytes memory) {
        return _cloneData;
    }
}
