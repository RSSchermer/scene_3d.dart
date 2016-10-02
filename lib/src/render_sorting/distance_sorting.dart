part of render_sorting;

/// Intended to be mixed into [AtomicRenderUnit] classes that may be used in
/// render trees that use a sort key based on the square of the distance between
/// the geometry rendered by the [AtomicRenderUnit] and the camera.
///
/// Sorting by distance to the camera (depth sorting) is may be required for
/// correctly rendering transparent geometry (furthest first) and may improve
/// performance by taking advantage of early-z optimization when rendering
/// opaque geometry (closest first).
///
/// The square of the distance is used, rather than just the distance itself, as
/// calculating the distance between an object in the camera typically involves
/// taking the hypotenuse of a vector representing the position of the object
/// and a vector representing the position of the camera. However, this involves
/// an expensive square root operation. By using the squared distance instead,
/// this square root operation can typically be avoided, thus resulting in
/// better performance, while still resulting in the same sort order.
abstract class SquaredDistanceSortable extends AtomicRenderUnit {
  /// The square of the distance between the [AtomicRenderUnit]'s geometry and
  /// the camera.
  ObservableValue<double> get squaredDistance;
}
