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

    /**
     * @dev A node is represented as a struct  with fields:{data,nxtNodePointer}
     * @notice the nextNodeSlot points to the data field of the next node.
     */
    struct node {
        //data || element in a node
        uint256 data;
        //storage slots are used instead of struct pointers
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

    function _insertAtSlot(node memory _node, uint256 _slot) internal {
        uint256 _data = _node.data;
        uint256 _nextSlot = _node.nextNodeSlot;
        assembly {
            sstore(_slot, _data)
            sstore(add(_slot, 0x01), _nextSlot)
        }
    }

    //returns all list elements..
    function traverseLinkedList()
        public
        view
        returns (node[] memory linkedlists)
    {
        uint256 _listLength = getLinkedListLength();
        //if list is empty
        if (_listLength < 1) {
            return linkedlists;
        }
        linkedlists = new node[](_listLength);
        node memory root = getRoot();
        uint256 indices;
        while (root.nextNodeSlot != uint256(0) || root.data != 0) {
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
        node memory _root = getRoot();
        //if node is empty store data in node
        if (_root.data == 0 && _root.nextNodeSlot == 0) {
            uint256 _rootSlot = ROOT_SLOT;
            assembly {
                sstore(_rootSlot, _data)
            }
            return;
        } else {
            uint256 _lastSlot = getTailSlot();
            assembly {
                //update the nextNodeSlot of the tail node to point to the new
                //node and then the data field
                sstore(add(_lastSlot, 0x01), add(_lastSlot, 0x02))
                sstore(add(_lastSlot, 0x02), _data)
            }
        }
    }

    /**
     *Sorts the Linked List
     */
    function sortList() external {
        node[] memory full_list = traverseLinkedList();
        full_list = _sortList(full_list);
        uint256 _rootSlot = ROOT_SLOT;
        for (uint8 i; i < full_list.length; i++) {
            //replaces the nextSlode previous parameter
            full_list[i].nextNodeSlot = _rootSlot + 2;
            _insertAtSlot(full_list[i], _rootSlot);
            _rootSlot += 2;
        }
    }

    /// @notice Sorts the linkedList using inserionSort
    //@todo replce with tim-sort
    /// @param _nodes :fulllist of nodes
    function _sortList(
        node[] memory _nodes
    ) internal pure returns (node[] memory _list) {
        _list = new node[](_nodes.length);
        for (int8 i = 1; i < int8(int256(_nodes.length)); i++) {
            int8 j;

            node memory _index = _nodes[uint8(i)];
            //previous node index
            j = i - 1;
            while (j >= 0 && _nodes[uint8(j)].data > _index.data) {
                //if the previous node is greater than index swap the prev
                //for the next node and move to the index-1
                _nodes[uint8(j + 1)] = _nodes[uint8(j)];

                j -= 1;
            }
            _nodes[uint8(j + 1)] = _index;
        }

        return _nodes;
    }

    ///@dev returns a tuple (node,_slot,_exists)
    ///@notice returns the full node struct, the slot of the node and a boolean indicating if the _data node exists.
    /**
     *
     * @param _data the uint256 value to search on the linked list
     * @return _node node struct of the node which data field matches {_data}
     * @return _exists
     */
    function searchLinkedList(
        uint256 _data
    ) external view returns (node memory _node, bool _exists) {
        node memory _head = getRoot();

        uint256 previousSlot = _head.nextNodeSlot;
        while (_head.nextNodeSlot != 0 || _head.data != 0) {
            if (_head.data == _data) {
                _node.data = _data;
                _node.nextNodeSlot = _head.nextNodeSlot;
                _exists = true;

                break;
            }
            previousSlot = _head.nextNodeSlot;
            _head = getNodeAtSlot(_head.nextNodeSlot);
        }
    }

    function getLinkedListLength() internal view returns (uint256 _length) {
        node memory _head = getRoot();
        while (_head.nextNodeSlot != uint256(0) || _head.data != 0) {
            unchecked {
                ++_length;
            }
            _head = getNodeAtSlot(_head.nextNodeSlot);
        }
    }

    /**
     *@dev Returns the storage slot of the last-node..
     *@notice the slot returned points to the data field of the last node
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
        //to keep track of the previous node .ie the node slot before the targetNode
        uint256 previousSlot = ROOT_SLOT;
        // uint256 prevSlot;
        //if the node to be removed is the head handle specially
        if (_data == _head.data) {
            node memory _nextSlot = getNodeAtSlot(_head.nextNodeSlot);
            uint256 _nextData = _nextSlot.data;
            uint256 _nextNextSlot = _nextSlot.nextNodeSlot;
            assembly {
                //store the next node data in the root node
                //and store the next-node pointer in the root-node
                sstore(previousSlot, _nextData)
                sstore(add(previousSlot, 0x01), _nextNextSlot)
            }
            return true;
        }

        while (_head.nextNodeSlot != 0 || _head.data != 0) {
            if (_head.data == _data) {
                uint256 nxtSlot = _head.nextNodeSlot;
                assembly {
                    //store in the nextSlot field of the previous node the nextSlot of the target node..
                    sstore(add(previousSlot, 0x01), nxtSlot)
                }
                return true;
            }
            previousSlot = _head.nextNodeSlot;
            _head = getNodeAtSlot(_head.nextNodeSlot);
        }

        return false;
    }
}
