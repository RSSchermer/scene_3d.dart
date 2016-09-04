part of camera;

class OrthographicCamera implements Camera {
  String name;

  double _magnificationVertical;

  double _aspectRatio;

  double _near;

  double _far;

  Vector4 _position = new Vector4(0.0, 0.0, 0.0, 1.0);

  Quaternion _viewDirection = new Quaternion(0.0, 0.0, 0.0, 1.0);

  Matrix4 _translationMatrix = new Matrix4.identity();

  Matrix4 _projectionTransform;

  Matrix4 _viewTransform;

  Matrix4 _viewProjectionTransform;

  OrthographicCamera(
      magnificationVertical, aspectRatio, near, far)
      : _magnificationVertical = magnificationVertical,
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

  /// The vertical magnification factor.
  double get magnificationVertical => _magnificationVertical;

  void set magnificationVertical(double value) {
    _magnificationVertical = value;
    _projectionTransform = null;
    _viewProjectionTransform = null;
  }

  /// The `horizontal / vertical` magnification aspect ratio.
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

  Vector4 get position => _position;

  void set position(Vector4 value) {
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

  /// The horizontal magnification factor.
  double get magnificationHorizontal => magnificationVertical * aspectRatio;

  Matrix4 get viewTransform {
    _viewTransform ??= (_translationMatrix * viewDirection.asMatrix4()).inverse;

    return _viewTransform;
  }

  Matrix4 get projectionTransform {
    if (projectionTransform == null) {
      final h = magnificationHorizontal;
      final v = magnificationVertical;

      _projectionTransform = new Matrix4.orthographic(-h, h, v, -v, near, far);
    }

    return _projectionTransform;
  }

  Matrix4 get viewProjectionTransform {
    _viewProjectionTransform ??= projectionTransform * viewTransform;

    return _viewProjectionTransform;
  }
}
