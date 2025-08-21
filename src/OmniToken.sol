// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IOmniToken.sol";
import "./interfaces/IZKBridge.sol";
import "./interfaces/IZKBridgeReceiver.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/**
 * @title OmniToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination via Polyhedra zkBridge.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings. Enforces zkBridge-only callbacks, source/peer validation, and replay protection.
 * @custom:source https://github.com/liqueth/omni-token
 */
abstract contract OmniToken is ERC20Upgradeable, IOmniToken, IZKBridgeReceiver {
    address internal _prototype;
    IZKBridge internal _zkBridge;
    bytes internal _cloneData;
    uint256[] internal _chains;
    mapping(uint256 => uint16) private _evmToZkChain;
    mapping(uint16 => uint256) private _zkToEvmChain;
    mapping(bytes32 => bool) private _received;

    /**
     * @notice Initializes zkBridge endpoint, chain ID mappings.
     * @param zkBridge_ zkBridge endpoint address on all chains.
     * @param zkChains Map EVM chain ids to zk bridge chain ids.
     */
    constructor(address zkBridge_, uint256[][] memory zkChains) {
        _prototype = address(this);
        _zkBridge = IZKBridge(zkBridge_);

        bool localChainIncluded = false;
        for (uint256 i = 0; i < zkChains.length; i++) {
            uint256 evmChain = zkChains[i][0];
            localChainIncluded = localChainIncluded || evmChain == block.chainid;
        }
        require(localChainIncluded, "Local chain ID not in chains");

        initializeChains(zkChains);

        _disableInitializers();
    }

    function initializeChains(uint256[][] memory zkChains) internal {
        for (uint256 i = 0; i < zkChains.length; i++) {
            uint256 evmChain = zkChains[i][0];
            uint16 zkChain = uint16(zkChains[i][1]);
            _evmToZkChain[evmChain] = uint16(zkChain);
            _zkToEvmChain[zkChain] = evmChain;
            _chains.push(evmChain);
        }
    }

    function initialize(
        bytes memory cloneData_,
        string memory name,
        string memory symbol,
        IZKBridge zkBridge_,
        uint256[][] memory zkChains
    ) internal {
        __ERC20_init(name, symbol);
        _cloneData = cloneData_;
        _prototype = msg.sender;
        _zkBridge = zkBridge_;
        initializeChains(zkChains);
    }

    function cloneEncoded(bytes memory cloneData_)
        public
        virtual
        returns (address token, bytes32 salt, bytes memory cloneData);

    /// @inheritdoc IOmniToken
    function deployToChain(uint256 toChain) external payable {
        uint64 nonce = _zkBridge.send{value: msg.value}(evmToZkChain(toChain), address(_prototype), _cloneData);
        emit DeployToChainInitiated(address(this), toChain, nonce);
    }

    /// @inheritdoc IOmniToken
    function bridge(uint256 toChain, uint256 amount) external payable {
        bytes memory payload = abi.encode(msg.sender, amount);
        _burn(msg.sender, amount);
        uint64 nonce = _zkBridge.send{value: msg.value}(evmToZkChain(toChain), address(this), payload);
        emit BridgeInitiated(msg.sender, address(this), toChain, amount, nonce);
    }

    /**
     * @notice zkBridge callback to mint tokens on this chain for a received bridge message.
     * @dev Only callable by the zkBridge endpoint. Validates the source chain/address and enforces replay protection.
     *      Decodes the payload (e.g., recipient, token, destChain, amount) and mints to the intended recipient.
     * @param fromZkChain Source zkBridge chain ID.
     * @param fromAddress Address of the token contract on the source chain.
     * @param nonce Source message nonce.
     * @param payload ABI-encoded bridge payload.
     */
    function zkReceive(uint16 fromZkChain, address fromAddress, uint64 nonce, bytes calldata payload) external {
        if (msg.sender != address(_zkBridge)) {
            revert SenderIsNotBridge(msg.sender);
        }

        // Ensure the message has not been processed before
        bytes32 messageHash = keccak256(abi.encodePacked(fromZkChain, fromAddress, nonce, payload));
        if (_received[messageHash]) {
            revert AlreadyReceived(messageHash);
        }
        _received[messageHash] = true;

        if (fromAddress == address(this)) {
            (address holder, uint256 amount) = abi.decode(payload, (address, uint256));
            uint256 evmChain = zkToEvmChain(fromZkChain);
            _mint(holder, amount);

            emit BridgeFinalized(holder, address(this), evmChain, amount, nonce);
        } else if (fromAddress == address(_prototype)) {
            (address token,,) = cloneEncoded(payload);
            emit DeployToChainFinalized(token, zkToEvmChain(fromZkChain), nonce);
        } else {
            revert SentFromDifferentAddress(fromAddress);
        }
    }

    /// @inheritdoc IOmniToken
    function bridgeFeeEstimate(uint256 toChain) external view returns (uint256 fee) {
        uint16 toZkChain = evmToZkChain(toChain);
        fee = _zkBridge.estimateFee(toZkChain);
    }

    /// @inheritdoc IOmniToken
    function prototype() external view returns (address) {
        return _prototype;
    }

    /// @inheritdoc IOmniToken
    function chains() external view returns (uint256[] memory) {
        return _chains;
    }

    /// @inheritdoc IOmniToken
    function cloneData() external view returns (bytes memory) {
        return _cloneData;
    }

    function zkToEvmChain(uint16 zkChain) internal view returns (uint256 chainId) {
        chainId = _zkToEvmChain[zkChain];
        if (chainId == 0) {
            revert UnsupportedSourceChain(zkChain);
        }
    }

    function evmToZkChain(uint256 chain) internal view returns (uint16 zkChain) {
        zkChain = _evmToZkChain[chain];
        if (zkChain == 0) {
            revert UnsupportedDestinationChain(chain);
        }
    }
}
