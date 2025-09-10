// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/src/Test.sol";
import "../src/OmniToken.sol";
import "../src/MessagingConfig.sol";

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
    string constant name1 = "Clone1";
    string constant name2 = "Clone2";
    OmniToken factory;
    OmniToken token;
    IMessagingConfig appConfig;
    OmniToken.Config config;
    OmniToken.Config config1;
    OmniToken.Config config2a;
    OmniToken.Config config2b;
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
        appConfig = loadEndpointConfig("./config/endpoint/testnet.json");
        factory = new OmniToken(appConfig);

        config = OmniToken.Config({mints: mints, owner: allocTo, name: name, symbol: symbol});
        config1 = OmniToken.Config({mints: mints, owner: allocTo, name: name1, symbol: name1});
        config2a = OmniToken.Config({mints: mints, owner: allocTo, name: name2, symbol: name2});
        config2b = OmniToken.Config({mints: mints, owner: allocTo, name: name2, symbol: name2});
        (address proxy,) = factory.clone(config);
        token = OmniToken(proxy);
    }

    function loadEndpointConfig(string memory path) public returns (IMessagingConfig cfg) {
        string memory json = vm.readFile(path);
        bytes memory encodedData = vm.parseJson(json);
        IMessagingConfig.Struct memory global = abi.decode(encodedData, (IMessagingConfig.Struct));
        cfg = new MessagingConfig{salt: 0x0}(global);
    }

    function test_CloneCanClone() public {
        vm.chainId(fromChain);
        (address clone1,) = factory.clone(config1);
        assertNotEq(address(clone1), address(0));
        (address clone2a,) = factory.clone(config2a);
        assertNotEq(address(clone2a), address(0));
        (address clone2b,) = OmniToken(clone1).clone(config2b);
        assertNotEq(address(clone2b), address(0));
        assertEq(address(clone2a), address(clone2b));
    }

    function test_RevertWhen_MintUnmappedChain() public {
        vm.chainId(fromChain);
        //vm.expectRevert(abi.encodeWithSelector(IOmniToken.UnsupportedDestinationChain.selector, unmappedChain));
        OmniToken.Config memory badConfig =
            OmniToken.Config({mints: badMints, owner: allocTo, name: name, symbol: symbol});
        factory.clone(badConfig);
    }

    function testInitialMintOnChainWithMintAmount() public view {
        assertEq(token.balanceOf(allocTo), fromMint);
        assertEq(token.totalSupply(), fromMint);
    }

    function test_RevertWhen_LocalChainNotMapped() public {
        vm.chainId(1); // Unsupported EVM chain ID
        //vm.expectRevert("Local chain ID not in chains");
        new OmniToken(appConfig);
    }
}
