// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IMessagingConfig, IUintToUint} from "./interfaces/IMessagingConfig.sol";
import {IOmniTokenCloner, IOmniToken} from "./interfaces/IOmniTokenCloner.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {OFT} from "@layerzerolabs/oft-evm/contracts/oft/OFT.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {IMessageLib} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLib.sol";
import {SendParam} from "@layerzerolabs/oft-evm/contracts/oft/interfaces/IOFT.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

/**
 * @title OmniToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination via Polyhedra zkBridge.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings. Enforces zkBridge-only callbacks, source/peer validation, and replay protection.
 * @custom:source https://github.com/liqueth/omni-token
 */
contract OmniToken is OFT, IOmniTokenCloner {
    using OptionsBuilder for bytes;

    address public immutable prototype;
    IMessagingConfig internal immutable _appConfig;
    string private _mutableName;
    string private _mutableSymbol;

    constructor(IMessagingConfig appConfig)
        OFT("", "", appConfig.endpoint().value(), address(this))
        Ownable(address(this))
    {
        prototype = address(this);
        _appConfig = appConfig;
    }

    function name() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return _mutableName;
    }

    function symbol() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return _mutableSymbol;
    }

    /// @notice Shared decimals used for cross-chain messaging.
    /// Setting this to 18 means 1 LD == 1 SD (no rounding).
    /// Cross-chain amounts are encoded as uint64 in SD units,
    /// so the maximum representable supply is 2^64 - 1 units,
    /// i.e. ~1.84e19 wei-units (~18.4 billion whole tokens at 18 decimals).
    function sharedDecimals() public view virtual override returns (uint8) {
        return 18;
    }

    function __OmniToken_init(Config memory config) public {
        if (bytes(_mutableSymbol).length != 0) {
            revert AlreadyInitialized();
        }
        if (bytes(config.symbol).length == 0) {
            revert SymbolEmpty();
        }

        _mutableName = config.name;
        _mutableSymbol = config.symbol;
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
                    _setPeer(eid, bytes32(uint256(uint160(address(this)))));
                }
            }
        }
    }

    /// @inheritdoc IOmniToken
    function canBridgeTo(uint256 chainId) external view returns (bool) {
        uint32 eid = uint32(_appConfig.endpointMapper().valueOf(chainId));
        address sender = _appConfig.sender().value();
        address receiver = _appConfig.receiver().value();
        return (eid != 0) && IMessageLib(sender).isSupportedEid(eid) && IMessageLib(receiver).isSupportedEid(eid);
    }

    function _buildSend(uint256 toChain, uint256 amount) internal view returns (SendParam memory param) {
        uint32 eid = uint32(_appConfig.endpointMapper().valueOf(toChain));
        if (eid == 0) {
            revert UnsupportedDestinationChain(toChain);
        }
        bytes memory extraOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(65000, 0);
        param.dstEid = eid;
        param.to = bytes32(uint256(uint160(address(this))));
        param.amountLD = amount;
        param.minAmountLD = amount;
        param.extraOptions = extraOptions;
        param.composeMsg = "";
        param.oftCmd = "";
    }

    /// @inheritdoc IOmniToken
    function bridgeQuote(uint256 toChain, uint256 amount) external view returns (uint256 fee) {
        SendParam memory param = _buildSend(toChain, amount);
        MessagingFee memory msgFee = this.quoteSend(param, false);
        fee = msgFee.nativeFee;
    }

    /// @inheritdoc IOmniToken
    function bridge(uint256 toChain, uint256 amount) external payable {
        SendParam memory param = _buildSend(toChain, amount);
        MessagingFee memory msgFee = MessagingFee(msg.value, 0);
        // Encode the send call with original msg.sender
        bytes memory calldataPayload = abi.encodeWithSignature(
            "send((uint32,bytes32,uint256,uint256,bytes,bytes,bytes),(uint256,uint256),address)",
            param,
            msgFee,
            msg.sender
        );
        (bool success,) = address(this).delegatecall(calldataPayload);
        if (!success) {
            revert("Send call failed");
        }
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
