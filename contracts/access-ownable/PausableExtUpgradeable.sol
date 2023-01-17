// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import { IPausable } from "../interfaces/IPausable.sol";

/**
 * @title PausableExtUpgradeable base contract
 * @author CloudWalk Inc.
 * @dev Extends the OpenZeppelin's {PausableUpgradeable} contract by adding the `pauser` account.
 *
 * This contract is used through inheritance. It introduces the `pauser` role that is allowed to
 * trigger the paused or unpaused state of the contract that is inherited from this one.
 */
abstract contract PausableExtUpgradeable is OwnableUpgradeable, PausableUpgradeable, IPausable {
    /// @dev The address of the pauser that is allowed to trigger the paused or unpaused state of the contract.
    address private _pauser;

    // -------------------- Events -----------------------------------

    /// @dev Emitted when the pauser is changed.
    event PauserChanged(address indexed pauser);

    // -------------------- Errors -----------------------------------

    /// @dev The message sender is not a pauser.
    error UnauthorizedPauser(address account);

    // -------------------- Modifiers --------------------------------

    /**
     * @dev Throws if called by any account other than the pauser.
     */
    modifier onlyPauser() {
        if (_msgSender() != _pauser) {
            revert UnauthorizedPauser(_msgSender());
        }
        _;
    }

    // -------------------- Functions --------------------------------

    /**
     * @dev The internal initializer of the upgradable contract.
     *
     * See details https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable.
     */
    function __PausableExt_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();

        __PausableExt_init_unchained();
    }

    /**
     * @dev The unchained internal initializer of the upgradable contract.
     *
     * See {PausableExtUpgradeable-__PausableExt_init}.
     */
    function __PausableExt_init_unchained() internal onlyInitializing {}

    /**
     * @dev Triggers the paused state of the contract.
     *
     * Requirements:
     *
     * - Can only be called by the contract pauser.
     */
    function pause() public onlyPauser {
        _pause();
    }

    /**
     * @dev Triggers the unpaused state of the contract.
     *
     * Requirements:
     *
     * - Can only be called by the contract pauser.
     */
    function unpause() public onlyPauser {
        _unpause();
    }

    /**
     * @dev Updates the pauser address.
     *
     * Requirements:
     *
     * - Can only be called by the contract owner.
     *
     * Emits a {PauserChanged} event.
     *
     * @param newPauser The address of a new pauser.
     */
    function setPauser(address newPauser) public onlyOwner {
        if (_pauser == newPauser) {
            return;
        }

        _pauser = newPauser;

        emit PauserChanged(newPauser);
    }

    /**
     * @dev Returns the pauser address.
     */
    function pauser() public view virtual returns (address) {
        return _pauser;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     */
    uint256[49] private __gap;
}
