part of render_sorting;

/// View on a render sort tree as an ordered set of [AtomicRenderUnit]s.
///
/// Views the [renderSortTree] as a set of the tree's [AtomicRenderUnit]s in
/// depth first order. Changes to the [renderSortTree] will result in changes to
/// these [RenderSortTreeUnits] and vice versa.
class RenderSortTreeUnits extends SetBase<AtomicRenderUnit>
    implements Set<AtomicRenderUnit> {
  /// The render sort tree viewed by these [RenderSortTreeUnits].
  final BranchingNode renderSortTree;

  final Map<AtomicRenderUnit, RenderUnitNode> _renderUnitsNodes = {};

  /// Instantiates a new instance of [RenderSortTreeUnits] as a view on the
  /// given [renderSortTree].
  RenderSortTreeUnits(this.renderSortTree);

  factory RenderSortTreeUnits.defaultSorting() {
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

    return new RenderSortTreeUnits(root);
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

  Set<AtomicRenderUnit> toSet() =>
      new RenderSortTreeUnits(renderSortTree.toRenderSortTree());
}
