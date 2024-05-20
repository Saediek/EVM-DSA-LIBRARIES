/**
 * SPDX-License-Identifier:UNLICENSED
 *@author <Saediek@proton.me>
 */
pragma solidity ^0.8;
import "src/LinearDataStructures/LinkedList.sol";
import "forge-std/Test.sol";

contract SinglyLinkedList is Test {
    using LinkedList for uint256;

    ////----TEST ALL FUNCTINALITIES OF A LINKED LIST---////
    function test_insert(uint256 _randomVariable, uint256 _length) external {
        _randomVariable = bound(_randomVariable, 200, 50000);
        _length = bound(_length, 10, 30);
        __insertData(_randomVariable, _length);
        assertEq(_length, LinkedList.getLinkedListLength());
        logList(LinkedList.traverseLinkedList());
    }

    function test_search_data() external {
        this.test_insert(2000, 20);

        (LinkedList.node memory _node, bool _exists) = LinkedList
            .searchLinkedList(2006);
        assertEq(_exists, true);

        logNode(_node);
    }

    function test_search_non_existing_data() external {
        this.test_insert(3000, 15);
        (LinkedList.node memory _node, bool _exists) = LinkedList
            .searchLinkedList(2006);
        assertEq(_exists, false);

        logNode(_node);
    }

    function __insertData(uint256 _start, uint256 insertCount) internal {
        for (uint8 i; i < insertCount; i++) {
            LinkedList.insertNode(_start + i);
        }
    }

    function test_deletion() external {
        uint256 target = 1010;
        this.test_insert(target, 25);
        bool _response = LinkedList.deleteNode(target);
        assertEq(_response, true);
        (LinkedList.node memory _node, bool found) = LinkedList
            .searchLinkedList(target);
        assertEq(found, false);
        logNode(_node);
    }

    //returns the last slot
    function test_get_tail() external {
        this.test_insert(2000, 12);
        logNode(LinkedList.getNodeAtSlot(LinkedList.getTailSlot()));
    }

    function test_sort_link_list() external {
        this.test_insert(5000, 25);
        LinkedList.insertNode(2000);
        LinkedList.sortList();
        logList(LinkedList.traverseLinkedList());
    }

    function logList(LinkedList.node[] memory list) internal view {
        for (uint8 i; i < list.length; i++) {
            console.log("NODE-DATA:[%s]", list[i].data);
            console.log("NODE-POINTER:[%s]", list[i].nextNodeSlot);
        }
    }

    function logNode(LinkedList.node memory _node) internal view {
        console.log("NODE-DATA:", _node.data);
        console.log("NODE-POINTER:", _node.nextNodeSlot);
    }
}
