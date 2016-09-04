part of rendering;

/// Creates [View]s for objects in a scene.
abstract class ViewFactory {
  /// Creates a new [View] for the [object].
  ///
  /// Throws an [ArgumentError] if this [ViewFactory] is unable to make a [View]
  /// for the [object].
  View makeView(Object object);
}

/// Chainable [ViewFactory].
///
/// If a [ChainableViewFactory] is process a [makeView] request for an object,
/// it will pass the request along to its [nextFactory].
abstract class ChainableViewFactory extends ViewFactory {
  /// The next [ViewFactory] that a [makeView] will be passed to.
  ViewFactory nextFactory;

  View makeView(Object object) {
    if (nextFactory != null) {
      return nextFactory.makeView(object);
    } else {
      throw new ArgumentError('None of the view factories in this chain could '
          'create a view for object "$object".');
    }
  }
}
