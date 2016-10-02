part of render_sorting;

class SortedRenderBin extends SetBase<AtomicRenderUnit> implements Set<AtomicRenderUnit> {
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
      if (renderUnit is SquaredDistanceSortable) {
        return new RenderUnitNode(renderUnit, renderUnit.squaredDistance);
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
      new _RenderUnitIterator(new _RenderTreeLeafIterator(renderSortTree));

  int get length => _renderUnitsNodes.length;

  bool add(AtomicRenderUnit renderUnit) {
    if (!_renderUnitsNodes.containsKey(renderUnit)) {
      _renderUnitsNodes[renderUnit] = renderSortTree.process(renderUnit);

      return true;
    } else {
      return false;
    }
  }

  bool contains(Object value) => _renderUnitsNodes.containsKey(value);

  AtomicRenderUnit lookup(Object value) {
    if (value is AtomicRenderUnit && _renderUnitsNodes.containsKey(value)) {
      return _renderUnitsNodes[value].renderUnit;
    } else {
      return null;
    }
  }

  bool remove(Object value) {
    if (value is AtomicRenderUnit) {
      final node = _renderUnitsNodes[value];

      if (node != null) {
        _renderUnitsNodes.remove(value);

        return node.disconnect();
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Set<AtomicRenderUnit> toSet() => new SortedRenderBin(renderSortTree.toRenderSortTree());
}

class _RenderTreeLeafIterator
    implements Iterator<RenderUnitNode>, RenderTreeVisitor {
  final RenderSortTreeNode rootNode;

  RenderUnitNode _currentNode = null;

  bool _moveDown = true;

  bool _terminated = false;

  _RenderTreeLeafIterator(this.rootNode) {
    _currentNode = rootNode;
    rootNode.sortTree();
  }

  RenderUnitNode get current => _currentNode;

  bool moveNext() {
    _currentNode.accept(this);

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

  AtomicRenderUnit get current => leafIterator.current.renderUnit;

  bool moveNext() => leafIterator.moveNext();
}
