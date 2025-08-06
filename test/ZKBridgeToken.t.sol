// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ZKBridgeToken.sol";

contract ZKBridgeTokenTest is Test {
    ZKBridgeToken token;
    address zkBridgeMock = address(0x123);
    address allocTo = address(0xABC);

    function setUp() public {
        vm.chainId(11155111); // EVM chain ID for Sepolia
        ZKBridgeToken.ChainConfig[] memory chainConfigs = new ZKBridgeToken.ChainConfig[](2);
        chainConfigs[0] = ZKBridgeToken.ChainConfig(11155111, 119, 1_000_000 * 10 ** 18); // Sepolia, full mint
        chainConfigs[1] = ZKBridgeToken.ChainConfig(97, 103, 0); // BSC Testnet, no mint

        token = new ZKBridgeToken("ZKBridgeToken", "ZBT", allocTo, zkBridgeMock, chainConfigs);
    }

    function testInitialMintOnChainWithMintAmount() public view {
        assertEq(token.balanceOf(allocTo), 1_000_000 * 10 ** 18);
        assertEq(token.totalSupply(), 1_000_000 * 10 ** 18);
    }

    function testNoMintOnChainWithZeroMintAmount() public {
        vm.chainId(97); // BSC Testnet EVM chain ID
        ZKBridgeToken.ChainConfig[] memory chainConfigs = new ZKBridgeToken.ChainConfig[](2);
        chainConfigs[0] = ZKBridgeToken.ChainConfig(11155111, 119, 1_000_000 * 10 ** 18);
        chainConfigs[1] = ZKBridgeToken.ChainConfig(97, 103, 0);

        ZKBridgeToken nonMintToken = new ZKBridgeToken("ZKBridgeToken", "ZBT", allocTo, zkBridgeMock, chainConfigs);
        assertEq(nonMintToken.balanceOf(allocTo), 0);
        assertEq(nonMintToken.totalSupply(), 0);
    }

    function testBridgeOutSameAddress() public {
        vm.chainId(11155111);
        vm.deal(address(this), 1 ether);
        vm.prank(allocTo);
        token.transfer(address(this), 1000);

        vm.mockCall(
            zkBridgeMock, abi.encodeWithSelector(IZKBridge.send.selector, 103, address(token)), abi.encode(1234)
        );
        token.bridgeOut{value: 0.1 ether}(97, 1000, address(0xABC)); // dstEvmChainId = 97 (BSC Testnet)
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testZkReceiveFromValidChain() public {
        vm.prank(zkBridgeMock);
        bytes memory payload = abi.encode(
            address(token), // tokenAddress
            119, // srcZkChainId (Sepolia)
            1000, // amount
            address(0xABC), // to
            103 // toChain (BSC Testnet)
        );
        vm.chainId(97); // BSC Testnet
        token.zkReceive(119, address(token), 1, payload);
        assertEq(token.balanceOf(address(0xABC)), 1000);
    }

    function testFailZkReceiveFromUnmappedChain() public {
        vm.prank(zkBridgeMock);
        bytes memory payload = abi.encode(
            address(token),
            999, // Unmapped zkChainId
            1000,
            address(0xABC),
            103
        );
        vm.chainId(97);
        vm.expectRevert("Source chain ID not mapped");
        token.zkReceive(999, address(token), 1, payload);
    }

    function testFailLocalChainNotMapped() public {
        vm.chainId(1); // Unsupported EVM chain ID
        ZKBridgeToken.ChainConfig[] memory chainConfigs = new ZKBridgeToken.ChainConfig[](2);
        chainConfigs[0] = ZKBridgeToken.ChainConfig(11155111, 119, 1_000_000 * 10 ** 18);
        chainConfigs[1] = ZKBridgeToken.ChainConfig(97, 103, 0);

        vm.expectRevert("Local chain ID not in chainConfigs");
        new ZKBridgeToken("ZKBridgeToken", "ZBT", allocTo, zkBridgeMock, chainConfigs);
    }
}
