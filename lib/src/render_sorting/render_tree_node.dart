part of render_sorting;

/// Function that returns a new [RenderUnitNode] for the [renderUnit].
typedef RenderUnitNode RenderUnitNodeFactory(AtomicRenderUnit renderUnit);

/// Function that returns a new BranchingNode
typedef BranchingNode BranchingNodeFactory();

/// Enumerates the ways in which the children of a [BranchingNode] may be
/// ordered.
enum SortOrder { ascending, descending, unsorted }

/// Node in a sorted render tree.
///
/// When the nodes in a sorted render tree are iterated over depth-first, then
/// the nodes should present [AtomicRenderUnit]s in an order that is beneficial
/// to rendering performance.
abstract class RenderSortTreeNode {
  BranchingNode _parentNode;

  RenderSortTreeNode _nextSibling;

  RenderSortTreeNode _previousSibling;

  /// The parent node if this [RenderSortTreeNode].
  ///
  /// May be `null` to indicate that this [RenderSortTreeNode] has no parent
  /// node and thus is a root node.
  BranchingNode get parentNode => _parentNode;

  /// This [RenderSortTreeNode]'s next sibling amongst the [parentNode]'s
  /// children.
  ///
  /// Returns `null` if this [RenderSortTreeNode] has no [parentNode] or is the
  /// [parentNode]'s last child.
  RenderSortTreeNode get nextSibling => _nextSibling;

  /// This [RenderSortTreeNode]'s previous sibling amongst the [parentNode]'s
  /// children.
  ///
  /// Returns `null` if this [RenderSortTreeNode] has no [parentNode] or is the
  /// [parentNode]'s first child.
  RenderSortTreeNode get previousSibling => _previousSibling;

  /// Code that may be used to determine the position if this
  /// [RenderSortTreeNode] amongst its sibling nodes.
  ObservableValue<num> get sortCode;

  /// Accepts a visit from the [visitor].
  void accept(RenderTreeVisitor visitor);

  /// Releases this [RenderUnitNode] from the tree.
  ///
  /// Leaves the node parentless and without siblings; a root node. Returns
  /// `true` if the node was released successfully, returns `false` if the node
  /// was already parentless or could not be released from its parent.
  bool release();
}

/// A [RenderSortTreeNode] that branches into one or more [children].
///
/// Used to divide [AtomicRenderUnit]s into groups.
abstract class BranchingNode extends RenderSortTreeNode {
  /// This [BranchingNode]'s child nodes.
  Iterable<RenderSortTreeNode> get children;

  void accept(RenderTreeVisitor visitor) {
    visitor.visitBranchingNode(this);
  }

  /// Processes the [renderUnit].
  ///
  /// Passes the [renderUnit] down one of this [BranchingNode]'s branches until
  /// a terminal [RenderUnitNode] is inserted into the tree. An
  /// [AtomicRenderUnit] may be passed down multiple levels of [BranchingNode]s,
  /// with each level assigning the [AtomicRenderUnit] to more specific groups.
  /// If none of the [BranchingNode]'s existing child branches are appropriate
  /// for the [renderUnit], it may create a new child branch.
  RenderUnitNode process(AtomicRenderUnit renderUnit);

  /// Removes the [node] from the [children].
  ///
  /// Returns `true` is the node was successfully removed from the [children] or
  /// `false` if the [node] was not a child of this [BranchingNode] or could not
  /// be removed for other reasons.
  bool removeChild(RenderSortTreeNode childNode);

  /// Cancels all subscriptions this [BranchingNode] has on any observable
  /// values that belong to the [renderUnit].
  void cancelSubscriptions(AtomicRenderUnit renderUnit);

  bool release() {
    if (parentNode != null) {
      return parentNode.removeChild(this);
    } else {
      return false;
    }
  }
}

/// A terminal [RenderSortTreeNode] that holds one [AtomicRenderUnit].
class RenderUnitNode extends RenderSortTreeNode {
  /// The [AtomicRenderUnit] held by this [RenderUnitNode].
  final AtomicRenderUnit atomicRenderUnit;

