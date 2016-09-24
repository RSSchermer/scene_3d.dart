part of render_sorting;

/// Intended to be mixed into [AtomicRenderUnit] classes that may be used in
/// render trees that use a sort key based on the distance between the geometry
/// rendered by the [AtomicRenderUnit] and the camera.
///
/// Sorting by distance to the camera (depth sorting) is may be required for
/// correctly rendering transparent geometry (furthest first) and may improve
/// performance by taking advantage of early-z optimization when rendering
/// opaque geometry (closest first).
abstract class DistanceSortable extends AtomicRenderUnit {
  ObservableValue<double> get distance;
}
