// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/FixedOmniToken.sol";

contract OmniTokenTest is Test {
    uint256 constant unmappedChain = 11155112;
    uint256 constant fromChain = 11155111;
    uint256 constant fromPk = 119;
    uint256 constant fromMint = 1_000_000;
    uint256 constant toChain = 97;
    uint256 constant toPk = 103;
    uint16 unsupportedSourceChain = 999;
    uint256 constant toMint = 1_000_000;
    string constant name = "Omni token";
    string constant symbol = "OMNI";
    string constant clone1Name = "Clone1";
    string constant clone2Name = "Clone2";
    IFixedOmniToken factory;
    IFixedOmniToken token;
    address zkBridgeMock = address(0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7);
    address allocTo = address(0xABC);
    address bridgeTo = address(0xDEF);
    uint256[][] chains;
    uint256[][] mints;
    uint256[][] badMints;

    function setUp() public {
        vm.chainId(fromChain);
        chains = [[fromChain, fromPk], [toChain, toPk]];
        mints = [[fromChain, fromMint], [toChain, toMint]];
        badMints = [[fromChain, fromMint], [unmappedChain, toMint]];
        vm.prank(allocTo);
        factory = new FixedOmniToken(zkBridgeMock, chains);
        (address proxy,,) = factory.clone(allocTo, name, symbol, mints);
        token = IFixedOmniToken(proxy);
    }

    function test_CloneCanClone() public {
        vm.chainId(fromChain);
        (address clone1,,) = factory.clone(allocTo, clone1Name, clone1Name, mints);
        assertNotEq(address(clone1), address(0));
        (address clone2a,,) = factory.clone(allocTo, clone2Name, clone2Name, mints);
        assertNotEq(address(clone2a), address(0));
        (address clone2b,,) = IFixedOmniToken(clone1).clone(allocTo, clone2Name, clone2Name, mints);
        assertNotEq(address(clone2b), address(0));
        assertEq(address(clone2a), address(clone2b));
    }

    function test_RevertWhen_MintUnmappedChain() public {
        vm.chainId(fromChain);
        vm.expectRevert(abi.encodeWithSelector(IOmniToken.UnsupportedDestinationChain.selector, unmappedChain));
        factory.clone(allocTo, clone1Name, clone1Name, badMints);
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
        FixedOmniToken(address(token)).zkReceive(uint16(fromPk), address(token), 1, payload);
        assertEq(token.balanceOf(bridgeTo), 1000);
    }

    function test_RevertWhen_ZkReceiveFromUnmappedChain() public {
        vm.prank(zkBridgeMock);
        bytes memory payload = abi.encode(allocTo, 1000);
        vm.chainId(toChain);
        vm.expectRevert(abi.encodeWithSelector(IOmniToken.UnsupportedSourceChain.selector, unsupportedSourceChain));
        FixedOmniToken(address(token)).zkReceive(unsupportedSourceChain, address(token), 1, payload);
    }

    function test_RevertWhen_ZkReceiveFromDifferentAddress() public {
        vm.prank(zkBridgeMock);
        bytes memory payload = abi.encode(allocTo, 1000);
        vm.chainId(toChain);
        vm.expectRevert(abi.encodeWithSelector(IOmniToken.SentFromDifferentAddress.selector, allocTo));
        FixedOmniToken(address(token)).zkReceive(uint16(fromPk), allocTo, 1, payload);
    }

    function test_RevertWhen_LocalChainNotMapped() public {
        vm.chainId(1); // Unsupported EVM chain ID
        vm.expectRevert("Local chain ID not in chains");
        new FixedOmniToken(zkBridgeMock, chains);
    }
}
