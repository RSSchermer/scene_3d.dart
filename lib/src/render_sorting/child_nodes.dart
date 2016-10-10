part of render_sorting;

/// Represent the child nodes of a [BranchingNode].
abstract class ChildNodes extends Iterable<RenderSortTreeNode> {
  /// The [BranchingNode] to which these [ChildNodes] belong.
  BranchingNode get owner;

  /// The way in which these [ChildNodes] are sorted.
  SortOrder get sortOrder;

  ///
  factory ChildNodes.unsorted(BranchingNode owner) = _UnsortedChildNodes;

  factory ChildNodes.ascending(BranchingNode owner) = _AscendingChildNodes;

  factory ChildNodes.descending(BranchingNode owner) = _DescendingChildNodes;

  /// Adds the [node] to these [ChildNodes].
  ///
  /// Does nothing if the [owner] is already the [node]'s parent.
  ///
  /// Throws a [StateError] if the [node] already has another parent node.
  void add(RenderSortTreeNode node);

  /// Removes the [node] from these [ChildNodes].
  ///
  /// Returns `true` if the [node] was a child node of the [owner], `false`
  /// otherwise. Leaves the node parentless and without siblings; a root node.
  bool remove(RenderSortTreeNode node);

  /// Sorts the nodes by sort code according to the [sortOrder].
  ///
  /// Does nothing if the [sortOrder] is [SortOrder.unsorted].
  void sort();
}

