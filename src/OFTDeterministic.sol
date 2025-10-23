// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IOmniTokenBridger} from "./interfaces/IOmniTokenBridger.sol";
import {IOmniTokenProto} from "./interfaces/IOmniTokenProto.sol";
import {IOmniTokenManager} from "./interfaces/IOmniTokenManager.sol";
import {IMessagingConfig, IUintToUint} from "./interfaces/IMessagingConfig.sol";
import {Assertions} from "./Assertions.sol";

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {OFTCore} from "@layerzerolabs/oft-evm/contracts/oft/OFTCore.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {IMessageLib} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLib.sol";
import {MessagingFee} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";
import {MessagingReceipt, OFTReceipt, SendParam} from "@layerzerolabs/oft-evm/contracts/oft/interfaces/IOFT.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

/// @notice Cross-chain ERC-20 token using LayerZero OFT for trustless transfers across EVM chains.
/// @dev Key features:
/// - Seamless cross-chain minting and burning with LayerZero's OFT protocol.
/// - Simplified bridge functions for user and developer friendly transfers.
/// - Cross-chain address consistency via deterministic deployment.
/// - Efficient proxy-based deployments using OpenZeppelin Clones.
/// - Ownership can renounced at cloning time for trustless tokens.
/// - Ownership can kept for post deployment management.
/// Constraints and considerations:
/// - All chain-specific values must be known at deployment.
/// - Adding new chains for existing trustless tokens is not possible.
/// - Addressing new chains for new trustless tokens requires deploying an updated protofactory.
/// - Requires a mechanism like Nick’s Factory (`CREATE2`) to guarantee identical addresses.
/// - The default OFT uses the default LayerZero DVN. Custom DVNs are currently not supported.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
abstract contract OFTDeterministic is OFTCore, IOmniTokenBridger, IOmniTokenProto, IOmniTokenManager {
    uint8 public constant LOCAL_DECIMALS = 8;

    function token() public view virtual returns (address);

    /// @inheritdoc IOmniTokenBridger
    function bridge(uint256 toChain, uint256 amount)
        external
        payable
        returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt)
    {
        SendParam memory param = sendParam(toChain, amount);
        MessagingFee memory msgFee = MessagingFee({nativeFee: msg.value, lzTokenFee: 0});
        if (!IERC20(token()).transfer(address(this), amount)) {
            revert TransferFailed(token(), msg.sender, address(this), amount);
        }
        (msgReceipt, oftReceipt) = this.send{value: msgFee.nativeFee}(param, msgFee, msg.sender);
    }

    /// @inheritdoc IOmniTokenBridger
    function bridgeFee(uint256 toChain, uint256 amount) external view returns (uint256 fee) {
        SendParam memory param = sendParam(toChain, amount);
        MessagingFee memory msgFee = this.quoteSend(param, false);
        fee = msgFee.nativeFee;
    }

    /// @inheritdoc IOmniTokenBridger
    function bridgeable(uint256 chainId) external view returns (bool) {
        uint32 eid = uint32(messagingConfig.endpointMapper().valueOf(chainId));
        address sender = messagingConfig.sender().value();
        address receiver = messagingConfig.receiver().value();
        return (eid != 0) && (sender != address(0)) && (receiver != address(0))
            && IMessageLib(sender).isSupportedEid(eid) && IMessageLib(receiver).isSupportedEid(eid);
    }

    using Assertions for address;

    /// @inheritdoc IOmniTokenProto
    function clone(Config memory config) public returns (address expected, bytes32 salt) {
        (expected, salt) = cloneAddress(config);
        if (expected.code.length == 0) {
            Clones.cloneDeterministic(prototype, salt).assertEqual(expected);
            OFTDeterministic(expected).initialize(config);
            emit Cloned(config.issuer, config.owner, expected, config.name, config.symbol);
        }
    }

    /// @inheritdoc IOmniTokenProto
    function cloneAddress(Config memory config) public view returns (address expected, bytes32 salt) {
        salt = keccak256(abi.encode(config));
        expected = Clones.predictDeterministicAddress(prototype, salt);
    }

    /// @inheritdoc IOmniTokenManager
    function setReceiverGasLimit(uint128 newLimit) external onlyOwner {
        _receiverGasLimit = newLimit;
        emit ReceiverGasLimitUpdated(newLimit);
    }

    /// @inheritdoc IOmniTokenManager
    function receiverGasLimit() external view returns (uint128) {
        return _receiverGasLimit;
    }

    /// @dev Immutable implementation/factory is the same for all clones.
    address public immutable prototype;
    /// @dev Immutable configuration is the same for all clones.
    IMessagingConfig public immutable messagingConfig;

    /// @dev Specify the gas limit for executing the _lzReceive callback function on the destination chain in a LayerZero OFT transfer.
    uint128 private _receiverGasLimit;

    constructor(IMessagingConfig messagingConfig_, address delegate_)
        OFTCore(LOCAL_DECIMALS, messagingConfig_.endpoint().value(), delegate_)
        Ownable(delegate_)
    {
        prototype = address(this);
        messagingConfig = messagingConfig_;
    }

    function initialize(Config memory config) public virtual {
        if (_receiverGasLimit != 0) {
            revert InitializedAlready();
        }
        if (config.receiverGasLimit == 0) {
            revert GasLimitZero();
        }
        _receiverGasLimit = config.receiverGasLimit;

        // Get the actual endpoint and sender and receiver libraries via their AddressLookup aliases.
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

        _transferOwnership(config.owner);
    }

    using OptionsBuilder for bytes;

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

    /// @notice Shared decimals used for cross-chain messaging.
    /// Setting this to 18 means 1 LD == 1 SD (no rounding).
    /// Cross-chain amounts are encoded as uint64 in SD units,
    /// so the maximum representable supply is 2^64 - 1 units,
    /// i.e. ~1.84e19 wei-units (~18.4 billion whole tokens at 18 decimals).
    function sharedDecimals() public view virtual override returns (uint8) {
        return 6;
    }
}
