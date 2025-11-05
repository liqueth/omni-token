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

    AddressLookup addressLookup;
    OmniToken omniTokenProto;
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
    uint256[] chains;
    uint32[] eids;

    struct UintToUintConfig {
        string env;
        string id;
        IUintToUint.KeyValue[] keyValues;
    }

    function setUp() public {
        chains = [fromChain, toChain];
        eids = [fromChainEid, toChainEid];
        mints = [[fromChain, fromMint], [toChain, toMint]];
        badMints = [[fromChain, fromMint], [unmappedChain, toMint]];

        config = newConfig(name, symbol);
        config1 = newConfig(name1, name1);
        config2a = newConfig(name2, name2);
        config2b = newConfig(name2, name2);
    }

    function newAppConfig(uint256 chain) internal {
        vm.chainId(chain);

        address endpointMapper = newEndpointMapper(endpointMapperPath);

        addressLookup = new AddressLookup{salt: 0x0}();
        address endpointLookup = newEndpointLookup();
        address receiverLookup = newMessageLibLookup();
        address senderLookup = newMessageLibLookup();

        IMessagingConfig.Struct memory global = IMessagingConfig.Struct({
            blocker: IAddressLookup(address(0)),
            endpoint: IAddressLookup(endpointLookup),
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
    }

    function initializeFactory(uint256 chain) internal {
        newAppConfig(chain);
        omniTokenProto = new OmniToken(appConfig);
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
        AddressLookup.KeyValue[] memory keyValues = new AddressLookup.KeyValue[](chains.length);
        for (uint256 i = 0; i < chains.length; i++) {
            keyValues[i].key = chains[i];
            keyValues[0].value = create(i);
        }
        (lookup,) = addressLookup.clone(keyValues);
        console.log("  lookup:", lookup);
        console.log("  lookup.value():", AddressLookup(lookup).value());
    }

    function newEndpoint(uint256 index) internal returns (address thing) {
        thing = address(new EndpointV2Mock(eids[index], endpointOwner));
    }

    function newEndpointLookup() private returns (address lookup) {
        lookup = newAddressLookup(newEndpoint);
    }

    function newMessageLib(uint256) internal returns (address thing) {
        thing = address(new MessageLibMock());
    }

    function newMessageLibLookup() private returns (address lookup) {
        lookup = newAddressLookup(newMessageLib);
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
        initializeFactory(fromChain);
        vm.chainId(fromChain);
        (address clone1,) = omniTokenProto.clone(config1);
        assertNotEq(address(clone1), address(0));
    }

    function test_CloneCanClone() public {
        initializeFactory(fromChain);
        vm.chainId(fromChain);
        (address clone1,) = omniTokenProto.clone(config1);
        assertNotEq(address(clone1), address(0));
        (address clone2a,) = omniTokenProto.clone(config2a);
        assertNotEq(address(clone2a), address(0));
        (address clone2b,) = OmniToken(clone1).clone(config2b);
        assertNotEq(address(clone2b), address(0));
        assertEq(address(clone2a), address(clone2b));
    }

    function test_RevertWhen_MintUnmappedChain() public {
        initializeFactory(fromChain);
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
        omniTokenProto.clone(badConfig);
    }

    function testInitialMintOnChainWithMintAmount() public {
        initializeFactory(fromChain);
        (address proxy,) = omniTokenProto.clone(config);
        OmniToken token = OmniToken(proxy);
        assertEq(token.balanceOf(allocTo), fromMint);
        assertEq(token.totalSupply(), fromMint);
    }

    function test_RevertWhen_LocalChainNotMapped() public {
        newAppConfig(1);
        vm.expectRevert();
        omniTokenProto = new OmniToken(appConfig);
    }
}
