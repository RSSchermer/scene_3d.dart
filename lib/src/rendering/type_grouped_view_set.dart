part of rendering;

/// A [Set] of [View]s which are grouped by `runtimeType` when iterating over
/// them.
///
/// This data structure was created based on the assumption that sequentially
/// rendering [View]s with the same `runtimeType` requires fewer rendering
/// backend state changes than sequentially rendering [View]s with different
/// `runtimeType`s. As rendering backend state changes tend to be relatively
/// expensive, rendering [View]s in this order should improve rendering
/// performance.
class TypeGroupedViewSet extends SetBase<View> implements Set<View> {
  final Map<Type, Set<View>> _typeViewSets = {};

  /// Creates an empty [TypeGroupedViewSet].
  TypeGroupedViewSet();

  /// Creates a [TypeGroupedViewSet] that contains all [views].
  factory TypeGroupedViewSet.from(Iterable<View> views) =>
      new TypeGroupedViewSet()..addAll(views);

  int get length {
    var s = 0;

    _typeViewSets.forEach((type, viewSet) {
      s += viewSet.length;
    });

    return s;
  }

  Iterator<View> get iterator {
    if (_typeViewSets.isNotEmpty) {
      return new _TypeGroupedViewSetIterator(this);
    } else {
      return new _EmptyViewIterator();
    }
  }

  bool add(View view) {
    final type = view.runtimeType;

    if (_typeViewSets.containsKey(type)) {
      return _typeViewSets[type].add(view);
    } else {
      _typeViewSets[type] = new Set()..add(view);

      return true;
    }
  }

  bool contains(Object value) {
    final typeViewSet = _typeViewSets[value.runtimeType];

    if (typeViewSet != null) {
      return typeViewSet.contains(value);
    } else {
      return false;
    }
  }

  void clear() {
    _typeViewSets.clear();
  }

  View lookup(Object object) {
    final typeViewSet = _typeViewSets[object.runtimeType];

    if (typeViewSet != null) {
      return typeViewSet.lookup(object);
    } else {
      return null;
    }
  }

  bool remove(Object value) {
    final type = value.runtimeType;
    final typeViewSet = _typeViewSets[type];

    if (typeViewSet != null) {
      final success = typeViewSet.remove(value);

      if (typeViewSet.isEmpty) {
        _typeViewSets.remove(type);
      }

      return success;
    } else {
      return false;
    }
  }

  TypeGroupedViewSet toSet() => new TypeGroupedViewSet()..addAll(this);
}

class _TypeGroupedViewSetIterator implements Iterator<View> {
  final Iterator<Set<View>> _viewSetsIterator;

  Iterator<View> _currentViewSetIterator;

  _TypeGroupedViewSetIterator(TypeGroupedViewSet typeGroupedViewSet)
      : _viewSetsIterator = typeGroupedViewSet._typeViewSets.values.iterator {
    _viewSetsIterator.moveNext();
    _currentViewSetIterator = _viewSetsIterator.current.iterator;
  }

  View get current => _currentViewSetIterator.current;

  bool moveNext() {
    if (_currentViewSetIterator.moveNext()) {
      return true;
    } else {
      if (_viewSetsIterator.moveNext()) {
        _currentViewSetIterator = _viewSetsIterator.current.iterator;

        return _currentViewSetIterator.moveNext();
      } else {
        return false;
      }
    }
  }
}

class _EmptyViewIterator extends Iterator<View> {
  final View current = null;

  bool moveNext() => false;
}
