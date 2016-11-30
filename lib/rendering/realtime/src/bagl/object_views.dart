part of rendering.realtime.bagl;

/// A collection of [BaGLRenderUnit]s that together render a single object.
abstract class View<U extends AtomicRenderUnit> extends Iterable<U> {
  /// The object represented by this [View].
  Object get object;

  /// The [Scene] that serves as the context for the [object].
  Scene get scene;

  /// Updates the [AtomicRenderUnit]s contained in this [View] to reflect the
  /// current state of the [object] and its context (e.g. a [Scene]).
  ViewChangeRecord<U> update(Camera camera);
}

/// Records the [AtomicRenderUnit]s that were added or removed from an
/// [View].
class ViewChangeRecord<U extends AtomicRenderUnit> {
  /// The [AtomicRenderUnit]s that were added as part of this change.
  final Set<U> additions;

  /// The [AtomicRenderUnit]s that were removed as part of this change.
  final Set<U> removals;

  /// Instantiates a new [ViewChangeRecord] for a change with the given
  /// [additions] and [removals].
  ViewChangeRecord(this.additions, this.removals);

  ViewChangeRecord.empty()
      : additions = new Set(),
        removals = new Set();
}

/// A set of [View]s.
///
/// Collects the [AtomicRenderUnit]s contained in the [View]s in its
/// [renderBin].
class ViewSet<U extends AtomicRenderUnit> extends SetBase<View<U>>
    implements Set<View<U>> {
  /// The aggregated [AtomicRenderUnit]s of these [ViewSet].
  final Set<U> renderBin;

  final Set<View<U>> _delegate = new Set();

  /// Instantiates a new [ViewSet] instance for the given [renderBin].
  ViewSet(this.renderBin);

  Iterator<View<U>> get iterator => _delegate.iterator;

  int get length => _delegate.length;

  bool contains(Object value) => _delegate.contains(value);

  View<U> lookup(Object value) => _delegate.lookup(value);

  bool add(View<U> view) {
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

  /// Updates all of the [View]s contained in these [ViewSet].
  void update(Camera camera) {
    for (var view in _delegate) {
      final changes = view.update(camera);

      renderBin.addAll(changes.additions);
      renderBin.removeAll(changes.removals);
    }
  }

  ViewSet<U> toSet() => new ViewSet<U>(new Set()..addAll(renderBin));
}

/// Creates [View]s for objects in a scene.
abstract class ViewFactory<U extends AtomicRenderUnit> {
  /// Creates a new [View] for the [object] in the context of the [scene].
  ///
  /// Throws an [ArgumentError] if this [ViewFactory] is unable to make a [View]
  /// for the [object].
  View<U> makeView(Object object, Scene scene);
}

/// Chainable [ViewFactory].
///
/// If a [ChainableViewFactory] is process a [makeView] request for an object,
/// it will pass the request along to its [nextFactory].
abstract class ChainableViewFactory<U extends AtomicRenderUnit>
    extends ViewFactory<U> {
  /// The next [ViewFactory] that a [makeView] will be passed to.
  ViewFactory<U> nextFactory;

  View<U> makeView(Object object, Scene scene) {
    if (nextFactory != null) {
      return nextFactory.makeView(object, scene);
    } else {
      throw new ArgumentError('None of the view factories in this chain could '
          'create a view for object "$object".');
    }
  }
}
