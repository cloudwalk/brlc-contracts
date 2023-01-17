// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { IWhitelistable } from "../interfaces/IWhitelistable.sol";

/**
 * @title WhitelistableUpgradeable base contract
 * @author CloudWalk Inc.
 * @dev Allows to whitelist and unwhitelist accounts using the `whitelister` account.
 *
 * This contract is used through inheritance. It makes available the modifier `onlyWhitelisted`,
 * which can be applied to functions to restrict their usage to whitelisted accounts only.
 */
abstract contract WhitelistableUpgradeable is OwnableUpgradeable, IWhitelistable {
    /// @dev The address of the whitelister that is allowed to whitelist and unwhitelist accounts.
    address private _whitelister;

    /// @dev Mapping of presence in the whitelist for a given address.
    mapping(address => bool) private _whitelisted;

    // -------------------- Events -----------------------------------

    /// @dev Emitted when the whitelister is changed.
    event WhitelisterChanged(address indexed newWhitelister);

    // -------------------- Errors -----------------------------------

    /// @dev The message sender is not a whitelister.
    error UnauthorizedWhitelister(address account);

    /// @dev The account is not whitelisted.
    error NotWhitelistedAccount(address account);

    // -------------------- Modifiers --------------------------------

    /**
     * @dev Throws if called by any account other than the whitelister.
     */
    modifier onlyWhitelister() {
        if (_msgSender() != _whitelister) {
            revert UnauthorizedWhitelister(_msgSender());
        }
        _;
    }

    /**
     * @dev Throws if called by not a whitelisted account.
     * @param account The address to check for presence in the whitelist.
     */
    modifier onlyWhitelisted(address account) {
        if (!_whitelisted[account]) {
            revert NotWhitelistedAccount(account);
        }
        _;
    }

    // -------------------- Functions --------------------------------

    /**
     * @dev The internal initializer of the upgradable contract.
     *
     * See details https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable.
     */
    function __Whitelistable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();

        __Whitelistable_init_unchained();
    }

    /**
     * @dev The unchained internal initializer of the upgradable contract.
     *
     * See {WhitelistableUpgradeable-__Whitelistable_init}.
     */
    function __Whitelistable_init_unchained() internal onlyInitializing {}

    /**
     * @dev Adds an account to the whitelist.
     *
     * Requirements:
     *
     * - Can only be called by the whitelister account.
     *
     * Emits a {Whitelisted} event.
     *
     * @param account The address to whitelist.
     */
    function whitelist(address account) public onlyWhitelister {
        if (_whitelisted[account]) {
            return;
        }

        _whitelisted[account] = true;

        emit Whitelisted(account);
    }

    /**
     * @dev Removes an account from the whitelist.
     *
     * Requirements:
     *
     * - Can only be called by the whitelister account.
     *
     * Emits an {UnWhitelisted} event.
     *
     * @param account The address to remove from the whitelist.
     */
    function unWhitelist(address account) public onlyWhitelister {
        if (!_whitelisted[account]) {
            return;
        }

        _whitelisted[account] = false;

        emit UnWhitelisted(account);
    }

    /**
     * @dev Updates the whitelister address.
     *
     * Requirements:
     *
     * - Can only be called by the contract owner.
     *
     * Emits a {WhitelisterChanged} event.
     *
     * @param newWhitelister The address of a new whitelister.
     */
    function setWhitelister(address newWhitelister) public onlyOwner {
        if (_whitelister == newWhitelister) {
            return;
        }

        _whitelister = newWhitelister;

        emit WhitelisterChanged(_whitelister);
    }

    /**
     * @dev Returns the whitelister address.
     */
    function whitelister() public view virtual returns (address) {
        return _whitelister;
    }

    /**
     * @dev Checks if an account is whitelisted.
     * @param account The address to check for presence in the whitelist.
     * @return True if the account is present in the whitelist.
     */
    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisted[account];
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[48] private __gap;
}
