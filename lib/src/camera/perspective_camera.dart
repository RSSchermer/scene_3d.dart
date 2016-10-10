part of camera;

class PerspectiveCamera implements Camera {
  String name;

  double _fovVertical;

  double _aspectRatio;

  double _near;

  double _far;

  Vector3 _position = new Vector3(0.0, 0.0, 0.0);

  Quaternion _viewDirection = new Quaternion(0.0, 0.0, 0.0, 1.0);

  Matrix4 _translationMatrix = new Matrix4.identity();

  Matrix4 _projectionTransform;

  Matrix4 _viewTransform;

  Matrix4 _viewProjectionTransform;

  PerspectiveCamera(
      double fovVertical, double aspectRatio, double near, double far)
      : _fovVertical = fovVertical,
        _aspectRatio = aspectRatio,
        _near = near,
        _far = far {
    if (near <= 0.0) {
      throw new ArgumentError('The near distance must be greater than 0.');
    }

    if (far <= near) {
      throw new ArgumentError('The far distance must be greater than the near '
          'distance');
    }
  }

  /// The vertical field-of-view in radians.
  double get fovVertical => _fovVertical;

  void set fovVertical(double value) {
    _fovVertical = value;
    _projectionTransform = null;
    _viewProjectionTransform = null;
  }

  /// The `horizontal / vertical` field-of-view aspect ratio.
  double get aspectRatio => _aspectRatio;

  void set aspectRatio(double value) {
    _aspectRatio = value;
    _projectionTransform = null;
    _viewProjectionTransform = null;
  }

  /// The distance to the near viewing plane.
  ///
  /// Geometry before this plane will be clipped.
  double get near => _near;

  void set near(double value) {
    if (value <= 0.0) {
      throw new ArgumentError('The near distance must be greater than 0.');
    }

    if (value >= far) {
      throw new ArgumentError('The near distance must be smaller than the far '
          'distance.');
    }

    _near = value;
    _projectionTransform = null;
    _viewProjectionTransform = null;
  }

  /// The distance to the far viewing plane.
  ///
  /// Geometry beyond this plane will be clipped.
  double get far => _far;

  void set far(double value) {
    if (value <= near) {
      throw new ArgumentError('The far distance must be greater than the near '
          'distance');
    }

    _far = value;
    _projectionTransform = null;
    _viewProjectionTransform = null;
  }

  Vector3 get position => _position;

  void set position(Vector3 value) {
    _position = value;
    _translationMatrix = new Matrix4.translation(value.x, value.y, value.z);
    _viewTransform = null;
    _viewProjectionTransform = null;
  }

  Quaternion get viewDirection => _viewDirection;

  void set viewDirection(Quaternion value) {
    _viewDirection = value;
    _viewTransform = null;
    _viewProjectionTransform = null;
  }

  /// The horizontal field-of-view in radians.
  double get fovHorizontal => _fovVertical * _aspectRatio;

  Matrix4 get viewTransform {
    _viewTransform ??= (_translationMatrix * viewDirection.asMatrix4()).inverse;

    return _viewTransform;
  }

  Matrix4 get projectionTransform {
    _projectionTransform ??=
    new Matrix4.perspective(_fovVertical, _aspectRatio, _near, _far);

    return _projectionTransform;
  }

  Matrix4 get viewProjectionTransform {
    _viewProjectionTransform ??= projectionTransform * viewTransform;

    return _viewProjectionTransform;
  }
}
