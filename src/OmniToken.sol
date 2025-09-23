// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IOmniToken, IOmniTokenCloner} from "./interfaces/IOmniTokenCloner.sol";
import {IMessagingConfig, IUintToUint} from "./interfaces/IMessagingConfig.sol";

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {OFT} from "@layerzerolabs/oft-evm/contracts/oft/OFT.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {IMessageLib} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLib.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {MessagingReceipt, OFTReceipt, SendParam} from "@layerzerolabs/oft-evm/contracts/oft/interfaces/IOFT.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

/// @notice Cross-chain ERC-20 token using LayerZero OFT for trustless transfers across EVM chains.
/// @dev Key features:
/// - Seamless cross-chain minting and burning with LayerZero's OFT protocol.
/// - Cross-chain address consistency via deterministic deployment.
/// - Efficient proxy-based deployments using OpenZeppelin Clones.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract OmniToken is OFT, IOmniTokenCloner {
    using OptionsBuilder for bytes;

    /// @dev Immutable implementation/factory is the same for all clones.
    address public immutable prototype;
    /// @dev Immutable configuration is the same for all clones.
    IMessagingConfig public immutable messagingConfig;

    /// @dev Mask the ERC-20 name to support initialization in clones wihout requiring an upgradeable ERC-20.
    string internal _name;
    /// @dev Mask the ERC-20 symbol to support initialization in clones wihout requiring an upgradeable ERC-20.
    string internal _symbol;
    /// @dev Specify the gas limit for executing the _lzReceive callback function on the destination chain in a LayerZero OFT transfer.
    uint128 private _receiverGasLimit;

    constructor(IMessagingConfig appConfig)
        OFT("", "", appConfig.endpoint().value(), address(this))
        Ownable(address(this))
    {
        prototype = address(this);
        messagingConfig = appConfig;
    }

    function __OmniToken_init(Config memory config) public {
        if (bytes(_symbol).length != 0) {
            revert AlreadyInitialized();
        }
        if (bytes(config.symbol).length == 0) {
            revert SymbolEmpty();
        }

        _name = config.name;
        _symbol = config.symbol;
        _receiverGasLimit = config.receiverGasLimit;
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

        // Get the actual endpoint and sender and receiver libraries via their OmniAddress aliases.
        address sender = messagingConfig.sender().value();
        address receiver = messagingConfig.receiver().value();
        ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(messagingConfig.endpoint().value());

        IUintToUint endpointMapper = IUintToUint(messagingConfig.endpointMapper());
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
    function bridgeable(uint256 chainId) external view returns (bool) {
        uint32 eid = uint32(messagingConfig.endpointMapper().valueOf(chainId));
        address sender = messagingConfig.sender().value();
        address receiver = messagingConfig.receiver().value();
        return (eid != 0) && IMessageLib(sender).isSupportedEid(eid) && IMessageLib(receiver).isSupportedEid(eid);
    }

    /// @inheritdoc IOmniToken
    function bridgeQuote(uint256 toChain, uint256 amount) external view returns (uint256 fee) {
        SendParam memory param = sendParam(toChain, amount);
        MessagingFee memory msgFee = this.quoteSend(param, false);
        fee = msgFee.nativeFee;
    }

    /// @inheritdoc IOmniToken
    function bridge(uint256 toChain, uint256 amount)
        external
        payable
        returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt)
    {
        SendParam memory param = sendParam(toChain, amount);
        MessagingFee memory msgFee = MessagingFee(msg.value, 0);
        transfer(address(this), amount);
        (msgReceipt, oftReceipt) = this.send{value: msgFee.nativeFee}(param, msgFee, msg.sender);
    }

    /// @dev Help construct SendParam for a given destination chain and amount.
    function sendParam(uint256 toChain, uint256 amount) internal view returns (SendParam memory param) {
        uint32 eid = uint32(messagingConfig.endpointMapper().valueOf(toChain));
        if (eid == 0) {
            revert UnsupportedDestinationChain(toChain);
        }
        bytes memory extraOptions = OptionsBuilder.newOptions().addExecutorLzReceiveOption(_receiverGasLimit, 0);
        param.dstEid = eid;
        param.to = bytes32(uint256(uint160(msg.sender)));
        param.amountLD = amount;
        param.minAmountLD = amount;
        param.extraOptions = extraOptions;
        param.composeMsg = "";
        param.oftCmd = "";
    }

    /// @inheritdoc IOmniTokenCloner
    function cloneAddress(Config memory config) public view returns (address clone_, bytes32 salt) {
        salt = keccak256(abi.encode(config));
        clone_ = Clones.predictDeterministicAddress(prototype, salt);
    }

    /// @inheritdoc IOmniTokenCloner
    function clone(Config memory config) public returns (address clone_, bytes32 salt) {
        (clone_, salt) = cloneAddress(config);
        if (clone_.code.length == 0) {
            clone_ = Clones.cloneDeterministic(prototype, salt);
            OmniToken(clone_).__OmniToken_init(config);
            emit Cloned(config.owner, clone_, config.name, config.symbol);
        }
    }

    /// @inheritdoc IERC20Metadata
    function name() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return _name;
    }

    /// @inheritdoc IERC20Metadata
    function symbol() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return _symbol;
    }

    /// @notice Shared decimals used for cross-chain messaging.
    /// Setting this to 18 means 1 LD == 1 SD (no rounding).
    /// Cross-chain amounts are encoded as uint64 in SD units,
    /// so the maximum representable supply is 2^64 - 1 units,
    /// i.e. ~1.84e19 wei-units (~18.4 billion whole tokens at 18 decimals).
    function sharedDecimals() public view virtual override returns (uint8) {
        return 18;
    }
}
