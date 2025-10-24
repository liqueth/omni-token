// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {OFTCoreDeterministic} from "./OFTCoreDeterministic.sol";
import {IMinter} from "./interfaces/IMinter.sol";
import {IMessagingConfig} from "./interfaces/IMessagingConfig.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

/// @notice Cross-chain ERC-20 token using LayerZero OFT for trustless transfers across EVM chains.
/// @dev Key features:
/// - Seamless cross-chain minting and burning with LayerZero's OFT protocol.
/// - Simplified bridge functions for user and developer friendly transfers.
/// - Cross-chain address consistency via deterministic deployment.
/// - Efficient proxy-based deployments using OpenZeppelin Clones.
/// - Ownership can renounced at cloning time for trustless tokens.
/// - Ownership can kept for post deployment management.
/// Constraints and considerations:
/// - All chain-specific values must be known at deployment.
/// - Adding new chains for existing trustless tokens is not possible.
/// - Addressing new chains for new trustless tokens requires deploying an updated protofactory.
/// - Requires a mechanism like Nick’s Factory (`CREATE2`) to guarantee identical addresses.
/// - The default OFT uses the default LayerZero DVN. Custom DVNs are currently not supported.
/// @author Paul Reinholdtsen (reinholdtsen.eth)
contract OmniToken is OFTCoreDeterministic, ERC20, IMinter {
    /// @inheritdoc IMinter
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
        emit Minted(to, amount);
    }

    /// @inheritdoc IMinter
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        emit Burned(amount);
    }

    /// @dev Mask the ERC-20 name to support initialization in clones wihout requiring an upgradeable ERC-20.
    string internal _name;
    /// @dev Mask the ERC-20 symbol to support initialization in clones wihout requiring an upgradeable ERC-20.
    string internal _symbol;

    constructor(IMessagingConfig messagingConfig_)
        OFTCoreDeterministic(messagingConfig_, address(this))
        ERC20("OmniToken Prototype", "OMNIPROT")
    {
        prototype = address(this);
        messagingConfig = messagingConfig_;
    }

    function initialize(Config memory config) public virtual override {
        super.initialize(config);

        if (bytes(_symbol).length != 0) {
            revert InitializedAlready();
        }
        if (bytes(config.symbol).length == 0) {
            revert SymbolEmpty();
        }

        _name = config.name;
        _symbol = config.symbol;
        uint256[][] memory mints = config.mints;
        for (uint256 i = 0; i < mints.length; i++) {
            uint256 chain = mints[i][0];
            uint256 minted = mints[i][1];
            if (chain == block.chainid) {
                if (minted > 0) {
                    _mint(config.issuer, minted);
                }
            }
        }
    }

    /// @inheritdoc IERC20Metadata
    function name() public view override returns (string memory) {
        return _name;
    }

    /// @inheritdoc IERC20Metadata
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    //// The following functions are overrides required by OFT and copied from OFT.sol

    /**
     * @dev Retrieves the address of the underlying ERC20 implementation.
     * @return The address of the OFT token.
     *
     * @dev In the case of OFT, address(this) and erc20 are the same contract.
     */
    function token() public view virtual override returns (address) {
        return address(this);
    }

    /**
     * @notice Indicates whether the OFT contract requires approval of the 'token()' to send.
     * @return requiresApproval Needs approval of the underlying token implementation.
     *
     * @dev In the case of OFT where the contract IS the token, approval is NOT required.
     */
    function approvalRequired() external pure virtual returns (bool) {
        return false;
    }

    /**
     * @dev Burns tokens from the sender's specified balance.
     * @param _from The address to debit the tokens from.
     * @param _amountLD The amount of tokens to send in local decimals.
     * @param _minAmountLD The minimum amount to send in local decimals.
     * @param _dstEid The destination chain ID.
     * @return amountSentLD The amount sent in local decimals.
     * @return amountReceivedLD The amount received in local decimals on the remote.
     */
    function _debit(address _from, uint256 _amountLD, uint256 _minAmountLD, uint32 _dstEid)
        internal
        virtual
        override
        returns (uint256 amountSentLD, uint256 amountReceivedLD)
    {
        (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);

        // @dev In NON-default OFT, amountSentLD could be 100, with a 10% fee, the amountReceivedLD amount is 90,
        // therefore amountSentLD CAN differ from amountReceivedLD.

        // @dev Default OFT burns on src.
        _burn(_from, amountSentLD);
    }

    /**
     * @dev Credits tokens to the specified address.
     * @param _to The address to credit the tokens to.
     * @param _amountLD The amount of tokens to credit in local decimals.
     * @dev _srcEid The source chain ID.
     * @return amountReceivedLD The amount of tokens ACTUALLY received in local decimals.
     */
    function _credit(
        address _to,
        uint256 _amountLD,
        uint32 /*_srcEid*/
    )
        internal
        virtual
        override
        returns (uint256 amountReceivedLD)
    {
        if (_to == address(0x0)) _to = address(0xdead); // _mint(...) does not support address(0x0)
        // @dev Default OFT mints on dst.
        _mint(_to, _amountLD);
        // @dev In the case of NON-default OFT, the _amountLD MIGHT not be == amountReceivedLD.
        return _amountLD;
    }
}
