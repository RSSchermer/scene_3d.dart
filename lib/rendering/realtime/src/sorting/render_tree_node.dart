part of rendering.realtime.sorting;

/// Function that returns a new [RenderUnitNode] for the [renderUnit].
typedef RenderUnitNode<U> RenderUnitNodeFactory<U extends AtomicRenderUnit>(
    U renderUnit);

/// Enumerates the ways in which the children of a [BranchingNode] may be
/// ordered.
enum SortOrder { ascending, descending, unsorted }

/// Node in a render tree.
///
/// When the nodes in a render tree are iterated over depth-first, then the
/// nodes should present [AtomicRenderUnit]s in an order that is beneficial to
/// rendering performance.
abstract class RenderTreeNode<U extends AtomicRenderUnit> {
  BranchingNode<U> _parentNode;

  RenderTreeNode<U> _nextSibling;

  RenderTreeNode<U> _previousSibling;

  /// The parent node if this [RenderTreeNode].
  ///
  /// May be `null` to indicate that this [RenderTreeNode] has no parent
  /// node and thus is a root node.
  BranchingNode<U> get parentNode => _parentNode;

  /// This [RenderTreeNode]'s next sibling amongst the [parentNode]'s
  /// children.
  ///
  /// Returns `null` if this [RenderTreeNode] has no [parentNode] or is the
  /// [parentNode]'s last child.
  RenderTreeNode<U> get nextSibling => _nextSibling;

  /// This [RenderTreeNode]'s previous sibling amongst the [parentNode]'s
  /// children.
  ///
  /// Returns `null` if this [RenderTreeNode] has no [parentNode] or is the
  /// [parentNode]'s first child.
  RenderTreeNode<U> get previousSibling => _previousSibling;

  /// Code that may be used to determine the position of this [RenderTreeNode]
  /// amongst its sibling nodes.
  ObservableValue<num> get sortCode;

  /// Accepts a visit from the [visitor].
  void accept(RenderTreeVisitor visitor);

  /// Disconnects this [RenderTreeNode] from the tree.
  ///
  /// Leaves the node parentless and without siblings; a root node. Returns
  /// `true` if the node was disconnected successfully, returns `false` if the
  /// node was already parentless or could not be released from its parent.
  bool disconnect();

  /// Updates the node order of the tree represented by this [RenderTreeNode] to
  /// reflect the current state of its [AtomicRenderUnit]s.
  ///
  /// Although new nodes are inserted in order, state changes in
  /// [AtomicRenderUnit]s processed previously may degenerate the sort order of
  /// the tree, causing [AtomicRenderUnit]s to no longer be in the correct
  /// branch or causing the order of branches to no longer reflect expected
  /// order. Calling this method reprocess [AtomicRenderUnit]s down different
  /// branches as necessary and updates the order of the branches to once again
  /// reflect the expected order.
  void sort();

  /// Returns a new copy of the subtree represented by this
  /// [RenderTreeNode].
  RenderTreeNode<U> toRenderTree();
}

/// A [RenderTreeNode] that branches into one or more [branches].
///
/// Used to divide [AtomicRenderUnit]s into groups.
abstract class BranchingNode<U extends AtomicRenderUnit>
    extends RenderTreeNode<U> {
  /// This [BranchingNode]'s child nodes.
  Iterable<RenderTreeNode<U>> get branches;

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
  RenderUnitNode<U> process(U renderUnit);

  /// Removes the [node] from the [branches].
  ///
  /// Returns `true` is the node was successfully removed from the [branches] or
  /// `false` if the [node] was not a child of this [BranchingNode] or could not
  /// be removed for other reasons.
  bool removeBranch(RenderTreeNode<U> node);

  /// Cancels all subscriptions this [BranchingNode] has on any observable
  /// values associated with the [renderUnitNode].
  void cancelSubscriptions(RenderUnitNode<U> renderUnitNode);

  bool disconnect() {
    if (parentNode != null) {
      return parentNode.removeBranch(this);
    } else {
      return false;
    }
  }

  BranchingNode<U> toRenderTree();
}

