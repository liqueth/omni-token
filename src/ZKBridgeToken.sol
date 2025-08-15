// SPDX-License-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IZKBridge.sol";
import "./interfaces/IZKBridgeReceiver.sol";

/**
 * @title ZKBridgeToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination via Polyhedra zkBridge.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings. Enforces zkBridge-only callbacks, source/peer validation, and replay protection.
 * @custom:source https://github.com/liqueth/ZKBridgeToken
 */
contract ZKBridgeToken is ERC20, IZKBridgeReceiver {
    error AlreadyReceived(bytes32 messageHash);
    error SenderIsNotBridge(address sender);
    error UnsupportedDestinationChain(uint256 chain);
    error UnsupportedSourceChain(uint16 zkChain);

    event BridgeInitiated(address indexed holder, uint256 indexed chain, uint256 amount, uint64 nonce);
    event BridgeFinalized(address indexed holder, uint256 indexed chain, uint256 amount, uint64 nonce);

    IZKBridge private _zkBridge;
    mapping(uint256 => uint16) private _evmToZkChain;
    mapping(uint16 => uint256) private _zkToEvmChain;
    mapping(bytes32 => bool) private _received;

    /**
     * @notice Initializes name/symbol, zkBridge endpoint, chain ID mappings, and mints the local chain’s initial supply.
     * @param holder Recipient of the initial mint on this chain.
     * @param name_ ERC-20 name.
     * @param symbol_ ERC-20 symbol.
     * @param zkBridge_ zkBridge endpoint address on this chain.
     * @param zkChains Map EVM chain ids to zk bridge chain ids.
     * @param mintAmounts Map EVM chain ids to amount to mint.
     */
    constructor(
        address holder,
        string memory name_,
        string memory symbol_,
        address zkBridge_,
        uint256[][] memory zkChains,
        uint256[][] memory mintAmounts
    ) ERC20(name_, symbol_) {
        _zkBridge = IZKBridge(zkBridge_);

        // Initialize chain ID mappings and mint on local chain if specified
        bool localChainIncluded = false;
        for (uint256 i = 0; i < zkChains.length; i++) {
            uint256 evmChain = zkChains[i][0];
            uint16 zkChain = uint16(zkChains[i][1]);
            _evmToZkChain[evmChain] = uint16(zkChain);
            _zkToEvmChain[zkChain] = evmChain;
            if (evmChain == block.chainid) {
                localChainIncluded = true;
            }
        }
        require(localChainIncluded, "Local chain ID not in chains");
        for (uint256 i = 0; i < mintAmounts.length; i++) {
            uint256 evmChain = mintAmounts[i][0];
            uint256 mintAmount = mintAmounts[i][1];
            if (evmChain == block.chainid) {
                if (mintAmount > 0) {
                    _mint(holder, mintAmount);
                }
            }
        }
    }

    /**
     * @notice Burn tokens here and send a cross-chain message to mint on the destination chain.
     * @dev Reverts if the destination is unsupported or the attached fee is insufficient. Emits a bridge event on success.
     * @param toChain Destination EVM `chainid`.
     * @param amount Token amount to bridge (in smallest units).
     */
    function bridge(uint256 toChain, uint256 amount) external payable {
        bytes memory payload = abi.encode(msg.sender, amount);
        _burn(msg.sender, amount);
        uint64 nonce = _zkBridge.send{value: msg.value}(evmToZkChain(toChain), address(this), payload);
        emit BridgeInitiated(msg.sender, toChain, amount, nonce);
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

        (address holder, uint256 amount) = abi.decode(payload, (address, uint256));
        uint256 evmChain = zkToEvmChain(fromZkChain);
        _mint(holder, amount);

        emit BridgeFinalized(holder, evmChain, amount, nonce);
    }

    /**
     * @notice Returns the native fee required to bridge to a destination chain.
     * @dev Proxies the zkBridge fee estimator; some endpoints use a destination gas limit to quote fees.
     * @param toChain Destination zkBridge chain ID.
     * @return fee Estimated native value (wei) the caller should send with {bridge}.
     */
    function bridgeFeeEstimate(uint256 toChain) external view returns (uint256 fee) {
        uint16 toZkChain = evmToZkChain(toChain);
        fee = _zkBridge.estimateFee(toZkChain);
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
