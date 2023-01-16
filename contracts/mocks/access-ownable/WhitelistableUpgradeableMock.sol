// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { WhitelistableUpgradeable } from "../../access-ownable/WhitelistableUpgradeable.sol";

/**
 * @title WhitelistableUpgradeableMock contract
 * @author CloudWalk Inc.
 * @dev An implementation of the {WhitelistableUpgradeable} contract for test purposes.
 */
contract WhitelistableUpgradeableMock is WhitelistableUpgradeable {
    /// @dev Emitted when a test function of the `onlyWhitelisted` modifier executes successfully.
    event TestOnlyWhitelistedModifierSucceeded();

    /**
     * @dev The initialize function of the upgradable contract.
     *
     * See details https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable.
     */
    function initialize() public initializer {
        __Whitelistable_init();
    }

    /**
     * @dev Needed to check that the initialize function of the ancestor contract
     * has the 'onlyInitializing' modifier.
     */
    function call_parent_initialize() public {
        __Whitelistable_init();
    }

    /**
     * @dev Needed to check that the unchained initialize function of the ancestor contract
     * has the 'onlyInitializing' modifier.
     */
    function call_parent_initialize_unchained() public {
        __Whitelistable_init_unchained();
    }

    /**
     * @dev Checks the execution of the {onlyWhitelisted} modifier.
     * If that modifier executed without reverting emits an event {TestOnlyWhitelistedModifierSucceeded}.
     */
    function testOnlyWhitelistedModifier() external onlyWhitelisted(_msgSender()) {
        emit TestOnlyWhitelistedModifierSucceeded();
    }
}
