part of camera;

abstract class Camera {
  /// A mutable label for this [Camera].
  String name;

  /// The position of this [Camera] in world space.
  Vector4 get position;

  void set position(Vector4 position);

  /// A [Quaternion] representing the orientation of this [Camera]'s view
  /// direction in world space.
  ///
  /// The unrotated view direction is along the Z axis in the negative Z
  /// direction in world space.
  Quaternion get viewDirection;

  void set viewDirection(Quaternion quaternion);

  /// A [Matrix4] transformation which projects view space coordinates onto clip
  /// space coordinates.
  Matrix4 get projectionTransform;

  /// A [Matrix4] transformation which transforms world space coordinates into
  /// view space coordinates.
  Matrix4 get viewTransform;

  /// Combines the [projectionTransform] and the [viewTransform] into a single
  /// [Matrix4] transformation.
  Matrix4 get viewProjectionTransform;
}
