// SPDX-License-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IZKBridge.sol";
import "./interfaces/IZKBridgeReceiver.sol";

contract ZKBridgeToken is ERC20, Ownable, IZKBridgeReceiver {
    address public immutable zkBridgeAddr;
    mapping(uint256 => uint16) public evmToZkChainId; // EVM chainId => zkBridge chainId
    mapping(uint16 => uint256) public zkToEvmChainId; // zkBridge chainId => EVM chainId

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
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(allocTo != address(0), "Invalid allocation address");
        require(_zkBridgeAddr != address(0), "Invalid zkBridge address");
        require(chainConfigs.length > 0, "Must provide at least one chain config");

        zkBridgeAddr = _zkBridgeAddr;

        // Initialize chain ID mappings and mint on local chain if specified
        bool localChainIncluded = false;
        for (uint256 i = 0; i < chainConfigs.length; i++) {
            require(chainConfigs[i].zkChainId != 0, "Invalid zkBridge chain ID");
            require(chainConfigs[i].evmChainId != 0, "Invalid EVM chain ID");
            evmToZkChainId[chainConfigs[i].evmChainId] = chainConfigs[i].zkChainId;
            zkToEvmChainId[chainConfigs[i].zkChainId] = chainConfigs[i].evmChainId;
            if (chainConfigs[i].evmChainId == block.chainid) {
                localChainIncluded = true;
                if (chainConfigs[i].mintAmount > 0) {
                    _mint(allocTo, chainConfigs[i].mintAmount);
                }
            }
        }
        require(localChainIncluded, "Local chain ID not in chainConfigs");
    }

    function bridgeOut(uint256 dstEvmChainId, uint256 amount, address recipient) external payable {
        uint16 dstZkChainId = evmToZkChainId[dstEvmChainId];
        uint16 localZkChainId = evmToZkChainId[block.chainid];
        require(localZkChainId != 0, "Local chain ID not mapped");
        require(dstZkChainId != 0, "Destination chain ID not mapped");
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than zero");

        _burn(msg.sender, amount);

        bytes memory payload = abi.encode(
            address(this), // tokenAddress (source token contract)
            localZkChainId, // tokenChain (source zkChainId)
            amount, // amount
            recipient, // to (recipient on dest)
            dstZkChainId // toChain (dest zkChainId)
        );

        IZKBridge(zkBridgeAddr).send{value: msg.value}(dstZkChainId, address(this), payload);
    }

    function zkReceive(uint16 srcZkChainId, address srcAddress, uint64, /*nonce*/ bytes calldata payload)
        external
        override
    {
        require(msg.sender == zkBridgeAddr, "Caller must be zkBridge");
        require(srcAddress == address(this), "Invalid source contract");
        require(zkToEvmChainId[srcZkChainId] != 0, "Source chain ID not mapped");

        (address tokenAddress, uint16 tokenChain, uint256 amount, address to, uint16 toChain) =
            abi.decode(payload, (address, uint16, uint256, address, uint16));

        require(toChain == evmToZkChainId[block.chainid], "Payload destination chain mismatch");
        require(tokenChain == srcZkChainId, "Token chain mismatch with source");
        require(tokenAddress == address(this), "Token address mismatch with source");
        require(amount > 0, "Amount must be greater than zero");
        require(to != address(0), "Invalid recipient");

        _mint(to, amount);
    }

    function estimateBridgeFee(uint16 dstZkChainId) external view returns (uint256) {
        return IZKBridge(zkBridgeAddr).estimateFee(dstZkChainId);
    }
}
