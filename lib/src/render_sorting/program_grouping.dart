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

  /// Instantiates a new [ProgramBranchingNode].
  ProgramBranchingNode(this.sortCode, this.makeChildNode,
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
    if (renderUnit is ProgramGroupable) {
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
        terminalNode.reprocess(this);
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

  void cancelSubscriptions(AtomicRenderUnit renderUnit) {
    if (renderUnit is ProgramGroupable) {
      renderUnit.program.unsubscribe(this);
    }
  }
}
