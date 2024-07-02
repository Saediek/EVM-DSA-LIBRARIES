/**
 * SPDX-License-Identifier:UNLICENSED
 */
pragma solidity ^0.8;

/// @title LinkedList
/// @author @Saediek
/// @notice Linked List library and related functionalities..

library LinkedList {
    //Kinda of an option alias for
    enum Option {
        None,
        Some
    }
    ///A node is just a struct.. which contains a data and pointer to the next node(.ie evm storage slot)

    uint256 public constant ROOT_SLOT =
        uint256(keccak256("LINKED-LIST-ROOT-SLOT"));

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
     * @dev returns the node stored at the root-Slot..
     */
    function getRoot() public view returns (node memory _root) {
        uint256 _rootSlot = ROOT_SLOT;
        uint256 pointerToNextNode;
        uint256 _data;

        assembly {
            //Load from storage the data value stored at the '_rootSlot'
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

    /**
     *@dev returns an array of the list..
     */
    function traverseLinkedList()
        public
        view
        returns (node[] memory linkedlists)
    {
        uint256 currentSlot = ROOT_SLOT;
        uint256 _listLength = getLinkedListLength();
        //if list is empty return an empty list
        if (_listLength == 0) {
            return linkedlists;
        }
        linkedlists = new node[](_listLength);
        node memory root = getRoot();
        uint256 indices;
        //While current node not == Option::None
        while (currentSlot != uint256(Option.None)) {
            linkedlists[indices] = root;
            currentSlot = root.nextNodeSlot;
            root = getNodeAtSlot(root.nextNodeSlot); //if empty node attributes are empty..
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

    //inserts 'data' into the tailSlot
    function insertNode(uint256 _data) external {
        //if node is empty store data in node
        uint256 _tailSlot = getTailSlot();
        if (_tailSlot == ROOT_SLOT) {
            assembly {
                sstore(_tailSlot, _data)
            }
        } else {
            assembly {
                //updates the 'tailNode pointer' and the data slot of the next slot..
                sstore(add(0x01, _tailSlot), add(0x02, _tailSlot))
                sstore(add(0x02, _tailSlot), _data)
            }
        }
    }

    /**
     *@dev Sort the list using the insertion sort algorithm..
     */
    //@todo Replace with timSort..
    function sortList() external {
        node[] memory full_list = traverseLinkedList();
        full_list = _sortList(full_list);
        uint256 _rootSlot = ROOT_SLOT;
        for (uint8 i; i < full_list.length; i++) {
            //replaces the nextNode previous parameter
            full_list[i].nextNodeSlot = _rootSlot + 2;
            _insertAtSlot(full_list[i], _rootSlot);
            _rootSlot += 2;
        }
    }

    /// @notice Sorts the linkedList using inserionSort
    //@todo replace with tim-sort
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

        uint256 currentNode = ROOT_SLOT;
        while (currentNode != uint256(Option.None)) {
            if (_head.data == _data) {
                _node.data = _data;
                _node.nextNodeSlot = _head.nextNodeSlot;
                _exists = true;

                break;
            }
            currentNode = _head.nextNodeSlot;
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
        uint256 previousSlot = 0;
        uint256 currentSlot = ROOT_SLOT;
        //if the data is of the root and the nextSlot is 0 the linked
        //list is an empty list!!
        if (head.data == 0 && head.nextNodeSlot == 0) {
            return ROOT_SLOT;
        }
        while (currentSlot != uint256(Option.None)) {
            previousSlot = currentSlot;
            currentSlot = head.nextNodeSlot;
            head = getNodeAtSlot(currentSlot);
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
        uint256 currentSlot = ROOT_SLOT;
        while (currentSlot != uint256(Option.None)) {
            if (_head.data == _data) {
                uint256 nxtSlot = _head.nextNodeSlot;
                assembly {
                    //store in the nextSlot field of the previous node the nextSlot of the target node..
                    sstore(add(previousSlot, 0x01), nxtSlot)
                }
                return true;
            }
            //Store the previous node before updating the currentSlot variable..
            previousSlot = currentSlot;
            currentSlot = _head.nextNodeSlot;
            _head = getNodeAtSlot(currentSlot);
        }

        return false;
    }
}
