// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { IWhitelistable } from "../interfaces/IWhitelistable.sol";

/**
 * @title WhitelistableUpgradeable base contract
 * @author CloudWalk Inc.
 * @dev Allows to whitelist and unwhitelist accounts using the {WHITELISTER_ROLE} role.
 *
 * This contract is used through inheritance. It makes available the modifier `onlyWhitelisted`,
 * which can be applied to functions to restrict their usage to whitelisted accounts only.
 */
abstract contract WhitelistableUpgradeable is AccessControlUpgradeable, IWhitelistable {
    /// @dev The role of the whitelister that is allowed to whitelist and unwhitelist accounts.
    bytes32 public constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");

    /// @dev Mapping of presence in the whitelist for a given address.
    mapping(address => bool) private _whitelisted;

    // -------------------- Errors -----------------------------------

    /// @dev The account is not whitelisted.
    error NotWhitelistedAccount(address account);

    // -------------------- Modifiers --------------------------------

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
    function __Whitelistable_init(bytes32 whitelisterRoleAdmin) internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();

        __Whitelistable_init_unchained(whitelisterRoleAdmin);
    }

    /**
     * @dev The unchained internal initializer of the upgradable contract.
     *
     * See {WhitelistableUpgradeable-__Whitelistable_init}.
     */
    function __Whitelistable_init_unchained(bytes32 whitelisterRoleAdmin) internal onlyInitializing {
        _setRoleAdmin(WHITELISTER_ROLE, whitelisterRoleAdmin);
    }

    /**
     * @dev Adds an account to the whitelist.
     *
     * Requirements:
     *
     * - The caller must have the {WHITELISTER_ROLE} role.
     *
     * Emits a {Whitelisted} event.
     *
     * @param account The address to whitelist.
     */
    function whitelist(address account) public onlyRole(WHITELISTER_ROLE) {
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
     * - The caller must have the {WHITELISTER_ROLE} role.
     *
     * Emits an {UnWhitelisted} event.
     *
     * @param account The address to remove from the whitelist.
     */
    function unWhitelist(address account) public onlyRole(WHITELISTER_ROLE) {
        if (!_whitelisted[account]) {
            return;
        }

        _whitelisted[account] = false;

        emit UnWhitelisted(account);
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
    uint256[49] private __gap;
}
