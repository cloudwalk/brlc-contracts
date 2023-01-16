// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title StoragePlaceholder150 base contract
 * @author CloudWalk Inc.
 * @dev Reserves 150 storage slots.
 * Such a storage placeholder contract allows future replacement of it with other contracts
 * without shifting down storage in the inheritance chain.
 *
 * E.g. the following code:
 * ```
 * abstract contract StoragePlaceholder150 {
 *     uint256[150] private __gap;
 * }
 *
 * contract A is B, StoragePlaceholder150, C {
 *     //Some implementation
 * }
 * ```
 * can be replaced with the following code without a storage shifting issue:
 * ```
 * abstract contract StoragePlaceholder100 {
 *     uint256[100] private __gap;
 * }
 *
 * abstract contract X {
 *     uint256[50] public values;
 *     // No more storage variables. Some set of functions should be here.
 * }
 *
 * contract A is B, X, StoragePlaceholder100, C {
 *     //Some implementation
 * }
 * ```
 */
abstract contract StoragePlaceholder150 {
    uint256[150] private __gap;
}
