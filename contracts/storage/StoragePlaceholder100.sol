// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title StoragePlaceholder100 base contract
 * @author CloudWalk Inc.
 * @dev Reserves 100 storage slots.
 * Such a storage placeholder contract allows future replacement of it with other contracts
 * without shifting down storage in the inheritance chain.
 *
 * E.g. the following code:
 * ```
 * abstract contract StoragePlaceholder100 {
 *     uint256[100] private __gap;
 * }
 *
 * contract A is B, StoragePlaceholder100, C {
 *     //Some implementation
 * }
 * ```
 * can be replaced with the following code without a storage shifting issue:
 * ```
 * abstract contract StoragePlaceholder50 {
 *     uint256[50] private __gap;
 * }
 *
 * abstract contract X {
 *     uint256[50] public values;
 *     // No more storage variables. Some set of functions should be here.
 * }
 *
 * contract A is B, X, StoragePlaceholder50, C {
 *     //Some implementation
 * }
 * ```
 */
abstract contract StoragePlaceholder100 {
    uint256[100] private __gap;
}
