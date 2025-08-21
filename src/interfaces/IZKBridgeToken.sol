// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title IOmniToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination via Polyhedra zkBridge.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings. Enforces zkBridge-only callbacks, source/peer validation, and replay protection.
 * @custom:source https://github.com/liqueth/ZKBridgeToken
 */
interface IOmniToken is IERC20Metadata {
    error AlreadyReceived(bytes32 messageHash);
    error SenderIsNotBridge(address sender);
    error SentFromDifferentAddress(address fromAddress);
    error UnsupportedDestinationChain(uint256 chain);
    error UnsupportedSourceChain(uint16 zkChain);

    event BridgeInitiated(
        address indexed holder, address indexed token, uint256 indexed toChain, uint256 amount, uint64 nonce
    );
    event BridgeFinalized(
        address indexed holder, address indexed token, uint256 indexed fromChain, uint256 amount, uint64 nonce
    );
    event Cloned(address indexed holder, address indexed token, string name, string symbol);
    event DeployToChainInitiated(address indexed token, uint256 indexed toChain, uint64 nonce);
    event DeployToChainFinalized(address indexed token, uint256 indexed fromChain, uint64 nonce);

    /**
     * @notice Initialize name/symbol, zkBridge endpoint, chain ID mappings, and mints the local chain’s initial supply.
     * @param holder Recipient of the initial mint on this chain.
     * @param name ERC-20 name.
     * @param symbol ERC-20 symbol.
     * @param mints Map EVM chain ids to amount to mint.
     */
    function clone(address holder, string memory name, string memory symbol, uint256[][] memory mints)
        external
        returns (IOmniToken);

    /**
     * @notice Predict the address of a clone with the given parameters.
     * @dev Returns the address that would be created by cloning this contract with the given parameters.
     *      Useful for off-chain tools to know where a clone will be deployed.
     * @param holder Recipient of the initial mint on this chain.
     * @param name ERC-20 name.
     * @param symbol ERC-20 symbol.
     * @param mints Map EVM chain ids to amount to mint.
     * @return proxy The predicted address of the clone.
     * @return salt The salt used for the prediction.
     */
    function clonePrediction(address holder, string memory name, string memory symbol, uint256[][] memory mints)
        external
        view
        returns (IOmniToken proxy, bytes32 salt);

    /**
     * @notice Initialize a clone with encoded parameters.
     * @param cloneData_ ABI encoded (address,string,string,uint256[][]) tuple of holder, name, symbol, mints.
     * @return token The new token clone.
     */
    function cloneEncoded(bytes memory cloneData_) external returns (IOmniToken token);

    /**
     * @notice Deploy this token to another network.
     * @param toChain Destination EVM `chainid`.
     */
    function deployToChain(uint256 toChain) external payable;

    /**
     * @notice Burn tokens here and send a cross-chain message to mint on the destination chain.
     * @dev Reverts if the destination is unsupported or the attached fee is insufficient.
     *         Emits a BridgeInitiated event on success.
     * @param toChain Destination EVM `chainid`.
     * @param fee Token amount to bridge (in smallest units).
     */
    function bridge(uint256 toChain, uint256 fee) external payable;

    /**
     * @notice Return the native fee required to bridge to a destination chain.
     * @dev Proxies the zkBridge fee estimator; some endpoints use a destination gas limit to quote fees.
     * @param toChain Destination zkBridge chain ID.
     * @return fee Estimated native value (wei) the caller should send with {bridge}.
     */
    function bridgeFeeEstimate(uint256 toChain) external returns (uint256 fee);

    /**
     * @notice Return the canonical prototype used as both implementation and factory for clone deployments.
     * @dev The returned address is the code-bearing contract that minimal proxies (EIP-1167/OpenZeppelin Clones)
     *      delegate to. Treat it as stateless logic; do not send funds here. Useful for tooling and off-chain
     *      introspection to know which logic/factory this instance points to.
     * @return Address of the prototype (implementation + factory).
     */
    function prototype() external view returns (IOmniToken);

    /**
     * @notice Return the EVM chain IDs supported by this token.
     * @return chains Array of EVM chain IDs.
     */
    function chains() external view returns (uint256[] memory);

    /**
     * @notice Return the zkBridge clone data used to deploy this token.
     * @dev Contains the holder, name, symbol, and mints for the token.
     * @return cloneData The ABI-encoded clone data.
     */
    function cloneData() external view returns (bytes memory);
}
