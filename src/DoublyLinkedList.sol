/**
 * SPDX-License-Identifier:UNLICENSED
 */
pragma solidity ^0.8;

/// @title LinkedList
/// @author @Saediek
/// @notice DoublyLinked List library and related functionalities..
/// check out.. the official implementation of the doubly linked list
library DoublyLinkedList {
    enum Option {
        None
    }
    uint256 public constant ROOT_SLOT =
        uint256(keccak256("DOUBLY-LINKED-LIST"));
    struct Node {
        uint256 prev_ptr;
        uint256 data;
        uint256 next_ptr;
    }

    function insertData(uint256 _data) external {}

    ///
    /// @param _ascending indicates if the Linked list should be sorted ascending or descending..
    function sortList(bool _ascending) external {}

    function deleteNode(uint256 _data) external returns (bool) {}

    function traverseList() external view returns (Node[] memory _list) {}
}
