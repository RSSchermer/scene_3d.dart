library transform;

import 'package:bagl/math.dart';

import 'quaternion.dart';

class Transform {
  Transform _parentTransform;

  Set<Transform> _childTransforms = new Set();

  Vector3 _translation = new Vector3(0.0, 0.0, 0.0);

  Quaternion _rotation = new Quaternion(0.0, 0.0, 0.0, 1.0);

  Vector3 _scaling = new Vector3(1.0, 1.0, 1.0);

  Vector3 _position = new Vector3(0.0, 0.0, 0.0);

  Vector3 _right = new Vector3(1.0, 0.0, 0.0);

  Vector3 _up = new Vector3(0.0, 1.0, 0.0);

  Vector3 _forward = new Vector3(0.0, 0.0, 1.0);

  Matrix4 _translationMatrix = new Matrix4.identity();

  Matrix4 _rotationMatrix = new Matrix4.identity();

  Matrix4 _scalingMatrix = new Matrix4.identity();

  Matrix4 _positionToWorld = new Matrix4.identity();

  Matrix3 _directionToWorld = new Matrix3.identity();

  Transform get parentTransform => _parentTransform;

  void set parentTransform(Transform value) {
    if (_parentTransform != null) {
      _parentTransform._childTransforms.remove(this);
    }

    _parentTransform = value;
    _clearCacheParentDerived();

    if (value != null) {
      value._childTransforms.add(this);
    }
  }

  /// The translation applied by this [Transform].
  ///
  /// The first coordinate represents the translation in the `x` direction, the
  /// second coordinate represents the translation in the `y` direction and the
  /// third coordinate represents the translation in the `z` direction.
  ///
  /// The translation is relative to the [parentTransform].
  Vector3 get translation => _translation;

  void set translation(Vector3 value) {
    _translation = value;
    _translationMatrix = null;
    _position = null;
    _positionToWorld = null;

    for (var child in _childTransforms) {
      child._clearCacheParentPositionDerived();
    }
  }

  /// The rotation applied by this [Transform].
  ///
  /// The rotation is relative to the [parentTransform].
  Quaternion get rotation => _rotation;

  void set rotation(Quaternion value) {
    _rotation = value;
    _rotationMatrix = null;
    _right = null;
    _up = null;
    _forward = null;
    _positionToWorld = null;
    _directionToWorld = null;

    for (var child in _childTransforms) {
      child._clearCacheParentDerived();
    }
  }

  /// The scaling applied by this [Transform].
  ///
  /// The scaling is relative to the [parentTransform].
  Vector3 get scaling => _scaling;

  void set scaling(Vector3 value) {
    _scaling = value;
    _scalingMatrix = null;
    _right = null;
    _up = null;
    _forward = null;
    _positionToWorld = null;
    _directionToWorld = null;

    for (var child in _childTransforms) {
      child._clearCacheParentDerived();
    }
  }

  /// The position in world space of the origin of this [Transform]'s local
  /// space.
  Vector3 get position {
    if (_position == null) {
      if (_parentTransform != null) {
        final local = new Vector4(
            _translation.x, _translation.y, _translation.z, 1.0);
        final transformed = _parentTransform.positionToWorld * local;

        _position = new Vector3(transformed.x, transformed.y, transformed.z);
      } else {
        _position = _translation;
      }
    }

    return _position;
  }

  /// The direction in world space of the x-axis of this [Transform]'s local
  /// space.
  Vector3 get right {
    if (_right == null) {
      if (parentTransform == null && scaling.x == 1.0 && scaling.y == 1.0 && scaling.z == 1.0) {
        _right = directionToWorld * new Vector3(1.0, 0.0, 0.0);
      } else {
        _right = (directionToWorld * new Vector3(1.0, 0.0, 0.0)).unitVector;
      }
    }

    return _right;
  }

  /// The direction in world space of the y-axis of this [Transform]'s local
  /// space.
  Vector3 get up {
    if (_up == null) {
      if (parentTransform == null && scaling.x == 1.0 && scaling.y == 1.0 && scaling.z == 1.0) {
        _up = directionToWorld * new Vector3(0.0, 1.0, 0.0);
      } else {
        _up = (directionToWorld * new Vector3(0.0, 1.0, 0.0)).unitVector;
      }
    }

    return _up;
  }

  /// The direction in world space of the z-axis of this [Transform]'s local
  /// space.
  Vector3 get forward {
    if (_forward == null) {
      if (parentTransform == null && scaling.x == 1.0 && scaling.y == 1.0 && scaling.z == 1.0) {
        _forward = directionToWorld * new Vector3(0.0, 0.0, 1.0);
      } else {
        _forward = (directionToWorld * new Vector3(0.0, 0.0, 1.0)).unitVector;
      }
    }

    return _forward;
  }

  /// Matrix that transforms positions local to this [Transform] into world
  /// positions.
  ///
  /// Combines this [Transform]'s [scaling], [rotation], [translation] and
  /// [parentTransform] into a single [Matrix4] transformation. When this
  /// transform is applied to a [Vector4] that represents a position local to
  /// this [Transform], then this position's coordinates are transformed into
  /// world coordinates.
  Matrix4 get positionToWorld {
    if (_positionToWorld == null) {
      _translationMatrix ??=
          new Matrix4.translation(translation.x, translation.y, translation.z);
      _rotationMatrix ??= rotation.asMatrix4();
      _scalingMatrix ??= new Matrix4.scale(scaling.x, scaling.y, scaling.z);
      _positionToWorld =
          _translationMatrix * _rotationMatrix * _scalingMatrix;

      if (_parentTransform != null) {
        _positionToWorld = _parentTransform.positionToWorld * _positionToWorld;
      }
    }

    return _positionToWorld;
  }

  /// Matrix that transforms directions local to this [Transform] into world
  /// directions.
  ///
  /// Combines this [Transform]'s [scaling], [rotation] and [parentTransform]
  /// into a single [Matrix3] transformation. When this transform is applied to
  /// a [Vector3] that represents a direction local to this [Transform], then
  /// this direction is transformed into world direction.
  Matrix3 get directionToWorld {
    if (_directionToWorld == null) {
      final w = positionToWorld;
      final m = new Matrix3(
          w.r0c0,
          w.r0c1,
          w.r0c2,
          w.r1c0,
          w.r1c1,
          w.r1c2,
          w.r2c0,
          w.r2c1,
          w.r2c2);

      if (_parentTransform == null && _scaling.x == 1 && _scaling.y == 1 && _scaling.z == 1) {
        _directionToWorld = m;
      } else {
        _directionToWorld = m.inverse.transpose;
      }
    }

    return _directionToWorld;
  }

  void _clearCacheParentPositionDerived() {
    _position = null;
    _positionToWorld = null;

    for (var child in _childTransforms) {
      child._clearCacheParentPositionDerived();
    }
  }

  void _clearCacheParentDerived() {
    _position = null;
    _right = null;
    _up = null;
    _forward = null;
    _positionToWorld = null;
    _directionToWorld = null;

    for (var child in _childTransforms) {
      child._clearCacheParentDerived();
    }
  }
}
