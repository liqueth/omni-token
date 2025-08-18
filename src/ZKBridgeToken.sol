// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IZKBridgeToken.sol";
import "./interfaces/IZKBridge.sol";
import "./interfaces/IZKBridgeReceiver.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

/**
 * @title ZKBridgeToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination via Polyhedra zkBridge.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings. Enforces zkBridge-only callbacks, source/peer validation, and replay protection.
 * @custom:source https://github.com/liqueth/ZKBridgeToken
 */
contract ZKBridgeToken is ERC20Upgradeable, IZKBridgeToken, IZKBridgeReceiver {
    ZKBridgeToken private _implementation;
    IZKBridge private _zkBridge;
    bytes private _cloneData;
    uint256[] private _chains;
    mapping(uint256 => uint16) private _evmToZkChain;
    mapping(uint16 => uint256) private _zkToEvmChain;
    mapping(bytes32 => bool) private _received;

    /**
     * @notice Initializes zkBridge endpoint, chain ID mappings.
     * @param zkBridge_ zkBridge endpoint address on all chains.
     * @param zkChains Map EVM chain ids to zk bridge chain ids.
     */
    constructor(address zkBridge_, uint256[][] memory zkChains) {
        _implementation = this;
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

    function cloneEncoded(bytes memory cloneData_) external returns (IZKBridgeToken token) {
        (address holder, string memory name, string memory symbol, uint256[][] memory mints) =
            abi.decode(cloneData_, (address, string, string, uint256[][]));
        token = clone(holder, name, symbol, mints);
    }

    /// @inheritdoc IZKBridgeToken
    function clone(address holder, string memory name, string memory symbol, uint256[][] memory mints)
        public
        returns (IZKBridgeToken token)
    {
        if (this != _implementation) {
            return _implementation.clone(holder, name, symbol, mints);
        }

        (address proxy, bytes32 salt) = predictAddress(holder, name, symbol, mints);
        token = IZKBridgeToken(proxy);
        if (proxy.code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            uint256[][] memory zkChains = new uint256[][](_chains.length);
            for (uint256 i = 0; i < _chains.length; i++) {
                zkChains[i] = new uint256[](2);
                zkChains[i][0] = _chains[i];
                zkChains[i][1] = _evmToZkChain[_chains[i]];
            }
            ZKBridgeToken(proxy).initialize(holder, name, symbol, _zkBridge, zkChains, mints);
        }

        emit Cloned(holder, proxy, name, symbol);
    }

    function initialize(
        address holder,
        string memory name,
        string memory symbol,
        IZKBridge zkBridge_,
        uint256[][] memory zkChains,
        uint256[][] memory mints
    ) public initializer {
        __ERC20_init(name, symbol);
        _implementation = ZKBridgeToken(msg.sender);
        _zkBridge = zkBridge_;
        _cloneData = abi.encode(holder, name, symbol, mints);
        initializeChains(zkChains);
        for (uint256 i = 0; i < mints.length; i++) {
            uint256 chain = mints[i][0];
            uint256 mint = mints[i][1];
            if (chain == block.chainid) {
                if (mint > 0) {
                    _mint(holder, mint);
                }
            }
        }
    }

    function predictAddress(address holder, string memory name, string memory symbol, uint256[][] memory mints)
        internal
        view
        returns (address proxy, bytes32 salt)
    {
        salt = keccak256(abi.encode(holder, name, symbol, mints));
        proxy = Clones.predictDeterministicAddress(address(this), salt, address(this));
    }

    /// @inheritdoc IZKBridgeToken
    function deployToChain(uint256 toChain) external payable {
        uint64 nonce = _zkBridge.send{value: msg.value}(evmToZkChain(toChain), address(_implementation), _cloneData);
        emit DeployToChainInitiated(address(this), toChain, nonce);
    }

    /// @inheritdoc IZKBridgeToken
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
        } else if (fromAddress == address(_implementation)) {
            // This is a bridge callback for a deployToChain message
            (address holder, string memory name, string memory symbol, uint256[][] memory mints) =
                abi.decode(_cloneData, (address, string, string, uint256[][]));
            IZKBridgeToken token = clone(holder, name, symbol, mints);
            emit DeployToChainFinalized(address(token), zkToEvmChain(fromZkChain), nonce);
        } else {
            revert SentFromDifferentAddress(fromAddress);
        }
    }

    /// @inheritdoc IZKBridgeToken
    function bridgeFeeEstimate(uint256 toChain) external view returns (uint256 fee) {
        uint16 toZkChain = evmToZkChain(toChain);
        fee = _zkBridge.estimateFee(toZkChain);
    }

    function chains() external view returns (uint256[] memory) {
        return _chains;
    }

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
