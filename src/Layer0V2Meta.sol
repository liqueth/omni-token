// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Maps nativeChainId => individual fields for LayerZero v2 EVM deployments.
/// @dev Immutable after construction. No setters; only public mapping getters.
contract Layer0V2Meta {
    enum ChainLayer {
        NONE,
        L1,
        L2,
        L3
    }

    enum ChainStack {
        NONE,
        OPSTACK,
        ARBSTACK,
        AVALANCHESTACK
    }

    struct Packed {
        uint32 eid;
        uint32 cmcId;
        ChainLayer chainLayer;
        ChainStack chainStack;
        uint8 decimals;
    }

    mapping(uint256 => Packed) public packed;

    mapping(uint256 => string) public chainKey;
    mapping(uint256 => string) public chainName;
    mapping(uint256 => string) public currency;
    // CoinGecko id (string)
    mapping(uint256 => string) public cgId;

    mapping(uint256 => address) public endpointV2;
    mapping(uint256 => address) public endpointV2View;
    mapping(uint256 => address) public executor;
    mapping(uint256 => address) public lzExecutor;
    mapping(uint256 => address) public sendUln302;
    mapping(uint256 => address) public receiveUln302;
    mapping(uint256 => address) public blockedMessageLib;

    uint256[] private _chainIds;

    error DuplicateChainId(uint256 id);
    error MissingData(uint256 id);

    /// LayerZero endpoint id
    function eid(uint256 nativeChainId) public view returns (uint32) {
        return packed[nativeChainId].eid;
    }

    /// CoinMarketCap id
    function cmcId(uint256 nativeChainId) external view returns (uint32) {
        return packed[nativeChainId].cmcId;
    }

    function chainLayer(uint256 nativeChainId) external view returns (ChainLayer) {
        return packed[nativeChainId].chainLayer;
    }

    function chainStack(uint256 nativeChainId) external view returns (ChainStack) {
        return packed[nativeChainId].chainStack;
    }

    function decimals(uint256 nativeChainId) external view returns (uint8) {
        return packed[nativeChainId].decimals;
    }

    /// @dev Input row used ONLY for constructor; nothing stored as a struct.
    struct Row {
        uint256 nativeChainId;
        uint32 eid;
        uint32 cmcId;
        uint8 chainLayer; // 1,2,3
        uint8 chainStack; // 0,1,2,3
        uint8 decimals;
        string chainKey;
        string chainName;
        string currency;
        string cgId;
        address endpointV2;
        address endpointV2View;
        address executor;
        address lzExecutor;
        address sendUln302;
        address receiveUln302;
        address blockedMessageLib;
    }

    constructor(Row[] memory rows) {
        uint256 n = rows.length;
        _chainIds = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            Row memory r = rows[i];

            if (eid(r.nativeChainId) != 0) {
                revert DuplicateChainId(r.nativeChainId);
            }

            if (r.eid == 0) {
                revert MissingData(r.nativeChainId);
            }

            _chainIds[i] = r.nativeChainId;

            // scalars
            packed[r.nativeChainId] = Packed({
                eid: r.eid,
                cmcId: r.cmcId,
                chainLayer: ChainLayer(r.chainLayer),
                chainStack: ChainStack(r.chainStack),
                decimals: r.decimals
            });

            // strings
            chainKey[r.nativeChainId] = r.chainKey;
            chainName[r.nativeChainId] = r.chainName;
            currency[r.nativeChainId] = r.currency;
            cgId[r.nativeChainId] = r.cgId;

            // addresses
            endpointV2[r.nativeChainId] = r.endpointV2;
            endpointV2View[r.nativeChainId] = r.endpointV2View;
            executor[r.nativeChainId] = r.executor;
            lzExecutor[r.nativeChainId] = r.lzExecutor;
            sendUln302[r.nativeChainId] = r.sendUln302;
            receiveUln302[r.nativeChainId] = r.receiveUln302;
            blockedMessageLib[r.nativeChainId] = r.blockedMessageLib;
        }
    }

    /// @notice All chain ids loaded at construction (order = constructor order).
    function chainIds() external view returns (uint256[] memory ids) {
        return _chainIds;
    }
}
