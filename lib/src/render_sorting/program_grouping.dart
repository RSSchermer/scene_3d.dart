part of render_sorting;

/// Intended to be mixed into [AtomicRenderUnit] classes that may be used in
/// render trees with [ProgramBranchingNode]s.
///
/// See the documentation for the [ProgramBranchingNode] class for more
/// information.
abstract class ProgramGroupable extends AtomicRenderUnit {
  ObservableValue<Program> get program;
}

/// A [BranchingNode] that groups [ProgramGroupable] [AtomicRenderUnit]
/// according to the [Program] they use.
///
/// Grouping [AtomicRenderUnit] by [Program] can reduce the amount of shader
/// program switching a GPU backend has to do.
class ProgramBranchingNode extends BranchingNode {
  /// The function used by this [ProgramBranchingNode] to create a new child
  /// branch when processing a [ProgramGroupable] [AtomicRenderUnit] for which
  /// no suitable branch exists yet.
  final BranchingNodeFactory makeChildNode;

  final SummarySortCode sortCode;

  final BiMap<Program, BranchingNode> _programsBranches = new BiMap();

  ChildNodes _children;

  BranchingNode _defaultChild;

  final Set<RenderUnitNode> _needReprocessing = new Set();

  /// Instantiates a new [ProgramBranchingNode].
  ProgramBranchingNode(this.sortCode, this.makeChildNode,
      {SortOrder sortOrder: SortOrder.unsorted}) {
    if (sortOrder == SortOrder.ascending) {
      _children = new ChildNodes.ascending(this);
    } else if (sortOrder == SortOrder.descending) {
      _children = new ChildNodes.descending(this);
    } else {
      _children = new ChildNodes.unsorted(this);
    }
  }

  Iterable<RenderSortTreeNode> get children => _children;

  RenderUnitNode process(AtomicRenderUnit renderUnit) {
    if (renderUnit is ProgramGroupable && renderUnit.program.value != null) {
      final program = renderUnit.program.value;
      var targetChild = _programsBranches[program];

      if (targetChild == null) {
        targetChild = makeChildNode();
        _programsBranches[program] = targetChild;
        _children.add(targetChild);
        sortCode.add(targetChild.sortCode);
      }

      final terminalNode = targetChild.process(renderUnit);

      renderUnit.program.subscribe(this, (newValue, oldValue) {
        _needReprocessing.add(terminalNode);
      });

      return terminalNode;
    } else {
      if (_defaultChild == null) {
        _defaultChild = makeChildNode();
        _children.add(_defaultChild);
        sortCode.add(_defaultChild.sortCode);
      }

      return _defaultChild.process(renderUnit);
    }
  }

  bool removeChild(RenderSortTreeNode childNode) {
    final success = _children.remove(childNode);

    if (success) {
      sortCode.remove(childNode.sortCode);

      if (childNode == _defaultChild) {
        _defaultChild = null;
      } else {
        _programsBranches.inverse.remove(childNode);
      }
    }

    return success;
  }

  void cancelSubscriptions(RenderUnitNode renderUnitNode) {
    final renderUnit = renderUnitNode.renderUnit;

    if (renderUnit is ProgramGroupable) {
      renderUnit.program.unsubscribe(this);
      _needReprocessing.remove(renderUnitNode);
    }
  }

  void sortTree() {
    for (var node in _needReprocessing) {
      node.reprocess(this);
    }

    _needReprocessing.clear();

    for (var child in children) {
      child.sortTree();
    }

    _children.sort();
  }

  ProgramBranchingNode toRenderSortTree() {
    final newSortCode = sortCode.asEmpty();
    final result = new ProgramBranchingNode(newSortCode, makeChildNode,
        sortOrder: _children.sortOrder);

    _programsBranches.forEach((program, branch) {
      final newBranch = branch.toRenderSortTree();

      result._children.add(newBranch);
      result._programsBranches[program] = newBranch;
      newSortCode.add(newBranch.sortCode);
    });

    if (_defaultChild != null) {
      final newDefault = _defaultChild.toRenderSortTree();

      result._children.add(newDefault);
      result._defaultChild = newDefault;
      newSortCode.add(newDefault.sortCode);
    }

    final iterator = new _RenderTreeLeafIterator(result);

    while (iterator.moveNext()) {
      final renderUnitNode = iterator.current;
      final renderUnit = renderUnitNode.renderUnit;

      if (renderUnit is ProgramGroupable) {
        renderUnit.program.subscribe(result, (newValue, oldValue) {
          renderUnitNode.reprocess(result);
        });
      }
    }

    return result;
  }
}
