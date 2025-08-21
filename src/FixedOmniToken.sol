// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OmniToken.sol";
import "./interfaces/IFixedOmniToken.sol";

/**
 * @title FixedOmniToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination via Polyhedra zkBridge.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings. Enforces zkBridge-only callbacks, source/peer validation, and replay protection.
 * @custom:source https://github.com/liqueth/omni-token
 */
contract FixedOmniToken is OmniToken, IFixedOmniToken {
    /**
     * @notice Initializes zkBridge endpoint, chain ID mappings.
     * @param zkBridge_ zkBridge endpoint address on all chains.
     * @param zkChains Map EVM chain ids to zk bridge chain ids.
     */
    constructor(address zkBridge_, uint256[][] memory zkChains) OmniToken(zkBridge_, zkChains) {}

    function clonePrediction(address holder, string memory name, string memory symbol, uint256[][] memory mints)
        public
        view
        returns (address token, bytes32 salt, bytes memory cloneData)
    {
        cloneData = abi.encode(holder, name, symbol, mints);
        salt = keccak256(cloneData);
        token = Clones.predictDeterministicAddress(_prototype, salt, _prototype);
    }

    /// @inheritdoc IFixedOmniToken
    function clone(address holder, string memory name, string memory symbol, uint256[][] memory mints)
        public
        returns (address token, bytes32 salt, bytes memory cloneData)
    {
        if (address(this) != _prototype) {
            return IFixedOmniToken(_prototype).clone(holder, name, symbol, mints);
        }

        (token, salt, cloneData) = clonePrediction(holder, name, symbol, mints);
        if (address(token).code.length == 0) {
            Clones.cloneDeterministic(address(this), salt);
            uint256[][] memory zkChains = new uint256[][](_chains.length);
            for (uint256 i = 0; i < _chains.length; i++) {
                zkChains[i] = new uint256[](2);
                zkChains[i][0] = _chains[i];
                zkChains[i][1] = evmToZkChain(_chains[i]);
            }
            FixedOmniToken(address(token)).initialize(holder, cloneData, name, symbol, _zkBridge, zkChains, mints);
        }

        emit Cloned(holder, address(token), name, symbol);
    }

    function cloneEncoded(bytes memory cloneData_)
        public
        override(OmniToken, IOmniToken)
        returns (address token, bytes32 salt, bytes memory cloneData)
    {
        (address holder, string memory name, string memory symbol, uint256[][] memory mints) =
            abi.decode(cloneData_, (address, string, string, uint256[][]));
        (token, salt, cloneData) = clone(holder, name, symbol, mints);
    }

    function initialize(
        address holder,
        bytes memory cloneData_,
        string memory name,
        string memory symbol,
        IZKBridge zkBridge_,
        uint256[][] memory zkChains,
        uint256[][] memory mints
    ) public initializer {
        super.initialize(cloneData_, name, symbol, zkBridge_, zkChains);
        for (uint256 i = 0; i < mints.length; i++) {
            uint256 chain = mints[i][0];
            evmToZkChain(chain); // Ensure chain is valid
            uint256 mint = mints[i][1];
            if (chain == block.chainid) {
                if (mint > 0) {
                    _mint(holder, mint);
                }
            }
        }
    }
}
