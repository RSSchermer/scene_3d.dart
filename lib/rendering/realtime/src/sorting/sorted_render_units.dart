part of rendering.realtime.sorting;

/// View on a render sort tree as an ordered set of [AtomicRenderUnit]s.
///
/// Views the [renderTree] as a set of the tree's [AtomicRenderUnit]s in depth
/// first order. Changes to the [renderTree] will result in changes to these
/// [SortedRenderUnits] and vice versa.
///
/// Iterating over the values in a [SortedRenderUnits] set always presents the
/// [AtomicRenderUnit]s contained in the set in the order defined by the
/// [renderTree].
class SortedRenderUnits<U extends AtomicRenderUnit> extends SetBase<U> {
  /// The render sort tree viewed by these [SortedRenderUnits].
  final BranchingNode<U> renderTree;

  final Map<U, RenderUnitNode<U>> _renderUnitsNodes = {};

  /// Instantiates a new instance of [SortedRenderUnits] as a view on the
  /// given [renderTree].
  SortedRenderUnits(this.renderTree);

  Iterator<U> get iterator =>
      new _RenderUnitIterator<U>(new _RenderTreeLeafIterator<U>(renderTree));

  int get length => _renderUnitsNodes.length;

  bool add(U renderUnit) {
    if (!_renderUnitsNodes.containsKey(renderUnit)) {
      _renderUnitsNodes[renderUnit] = renderTree.process(renderUnit);

      return true;
    } else {
      return false;
    }
  }

  bool contains(Object value) => _renderUnitsNodes.containsKey(value);

  U lookup(Object value) {
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

  Set<U> toSet() => new SortedRenderUnits<U>(renderTree.toRenderTree());
}
