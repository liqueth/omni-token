// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {OFTCoreDeterministic} from "./OFTCoreDeterministic.sol";
import {IOFTProto} from "./interfaces/IOFTProto.sol";
import {IBridge, MessagingReceipt, OFTReceipt} from "./interfaces/IBridge.sol";
import {IMintBurn} from "./interfaces/IMintBurn.sol";
import {Assertions} from "./Assertions.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";

/**
 * @notice OmniTokenBridged is ERC-20 token paired with an Bridge a to the OFT functionality.
 *
 * @dev For existing ERC20 tokens, this can be used to convert the token to crosschain compatibility.
 * @dev WARNING: ONLY 1 of these should exist for a given global mesh,
 * unless you make a NON-default implementation of OFT and needs to be done very carefully.
 * @dev WARNING: The default BridgeDeterministic implementation assumes LOSSLESS transfers, ie. 1 token in, 1 token out.
 * IF the 'innerToken' applies something like a transfer fee, the default will NOT work...
 * a pre/post balance check will need to be done to calculate the amountSentLD/amountReceivedLD.
 */
contract OmniTokenBridged is ERC20, IOFTProto, IMintBurn, IBridge {
    /// @dev Immutable implementation/factory is the same for all clones.
    address public immutable prototype;

    using Assertions for address;

    /// @inheritdoc IOFTProto
    function clone(Config memory config) public returns (address expected, bytes32 salt) {
        (expected, salt) = cloneAddress(config);
        if (expected.code.length == 0) {
            Clones.cloneDeterministic(prototype, salt).assertEqual(expected);
            OFTCoreDeterministic(expected).initialize(config);
            emit Cloned(config.issuer, config.owner, expected, config.name, config.symbol);
        }
    }

    /// @inheritdoc IOFTProto
    function cloneAddress(Config memory config) public view returns (address expected, bytes32 salt) {
        salt = keccak256(abi.encode(config));
        expected = Clones.predictDeterministicAddress(prototype, salt);
    }

    /// @inheritdoc IBridge
    function actualBridge() external view returns (IBridge actual) {
        actual = _bridge;
    }

    /// @inheritdoc IBridge
    function bridgeable(uint256 chainId) external view returns (bool whether) {
        whether = IBridge(_bridge).bridgeable(chainId);
    }

    /// @inheritdoc IBridge
    function bridgeFee(uint256 toChain, uint256 amount) external view returns (uint256 fee) {
        fee = IBridge(_bridge).bridgeFee(toChain, amount);
    }

    /// @inheritdoc IBridge
    function bridge(uint256 toChain, uint256 amount)
        external
        payable
        returns (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt)
    {
        if (!transfer(address(this), amount)) {
            revert TransferFailed(address(this), msg.sender, address(this), amount);
        }
        (msgReceipt, oftReceipt) = IBridge(_bridge).bridge(toChain, amount);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyMinter() {
        _checkMinter();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function minter() public view returns (address) {
        return _minter;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkMinter() internal view virtual {
        if (minter() != _msgSender()) {
            revert UnauthorizedMinter(_msgSender());
        }
    }

    /// @inheritdoc IMintBurn
    function mint(address to, uint256 amount) public onlyMinter {
        _mint(to, amount);
        emit Minted(to, amount);
    }

    /// @inheritdoc IMintBurn
    function burn(address from, uint256 amount) public onlyMinter {
        _burn(from, amount);
        emit Burned(from, amount);
    }

    IOFTProto public immutable bridgeFactory;
    IBridge internal _bridge;

    /**
     * @dev Constructor for the OFTAdapter contract.
     * @param config The LayerZero endpoint address.
     */
    constructor(Config memory config, IOFTProto bridgeFactory_) ERC20(config.name, config.symbol) {
        bridgeFactory = bridgeFactory_;
        initialize(config);
    }

    function initialize(Config memory config) public virtual {
        if (bytes(_symbol).length != 0) {
            revert InitializedAlready();
        }
        if (bytes(config.symbol).length == 0) {
            revert SymbolEmpty();
        }

        _name = config.name;
        _symbol = config.symbol;

        (address bridgeAddress,) = bridgeFactory.clone(config);
        _bridge = IBridge(bridgeAddress);

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

    address private _minter;
    /// @dev Mask the ERC-20 name to support initialization in clones wihout requiring an upgradeable ERC-20.
    string internal _name;
    /// @dev Mask the ERC-20 symbol to support initialization in clones wihout requiring an upgradeable ERC-20.
    string internal _symbol;

    /// @inheritdoc IERC20Metadata
    function name() public view override returns (string memory) {
        return _name;
    }

    /// @inheritdoc IERC20Metadata
    function symbol() public view override returns (string memory) {
        return _symbol;
    }
}
