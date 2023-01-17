// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { BlacklistableUpgradeable } from "../../access-ownable/BlacklistableUpgradeable.sol";

/**
 * @title BlacklistableUpgradeableMock contract
 * @author CloudWalk Inc.
 * @dev An implementation of the {BlacklistableUpgradeable} contract for test purposes.
 */
contract BlacklistableUpgradeableMock is BlacklistableUpgradeable {
    /// @dev Emitted when a test function of the `notBlacklisted` modifier executes successfully.
    event TestNotBlacklistedModifierSucceeded();

    /**
     * @dev The initialize function of the upgradable contract.
     *
     * See details https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable.
     */
    function initialize() public initializer {
        __Blacklistable_init();
    }

    /**
     * @dev Needed to check that the initialize function of the ancestor contract
     * has the 'onlyInitializing' modifier.
     */
    function call_parent_initialize() public {
        __Blacklistable_init();
    }

    /**
     * @dev Needed to check that the unchained initialize function of the ancestor contract
     * has the 'onlyInitializing' modifier.
     */
    function call_parent_initialize_unchained() public {
        __Blacklistable_init_unchained();
    }

    /**
     * @dev Checks the execution of the {notBlacklisted} modifier.
     * If that modifier executed without reverting emits an event {TestNotBlacklistedModifierSucceeded}.
     */
    function testNotBlacklistedModifier() external notBlacklisted(_msgSender()) {
        emit TestNotBlacklistedModifierSucceeded();
    }
}
