// SPDX-License-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ZKBridgeToken.sol";

contract ZKBridgeTokenTest is Test {
    uint256 constant mintAcount = 1_000_000 * 10 ** 18;
    ZKBridgeToken token;
    address zkBridgeMock = address(0x123);
    address allocTo = address(0xABC);
    address bridgeTo = address(0xDEF);

    function setUp() public {
        vm.chainId(11155111); // EVM chain ID for Sepolia
        ZKBridgeToken.ChainConfig[] memory chains = new ZKBridgeToken.ChainConfig[](2);
        chains[0] = ZKBridgeToken.ChainConfig(11155111, mintAcount, "Ethereum Testnet", 119);
        chains[1] = ZKBridgeToken.ChainConfig(97, 0, "BNB Testnet", 103); // BSC Testnet, no mint

        vm.prank(allocTo);
        token = new ZKBridgeToken(allocTo, "ZKBridgeToken", "ZBT", zkBridgeMock, chains);
    }

    function testInitialMintOnChainWithMintAmount() public view {
        assertEq(token.balanceOf(allocTo), mintAcount);
        assertEq(token.totalSupply(), mintAcount);
    }

    function testNoMintOnChainWithZeroMintAmount() public {
        vm.chainId(97); // BSC Testnet EVM chain ID
        ZKBridgeToken.ChainConfig[] memory chains = new ZKBridgeToken.ChainConfig[](2);
        chains[0] = ZKBridgeToken.ChainConfig(11155111, mintAcount, "Ethereum Testnet", 119);
        chains[1] = ZKBridgeToken.ChainConfig(97, 0, "BNB Testnet", 103);

        vm.prank(allocTo);
        ZKBridgeToken nonMintToken = new ZKBridgeToken(allocTo, "ZKBridgeToken", "ZBT", zkBridgeMock, chains);
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
        token.bridge{value: 0.1 ether}(97, 1000); // dstEvmChainId = 97 (BSC Testnet)
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testZkReceiveFromValidChain() public {
        vm.prank(zkBridgeMock);
        bytes memory payload = abi.encode(
            bridgeTo, // to
            1000 // amount
        );
        vm.chainId(97); // BSC Testnet
        token.zkReceive(119, address(token), 1, payload);
        assertEq(token.balanceOf(bridgeTo), 1000);
    }

    function test_RevertWhen_ZkReceiveFromUnmappedChain() public {
        vm.prank(zkBridgeMock);
        bytes memory payload = abi.encode(address(0xABC), 1000);
        vm.chainId(97);
        vm.expectRevert();
        token.zkReceive(999, address(token), 1, payload);
    }

    function test_RevertWhen_LocalChainNotMapped() public {
        vm.chainId(1); // Unsupported EVM chain ID
        ZKBridgeToken.ChainConfig[] memory chains = new ZKBridgeToken.ChainConfig[](2);
        chains[0] = ZKBridgeToken.ChainConfig(11155111, mintAcount, "Ethereum Testnet", 119);
        chains[1] = ZKBridgeToken.ChainConfig(97, 0, "BNB Testnet", 103);

        vm.expectRevert("Local chain ID not in chains");
        new ZKBridgeToken(allocTo, "ZKBridgeToken", "ZBT", zkBridgeMock, chains);
    }
}
