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

  /// Disconnects this [RenderUnitNode] from the tree.
  ///
  /// Leaves the node parentless and without siblings; a root node. Returns
  /// `true` if the node was disconnected successfully, returns `false` if the
  /// node was already parentless or could not be released from its parent.
  bool disconnect();

  /// Updates the node order of the tree represented by this
  /// [RenderSortTreeNode] to reflect the current state of its
  /// [AtomicRenderUnit]s.
  ///
  /// Although new nodes are inserted in order, state changes in
  /// [AtomicRenderUnit]s processed previously may degenerate the sort order of
  /// the tree, causing [AtomicRenderUnit]s to no longer be in the correct
  /// branch or causing the order of branches to no longer reflect expected
  /// order. Calling this method reprocess [AtomicRenderUnit]s down different
  /// branches as necessary and updates the order of the branches to once again
  /// reflect the expected order.
  void sortTree();

  /// Returns a new copy of the subtree represented by this
  /// [RenderSortTreeNode].
  RenderSortTreeNode toRenderSortTree();
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
  /// values on the [renderUnitNode] or its [AtomicRenderUnit].
  void cancelSubscriptions(RenderUnitNode renderUnitNode);

  bool disconnect() {
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
  final AtomicRenderUnit renderUnit;

  final ObservableValue<num> sortCode;

  /// Instantiates a new [RenderUnitNode].
  RenderUnitNode(this.renderUnit, this.sortCode);

  void accept(RenderTreeVisitor visitor) {
    visitor.visitRenderUnitNode(this);
  }

  bool disconnect() {
    var node = parentNode;

    while (node != null) {
      node.cancelSubscriptions(this);

      node = node.parentNode;
    }

    if (parentNode != null) {
      return parentNode.removeChild(this);
    } else {
      return false;
    }
  }

  /// Releases this [RenderUnitNode] from the tree and reprocesses the
  /// [renderUnit] at the [reentryNode].
  ///
  /// Typically called by a [BranchingNode] higher up in the tree when the
  /// [renderUnit]'s state changes in a way that requires assigning it to
  /// a different branch.
  void reprocess(BranchingNode reentryNode) {
    var node = parentNode;

    while (node != reentryNode && node != null) {
      node.cancelSubscriptions(this);

      node = node.parentNode;
    }

    parentNode?.removeChild(this);
    reentryNode.process(renderUnit);
  }

  void sortTree() {}

  RenderUnitNode toRenderSortTree() => new RenderUnitNode(renderUnit, sortCode);
}

/// A [BranchingNode] that holds some number of terminal [RenderUnitNode]s.
class RenderUnitGroupNode extends BranchingNode {
  /// The function used to make new [RenderUnitNode]s when processing an
  /// [AtomicRenderUnit].
  final RenderUnitNodeFactory makeRenderUnitNode;

  final SummarySortCode sortCode;

  ChildNodes _children;

  /// Instantiates a new [RenderUnitGroupNode].
  RenderUnitGroupNode(this.sortCode, this.makeRenderUnitNode,
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
    final node = makeRenderUnitNode(renderUnit);

    _children.add(node);
    sortCode.add(node.sortCode);

    return node;
  }

  bool removeChild(RenderSortTreeNode childNode) {
    final success = _children.remove(childNode);

    if (success) {
      sortCode.remove(childNode.sortCode);
    }

    if (_children.isEmpty) {
      disconnect();
    }

    return success;
  }

  void cancelSubscriptions(RenderUnitNode renderUnitNode) {}

  void sortTree() {
    _children.sort();
  }

  RenderUnitGroupNode toRenderSortTree() {
    final newSortCode = sortCode.asEmpty();
    final result = new RenderUnitGroupNode(newSortCode, makeRenderUnitNode,
        sortOrder: _children.sortOrder);

    for (var child in _children) {
      result._children.add(child.toRenderSortTree());
      newSortCode.add(child.sortCode);
    }

    return result;
  }
}

/// Defines an interface for [RenderSortTreeNode] visitors.
abstract class RenderTreeVisitor {
  /// Visit a [BranchingNode].
  void visitBranchingNode(BranchingNode node);

  /// Visit a terminal [RenderUnitNode].
  void visitRenderUnitNode(RenderUnitNode node);
}

class _RenderTreeLeafIterator
    implements Iterator<RenderUnitNode>, RenderTreeVisitor {
  final RenderSortTreeNode rootNode;

  RenderUnitNode _currentNode = null;

  bool _moveDown = true;

  bool _terminated = false;

  _RenderTreeLeafIterator(this.rootNode) {
    rootNode.sortTree();
  }

  RenderUnitNode get current => _currentNode;

  bool moveNext() {
    (_currentNode ?? rootNode).accept(this);

    return !_terminated;
  }

  void visitRenderUnitNode(RenderUnitNode node) {
    if (_moveDown) {
      _moveDown = false;

      _currentNode = node;
    } else {
      if (node.nextSibling != null) {
        _moveDown = true;

        node.nextSibling.accept(this);
      } else if (node.parentNode != null) {
        node.parentNode.accept(this);
      } else {
        _terminated = true;
      }
    }
  }

  void visitBranchingNode(BranchingNode node) {
    if (_moveDown) {
      final firstChild = node.children.first;

      if (firstChild != null) {
        firstChild.accept(this);
      } else {
        _moveDown = false;

        node.accept(this);
      }
    } else {
      if (node.nextSibling != null) {
        _moveDown = true;

        node.nextSibling.accept(this);
      } else if (node.parentNode != null) {
        node.parentNode.accept(this);
      } else {
        _terminated = true;
      }
    }
  }
}

class _RenderUnitIterator implements Iterator<AtomicRenderUnit> {
  final _RenderTreeLeafIterator leafIterator;

  _RenderUnitIterator(this.leafIterator);

  AtomicRenderUnit get current {
    return leafIterator.current.renderUnit;
  }

  bool moveNext() => leafIterator.moveNext();
}
