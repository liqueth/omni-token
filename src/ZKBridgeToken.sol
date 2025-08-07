// SPDX-License-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IZKBridge.sol";
import "./interfaces/IZKBridgeReceiver.sol";

contract ZKBridgeToken is ERC20, IZKBridgeReceiver {
    error AlreadyReceived(bytes32 messageHash);
    error SenderIsNotBridge(address sender);
    error UnsupportedDestinationChain(uint256 chain);
    error UnsupportedSourceChain(uint16 zkChain);

    event Bridged(address indexed holder, uint256 indexed chain, uint256 amount, uint64 nonce);
    event Received(address indexed holder, uint256 indexed chain, uint256 amount, uint64 nonce);

    IZKBridge private _zkBridge;
    mapping(uint256 => uint16) private _evmToZkChain;
    mapping(uint16 => uint256) private _zkToEvmChain;
    mapping(bytes32 => bool) private _received;

    struct ChainConfig {
        uint256 evmChainId;
        uint16 zkChainId;
        uint256 mintAmount;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        address allocTo,
        address _zkBridgeAddr,
        ChainConfig[] memory chainConfigs
    ) ERC20(name_, symbol_) {
        _zkBridge = IZKBridge(_zkBridgeAddr);

        // Initialize chain ID mappings and mint on local chain if specified
        bool localChainIncluded = false;
        for (uint256 i = 0; i < chainConfigs.length; i++) {
            _evmToZkChain[chainConfigs[i].evmChainId] = chainConfigs[i].zkChainId;
            _zkToEvmChain[chainConfigs[i].zkChainId] = chainConfigs[i].evmChainId;
            if (chainConfigs[i].evmChainId == block.chainid) {
                localChainIncluded = true;
                if (chainConfigs[i].mintAmount > 0) {
                    _mint(allocTo, chainConfigs[i].mintAmount);
                }
            }
        }
        require(localChainIncluded, "Local chain ID not in chainConfigs");
    }

    function bridge(uint256 toChain, uint256 amount) external payable {
        bytes memory payload = abi.encode(msg.sender, amount);
        _burn(msg.sender, amount);
        uint64 nonce = _zkBridge.send{value: msg.value}(evmToZkChain(toChain), address(this), payload);
        emit Bridged(msg.sender, toChain, amount, nonce);
    }

    function zkReceive(uint16 fromZkChain, address fromAddress, uint64 nonce, bytes calldata payload) external {
        if (msg.sender != address(_zkBridge)) {
            revert SenderIsNotBridge(msg.sender);
        }

        bytes32 messageHash = keccak256(abi.encodePacked(fromZkChain, fromAddress, nonce, payload));
        if (_received[messageHash]) {
            revert AlreadyReceived(messageHash);
        }
        _received[messageHash] = true;

        (address holder, uint256 amount) = abi.decode(payload, (address, uint256));
        emit Received(holder, zkToEvmChain(fromZkChain), amount, nonce);
        _mint(holder, amount);
    }

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