/// A terminal [RenderTreeNode] that holds an [AtomicRenderUnit].
class RenderUnitNode<U extends AtomicRenderUnit> extends RenderTreeNode<U> {
  /// The [AtomicRenderUnit] held by this [RenderUnitNode].
  final U renderUnit;

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
      return parentNode.removeBranch(this);
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
  void reprocess(BranchingNode<U> reentryNode) {
    var node = parentNode;

    while (node != reentryNode && node != null) {
      node.cancelSubscriptions(this);

      node = node.parentNode;
    }

    parentNode?.removeBranch(this);
    reentryNode.process(renderUnit);
  }

  void sort() {}

  RenderUnitNode<U> toRenderTree() =>
      new RenderUnitNode<U>(renderUnit, sortCode);
}

/// A [BranchingNode] that holds some number of terminal [RenderUnitNode]s.
class RenderUnitGroupNode<U extends AtomicRenderUnit> extends BranchingNode<U> {
  /// The function used to make new [RenderUnitNode]s when processing an
  /// [AtomicRenderUnit].
  final RenderUnitNodeFactory<U> makeRenderUnitNode;

  final SummarySortCode sortCode;

  ChildNodes<U> _children;

  /// Instantiates a new [RenderUnitGroupNode].
  RenderUnitGroupNode(this.sortCode, this.makeRenderUnitNode,
      {SortOrder sortOrder: SortOrder.unsorted}) {
    if (sortOrder == SortOrder.ascending) {
      _children = new ChildNodes.ascending(this);
    } else if (sortOrder == SortOrder.descending) {
      _children = new ChildNodes.descending(this);
    } else {
      _children = new ChildNodes.unsorted(this);
    }
  }

  Iterable<RenderTreeNode<U>> get branches => _children;

  RenderUnitNode<U> process(U renderUnit) {
    final node = makeRenderUnitNode(renderUnit);

    _children.add(node);
    sortCode.add(node.sortCode);

    return node;
  }

  bool removeBranch(RenderTreeNode<U> node) {
    final success = _children.remove(node);

    if (success) {
      sortCode.remove(node.sortCode);
    }

    if (_children.isEmpty) {
      disconnect();
    }

    return success;
  }

  void cancelSubscriptions(RenderUnitNode<U> renderUnitNode) {}

  void sort() {
    _children.sort();
  }

  RenderUnitGroupNode<U> toRenderTree() {
    final newSortCode = sortCode.asEmpty();
    final result = new RenderUnitGroupNode<U>(newSortCode, makeRenderUnitNode,
        sortOrder: _children.sortOrder);

    for (var child in _children) {
      result._children.add(child.toRenderTree());
      newSortCode.add(child.sortCode);
    }

    return result;
  }
}

/// Defines an interface for [RenderTreeNode] visitors.
abstract class RenderTreeVisitor<U extends AtomicRenderUnit> {
  /// Visit a [BranchingNode].
  void visitBranchingNode(BranchingNode<U> node);

  /// Visit a terminal [RenderUnitNode].
  void visitRenderUnitNode(RenderUnitNode<U> node);
}

class _RenderTreeLeafIterator<U extends AtomicRenderUnit>
    implements Iterator<RenderUnitNode<U>>, RenderTreeVisitor<U> {
  final RenderTreeNode<U> rootNode;

  RenderUnitNode<U> _currentNode = null;

  bool _moveDown = true;

  bool _terminated = false;

  _RenderTreeLeafIterator(this.rootNode) {
    rootNode.sort();
  }

  RenderUnitNode<U> get current => _currentNode;

  bool moveNext() {
    (_currentNode ?? rootNode).accept(this);

    return !_terminated;
  }

  void visitRenderUnitNode(RenderUnitNode<U> node) {
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

  void visitBranchingNode(BranchingNode<U> node) {
    if (_moveDown) {
      final firstChild = node.branches.first;

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

class _RenderUnitIterator<U extends AtomicRenderUnit> implements Iterator<U> {
  final _RenderTreeLeafIterator<U> leafIterator;

  _RenderUnitIterator(this.leafIterator);

  U get current => leafIterator.current.renderUnit;

  bool moveNext() => leafIterator.moveNext();
}