/// Implementation of [ChildNodes] in which child nodes are sorted by their
/// sort code in ascending order.
///
/// New child nodes are inserted in order. However, changes to sort codes at a
/// later time may degenerate the order of the nodes. Call [sort] to rearrange
/// the nodes in the expected order.
class _AscendingChildNodes extends IterableBase<RenderSortTreeNode>
    implements ChildNodes {
  final BranchingNode owner;

  final SortOrder sortOrder = SortOrder.ascending;

  final Set<RenderSortTreeNode> _needHeadShift = new Set();
  final Set<RenderSortTreeNode> _needTailShift = new Set();

  /// Creates a new [AscendingChildNodes] instance for the given [owner].
  _AscendingChildNodes(this.owner);

  int _length = 0;

  RenderSortTreeNode _initial;

  RenderSortTreeNode _final;

  RenderSortTreeNode get first => _initial;

  RenderSortTreeNode get last => _final;

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length > 0;

  int get length => _length;

  Iterator<RenderSortTreeNode> get iterator => new _ChildNodeIterator(this);

  void add(RenderSortTreeNode node) {
    if (node.parentNode == null) {
      node._parentNode = owner;

      if (isEmpty) {
        _initial = node;
        _final = node;
      } else {
        sort();

        var currentNode = _initial;

        while (currentNode != null &&
            currentNode.sortCode.value < node.sortCode.value) {
          currentNode = currentNode._nextSibling;
        }

        if (currentNode == null) {
          _final._nextSibling = node;
          node._previousSibling = _final;
          _final = node;
        } else {
          final previousNode = currentNode._previousSibling;

          if (previousNode == null) {
            _initial._previousSibling = node;
            node._nextSibling = _initial;
            _initial = node;
          } else {
            currentNode._previousSibling = node;
            node._nextSibling = currentNode;
            node._previousSibling = previousNode;
            previousNode._nextSibling = node;
          }
        }

        node.sortCode.subscribe(this, (newValue, oldValue) {
          if (newValue < oldValue) {
            _needHeadShift.add(node);
          } else if (newValue > oldValue) {
            _needTailShift.add(node);
          }
        });
      }

      _length++;
    } else if (node.parentNode != owner) {
      throw new StateError('Tried to add a node as a child, but the node '
          'already belongs to a different parent. A node can only be a child '
          'of one parent. Try calling `release` on the node before adding it.');
    }
  }

  bool remove(RenderSortTreeNode node) {
    if (node.parentNode == owner) {
      final previous = node._previousSibling;
      final next = node._nextSibling;

      previous?._nextSibling = next;
      next?._previousSibling = previous;

      if (node == _initial) {
        _initial = node._nextSibling;
      }

      if (node == _final) {
        _final = node._previousSibling;
      }

      node._parentNode = null;
      node._previousSibling = null;
      node._nextSibling = null;

      _length--;

      node.sortCode.unsubscribe(this);
      _needHeadShift.remove(node);
      _needTailShift.remove(node);

      return true;
    } else {
      return false;
    }
  }

  void sort() {
    if (_needHeadShift.isNotEmpty) {
      for (var node in _needHeadShift) {
        final previousSibling = node._previousSibling;

        // Check if node is not initial node (which has no previous sibling). If
        // it already is the initial node, then nothing needs to happen (it's
        // already shifted as far forward as it can be).
        if (previousSibling != null) {
          var currentNode = previousSibling;

          while (currentNode != null &&
              currentNode.sortCode.value > node.sortCode.value) {
            currentNode = currentNode._previousSibling;
          }

          // If after searching the currentNode is still the previousNode, then
          // the node was already in the right position and does not need to be
          // moved.
          if (currentNode != previousSibling) {

            // Node does in fact need to be moved so excise it
            if (node == _final) {
              previousSibling._nextSibling = null;
              _final = previousSibling;
            } else {
              final nextSibling = node._nextSibling;

              previousSibling._nextSibling = nextSibling;
              nextSibling?._previousSibling = previousSibling;
            }

            // And then reinsert it earlier in the chain
            if (currentNode == null) {
              _initial._previousSibling = node;
              node._nextSibling = _initial;
              node._previousSibling = null;
              _initial = node;
            } else {
              final nextNode = currentNode._nextSibling;

              currentNode._nextSibling = node;
              node._previousSibling = currentNode;
              node._nextSibling = nextNode;
              nextNode?._previousSibling = node;
            }
          }
        }
      }

      _needHeadShift.clear();
    }

    if (_needTailShift.isNotEmpty) {
      for (var node in _needTailShift) {
        final nextSibling = node._nextSibling;

        // Check if node is not the final node (which has no next sibling). If
        // it already is the final node, then nothing needs to happen (it's
        // already shifted as far backward as it can be).
        if (nextSibling != null) {
          var currentNode = nextSibling;

          while (currentNode != null &&
              currentNode.sortCode.value < node.sortCode.value) {
            currentNode = currentNode._nextSibling;
          }

          // If after searching the currentNode is still the nextNode, then
          // the node was already in the right position and does not need to be
          // moved.
          if (currentNode != nextSibling) {

            // Node does in fact need to be moved so excise it
            if (node == _initial) {
              nextSibling._previousSibling = null;
              _initial = nextSibling;
            } else {
              final previousSibling = node._previousSibling;

              nextSibling._previousSibling = previousSibling;
              previousSibling?._nextSibling = nextSibling;
            }

            // And then reinsert it later in the chain
            if (currentNode == null) {
              _final._nextSibling = node;
              node._previousSibling = _final;
              node._nextSibling = null;
              _final = node;
            } else {
              final previousNode = currentNode._previousSibling;

              currentNode._previousSibling = node;
              node._nextSibling = currentNode;
              node._previousSibling = previousNode;
              previousNode?._nextSibling = node;
            }
          }
        }
      }

      _needTailShift.clear();
    }
  }
}

