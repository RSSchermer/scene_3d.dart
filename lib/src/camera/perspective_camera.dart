part of camera;

class PerspectiveCamera implements Camera {
  String name;

  final Transform transform = new Transform();

  double _fovVertical;

  double _aspectRatio;

  double _near;

  double _far;

  Matrix4 _cameraToClip;

  Matrix4 _worldToCamera;

  Matrix4 _worldToClip;

  Matrix4 _positionToWorldPrevious;

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
    _cameraToClip = null;
    _worldToClip = null;
  }

  /// The `horizontal / vertical` field-of-view aspect ratio.
  double get aspectRatio => _aspectRatio;

  void set aspectRatio(double value) {
    _aspectRatio = value;
    _cameraToClip = null;
    _worldToClip = null;
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
    _cameraToClip = null;
    _worldToClip = null;
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
    _cameraToClip = null;
    _worldToClip = null;
  }

  /// The horizontal field-of-view in radians.
  double get fovHorizontal => _fovVertical * _aspectRatio;

  Matrix4 get worldToCamera {
    if (_worldToCamera == null || !identical(transform.positionToWorld, _positionToWorldPrevious)) {
      _worldToCamera = transform.positionToWorld.inverse;
    }

    return _worldToCamera;
  }

  Matrix4 get cameraToClip {
    _cameraToClip ??=
    new Matrix4.perspective(_fovVertical, _aspectRatio, _near, _far);

    return _cameraToClip;
  }

  Matrix4 get worldToClip {
    _worldToClip ??= cameraToClip * worldToCamera;

    return _worldToClip;
  }
}
