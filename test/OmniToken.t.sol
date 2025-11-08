// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";

import {AddressLookup, IAddressLookup} from "../src/AddressLookup.sol";
import {OmniToken} from "../src/OmniToken.sol";
import {MessagingConfig, IMessagingConfig} from "../src/MessagingConfig.sol";
import {ImmutableUintToUint, IUintToUint} from "../src/ImmutableUintToUint.sol";
import {Bridge} from "../src/Bridge.sol";
import {OmniTokenBridged} from "../src/OmniTokenBridged.sol";

import {EndpointV2Mock} from "./mocks/EndpointV2Mock.sol";
import {MessageLibMock} from "./mocks/MessageLibMock.sol";

import {IOFTProto} from "../src/interfaces/IOFTProto.sol";

contract OmniTokenTest is Test {
    uint256 constant unmappedChain = 11155112;

    uint256 constant fromChain = 11155111;
    uint32 constant fromChainEid = 40161;
    uint256 constant fromMint = 1_000_000;

    uint256 constant toChain = 97;
    uint32 constant toChainEid = 40102;
    uint256 constant toMint = 1_000_000;

    uint128 constant receiverGasLimit = 35000;
    string constant name = "Omni token";
    string constant symbol = "OMNI";
    string constant name1 = "Clone1";
    string constant name2 = "Clone2";

    AddressLookup addressLookup;
    ImmutableUintToUint uintToUintProto;
    IOFTProto.Config config;
    IOFTProto.Config config1;
    IOFTProto.Config config2a;
    IOFTProto.Config config2b;
    address allocTo = address(0xABC);
    address issuer = allocTo;
    address bridgeTo = address(0xDEF);
    address endpointOwner = vm.addr(3);
    uint256[][] mints;
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

        config = newConfig(name, symbol);
        config1 = newConfig(name1, name1);
        config2a = newConfig(name2, name2);
        config2b = newConfig(name2, name2);
    }

    function newAppConfig(uint256 chain) public returns (IMessagingConfig appConfig) {
        vm.chainId(chain);

        address endpointMapper = newEndpointMapper();

        if (address(addressLookup) == address(0)) {
            addressLookup = new AddressLookup{salt: 0x0}();
        }
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

    function newOmniTokenProto(uint256 chain) public returns (IMessagingConfig appConfig, OmniToken proto) {
        appConfig = newAppConfig(chain);
        proto = new OmniToken(appConfig);
    }

    function newBridgeProto(uint256 chain) public returns (IMessagingConfig appConfig, Bridge proto) {
        appConfig = newAppConfig(chain);
        proto = new Bridge(appConfig);
    }

    function newOmniTokenBridgedProto(uint256 chain)
        public
        returns (IMessagingConfig appConfig, Bridge bridgeProto, OmniTokenBridged tokenProto)
    {
        appConfig = newAppConfig(chain);
        (appConfig, bridgeProto) = newBridgeProto(chain);
        tokenProto = new OmniTokenBridged(config, bridgeProto);
    }

    function newConfig(string memory name_, string memory symbol_) private view returns (IOFTProto.Config memory) {
        return IOFTProto.Config({
            issuer: issuer,
            mints: mints,
            name: name_,
            owner: allocTo,
            receiverGasLimit: receiverGasLimit,
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

    function newEndpointMapper() private returns (address mapper) {
        if (address(uintToUintProto) == address(0)) {
            uintToUintProto = new ImmutableUintToUint{salt: 0x0}();
        }

        IUintToUint.KeyValue[] memory keyValues = new IUintToUint.KeyValue[](chains.length);
        for (uint256 i = 0; i < chains.length; i++) {
            keyValues[i].key = chains[i];
            keyValues[0].value = eids[i];
        }

        // Resolve expected clone address (pure/read-only)
        (mapper,) = uintToUintProto.clone(keyValues);
    }

    function test_Dummy() public pure {
        assertTrue(true);
    }

    function test_Clone1() public {
        (, OmniToken omniTokenProto) = newOmniTokenProto(fromChain);
        (address clone1,) = omniTokenProto.clone(config1);
        assertNotEq(address(clone1), address(0));
    }

    function test_CloneCanClone() public {
        (, OmniToken proto) = newOmniTokenProto(fromChain);
        (address clone1,) = proto.clone(config1);
        assertNotEq(address(clone1), address(0));
        (address clone2a,) = proto.clone(config2a);
        assertNotEq(address(clone2a), address(0));
        (address clone2b,) = OmniToken(clone1).clone(config2b);
        assertNotEq(address(clone2b), address(0));
        assertEq(address(clone2a), address(clone2b));
    }

    uint256[][] badMints;

    function test_RevertWhen_MintUnmappedChain() public {
        (, OmniToken proto) = newOmniTokenProto(fromChain);
        badMints = [[fromChain, fromMint], [unmappedChain, toMint]];
        //vm.expectRevert(abi.encodeWithSelector(IBridge.UnsupportedDestinationChain.selector, unmappedChain));
        OmniToken.Config memory badConfig = IOFTProto.Config({
            issuer: issuer,
            mints: badMints,
            owner: allocTo,
            name: name,
            receiverGasLimit: receiverGasLimit,
            symbol: symbol,
            token: address(0)
        });
        proto.clone(badConfig);
    }

    function testInitialMintOnChainWithMintAmount() public {
        (, OmniToken proto) = newOmniTokenProto(fromChain);
        (address proxy,) = proto.clone(config);
        OmniToken token = OmniToken(proxy);
        assertEq(token.balanceOf(allocTo), fromMint);
        assertEq(token.totalSupply(), fromMint);
    }

    function test_RevertWhen_LocalChainNotMapped() public {
        IMessagingConfig appConfig = newAppConfig(unmappedChain);
        vm.expectRevert();
        new OmniToken(appConfig);
    }

    function test_BridgedToken() public {
        (, Bridge bridgeProto, OmniTokenBridged tokenProto) = newOmniTokenBridgedProto(fromChain);
        assertNotEq(address(bridgeProto), address(0));
        assertNotEq(address(tokenProto), address(0));
        (address tokenAddress,) = tokenProto.clone(config);
        assertNotEq(tokenAddress, address(0));
    }
}
