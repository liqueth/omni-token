// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/**
 * @title IOmniToken
 * @notice Omnichain ERC-20 that burns on the source chain and mints on the destination.
 * @dev Deployed to the same address on multiple chains using CREATE2. Constructor config sets per-chain minting
 *      and chain ID mappings.
 * @custom:source https://github.com/liqueth/omni-token
 */
interface IOmniToken is IERC20Metadata {
    error AlreadyReceived(bytes32 messageHash);
    error SenderIsNotBridge(address sender);
    error SentFromDifferentAddress(address fromAddress);
    error UnsupportedDestinationChain(uint256 chain);
    error UnsupportedSourceChain(uint16 zkChain);

    event Cloned(address indexed owner, address indexed token, string name, string symbol);

    /**
     * @notice Initialize a clone with encoded parameters.
     * @param cloneData_ ABI encoded (address,string,string,uint256[][]) tuple of holder, name, symbol, mints.
     * @return token The new token clone.
     * @return salt The salt used for the prediction.
     */
    function cloneEncoded(bytes memory cloneData_) external returns (address token, bytes32 salt);

    /**
     * @notice Return the canonical prototype used as both implementation and factory for clone deployments.
     * @dev The returned address is the code-bearing contract that minimal proxies (EIP-1167/OpenZeppelin Clones)
     *      delegate to. Treat it as stateless logic; do not send funds here. Useful for tooling and off-chain
     *      introspection to know which logic/factory this instance points to.
     * @return Address of the prototype (implementation + factory).
     */
    function prototype() external view returns (address);

    /**
     * @notice Return the EVM chain IDs supported by this token.
     * @return chains Array of EVM chain IDs.
     */
    //function chains() external view returns (uint256[] memory);

    /**
     * @notice Return the zkBridge clone data used to deploy this token.
     * @dev Contains the holder, name, symbol, and mints for the token.
     * @return cloneData The ABI-encoded clone data.
     */
    function cloneData() external view returns (bytes memory);
}
