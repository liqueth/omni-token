// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ZKBridgeToken.sol";

contract ZKBridgeTokenTest is Test {
    uint256 constant fromChain = 11155111;
    uint256 constant fromPk = 119;
    uint256 constant fromMint = 1_000_000;
    uint256 constant toChain = 97;
    uint256 constant toPk = 103;
    uint16 unsupportedSourceChain = 999;
    uint256 constant toMint = 1_000_000;
    string constant name = "ZKBridgeToken";
    string constant symbol = "ZKBT";
    IZKBridgeToken factory;
    IZKBridgeToken token;
    address zkBridgeMock = address(0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7);
    address allocTo = address(0xABC);
    address bridgeTo = address(0xDEF);
    uint256[][] chains;
    uint256[][] mints;

    function setUp() public {
        vm.chainId(fromChain);
        chains = [[fromChain, fromPk], [toChain, toPk]];
        mints = [[fromChain, fromMint], [toChain, toMint]];

        vm.prank(allocTo);
        factory = new ZKBridgeToken(zkBridgeMock, chains);
        token = factory.clone(allocTo, name, symbol, mints);
    }

    function testInitialMintOnChainWithMintAmount() public view {
        assertEq(token.balanceOf(allocTo), fromMint);
        assertEq(token.totalSupply(), fromMint);
    }

    function testBridgeOutSameAddress() public {
        vm.chainId(fromChain);
        vm.deal(address(this), 1 ether);
        vm.prank(allocTo);
        token.transfer(address(this), 1000);

        vm.mockCall(
            zkBridgeMock, abi.encodeWithSelector(IZKBridge.send.selector, toPk, address(token)), abi.encode(1234)
        );
        token.bridge{value: 0.1 ether}(toChain, 1000);
        assertEq(token.balanceOf(address(this)), 0);
    }

    function testZkReceiveFromValidChain() public {
        vm.prank(zkBridgeMock);
        bytes memory payload = abi.encode(
            bridgeTo, // to
            1000 // amount
        );
        vm.chainId(toChain); // BSC Testnet
        ZKBridgeToken(address(token)).zkReceive(uint16(fromPk), address(token), 1, payload);
        assertEq(token.balanceOf(bridgeTo), 1000);
    }

    function test_RevertWhen_ZkReceiveFromUnmappedChain() public {
        vm.prank(zkBridgeMock);
        bytes memory payload = abi.encode(address(0xABC), 1000);
        vm.chainId(toChain);
        vm.expectRevert(abi.encodeWithSelector(IZKBridgeToken.UnsupportedSourceChain.selector, unsupportedSourceChain));
        ZKBridgeToken(address(token)).zkReceive(unsupportedSourceChain, address(token), 1, payload);
    }

    function test_RevertWhen_ZkReceiveFromDifferentAddress() public {
        vm.prank(zkBridgeMock);
        bytes memory payload = abi.encode(address(0xABC), 1000);
        vm.chainId(toChain);
        vm.expectRevert(abi.encodeWithSelector(IZKBridgeToken.SentFromDifferentAddress.selector, address(factory)));
        ZKBridgeToken(address(token)).zkReceive(uint16(fromPk), address(factory), 1, payload);
    }

    function test_RevertWhen_LocalChainNotMapped() public {
        vm.chainId(1); // Unsupported EVM chain ID
        vm.expectRevert("Local chain ID not in chains");
        new ZKBridgeToken(zkBridgeMock, chains);
    }
}
