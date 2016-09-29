part of render_sorting;

/// Intended to be mixed into [AtomicRenderUnit] classes that may be used in
/// render trees with [TranslucencyBranchingNode]s.
///
/// See the documentation for the [TranslucencyBranchingNode] class for more
/// information.
abstract class TranslucencyGroupable extends AtomicRenderUnit {
  ObservableValue<bool> get isTranslucent;
}

/// [BranchingNode] that splits [AtomicRenderUnit]s into an opaque group and
/// a translucent group.
///
/// Opaque geometry needs to be drawn before translucent geometry to ensure that
/// the translucent geometry is displayed correctly.
class TranslucencyBranchingNode extends BranchingNode {
  /// The branch down which opaque objects are passed.
  final BranchingNode opaqueBranch;

  /// The branch down which translucent objects are passed.
  final BranchingNode translucentBranch;

  final ObservableValue<num> sortCode;

  final Set<RenderUnitNode> _needReprocessing = new Set();

  /// Instantiates a new [TranslucencyBranchingNode].
  TranslucencyBranchingNode(this.opaqueBranch, this.translucentBranch,
      [ObservableValue<num> sortCode])
      : sortCode = sortCode ?? new ObservableValue<num>(0) {
    if (opaqueBranch.parentNode != null) {
      throw new ArgumentError('Only a node that does not already have another '
          'parentNode can be used as the `opaqueBranch` of a '
          'TranslucencyBranchingNode.');
    } else {
      opaqueBranch._parentNode = this;
      opaqueBranch._nextSibling = translucentBranch;
    }

    if (translucentBranch.parentNode != null) {
      throw new ArgumentError('Only a node that does not already have another '
          'parentNode can be used as the `translucentBranch` of a '
          'TranslucencyBranchingNode.');
    } else {
      translucentBranch._parentNode = this;
      translucentBranch._previousSibling = opaqueBranch;
    }
  }

  Iterable<RenderSortTreeNode> get children =>
      [opaqueBranch, translucentBranch];

  RenderUnitNode process(AtomicRenderUnit renderUnit) {
    if (renderUnit is TranslucencyGroupable) {
      var terminalNode = renderUnit.isTranslucent.value
          ? translucentBranch.process(renderUnit)
          : opaqueBranch.process(renderUnit);

      renderUnit.isTranslucent.subscribe(this, (newValue, oldValue) {
        _needReprocessing.add(terminalNode);
      });

      return terminalNode;
    } else {
      return opaqueBranch.process(renderUnit);
    }
  }

  bool removeChild(RenderSortTreeNode childNode) => false;

  void cancelSubscriptions(RenderUnitNode renderUnitNode) {
    final renderUnit = renderUnitNode.renderUnit;

    if (renderUnit is TranslucencyGroupable) {
      renderUnit.isTranslucent.unsubscribe(this);
      _needReprocessing.remove(renderUnitNode);
    }
  }

  void sort() {
    for (var node in _needReprocessing) {
      node.reprocess(this);
    }

    for (var child in children) {
      child.sort();
    }

    _needReprocessing.clear();
  }

  TranslucencyBranchingNode toRenderSortTree() {
    final newOpaqueBranch = opaqueBranch.toRenderSortTree();
    final newTranslucentBranch = translucentBranch.toRenderSortTree();
    final result = new TranslucencyBranchingNode(newOpaqueBranch, newTranslucentBranch, sortCode);

    final iterator = new _RenderTreeLeafIterator(result);

    while (iterator.moveNext()) {
      final renderUnitNode = iterator.current;
      final renderUnit = renderUnitNode.renderUnit;

      if (renderUnit is TranslucencyGroupable) {
        renderUnit.isTranslucent.subscribe(result, (newValue, oldValue) {
          renderUnitNode.reprocess(result);
        });
      }
    }

    return result;
  }
}
