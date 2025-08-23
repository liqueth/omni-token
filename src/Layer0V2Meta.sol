// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Layer0V2Meta
/// @notice Maps nativeChainId => individual LayerZero v2 EVM metadata fields via separate mappings.
/// @dev Immutable after construction. No setters. Uses a small Packed bucket per chain to co-locate sub-32B scalars.
contract Layer0V2Meta {
    // -------------------- Types --------------------

    /// @notice Layer classification.
    enum ChainLayer {
        NONE,
        L1,
        L2,
        L3
    } // 0..3

    /// @notice Rollup stack classification.
    enum ChainStack {
        NONE,
        OPSTACK,
        ARBSTACK,
        AVALANCHESTACK
    } // 0..3

    /// @notice Gas-optimized bucket that packs small scalars into one storage slot.
    struct Packed {
        uint32 eid; // LayerZero endpoint id (non-zero if present)
        uint32 cmcId; // CoinMarketCap id (fits in uint32 for observed data)
        ChainLayer chainLayer;
        ChainStack chainStack;
        uint8 decimals; // native currency decimals
    }

    /// @notice Input row ONLY for constructor ingestion; not stored as a struct.
    struct Row {
        uint256 nativeChainId;
        // packed scalars
        uint32 eid;
        uint32 cmcId;
        uint8 chainLayer; // 0=NONE,1=L1,2=L2,3=L3
        uint8 chainStack; // 0=NONE,1=OPSTACK,2=ARBSTACK,3=AVALANCHESTACK
        uint8 decimals;
        // strings
        string chainKey; // LayerZero chain key (short)
        string chainName; // human-readable name
        string currency; // native currency symbol (e.g., ETH)
        string cgId; // CoinGecko id (string)
        // addresses
        address endpointV2;
        address endpointV2View;
        address executor;
        address lzExecutor;
        address sendUln302;
        address receiveUln302;
        address blockedMessageLib;
    }

    // -------------------- Storage --------------------

    /// @dev Packed sub-32B scalars per chain.
    mapping(uint256 => Packed) private _packed;

    /// @notice Human-readable metadata per chain.
    mapping(uint256 => string) public chainKey;
    mapping(uint256 => string) public chainName;
    mapping(uint256 => string) public currency;
    mapping(uint256 => string) public cgId;

    /// @notice LayerZero endpoint + libs per chain.
    mapping(uint256 => address) public endpointV2;
    mapping(uint256 => address) public endpointV2View;
    mapping(uint256 => address) public executor;
    mapping(uint256 => address) public lzExecutor;
    mapping(uint256 => address) public sendUln302;
    mapping(uint256 => address) public receiveUln302;
    mapping(uint256 => address) public blockedMessageLib;

    /// @dev Enumerability helpers.
    uint256[] private _chainIds;

    // -------------------- Errors --------------------

    error DuplicateChainId(uint256 id);
    error MissingData(uint256 id);
    error InvalidLayer(uint8 v);
    error InvalidStack(uint8 v);

    // -------------------- Constructor --------------------

    /// @param rows Array of per-chain rows; after construction, data is immutable.
    constructor(Row[] memory rows) {
        uint256 n = rows.length;
        _chainIds = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            Row memory r = rows[i];

            // Prevent duplicate inserts (eid non-zero is our sentinel).
            if (_packed[r.nativeChainId].eid != 0) {
                revert DuplicateChainId(r.nativeChainId);
            }
            // Minimal sanity: eid must be non-zero to mark existence.
            if (r.eid == 0) {
                revert MissingData(r.nativeChainId);
            }
            // Enum range guards.
            if (r.chainLayer > uint8(ChainLayer.L3)) {
                revert InvalidLayer(r.chainLayer);
            }
            if (r.chainStack > uint8(ChainStack.AVALANCHESTACK)) {
                revert InvalidStack(r.chainStack);
            }

            _chainIds[i] = r.nativeChainId;

            // Pack small scalars in one slot.
            _packed[r.nativeChainId] = Packed({
                eid: r.eid,
                cmcId: r.cmcId,
                chainLayer: ChainLayer(r.chainLayer),
                chainStack: ChainStack(r.chainStack),
                decimals: r.decimals
            });

            // Strings.
            chainKey[r.nativeChainId] = r.chainKey;
            chainName[r.nativeChainId] = r.chainName;
            currency[r.nativeChainId] = r.currency;
            cgId[r.nativeChainId] = r.cgId;

            // Addresses.
            endpointV2[r.nativeChainId] = r.endpointV2;
            endpointV2View[r.nativeChainId] = r.endpointV2View;
            executor[r.nativeChainId] = r.executor;
            lzExecutor[r.nativeChainId] = r.lzExecutor;
            sendUln302[r.nativeChainId] = r.sendUln302;
            receiveUln302[r.nativeChainId] = r.receiveUln302;
            blockedMessageLib[r.nativeChainId] = r.blockedMessageLib;
        }
    }

    // -------------------- Views (packed fields) --------------------

    /// @notice Existence check (true if a row was loaded for id).
    function has(uint256 nativeChainId) external view returns (bool) {
        return _packed[nativeChainId].eid != 0;
    }

    /// @notice LayerZero endpoint id for a chain (non-zero means present).
    function eid(uint256 nativeChainId) external view returns (uint32) {
        return _packed[nativeChainId].eid;
    }

    /// @notice CoinMarketCap id for the native currency.
    function cmcId(uint256 nativeChainId) external view returns (uint32) {
        return _packed[nativeChainId].cmcId;
    }

    /// @notice L1/L2/L3 (0=NONE).
    function chainLayer(uint256 nativeChainId) external view returns (ChainLayer) {
        return _packed[nativeChainId].chainLayer;
    }

    /// @notice Rollup stack classification (0=NONE,1=OPSTACK,2=ARBSTACK,3=AVALANCHESTACK).
    function chainStack(uint256 nativeChainId) external view returns (ChainStack) {
        return _packed[nativeChainId].chainStack;
    }

    /// @notice Native currency decimals.
    function decimals(uint256 nativeChainId) external view returns (uint8) {
        return _packed[nativeChainId].decimals;
    }

    /// @notice All chain ids loaded at construction (order = constructor order).
    function chainIds() external view returns (uint256[] memory ids) {
        return _chainIds;
    }
}
