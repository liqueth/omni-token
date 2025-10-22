// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AddressLookup} from "../src/AddressLookup.sol";

import "forge-std/Test.sol";

contract AddressLookupTest is Test {
    AddressLookup proto;
    Config config;

    // The contract maps a key and a network to a KV lookup table
    struct Config {
        string env;
        string id;
        AddressLookup.KeyValue[] keyValues;
    }

    // setUp() is always run before each test
    function setUp() public {
        config = abi.decode(vm.parseJson(vm.readFile("test/endpoint.json")), (Config));
        // CREATE2 for proto, so its address is stable across our snapshots
        proto = new AddressLookup{salt: 0x0}();
        assertNotEq(address(proto), address(0), "proto is unexpectedly zero in setup().");
    }

    // Test clone()
    function test_AddressLookupClone() public {
        (address address1, bytes32 salt1) = proto.clone(config.keyValues);
        assertNotEq(address1, address(0), "address1 is unexpectedly zero.");
        assertNotEq(salt1, bytes32(0), "salt2 is unexpectedly zero.");
    }

    // Test redundant clone()
    function test_AddressLookupClone2() public {
        (address address1, bytes32 salt1) = proto.clone(config.keyValues);
        assertNotEq(address1, address(0), "address1 is unexpectedly zero.");
        assertNotEq(salt1, bytes32(0), "salt1 is unexpectedly zero.");

        (address address2, bytes32 salt2) = proto.clone(config.keyValues);
        assertNotEq(address2, address(0), "address2 is unexpectedly zero.");
        assertNotEq(salt2, bytes32(0), "salt2 is unexpectedly zero.");

        assertEq(address1, address2, "Second clone should return address1.");
        assertEq(salt1, salt2, "Second clone should return same salt as address1.");
    }

    // Test that clone() clones to the address that cloneAddress() predicts
    function test_AddressLookupCloneAddress() public {
        (address address1, bytes32 salt1) = proto.cloneAddress(config.keyValues);
        (address address2, bytes32 salt2) = proto.clone(config.keyValues);
        assertEq(address1, address2, "cloneAddress() and clone() disagree on deployed address.");
        assertEq(salt1, salt2, "cloneAddress() and clone() return different values for salt.");
    }

    // Test that different KVs affect the resulting address.
    function test_AddressLookupCloneDifferentKVsGivesDifferentAddress() public {
        AddressLookup.KeyValue[] memory altered = config.keyValues;
        altered[0].value = address(42);
        (address address1,) = proto.clone(config.keyValues);
        (address address2,) = proto.clone(altered);
        assertNotEq(address1, address(0), "clone of KVs failed.");
        assertNotEq(address2, address(0), "clone of modified KVs failed.");
        assertNotEq(address1, address2, "Distinct KVs should yield different clone addresses");
    }

    // Test that empty KVs is acceptable (This should probably be reversed but it's currently allowed)
    function test_AddressLookupEmptyConfigIsDeterministic() public {
        AddressLookup.KeyValue[] memory empty;
        (address address1, bytes32 salt1) = proto.cloneAddress(empty);
        assertNotEq(address1, address(0), "cloneAddress() on empty KVs failed.");
        assertNotEq(salt1, 0, "salt1 unexpectedly zero.");
        (address address2, bytes32 salt2) = proto.clone(empty);
        assertNotEq(address2, address(0), "clone() on empty KVs failed.");
        assertNotEq(salt2, 0, "salt2 unexpectedly zero.");
        assertEq(address1, address2, "cloneAddress() and clone() should return the same address.");
        assertEq(salt1, salt2, "cloneAddress() and clone() should return the same salt.");
    }

    // Helper for switching chain-ids during cloneAddress()
    function _predictUnder(uint256 newChainId) internal returns (address predicted, bytes32 salt) {
        uint256 prev = block.chainid;
        vm.chainId(newChainId);
        (predicted, salt) = proto.cloneAddress(config.keyValues);
        vm.chainId(prev);
    }

    // Helper for switching chain-ids during clone()
    function _deployUnder(uint256 newChainId) internal returns (address deployed, bytes32 salt) {
        uint256 prev = block.chainid;
        vm.chainId(newChainId);
        (deployed, salt) = proto.clone(config.keyValues);
        vm.chainId(prev);
    }

    // Show determinism across chain IDs (prediction)
    function test_AddressLookupSamePredictedAddressAcrossChainIds() public {
        // Pick any two distinct chain IDs you care about
        uint256 CHAIN_A = 1; // Ethereum mainnet
        uint256 CHAIN_B = 8453; // Base mainnet (example)

        (address pA, bytes32 sA) = _predictUnder(CHAIN_A);
        (address pB, bytes32 sB) = _predictUnder(CHAIN_B);

        // If your salt/bytecode/deployer are the same and you don't bake chainid into your salt,
        // these should be identical.
        assertEq(pA, pB, "Predicted clone address should be identical across chain IDs");
        assertEq(sA, sB, "Predicted salt should be identical across chain IDs");
    }

    // Show determinism across chain IDs (deployment)
    function test_AddressLookupSameDeployedAddressAcrossChainIds() public {
        uint256 CHAIN_A = 1;
        uint256 CHAIN_B = 8453;

        // Take a clean snapshot of the world right after setUp()
        uint256 snap = vm.snapshotState();

        // Deploy under CHAIN_A
        (address dA, bytes32 sA) = _deployUnder(CHAIN_A);
        assertNotEq(dA, address(0), "Deploy on CHAIN_A failed");
        assertNotEq(sA, bytes32(0), "Salt unexpectedly zero on CHAIN_A");

        // Roll back state so we can deploy "fresh" again
        vm.revertToState(snap);

        // Deploy under CHAIN_B
        (address dB, bytes32 sB) = _deployUnder(CHAIN_B);
        assertNotEq(dB, address(0), "Deploy on CHAIN_B failed");
        assertNotEq(sB, bytes32(0), "Salt unexpectedly zero on CHAIN_B");

        // If chain ID is not included in your salt/derivation, these must match
        assertEq(dA, dB, "Deployed clone address should match across chain IDs");
        assertEq(sA, sB, "Salt should match across chain IDs");
    }
}
