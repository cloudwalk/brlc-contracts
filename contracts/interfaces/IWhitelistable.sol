// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Whitelistable contract interface
 * @author CloudWalk Inc.
 * @dev Allows to whitelist and unwhitelist accounts.
 */
interface IWhitelistable {
    // -------------------- Events -----------------------------------

    /// @dev Emitted when an account is whitelisted.
    event Whitelisted(address indexed account);

    /// @dev Emitted when an account is unwhitelisted.
    event UnWhitelisted(address indexed account);

    // -------------------- Functions -----------------------------------

    /**
     * @dev Adds an account to the whitelist.
     *
     * Emits a {Whitelisted} event.
     *
     * @param account The address to add to the whitelist.
     */
    function whitelist(address account) external;

    /**
     * @dev Removes an account from the whitelist.
     *
     * Emits an {UnWhitelisted} event.
     *
     * @param account The address to remove from the whitelist.
     */
    function unWhitelist(address account) external;

    /**
     * @dev Checks if an account is whitelisted.
     * @param account The address to check for presence in the whitelist.
     * @return True if the account is present in the whitelist.
     */
    function isWhitelisted(address account) external returns (bool);
}
