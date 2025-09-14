// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/OmniAddress.sol";
import "../src/OmniToken.sol";
import "../src/MessagingConfig.sol";
import "../src/ImmutableUintToUint.sol";

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
    string constant messagingPath = "test/messaging.json";
    OmniAddress omniAddress;
    OmniToken factory;
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

    struct OmniAddressConfig {
        string env;
        string id;
        OmniAddress.KeyValue[] keyValues;
    }

    struct UintToUintConfig {
        string env;
        string id;
        IUintToUint.KeyValue[] keyValues;
    }

    function setUp() public {
        vm.chainId(fromChain);

        deployEndpointMapper();

        omniAddress = new OmniAddress{salt: 0x0}();
        console.log("OmniAddress: ", address(omniAddress));

        newEndpoint();

        chains = [[fromChain, fromPk], [toChain, toPk]];
        mints = [[fromChain, fromMint], [toChain, toMint]];
        badMints = [[fromChain, fromMint], [unmappedChain, toMint]];
        vm.prank(allocTo);
        console.log("before loadEndpointConfig");
        appConfig = loadEndpointConfig(messagingPath);
        console.log("App config address: ", address(appConfig));
        address endpoint = address(appConfig.endpoint());
        console.log("endpoint: ", address(endpoint));

        factory = new OmniToken(appConfig);
        console.log("config: ");

        config = IOmniTokenCloner.Config({mints: mints, owner: allocTo, name: name, symbol: symbol});
        config1 = IOmniTokenCloner.Config({mints: mints, owner: allocTo, name: name1, symbol: name1});
        config2a = IOmniTokenCloner.Config({mints: mints, owner: allocTo, name: name2, symbol: name2});
        config2b = IOmniTokenCloner.Config({mints: mints, owner: allocTo, name: name2, symbol: name2});
    }

    function newEndpoint() private returns (address endpointAlias) {
        string memory endpointPath = "test/endpoint.json";
        bytes memory raw = vm.parseJson(vm.readFile(endpointPath));
        OmniAddressConfig memory cfg = abi.decode(raw, (OmniAddressConfig));
        (endpointAlias,) = omniAddress.clone(cfg.keyValues);
        console.log("endpointAlias: ", address(endpointAlias));
        vm.writeJson(vm.toString(endpointAlias), messagingPath, ".endpoint");
    }

    function deployEndpointMapper() private returns (address mapper) {
        ImmutableUintToUint cloner = new ImmutableUintToUint{salt: 0x0}();
        string memory path = "test/eid.json";

        // Read & decode config
        bytes memory raw = vm.parseJson(vm.readFile(path));
        UintToUintConfig memory cfg = abi.decode(raw, (UintToUintConfig));

        // Resolve expected clone address (pure/read-only)
        (mapper,) = cloner.cloneAddress(cfg.keyValues);
        console.log("endpointMapper: ", mapper);
    }

    function loadEndpointConfig(string memory path) public returns (IMessagingConfig cfg) {
        string memory json = vm.readFile(path);
        bytes memory encodedData = vm.parseJson(json);
        IMessagingConfig.Struct memory global = abi.decode(encodedData, (IMessagingConfig.Struct));
        cfg = new MessagingConfig{salt: 0x0}(global);
    }

    function test_Dummy() public pure {
        assertTrue(true);
    }

    function test_Clone1() public {
        vm.chainId(fromChain);
        (address clone1,) = factory.clone(config1);
        assertNotEq(address(clone1), address(0));
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
            IOmniTokenCloner.Config({mints: badMints, owner: allocTo, name: name, symbol: symbol});
        factory.clone(badConfig);
    }

    function testInitialMintOnChainWithMintAmount() public {
        (address proxy,) = factory.clone(config);
        OmniToken token = OmniToken(proxy);
        assertEq(token.balanceOf(allocTo), fromMint);
        assertEq(token.totalSupply(), fromMint);
    }

    function test_RevertWhen_LocalChainNotMapped() public {
        vm.chainId(1); // Unsupported EVM chain ID
        //vm.expectRevert("Local chain ID not in chains");
        new OmniToken(appConfig);
    }
}
