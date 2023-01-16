// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Blacklistable contract interface
 * @author CloudWalk Inc.
 * @dev Allows to blacklist and unblacklist accounts.
 */
interface IBlacklistable {
    // -------------------- Events -----------------------------------

    /// @dev Emitted when an account is blacklisted.
    event Blacklisted(address indexed account);

    /// @dev Emitted when an account is unblacklisted.
    event UnBlacklisted(address indexed account);

    /// @dev Emitted when an account is self blacklisted.
    event SelfBlacklisted(address indexed account);

    // -------------------- Functions -----------------------------------

    /**
     * @dev Adds an account to the blacklist.
     *
     * Emits a {Blacklisted} event.
     *
     * @param account The address to add to the blacklist.
     */
    function blacklist(address account) external;

    /**
     * @dev Removes an account from the blacklist.
     *
     * Emits an {UnBlacklisted} event.
     *
     * @param account The address to remove from the blacklist.
     */
    function unBlacklist(address account) external;

    /**
     * @dev Adds the message sender to the blacklist.
     *
     * Emits a {SelfBlacklisted} event.
     */
    function selfBlacklist() external;

    /**
     * @dev Checks if an account is blacklisted.
     * @param account The address to check for presence in the blacklist.
     * @return True if the account is present in the blacklist.
     */
    function isBlacklisted(address account) external returns (bool);
}
