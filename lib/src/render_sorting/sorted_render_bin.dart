part of render_sorting;

class SortedRenderBin extends IterableBase<AtomicRenderUnit> {
  final BranchingNode renderSortTree;

  final Map<AtomicRenderUnit, RenderUnitNode> _renderUnitsNodes = {};

  SortedRenderBin(this.renderSortTree);

  factory SortedRenderBin.defaultSorting() {
    // Set up branch for opaque render units
    makeOpaqueUnitNode(AtomicRenderUnit renderUnit) =>
        new RenderUnitNode(renderUnit, new ObservableValue(0));

    makeOpaqueUnitGroupNode() =>
        new RenderUnitGroupNode(new StaticSortCode(0), makeOpaqueUnitNode);

    final opaqueBranch = new ProgramBranchingNode(
        new StaticSortCode(0), makeOpaqueUnitGroupNode);

    // Set up branch for translucent render units
    makeTranslucentUnitNode(AtomicRenderUnit renderUnit) {
      if (renderUnit is DistanceSortable) {
        return new RenderUnitNode(renderUnit, renderUnit.distance);
      } else {
        return new RenderUnitNode(renderUnit, new ObservableValue(0));
      }
    }

    final translucentBranch = new RenderUnitGroupNode(
        new StaticSortCode(0), makeTranslucentUnitNode,
        sortOrder: SortOrder.descending);

    final root = new TranslucencyBranchingNode(opaqueBranch, translucentBranch);

    return new SortedRenderBin(root);
  }

  Iterator<AtomicRenderUnit> get iterator =>
      new RenderSortTreeIterator(renderSortTree);

  void add(AtomicRenderUnit renderUnit) {
    if (_renderUnitsNodes.containsKey(renderUnit)) {
      _renderUnitsNodes[renderUnit] = renderSortTree.process(renderUnit);
    }
  }

  bool remove(AtomicRenderUnit renderUnit) {
    final node = _renderUnitsNodes[renderUnit];

    if (node != null) {
      _renderUnitsNodes[renderUnit] = null;

      return node.release();
    } else {
      return false;
    }
  }
}

class RenderSortTreeIterator
    implements Iterator<AtomicRenderUnit>, RenderTreeVisitor {
  final RenderSortTreeNode sortTree;

  RenderUnitNode _currentNode = null;

  bool _moveDown = true;

  bool _terminated = false;

  RenderSortTreeIterator(this.sortTree) {
    _currentNode = sortTree;
  }

  AtomicRenderUnit get current => _currentNode.atomicRenderUnit;

  bool moveNext() {
    _currentNode.accept(this);

    return _terminated;
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