  final ObservableValue<num> sortCode;

  /// Instantiates a new [AtomicRenderUnit].
  RenderUnitNode(this.atomicRenderUnit, this.sortCode);

  void accept(RenderTreeVisitor visitor) {
    visitor.visitRenderUnitNode(this);
  }

  bool release() {
    var node = parentNode;

    while (node != null) {
      node.cancelSubscriptions(atomicRenderUnit);

      node = node.parentNode;
    }

    if (parentNode != null) {
      return parentNode.removeChild(this);
    } else {
      return false;
    }
  }

  /// Releases this [RenderUnitNode] from the tree and reprocesses the
  /// [atomicRenderUnit] at the [reentryNode].
  ///
  /// Typically called by a [BranchingNode] higher up in the tree when the
  /// [atomicRenderUnit]'s state changes in a way that requires assigning it to
  /// a different branch.
  void reprocess(BranchingNode reentryNode) {
    var node = parentNode;

    while (node != reentryNode && node != null) {
      node.cancelSubscriptions(atomicRenderUnit);

      node = node.parentNode;
    }

    parentNode?.removeChild(this);
    reentryNode.process(atomicRenderUnit);
  }
}

/// A [BranchingNode] that holds some number of terminal [RenderUnitNode]s.
class RenderUnitGroupNode extends BranchingNode {
  /// The function used to make new [RenderUnitNode]s when processing an
  /// [AtomicRenderUnit].
  final RenderUnitNodeFactory makeAtomicRenderUnit;

  final SummarySortCode sortCode;

  ChildNodes _children;

  /// Instantiates a new [RenderUnitGroupNode].
  RenderUnitGroupNode(this.sortCode, this.makeAtomicRenderUnit,
      {SortOrder sortOrder: SortOrder.unsorted}) {
    if (sortOrder == SortOrder.ascending) {
      _children = new SortedChildNodes.ascending(this);
    } else if (sortOrder == SortOrder.descending) {
      _children = new SortedChildNodes.descending(this);
    } else {
      _children = new UnsortedChildNodes(this);
    }
  }

  Iterable<RenderSortTreeNode> get children => _children;

  RenderUnitNode process(AtomicRenderUnit renderUnit) {
    final node = makeAtomicRenderUnit(renderUnit);

    _children.add(node);
    sortCode.add(node.sortCode);

    return node;
  }

  bool removeChild(RenderSortTreeNode childNode) {
    final success = _children.remove(childNode);

    if (success) {
      sortCode.remove(childNode.sortCode);
    }

    return success;
  }

  void cancelSubscriptions(AtomicRenderUnit renderUnit) {}
}

/// Defines an interface for [RenderSortTreeNode] visitors.
abstract class RenderTreeVisitor {
  /// Visit a [BranchingNode].
  void visitBranchingNode(BranchingNode node);

  /// Visit a terminal [RenderUnitNode].
  void visitRenderUnitNode(RenderUnitNode node);
}

abstract class ChildNodes extends Iterable<RenderSortTreeNode> {
  /// The [BranchingNode] to which these [ChildNodes] belong.
  BranchingNode get owner;

  /// The way in which these [ChildNodes] are sorted.
  SortOrder get sortOrder;

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
}

