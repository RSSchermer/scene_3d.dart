part of rendering;

/// A [View] that does not render anything.
///
/// Used for objects in a [Scene] for which no geometry should be drawn. For
/// example, often no geometry needs to be rendered for a scene's cameras or
/// lights.
class NullView implements View {
  final bool isTransparent = false;

  void render(Camera camera) {}

  void decommission() {}
}

typedef bool ViewFactoryMatcher(Object);

/// [ChainableViewFactory] that makes [NullView]s.
///
/// A [matcher] function can be specified to determine which objects this
/// factory should make [NullView]s for:
///
///     // Will make a NullView for any Camera type objects, otherwise passes
///     // on the request to the nextFactory.
///     var cameraFactory = new NullViewFactory((o) => o is Camera);
///
class NullViewFactory extends ChainableViewFactory {
  final ViewFactoryMatcher matcher;

  NullViewFactory(this.matcher);

  View makeView(Object object) {
    if (matcher(object)) {
      return new NullView();
    } else {
      return super.makeView(object);
    }
  }
}
