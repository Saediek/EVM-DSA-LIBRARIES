/**
 * SPDX-License-Identifier:UNLICENSED
 * @author:<Saediek@proton.me>
 */
pragma solidity ^0.8;

//A library for linked list and it's operations..

library LinkedList {
    //A node is just a struct..
    //containing the data and the nxt-pointer
    uint256 constant ROOT_SLOT = uint256(keccak256("LINKED-LIST-ROOT-SLOT"));
    //The node struct occupes two slots
    struct node {
        //data || element in a node
        uint256 data;
        //Pointer || slot to the next node Zero if it is the tailNode
        uint256 nextNodeSlot;
        // node _nxtNode;
    }

    /**
     *
     */
    function getRoot() public view returns (node memory _root) {
        uint256 _rootSlot = ROOT_SLOT;
        uint256 pointerToNextNode;
        uint256 _data;

        assembly {
            _data := sload(_rootSlot)
            pointerToNextNode := sload(add(_rootSlot, 0x01))
        }
        _root.data = _data;
        _root.nextNodeSlot = pointerToNextNode;
    }

    //returns all list elements..
    function transverseLinkedList()
        external
        view
        returns (node[] memory linkedlists)
    {
        uint256 _listLength = getLinkedListLength();
        if (_listLength < 1) {
            return linkedlists;
        }
        linkedlists = new node[](_listLength);
        node memory root = getRoot();
        uint256 indices;
        while (root.nextNodeSlot != uint256(0)) {
            linkedlists[indices] = root;
            root = getNodeAtSlot(root.nextNodeSlot);
            indices++;
        }
    }

    function getNodeAtSlot(
        uint256 _slot
    ) internal view returns (node memory _nextNode) {
        uint256 _data;
        uint256 _pointer;
        assembly {
            _data := sload(_slot)
            _pointer := sload(add(_slot, 0x01))
        }
        _nextNode.data = _data;
        _nextNode.nextNodeSlot = _pointer;
    }

    //inserts
    function insertNode(uint256 _data) external {
        uint256 _tailSlot = getTailSlot();
        //Updates the tail node pointer and the nextPointer data..
        assembly {
            //update the tailSlot.pointer to the nextSlot
            sstore(add(_tailSlot, 0x01), add(_tailSlot, 0x02))
            sstore(add(_tailSlot, 0x02), _data)
        }
    }

    function sortList() external {}

    function searchLinkedList(uint256 _data) external view returns (bool) {}

    function getLinkedListLength() internal view returns (uint256 _length) {
        node memory _head = getRoot();
        while (_head.nextNodeSlot != uint256(0)) {
            unchecked {
                _length++;
            }
            _head = getNodeAtSlot(_head.nextNodeSlot);
        }
    }

    /**
     *@dev Returns the storage slot of the last-node..
     */
    function getTailSlot() internal view returns (uint256) {
        node memory head = getRoot();
        uint256 previousSlot = ROOT_SLOT;
        //if the data is of the root and the nextSlot is 0 the linked
        //list is an empty list!!
        if (head.data == 0 && head.nextNodeSlot == 0) {
            return ROOT_SLOT;
        }
        while (head.nextNodeSlot != 0) {
            previousSlot = head.nextNodeSlot;
            head = getNodeAtSlot(head.nextNodeSlot);
        }
        return previousSlot;
    }

    function deleteNode(uint256 _data) external returns (bool) {
        node memory _head = getRoot();
        uint256 previousSlot = ROOT_SLOT;

        while (_head.nextNodeSlot != 0) {
            previousSlot = _head.nextNodeSlot;
            if (_head.data == _data) {
                uint256 nxtSlot = _head.nextNodeSlot;
                assembly {
                    //store in the nextSlot field of the previous node the nextSlot of the next node..
                    sstore(add(previousSlot, 0x01), nxtSlot)
                }
                return true;
            }
            _head = getNodeAtSlot(_head.nextNodeSlot);
        }

        return false;
    }
}