/// Implementation of [ChildNodes] in which child nodes are sorted by their
/// sort code in ascending order.
///
/// New child nodes are inserted in order. However, changes to sort codes at a
/// later time may degenerate the order of the nodes. Call [sort] to rearrange
/// the nodes in the expected order.
class _DescendingChildNodes extends IterableBase<RenderSortTreeNode>
    implements ChildNodes {
  final BranchingNode owner;

  final SortOrder sortOrder = SortOrder.descending;

  final Set<RenderSortTreeNode> _needHeadShift = new Set();
  final Set<RenderSortTreeNode> _needTailShift = new Set();

  /// Creates a new [AscendingChildNodes] instance for the given [owner].
  _DescendingChildNodes(this.owner);

  int _length = 0;

  RenderSortTreeNode _initial;

  RenderSortTreeNode _final;

  RenderSortTreeNode get first => _initial;

  RenderSortTreeNode get last => _final;

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length > 0;

  int get length => _length;

  Iterator<RenderSortTreeNode> get iterator => new _ChildNodeIterator(this);

  void add(RenderSortTreeNode node) {
    if (node.parentNode == null) {
      node._parentNode = owner;

      if (isEmpty) {
        _initial = node;
        _final = node;
      } else {
        sort();

        var currentNode = _initial;

        while (currentNode != null &&
            currentNode.sortCode.value > node.sortCode.value) {
          currentNode = currentNode._nextSibling;
        }

        if (currentNode == null) {
          _final._nextSibling = node;
          node._previousSibling = _final;
          _final = node;
        } else {
          final previousNode = currentNode._previousSibling;

          if (previousNode == null) {
            _initial._previousSibling = node;
            node._nextSibling = _initial;
            _initial = node;
          } else {
            currentNode._previousSibling = node;
            node._nextSibling = currentNode;
            node._previousSibling = previousNode;
            previousNode._nextSibling = node;
          }
        }

        node.sortCode.subscribe(this, (newValue, oldValue) {
          if (newValue > oldValue) {
            _needHeadShift.add(node);
          } else if (newValue < oldValue) {
            _needTailShift.add(node);
          }
        });
      }

      _length++;
    } else if (node.parentNode != owner) {
      throw new StateError('Tried to add a node as a child, but the node '
          'already belongs to a different parent. A node can only be a child '
          'of one parent. Try calling `release` on the node before adding it.');
    }
  }

  bool remove(RenderSortTreeNode node) {
    if (node.parentNode == owner) {
      final previous = node._previousSibling;
      final next = node._nextSibling;

      previous?._nextSibling = next;
      next?._previousSibling = previous;

      if (node == _initial) {
        _initial = node._nextSibling;
      }

      if (node == _final) {
        _final = node._previousSibling;
      }

      node._parentNode = null;
      node._previousSibling = null;
      node._nextSibling = null;

      _length--;

      node.sortCode.unsubscribe(this);
      _needHeadShift.remove(node);
      _needTailShift.remove(node);

      return true;
    } else {
      return false;
    }
  }

  void sort() {
    if (_needHeadShift.isNotEmpty) {
      for (var node in _needHeadShift) {
        final previousSibling = node._previousSibling;

        // Check if node is not initial node (which has no previous sibling). If
        // it already is the initial node, then nothing needs to happen (it's
        // already shifted as far forward as it can be).
        if (previousSibling != null) {
          var currentNode = previousSibling;

          while (currentNode != null &&
              currentNode.sortCode.value < node.sortCode.value) {
            currentNode = currentNode._previousSibling;
          }

          // If after searching the currentNode is still the previousNode, then
          // the node was already in the right position and does not need to be
          // moved.
          if (currentNode != previousSibling) {

            // Node does in fact need to be moved so excise it
            if (node == _final) {
              previousSibling._nextSibling = null;
              _final = previousSibling;
            } else {
              final nextSibling = node._nextSibling;

              previousSibling._nextSibling = nextSibling;
              nextSibling?._previousSibling = previousSibling;
            }

            // And then reinsert it earlier in the chain
            if (currentNode == null) {
              _initial._previousSibling = node;
              node._nextSibling = _initial;
              node._previousSibling = null;
              _initial = node;
            } else {
              final nextNode = currentNode._nextSibling;

              currentNode._nextSibling = node;
              node._previousSibling = currentNode;
              node._nextSibling = nextNode;
              nextNode?._previousSibling = node;
            }
          }
        }
      }

      _needHeadShift.clear();
    }

    if (_needTailShift.isNotEmpty) {
      for (var node in _needTailShift) {
        final nextSibling = node._nextSibling;

        // Check if node is not the final node (which has no next sibling). If
        // it already is the final node, then nothing needs to happen (it's
        // already shifted as far backward as it can be).
        if (nextSibling != null) {
          var currentNode = nextSibling;

          while (currentNode != null &&
              currentNode.sortCode.value > node.sortCode.value) {
            currentNode = currentNode._nextSibling;
          }

          // If after searching the currentNode is still the nextNode, then
          // the node was already in the right position and does not need to be
          // moved.
          if (currentNode != nextSibling) {

            // Node does in fact need to be moved so excise it
            if (node == _initial) {
              nextSibling._previousSibling = null;
              _initial = nextSibling;
            } else {
              final previousSibling = node._previousSibling;

              nextSibling._previousSibling = previousSibling;
              previousSibling?._nextSibling = nextSibling;
            }

            // And then reinsert it later in the chain
            if (currentNode == null) {
              _final._nextSibling = node;
              node._previousSibling = _final;
              node._nextSibling = null;
              _final = node;
            } else {
              final previousNode = currentNode._previousSibling;

              currentNode._previousSibling = node;
              node._nextSibling = currentNode;
              node._previousSibling = previousNode;
              previousNode?._nextSibling = node;
            }
          }
        }
      }

      _needTailShift.clear();
    }
  }
}

