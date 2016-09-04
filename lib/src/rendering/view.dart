part of rendering;

/// A renderable view of a single geometric unit.
abstract class View {
  /// Whether or not the geometry rendered by this view is completely or
  /// partially transparent.
  ///
  /// Geometry is considered transparent when it's colors should be blended with
  /// the colors of geometry appearing behind it.
  bool get isTransparent;

  /// Renders this [View]'s geometry from the perspective of the [camera].
  ///
  /// Typically draws a sequence of geometric primitives (points, lines or
  /// triangles) to a render target.
  void render(Camera camera);

  /// Should be called when this [View] is no longer in use.
  ///
  /// Hook that may be used to deprovision any resources that may have used
  /// to support this [View].
  void decommission();
}
