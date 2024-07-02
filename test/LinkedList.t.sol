/**
 * SPDX-License-Identifier:UNLICENSED
 * @author:<Saediek@proton.me>
 */
pragma solidity 0.8.0;
import "src/LinkedList.sol";
import "forge-std/Test.sol";

contract LinkedListTest is Test {
    /**
     * Major functionalities:
     * 'deleteNode'
     * 'searchLinkedList'
     * 'sortList'
     * 'insertNode'
     * 'traverseList'
     */
    ///TESTS
    function test_insert() external {
        uint256 x;
        _insertData(x);
        assertEq(getRoot(), getTail());
    }

    ////Logging helpers..
    function log_node(LinkedList.node memory _node) internal view {
        console.log("NODE::SLOT:[%s]", _node.nextNodeSlot);
        console.log("NODE-DATA-VALUE:[%s]", _node.data);
    }

    function getRoot() internal pure returns (uint256) {
        return LinkedList.ROOT_SLOT;
    }

    function getTail() internal view returns (uint256) {
        return LinkedList.getTailSlot();
    }

    function log_list(LinkedList.node[] memory _list) internal view {
        for (uint8 x; x < _list.length; x++) {
            log_node(_list[x]);
        }
    }

    function _insertData(uint256 _data) internal {
        LinkedList.insertNode(_data);
    }

    function get_list() internal view returns (LinkedList.node[] memory _list) {
        return LinkedList.traverseLinkedList();
    }

    function sort_list() internal {
        LinkedList.sortList();
    }
}
