part of bagl_forward_rendering;

/// A collection of [AtomicRenderUnit]s that together render a single object.
abstract class ObjectView extends Iterable<AtomicRenderUnit> {
  /// The object represented by this [ObjectView].
  Object get object;

  /// The [Scene] that serves as the context for the [object].
  Scene get scene;

  /// Updates the [AtomicRenderUnit]s that belong to this [ObjectView] to
  /// reflect the current state of the [object] and its context (e.g. a
  /// [Scene]).
  ViewChangeRecord update(Camera camera);
}

/// Records the [AtomicRenderUnit]s that were added or removed from an
/// [ObjectView].
class ViewChangeRecord {
  /// The [AtomicRenderUnit]s that were added as part of this change.
  final Set<AtomicRenderUnit> additions;

  /// The [AtomicRenderUnit]s that were removed as part of this change.
  final Set<AtomicRenderUnit> removals;

  /// Instantiates a new [ViewChangeRecord] for a change with the given
  /// [additions] and [removals].
  ViewChangeRecord(this.additions, this.removals);

  ViewChangeRecord.empty()
      : additions = new Set(),
        removals = new Set();
}

/// A set of [ObjectView]s.
///
/// Collects the [AtomicRenderUnit]s [ObjectView]s it contains in the
/// [renderBin].
class ViewSet extends SetBase<ObjectView> implements Set<ObjectView> {
  /// The aggregated [AtomicRenderUnit]s of these [ViewSet].
  final Set<AtomicRenderUnit> renderBin;

  final Set<ObjectView> _delegate = new Set();

  /// Instantiates a new [ViewSet] instance for the given [renderBin].
  ViewSet(this.renderBin);

  Iterator<ObjectView> get iterator => _delegate.iterator;

  int get length => _delegate.length;

  bool contains(Object value) => _delegate.contains(value);

  ObjectView lookup(Object value) => _delegate.lookup(value);

  bool add(ObjectView view) {
    final success = _delegate.add(view);

    if (success) {
      renderBin.addAll(view);
    }

    return success;
  }

  bool remove(Object item) {
    final success = _delegate.remove(item);

    if (success) {
      renderBin.removeAll(item);
    }

    return success;
  }

  /// Updates all of the [ObjectView]s contained in these [ViewSet].
  void update(Camera camera) {
    for (var view in _delegate) {
      final changes = view.update(camera);

      renderBin.addAll(changes.additions);
      renderBin.removeAll(changes.removals);
    }
  }

  ViewSet toSet() => new ViewSet(new Set()..addAll(renderBin));
}

/// Creates [View]s for objects in a scene.
abstract class ViewFactory {
  /// Creates a new [View] for the [object] in the context of the [scene].
  ///
  /// Throws an [ArgumentError] if this [ViewFactory] is unable to make a [View]
  /// for the [object].
  ObjectView makeView(Object object, Scene scene);
}

/// Chainable [ViewFactory].
///
/// If a [ChainableViewFactory] is process a [makeView] request for an object,
/// it will pass the request along to its [nextFactory].
abstract class ChainableViewFactory extends ViewFactory {
  /// The next [ViewFactory] that a [makeView] will be passed to.
  ViewFactory nextFactory;

  ObjectView makeView(Object object, Scene scene) {
    if (nextFactory != null) {
      return nextFactory.makeView(object, scene);
    } else {
      throw new ArgumentError('None of the view factories in this chain could '
          'create a view for object "$object".');
    }
  }
}
