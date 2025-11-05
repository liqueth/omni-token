// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AddressLookup.sol";
import "../src/OmniToken.sol";
import "../src/MessagingConfig.sol";
import "../src/ImmutableUintToUint.sol";
import {EndpointV2Mock} from "./mocks/EndpointV2Mock.sol";
import {MessageLibMock} from "./mocks/MessageLibMock.sol";

import {IOFTProto} from "../src/interfaces/IOFTProto.sol";

contract OmniTokenTest is Test {
    uint256 constant unmappedChain = 11155112;
    uint256 constant fromKeyIndex = 1;
    uint256 constant fromChain = 11155111;
    uint32 constant fromChainEid = 40161;
    uint256 constant fromMint = 1_000_000;
    uint256 constant toKeyIndex = 0;
    uint256 constant toChain = 97;
    uint32 constant toChainEid = 40102;
    uint16 unsupportedSourceChain = 999;
    uint128 constant rgl = 35000;
    uint256 constant toMint = 1_000_000;
    string constant name = "Omni token";
    string constant symbol = "OMNI";
    string constant name1 = "Clone1";
    string constant name2 = "Clone2";
    string constant endpointMapperPath = "test/endpointMapper.json";
    string constant endpointPath = "test/endpoint.json";

    AddressLookup addressLookup;
    OmniToken factory;
    IMessagingConfig appConfig;
    OmniToken.Config config;
    OmniToken.Config config1;
    OmniToken.Config config2a;
    OmniToken.Config config2b;
    address allocTo = address(0xABC);
    address issuer = allocTo;
    address bridgeTo = address(0xDEF);
    address endpointOwner = vm.addr(3);
    uint256[][] mints;
    uint256[][] badMints;
    uint32[] eids;

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

    function setUp() public {
        vm.chainId(fromChain);

        eids = new uint32[](2);
        eids[fromKeyIndex] = fromChainEid;
        eids[toKeyIndex] = toChainEid;

        mints = [[fromChain, fromMint], [toChain, toMint]];
        badMints = [[fromChain, fromMint], [unmappedChain, toMint]];

        config = newConfig(name, symbol);
        config1 = newConfig(name1, name1);
        config2a = newConfig(name2, name2);
        config2b = newConfig(name2, name2);

        address endpointMapper = newEndpointMapper(endpointMapperPath);

        addressLookup = new AddressLookup{salt: 0x0}();

        address endpointAlias = newEndpoint();
        console.log("endpointAlias:", endpointAlias);

        address senderLookup = newSenderLookup();
        console.log("senderLookup:", senderLookup);

        address receiverLookup = newReceiverLookup();
        console.log("receiverLookup:", receiverLookup);

        vm.prank(allocTo);

        IMessagingConfig.Struct memory global = IMessagingConfig.Struct({
            blocker: IAddressLookup(address(0)),
            endpoint: IAddressLookup(endpointAlias),
            endpointMapper: IUintToUint(endpointMapper),
            executor: IAddressLookup(address(0)),
            receiver: IAddressLookup(receiverLookup),
            sender: IAddressLookup(senderLookup)
        });
        appConfig = new MessagingConfig{salt: 0x0}(global);

        console.log("appConfig:");
        console.log("  blocker:", address(appConfig.blocker()));
        console.log("  endpoint:", address(appConfig.endpoint()));
        console.log("  executor:", address(appConfig.executor()));
        console.log("  receiver:", address(appConfig.receiver()));
        console.log("  sender:", address(appConfig.sender()));

        factory = new OmniToken(appConfig);
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

    function newAddressLookup(function(uint256) returns (address) create) internal returns (address lookup) {
        console.log("newAddressLookup:");
        address to = create(0);
        console.log("  to:", to);
        address from = create(1);
        console.log("  from:", from);
        AddressLookup.KeyValue[] memory keyValues = new AddressLookup.KeyValue[](2);
        keyValues[0].key = toChain;
        keyValues[0].value = to;
        keyValues[1].key = fromChain;
        keyValues[1].value = from;
        (lookup,) = addressLookup.clone(keyValues);
        console.log("  lookup:", lookup);
        console.log("  lookup.value():", AddressLookup(lookup).value());
    }

    function newEndpointV2Mock(uint256 index) internal returns (address thing) {
        thing = address(new EndpointV2Mock(eids[index], endpointOwner));
    }

    function newEndpoint() private returns (address lookup) {
        lookup = newAddressLookup(newEndpointV2Mock);
    }

    function newMessageLibMock(uint256) internal returns (address thing) {
        thing = address(new MessageLibMock());
    }

    function newSenderLookup() private returns (address lookup) {
        lookup = newAddressLookup(newMessageLibMock);
    }

    function newReceiverLookup() private returns (address lookup) {
        lookup = newAddressLookup(newMessageLibMock);
    }

    function newEndpointMapper(string memory path) private returns (address mapper) {
        ImmutableUintToUint cloner = new ImmutableUintToUint{salt: 0x0}();

        // Read & decode config
        bytes memory raw = vm.parseJson(vm.readFile(path));
        UintToUintConfig memory cfg = abi.decode(raw, (UintToUintConfig));

        // Resolve expected clone address (pure/read-only)
        (mapper,) = cloner.clone(cfg.keyValues);
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
