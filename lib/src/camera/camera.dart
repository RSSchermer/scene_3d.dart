part of camera;

abstract class Camera {
  /// A mutable label for this [Camera].
  String name;

  Transform get transform;

  /// A [Matrix4] transformation which projects camera space coordinates onto
  /// clip space coordinates.
  Matrix4 get cameraToClip;

  /// A [Matrix4] transformation which transforms world space coordinates into
  /// camera space coordinates.
  Matrix4 get worldToCamera;

  /// Combines the [cameraToClip] and the [worldToCamera] into a single
  /// [Matrix4] transformation.
  Matrix4 get worldToClip;
}