/// Implementation of [ChildNodes] in which child nodes are sorted by their
/// sort code in ascending or descending order.
///
/// The order of the child nodes is maintained automatically by observing the
/// children's sort code values.
class SortedChildNodes extends IterableBase<RenderSortTreeNode>
    implements ChildNodes {
  final BranchingNode owner;

  final SortOrder sortOrder;

  /// Creates a new [SortedChildNodes] instance for the given [owner] in which
  /// nodes will be sorted by their sort codes in ascending order.
  SortedChildNodes.ascending(this.owner) : sortOrder = SortOrder.ascending;

  /// Creates a new [SortedChildNodes] instance for the given [owner] in which
  /// nodes will be sorted by their sort codes in descending order.
  SortedChildNodes.descending(this.owner) : sortOrder = SortOrder.descending;

  int _length = 0;

  RenderSortTreeNode _first;

  RenderSortTreeNode _last;

  RenderSortTreeNode get first =>
      sortOrder == SortOrder.ascending ? _first : _last;

  RenderSortTreeNode get last =>
      sortOrder == SortOrder.ascending ? _last : _first;

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length > 0;

  int get length => _length;

  Iterator<RenderSortTreeNode> get iterator => sortOrder == SortOrder.ascending
      ? new _ChildNodeIterator(this)
      : new _ReverseChildNodeIterator(this);

  void add(RenderSortTreeNode node) {
    if (node.parentNode == null) {
      if (isEmpty) {
        _first = node;
        _last = node;
      } else {
        node._parentNode = owner;

        var currentNode = _first;

        while (currentNode._nextSibling != null &&
            currentNode.sortCode.value <= node.sortCode.value) {
          currentNode = currentNode._nextSibling;
        }

        final previousNode = currentNode._previousSibling;

        currentNode._previousSibling = node;
        node._nextSibling = currentNode;
        node._previousSibling = previousNode;
        previousNode?._nextSibling = node;

        node.sortCode.subscribe(this, (newValue, oldValue) {
          if (newValue < oldValue && node != _first) {
            var currentNode = node._previousSibling;

            while (currentNode._previousSibling != null &&
                currentNode.sortCode.value >= node.sortCode.value) {
              currentNode = currentNode._previousSibling;
            }

            final nextNode = currentNode._nextSibling;

            currentNode._nextSibling = node;
            node._previousSibling = currentNode;
            node._nextSibling = nextNode;
            nextNode?._previousSibling = node;
          } else if (newValue > oldValue && node != _last) {
            var currentNode = node._nextSibling;

            while (currentNode._nextSibling != null &&
                currentNode.sortCode.value <= node.sortCode.value) {
              currentNode = currentNode._nextSibling;
            }

            final previousNode = currentNode._previousSibling;

            currentNode._previousSibling = node;
            node._nextSibling = currentNode;
            node._previousSibling = previousNode;
            previousNode?._nextSibling = node;
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

      if (node == _first) {
        _first = node._nextSibling;
      }

      if (node == _last) {
        _last = node._previousSibling;
      }

      node._parentNode = null;
      node._previousSibling = null;
      node._nextSibling = null;

      _length--;

      node.sortCode.unsubscribe(this);

      return true;
    } else {
      return false;
    }
  }
}

/// An implementation of [ChildNodes] that presents the children in insertion
/// order.
class UnsortedChildNodes extends IterableBase<RenderSortTreeNode>
    implements ChildNodes {
  final BranchingNode owner;

  final SortOrder sortOrder = SortOrder.unsorted;

  int _length = 0;

  RenderSortTreeNode _initial;

  RenderSortTreeNode _final;

  /// Creates a new [UnsortedChildNodes] instance for the given [owner].
  UnsortedChildNodes(this.owner);

  RenderSortTreeNode get first => _initial;

  RenderSortTreeNode get last => _final;

  Iterator<RenderSortTreeNode> get iterator => new _ChildNodeIterator(this);

  bool get isEmpty => _length == 0;

  bool get isNotEmpty => _length > 0;

  int get length => _length;

  void add(RenderSortTreeNode node) {
    if (node.parentNode == null) {
      if (isEmpty) {
        _initial = node;
        _final = node;
      } else {
        node._parentNode = owner;

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

      return true;
    } else {
      return false;
    }
  }
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

class _ReverseChildNodeIterator implements Iterator<RenderSortTreeNode> {
  final ChildNodes nodes;

  RenderSortTreeNode _currentNode;

  _ReverseChildNodeIterator(this.nodes);

  RenderSortTreeNode get current => _currentNode;

  bool moveNext() {
    _currentNode =
        _currentNode == null ? nodes.first : _currentNode._previousSibling;

    return _currentNode != null;
  }
}