/// An implementation of [ChildNodes] that presents the children in insertion
/// order.
class _UnsortedChildNodes extends IterableBase<RenderSortTreeNode>
    implements ChildNodes {
  final BranchingNode owner;

  final SortOrder sortOrder = SortOrder.unsorted;

  int _length = 0;

  RenderSortTreeNode _initial;

  RenderSortTreeNode _final;

  /// Creates a new [UnsortedChildNodes] instance for the given [owner].
  _UnsortedChildNodes(this.owner);

  RenderSortTreeNode get first => _initial;

  RenderSortTreeNode get last => _final;

  Iterator<RenderSortTreeNode> get iterator => new _ChildNodeIterator(this);

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length > 0;

  int get length => _length;

  void add(RenderSortTreeNode node) {
    if (node.parentNode == null) {
      node._parentNode = owner;

      if (isEmpty) {
        _initial = node;
        _final = node;
      } else {
        _final._nextSibling = node;
        node._previousSibling = _final;
        node._nextSibling = null;

        _final = node;
      }

      _length++;
    } else if (node.parentNode != owner) {
      throw new StateError('Tried to add a node as a child, but the node '
          'already belongs to a different parent. A node can only be a child '
          'of one parent. Try calling `release` on the node before adding it.');
    }
  }

  bool remove(RenderSortTreeNode node) {
    if (node.parentNode == owner) {
      final previous = node._previousSibling;
      final next = node._nextSibling;

      previous?._nextSibling = next;
      next?._previousSibling = previous;

      if (node == _final) {
        _final = node._previousSibling;
      }

      if (node == _initial) {
        _initial = node._nextSibling;
      }

      node._parentNode = null;
      node._previousSibling = null;
      node._nextSibling = null;

      _length--;

      return true;
    } else {
      return false;
    }
  }

  void sort() {}
}

class _ChildNodeIterator implements Iterator<RenderSortTreeNode> {
  final ChildNodes nodes;

  RenderSortTreeNode _currentNode;

  _ChildNodeIterator(this.nodes);

  RenderSortTreeNode get current => _currentNode;

  bool moveNext() {
    _currentNode =
    _currentNode == null ? nodes.first : _currentNode._nextSibling;

    return _currentNode != null;
  }
}
