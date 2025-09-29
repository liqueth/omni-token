// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ImmutableUintToUint} from "../src/ImmutableUintToUint.sol";
import {IUintToUint} from "../src/interfaces/IUintToUint.sol";

import "forge-std/Test.sol";

contract ImmutableUintToUintTest is Test {
    ImmutableUintToUint proto;
    Config config;

    // The contract maps a key and a network to a KV lookup table
    struct Config {
        string env;
        string id;
        IUintToUint.KeyValue[] keyValues;
    }

    // setUp() is always run before each test
    function setUp() public {
        config = abi.decode(vm.parseJson(vm.readFile("test/endpointMapper.json")), (Config));
        proto = new ImmutableUintToUint{salt: 0x0}();
        assertNotEq(address(proto), address(0), "proto is unexpectedly zero in setup().");
    }

    // Test clone()
    function test_UintToUintClone() public {
        // Simple canonical deployment
        (address address1, bytes32 salt1) = proto.clone(config.keyValues);
        assertNotEq(address1, address(0), "address1 is unexpectedly zero.");
        assertNotEq(salt1, bytes32(0), "salt2 is unexpectedly zero.");
    }

    // Test redundant clone()
    function test_UintToUintClone2() public {
        // Clone for the first time
        (address address1, bytes32 salt1) = proto.clone(config.keyValues);
        assertNotEq(address1, address(0), "address1 is unexpectedly zero.");
        assertNotEq(salt1, bytes32(0), "salt1 is unexpectedly zero.");

        // Test that a second clone looks just like the first clone
        (address address2, bytes32 salt2) = proto.clone(config.keyValues);
        assertNotEq(address2, address(0), "address2 is unexpectedly zero.");
        assertNotEq(salt2, bytes32(0), "salt2 is unexpectedly zero.");

        // Test that the second clone() was returning the same values as the first
        assertEq(address1, address2, "Second clone should return address1.");
        assertEq(salt1, salt2, "Second clone should return same salt as address1.");
    }

    // Test that clone() clones to the address that cloneAddress() predicts
    function test_UintToUintCloneAddress() public {
        // Call cloneAddress() and clone() for comparison
        (address address1, bytes32 salt1) = proto.cloneAddress(config.keyValues);
        (address address2, bytes32 salt2) = proto.clone(config.keyValues);

        // Both should return the same address and salt
        assertEq(address1, address2, "cloneAddress() and clone() disagree on deployed address.");
        assertEq(salt1, salt2, "cloneAddress() and clone() return different values for salt.");
    }

    // Test that different KVs affect the resulting address.
    function test_UintToUintCloneDifferentKVsGivesDifferentAddress() public {
        // Make a copy of the config KV's and change the first element
        IUintToUint.KeyValue[] memory altered = config.keyValues;
        altered[0].value = 42;

        // Deploy with both sets of KVs
        (address address1,) = proto.clone(config.keyValues);
        (address address2,) = proto.clone(altered);

        // Make sure that we get two non-zero address
        assertNotEq(address1, address(0), "clone of KVs failed.");
        assertNotEq(address2, address(0), "clone of modified KVs failed.");
        assertNotEq(address1, address2, "Distinct KVs should yield different clone addresses");
    }

    // Test that empty KVs is acceptable (This should probably be reversed but it's currently allowed)
    function test_UintToUintEmptyConfigIsDeterministic() public {
        // Need an empty set of KVs
        IUintToUint.KeyValue[] memory empty;

        // Call cloneAddress() on the empty set of KVs
        (address address1, bytes32 salt1) = proto.cloneAddress(empty);
        assertNotEq(address1, address(0), "cloneAddress() on empty KVs failed.");
        assertNotEq(salt1, 0, "salt1 unexpectedly zero.");

        // Call clone() on the empty set of KVs
        (address address2, bytes32 salt2) = proto.clone(empty);
        assertNotEq(address2, address(0), "clone() on empty KVs failed.");
        assertNotEq(salt2, 0, "salt2 unexpectedly zero.");

        // Expect cloneAddress() and clone() to return the same address and salt
        assertEq(address1, address2, "cloneAddress() and clone() should return the same address.");
        assertEq(salt1, salt2, "cloneAddress() and clone() should return the same salt.");
    }
}
