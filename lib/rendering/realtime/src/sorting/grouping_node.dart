part of rendering.realtime.sorting;

/// Function that resolves the [ObservableValue] is is to be used for grouping
/// from the given [renderUnit].
typedef ObservableValue<V> GroupingValueResolver<U extends AtomicRenderUnit, V>(
    U renderUnit);

/// Function that returns a new [BranchingNode] for the given [value].
typedef BranchingNode<U> BranchingNodeFactory<U extends AtomicRenderUnit, V>(
    V value);

/// A [BranchingNode] that groups the [AtomicRenderUnit]s it processes into
/// branches based on a grouping value.
class GroupingNode<U extends AtomicRenderUnit, V> extends BranchingNode<U> {
  /// Function that resolves the grouping value for a given [AtomicRenderUnit].
  final GroupingValueResolver<U, V> resolveGroupingValue;

  /// Factory function that creates new branch instances for values for which
  /// no branch exists yet.
  final BranchingNodeFactory<U, V> makeBranch;

  final SummarySortCode sortCode;

  /// An optional default value that will be used when the grouping value
  /// resolves to `null`.
  final V defaultValue;

  ChildNodes<U> _branches;

  final BiMap<V, BranchingNode<U>> _valueBranches = new BiMap();

  BranchingNode<U> _defaultBranch;

  final Set<RenderUnitNode> _needReprocessing = new Set();

  GroupingNode(this.resolveGroupingValue, this.makeBranch, this.sortCode,
      {this.defaultValue, SortOrder sortOrder: SortOrder.unsorted}) {
    if (sortOrder == SortOrder.ascending) {
      _branches = new ChildNodes.ascending(this);
    } else if (sortOrder == SortOrder.descending) {
      _branches = new ChildNodes.descending(this);
    } else {
      _branches = new ChildNodes.unsorted(this);
    }
  }

  Iterable<RenderTreeNode<U>> get branches => _branches;

  RenderUnitNode<U> process(U renderUnit) {
    final observableValue = resolveGroupingValue(renderUnit);
    final value = observableValue?.value ?? defaultValue;
    RenderUnitNode<U> terminalNode;

    if (value != null) {
      var targetBranch = _valueBranches[value];

      if (targetBranch == null) {
        targetBranch = makeBranch(value);
        _valueBranches[value] = targetBranch;
        _branches.add(targetBranch);
        sortCode.add(targetBranch.sortCode);
      }

      terminalNode = targetBranch.process(renderUnit);
    } else {
      if (_defaultBranch == null) {
        _defaultBranch = makeBranch(null);
        _branches.add(_defaultBranch);
        sortCode.add(_defaultBranch.sortCode);
      }

      terminalNode = _defaultBranch.process(renderUnit);
    }

    observableValue?.subscribe(this, (newValue, oldValue) {
      _needReprocessing.add(terminalNode);
    });

    return terminalNode;
  }

  bool removeBranch(RenderTreeNode node) {
    final success = _branches.remove(node);

    if (success) {
      sortCode.remove(node.sortCode);
      _valueBranches.inverse.remove(node);

      if (node == _defaultBranch) {
        _defaultBranch = null;
      }
    }

    return success;
  }

  void cancelSubscriptions(RenderUnitNode<U> renderUnitNode) {
    resolveGroupingValue(renderUnitNode.renderUnit)?.unsubscribe(this);
    _needReprocessing.remove(renderUnitNode);
  }

  void sort() {
    for (var node in _needReprocessing) {
      node.reprocess(this);
    }

    _needReprocessing.clear();

    for (var branch in branches) {
      branch.sort();
    }

    _branches.sort();
  }

  GroupingNode<U, V> toRenderTree() {
    final newSortCode = sortCode.asEmpty();
    final result = new GroupingNode<U, V>(
        resolveGroupingValue, makeBranch, newSortCode,
        sortOrder: _branches.sortOrder);

    _valueBranches.forEach((value, branch) {
      final newBranch = branch.toRenderTree();

      result._branches.add(newBranch);
      result._valueBranches[value] = newBranch;
      newSortCode.add(newBranch.sortCode);
    });

    if (_defaultBranch != null) {
      final newDefaultBranch = _defaultBranch.toRenderTree();

      result._defaultBranch = newDefaultBranch;
      result._branches.add(newDefaultBranch);
      newSortCode.add(newDefaultBranch.sortCode);
    }

    final iterator = new _RenderTreeLeafIterator(result);

    while (iterator.moveNext()) {
      final renderUnitNode = iterator.current;
      final observableValue = resolveGroupingValue(renderUnitNode.renderUnit);

      observableValue?.subscribe(result, (newValue, oldValue) {
        renderUnitNode.reprocess(result);
      });
    }

    return result;
  }
}
