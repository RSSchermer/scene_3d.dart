part of rendering.realtime.bagl;

/// A [View] that does not consist of any [AtomicRenderUnit]s and thus does not
/// render anything.
///
/// Used for objects in a [Scene] for which no geometry should be drawn. For
/// example, often no geometry needs to be rendered for a scene's cameras or
/// lights.
class NullView extends DelegatingIterable<BaGLRenderUnit>
    implements ObjectView {
  final Object object;

  final Scene scene;

  final Iterable<BaGLRenderUnit> delegate = const [];

  /// Instantiates a new [NullView] for the given [object].
  NullView(this.object, this.scene);

  ViewChangeRecord update(Camera camera) => new ViewChangeRecord.empty();
}

typedef bool ViewFactoryMatcher(Object);

/// [ChainableViewFactory] that makes [NullView]s.
///
/// A [matcher] function is used to determine which objects this factory should
/// make [NullView]s for:
///
///     // Will make a NullView for any Camera type objects, otherwise passes
///     // on the request to the nextFactory.
///     var cameraFactory = new NullViewFactory((o) => o is Camera);
///
class NullViewFactory extends ChainableViewFactory {
  /// The function used to match this [NullViewFactory] to scene objects.
  final ViewFactoryMatcher matcher;

  /// Instantiates a new [NullViewFactory] with the given [matcher].
  NullViewFactory(this.matcher);

  ObjectView makeView(Object object, Scene scene) {
    if (matcher(object)) {
      return new NullView(object, scene);
    } else {
      return super.makeView(object, scene);
    }
  }
}
