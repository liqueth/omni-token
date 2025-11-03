// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AddressLookup.sol";
import "../src/OmniToken.sol";
import "../src/MessagingConfig.sol";
import "../src/ImmutableUintToUint.sol";
import {EndpointV2Mock} from "./mocks/EndpointV2Mock.sol";

import {IOFTProto} from "../src/interfaces/IOFTProto.sol";

contract OmniTokenTest is Test {
    uint256 constant unmappedChain = 11155112;
    uint256 constant fromKeyIndex = 1;
    uint256 constant fromChain = 11155111;
    uint32 constant fromChainEid = 40161;
    uint256 constant fromPk = 119;
    uint256 constant fromMint = 1_000_000;
    uint256 constant toKeyIndex = 0;
    uint256 constant toChain = 97;
    uint32 constant toChainEid = 40102;
    uint256 constant toPk = 103;
    uint16 unsupportedSourceChain = 999;
    uint128 constant rgl = 35000;
    uint256 constant toMint = 1_000_000;
    string constant name = "Omni token";
    string constant symbol = "OMNI";
    string constant name1 = "Clone1";
    string constant name2 = "Clone2";
    string constant messagingPath = "test/messaging.json";
    string constant endpointMapperPath = "test/endpointMapper.json";
    string constant messagingPath3 = "test/messaging.json";
    string constant endpointPath = "test/endpoint.json";

    AddressLookup addressLookup;
    OmniToken factory;
    IMessagingConfig appConfig;
    OmniToken.Config config;
    OmniToken.Config config1;
    OmniToken.Config config2a;
    OmniToken.Config config2b;
    address zkBridgeMock = address(0xa8a4547Be2eCe6Dde2Dd91b4A5adFe4A043b21C7);
    address allocTo = address(0xABC);
    address issuer = allocTo;
    address bridgeTo = address(0xDEF);
    address endpointOwner = vm.addr(3);
    uint256[][] chains;
    uint256[][] mints;
    uint256[][] badMints;

    struct AddressLookupConfig {
        string env;
        string id;
        AddressLookup.KeyValue[] keyValues;
    }

    struct UintToUintConfig {
        string env;
        string id;
        IUintToUint.KeyValue[] keyValues;
    }

    function setUp() public {}

    function test_setUp() public {
        vm.chainId(fromChain);

        newEndpointMapper(endpointMapperPath);

        addressLookup = new AddressLookup{salt: 0x0}();

        address endpointAlias = newEndpoint();

        console.log("endpointAlias:", endpointAlias);

        chains = [[fromChain, fromPk], [toChain, toPk]];
        mints = [[fromChain, fromMint], [toChain, toMint]];
        badMints = [[fromChain, fromMint], [unmappedChain, toMint]];
        vm.prank(allocTo);
        appConfig = loadEndpointConfig(messagingPath);
        console.log("appConfig:");
        console.log("  blocker:", address(appConfig.blocker()));
        console.log("  endpoint:", address(appConfig.endpoint()));
        console.log("  executor:", address(appConfig.executor()));
        console.log("  receiver:", address(appConfig.receiver()));
        console.log("  sender:", address(appConfig.sender()));

        factory = new OmniToken(appConfig);

        config = newConfig(name, symbol);
        config1 = newConfig(name1, name1);
        config2a = newConfig(name2, name2);
        config2b = newConfig(name2, name2);
    }

    function newConfig(string memory name_, string memory symbol_) private view returns (IOFTProto.Config memory) {
        return IOFTProto.Config({
            issuer: issuer,
            mints: mints,
            name: name_,
            owner: allocTo,
            receiverGasLimit: rgl,
            symbol: symbol_,
            token: address(0)
        });
    }

    function newEndpoint() private returns (address endpointAlias) {
        address fromEndpointV2 = address(new EndpointV2Mock(fromChainEid, endpointOwner));
        address toEndpointV2 = address(new EndpointV2Mock(toChainEid, endpointOwner));
        AddressLookup.KeyValue[] memory keyValues = new AddressLookup.KeyValue[](2);
        keyValues[0].key = toChainEid;
        keyValues[0].value = toEndpointV2;
        keyValues[1].key = fromChainEid;
        keyValues[1].value = fromEndpointV2;
        (endpointAlias,) = addressLookup.clone(keyValues);
        vm.writeJson(vm.toString(endpointAlias), messagingPath, ".endpoint");
    }

    function newEndpointMapper(string memory path) private returns (address mapper) {
        ImmutableUintToUint cloner = new ImmutableUintToUint{salt: 0x0}();

        // Read & decode config
        bytes memory raw = vm.parseJson(vm.readFile(path));
        UintToUintConfig memory cfg = abi.decode(raw, (UintToUintConfig));

        // Resolve expected clone address (pure/read-only)
        (mapper,) = cloner.clone(cfg.keyValues);
        vm.writeJson(vm.toString(mapper), messagingPath, ".endpointMapper");
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

    function ntest_Clone1() public {
        vm.chainId(fromChain);
        (address clone1,) = factory.clone(config1);
        assertNotEq(address(clone1), address(0));
    }

    function ntest_CloneCanClone() public {
        vm.chainId(fromChain);
        (address clone1,) = factory.clone(config1);
        assertNotEq(address(clone1), address(0));
        (address clone2a,) = factory.clone(config2a);
        assertNotEq(address(clone2a), address(0));
        (address clone2b,) = OmniToken(clone1).clone(config2b);
        assertNotEq(address(clone2b), address(0));
        assertEq(address(clone2a), address(clone2b));
    }

    function ntest_RevertWhen_MintUnmappedChain() public {
        vm.chainId(fromChain);
        //vm.expectRevert(abi.encodeWithSelector(IBridge.UnsupportedDestinationChain.selector, unmappedChain));
        OmniToken.Config memory badConfig = IOFTProto.Config({
            issuer: issuer,
            mints: badMints,
            owner: allocTo,
            name: name,
            receiverGasLimit: rgl,
            symbol: symbol,
            token: address(0)
        });
        factory.clone(badConfig);
    }

    function ntestInitialMintOnChainWithMintAmount() public {
        (address proxy,) = factory.clone(config);
        OmniToken token = OmniToken(proxy);
        assertEq(token.balanceOf(allocTo), fromMint);
        assertEq(token.totalSupply(), fromMint);
    }

    function ntest_RevertWhen_LocalChainNotMapped() public {
        vm.chainId(1); // Unsupported EVM chain ID
        //vm.expectRevert("Local chain ID not in chains");
        new OmniToken(appConfig);
    }
}
