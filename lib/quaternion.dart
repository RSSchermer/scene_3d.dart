/// Provides a [Quaternion] data structure for representing 3D rotations.
library quaternion;

import 'dart:math';

import 'package:bagl/math.dart' show Vector3, Vector4, Matrix3, Matrix4;

/// Quaternion data structure.
///
/// Used to represent 3D rotations.
class Quaternion {
  /// The `X` component of this [Quaternion].
  final double x;

  /// The `Y` component of this [Quaternion].
  final double y;

  /// The `Z` component of this [Quaternion].
  final double z;

  /// The `W` component of this [Quaternion].
  final double w;

  double _squareSum;

  double _magnitude;

  Quaternion _unitQuaternion;

  Matrix3 _matrix3;

  Matrix4 _matrix4;

  /// Instantiates a new [Quaternion].
  Quaternion(this.x, this.y, this.z, this.w);

  /// Instantiates a new [Quaternion] from the [list].
  ///
  /// Throws an [ArgumentError] if the `length` of the list does not equal `4`.
  factory Quaternion.fromList(List<double> list) {
    if (list.length != 4) {
      throw new ArgumentError('Can only instantiate a Quaternion from a list '
          'of length 4.');
    }

    return new Quaternion(list[0], list[1], list[2], list[3]);
  }

  /// Creates a new [Quaternion] representation of a rotation of [angle] radians
  /// around the [axis].
  ///
  /// The [axis] is assumed to be a unit vector.
  factory Quaternion.fromAxisAngle(Vector3 axis, double angle) {
    final halfAngle = angle / 2;
    final sinHalfAngle = sin(halfAngle);

    return new Quaternion(axis.x * sinHalfAngle, axis.y * sinHalfAngle,
        axis.z * sinHalfAngle, cos(halfAngle));
  }

  /// Creates a new [Quaternion] representation of a rotation described by Euler
  /// angles, applied in `XYZ` order.
  ///
  /// Represents a rotation that can be constructed by first rotating [angleX],
  /// radians around the `X` axis, then rotating [angleY] radians around the `Y`
  /// axis, and finally rotating [angleZ] radians around the `Z` axis.
  ///
  /// Note that applying the rotation angles in a different order can result
  /// in a different final rotation. See also [fromEulerAnglesXZY],
  /// [fromEulerAnglesYXZ], [fromEulerAnglesYZX], [fromEulerAnglesZXY] and
  /// [fromEulerAnglesZYX].
  factory Quaternion.fromEulerAnglesXYZ(
      double angleX, double angleY, double angleZ) {
    final cosX = cos(angleX / 2);
    final cosY = cos(angleY / 2);
    final cosZ = cos(angleZ / 2);
    final sinX = sin(angleX / 2);
    final sinY = sin(angleY / 2);
    final sinZ = sin(angleZ / 2);

    return new Quaternion(
        sinX * cosY * cosZ + cosX * sinY * sinZ,
        cosX * sinY * cosZ - sinX * cosY * sinZ,
        cosX * cosY * sinZ + sinX * sinY * cosZ,
        cosX * cosY * cosZ - sinX * sinY * sinZ);
  }

  /// Creates a new [Quaternion] representation of a rotation described by Euler
  /// angles, applied in `XZY` order.
  ///
  /// Represents a rotation that can be constructed by first rotating [angleX],
  /// radians around the `X` axis, then rotating [angleZ] radians around the `Z`
  /// axis, and finally rotating [angleY] radians around the `Y` axis.
  ///
  /// Note that applying the rotation angles in a different order can result
  /// in a different final rotation. See also [fromEulerAnglesXYZ],
  /// [fromEulerAnglesYXZ], [fromEulerAnglesYZX], [fromEulerAnglesZXY] and
  /// [fromEulerAnglesZYX].
  factory Quaternion.fromEulerAnglesXZY(
      double angleX, double angleZ, double angleY) {
    final cosX = cos(angleX / 2);
    final cosY = cos(angleY / 2);
    final cosZ = cos(angleZ / 2);
    final sinX = sin(angleX / 2);
    final sinY = sin(angleY / 2);
    final sinZ = sin(angleZ / 2);

    return new Quaternion(
        sinX * cosY * cosZ - cosX * sinY * sinZ,
        cosX * sinY * cosZ - sinX * cosY * sinZ,
        cosX * cosY * sinZ + sinX * sinY * cosZ,
        cosX * cosY * cosZ + sinX * sinY * sinZ);
  }

  /// Creates a new [Quaternion] representation of a rotation described by Euler
  /// angles, applied in `YXZ` order.
  ///
  /// Represents a rotation that can be constructed by first rotating [angleY],
  /// radians around the `Y` axis, then rotating [angleX] radians around the `X`
  /// axis, and finally rotating [angleZ] radians around the `Z` axis.
  ///
  /// Note that applying the rotation angles in a different order can result
  /// in a different final rotation. See also [fromEulerAnglesXYZ],
  /// [fromEulerAnglesXZY], [fromEulerAnglesYZX], [fromEulerAnglesZXY] and
  /// [fromEulerAnglesZYX].
  factory Quaternion.fromEulerAnglesYXZ(
      double angleY, double angleX, double angleZ) {
    final cosX = cos(angleX / 2);
    final cosY = cos(angleY / 2);
    final cosZ = cos(angleZ / 2);
    final sinX = sin(angleX / 2);
    final sinY = sin(angleY / 2);
    final sinZ = sin(angleZ / 2);

    return new Quaternion(
        sinX * cosY * cosZ + cosX * sinY * sinZ,
        cosX * sinY * cosZ - sinX * cosY * sinZ,
        cosX * cosY * sinZ - sinX * sinY * cosZ,
        cosX * cosY * cosZ + sinX * sinY * sinZ);
  }

  /// Creates a new [Quaternion] representation of a rotation described by Euler
  /// angles, applied in `YZX` order.
  ///
  /// Represents a rotation that can be constructed by first rotating [angleY],
  /// radians around the `Y` axis, then rotating [angleZ] radians around the `Z`
  /// axis, and finally rotating [angleX] radians around the `X` axis.
  ///
  /// Note that applying the rotation angles in a different order can result
  /// in a different final rotation. See also [fromEulerAnglesXYZ],
  /// [fromEulerAnglesXZY], [fromEulerAnglesYXZ], [fromEulerAnglesZXY] and
  /// [fromEulerAnglesZYX].
  factory Quaternion.fromEulerAnglesYZX(
      double angleY, double angleZ, double angleX) {
    final cosX = cos(angleX / 2);
    final cosY = cos(angleY / 2);
    final cosZ = cos(angleZ / 2);
    final sinX = sin(angleX / 2);
    final sinY = sin(angleY / 2);
    final sinZ = sin(angleZ / 2);

    return new Quaternion(
        sinX * cosY * cosZ + cosX * sinY * sinZ,
        cosX * sinY * cosZ + sinX * cosY * sinZ,
        cosX * cosY * sinZ - sinX * sinY * cosZ,
        cosX * cosY * cosZ - sinX * sinY * sinZ);
  }

  /// Creates a new [Quaternion] representation of a rotation described by Euler
  /// angles, applied in `ZXY` order.
  ///
  /// Represents a rotation that can be constructed by first rotating [angleZ],
  /// radians around the `Z` axis, then rotating [angleX] radians around the `X`
  /// axis, and finally rotating [angleY] radians around the `Y` axis.
  ///
  /// Note that applying the rotation angles in a different order can result
  /// in a different final rotation. See also [fromEulerAnglesXYZ],
  /// [fromEulerAnglesXZY], [fromEulerAnglesYXZ], [fromEulerAnglesYZX] and
  /// [fromEulerAnglesZYX].
  factory Quaternion.fromEulerAnglesZXY(
      double angleZ, double angleX, double angleY) {
    final cosX = cos(angleX / 2);
    final cosY = cos(angleY / 2);
    final cosZ = cos(angleZ / 2);
    final sinX = sin(angleX / 2);
    final sinY = sin(angleY / 2);
    final sinZ = sin(angleZ / 2);

    return new Quaternion(
        sinX * cosY * cosZ - cosX * sinY * sinZ,
        cosX * sinY * cosZ + sinX * cosY * sinZ,
        cosX * cosY * sinZ + sinX * sinY * cosZ,
        cosX * cosY * cosZ - sinX * sinY * sinZ);
  }

  /// Creates a new [Quaternion] representation of a rotation described by Euler
  /// angles, applied in `ZYX` order.
  ///
  /// Represents a rotation that can be constructed by first rotating [angleZ],
  /// radians around the `Z` axis, then rotating [angleY] radians around the `Y`
  /// axis, and finally rotating [angleX] radians around the `X` axis.
  ///
  /// Note that applying the rotation angles in a different order can result
  /// in a different final rotation. See also [fromEulerAnglesXYZ],
  /// [fromEulerAnglesXZY], [fromEulerAnglesYXZ], [fromEulerAnglesYZX] and
  /// [fromEulerAnglesZXY].
  factory Quaternion.fromEulerAnglesZYX(
      double angleZ, double angleY, double angleX) {
    final cosX = cos(angleX / 2);
    final cosY = cos(angleY / 2);
    final cosZ = cos(angleZ / 2);
    final sinX = sin(angleX / 2);
    final sinY = sin(angleY / 2);
    final sinZ = sin(angleZ / 2);

    return new Quaternion(
        sinX * cosY * cosZ - cosX * sinY * sinZ,
        cosX * sinY * cosZ + sinX * cosY * sinZ,
        cosX * cosY * sinZ - sinX * sinY * cosZ,
        cosX * cosY * cosZ + sinX * sinY * sinZ);
  }

  /// The magnitude of this [Quaternion].
  double get magnitude {
    if (_magnitude == null) {
      _squareSum ??= x * x + y * y + z * z + w * w;

      if ((_squareSum - 1).abs() < 0.0001) {
        _magnitude = 1.0;
      } else {
        _magnitude = sqrt(_squareSum);
      }
    }

    return _magnitude;
  }

  /// This [Quaternion]'s unit quaternion.
  ///
  /// A normalized version of this [Quaternion] with a magnitude of `1`.
  Quaternion get unitQuaternion {
    if (_unitQuaternion == null) {
      if (_magnitude != null) {
        if (_magnitude == 1.0) {
          _unitQuaternion = new Quaternion(x, y, z, w);
        } else {
          _unitQuaternion = new Quaternion(
              x / _magnitude, y / _magnitude, z / _magnitude, w / _magnitude);
        }
      } else {
        _squareSum ??= x * x + y * y + z * z + w * w;

        if ((_squareSum - 1).abs() < 0.0001) {
          _unitQuaternion = new Quaternion(x, y, z, w);
        } else {
          _magnitude ??= sqrt(_squareSum);

          _unitQuaternion = new Quaternion(
              x / _magnitude, y / _magnitude, z / _magnitude, w / _magnitude);
        }
      }
    }

    return _unitQuaternion;
  }

  /// Whether or not this [Quaternion] is a unit quaternion.
  bool get isUnit {
    if (_magnitude != null) {
      return _magnitude == 1.0;
    } else {
      _squareSum ??= x * x + y * y + z * z + w * w;

      return (_squareSum - 1).abs() < 0.0001;
    }
  }

  /// Returns a [Matrix3] that represents this [Quaternion]'s rotation as a
  /// matrix transformation.
  ///
  /// When this [Matrix3] is a applied to a [Vector3] representing coordinates,
  /// then the resulting [Vector3] is rotated around the origin with the
  /// rotation represented by this [Quaternion].
  ///
  /// This [Quaternion] is assumed to be a unit quaternion. If this [Quaternion]
  /// is not a unit quaternion, then the matrix may be incorrect.
  Matrix3 asMatrix3() {
    if (_matrix3 == null) {
      final x2 = x * 2;
      final y2 = y * 2;
      final z2 = z * 2;

      final xx2 = x * x2;
      final xy2 = x * y2;
      final xz2 = x * z2;
      final yy2 = y * y2;
      final yz2 = y * z2;
      final zz2 = z * z2;
      final wx2 = w * x2;
      final wy2 = w * y2;
      final wz2 = w * z2;

      _matrix3 = new Matrix3(
          // First row
          1.0 - (yy2 + zz2),
          xy2 - wz2,
          xz2 + wy2,

          // Second row
          xy2 + wz2,
          1.0 - (xx2 + zz2),
          yz2 - wx2,

          // Third row
          xz2 - wy2,
          yz2 + wx2,
          1.0 - (xx2 + yy2));
    }

    return _matrix3;
  }

  /// Returns a [Matrix4] that represents this [Quaternion]'s rotation as a
  /// matrix transformation.
  ///
  /// When this [Matrix4] is a applied to a [Vector4] representing coordinates,
  /// then the resulting [Vector4] is rotated around the origin with the
  /// rotation represented by this [Quaternion].
  ///
  /// This [Quaternion] is assumed to be a unit quaternion. If this [Quaternion]
  /// is not a unit quaternion, then the matrix may be incorrect.
  Matrix4 asMatrix4() {
    if (_matrix4 == null) {
      final x2 = x * 2;
      final y2 = y * 2;
      final z2 = z * 2;

      final xx2 = x * x2;
      final xy2 = x * y2;
      final xz2 = x * z2;
      final yy2 = y * y2;
      final yz2 = y * z2;
      final zz2 = z * z2;
      final wx2 = w * x2;
      final wy2 = w * y2;
      final wz2 = w * z2;

      _matrix4 = new Matrix4(
          // First row
          1.0 - (yy2 + zz2),
          xy2 - wz2,
          xz2 + wy2,
          0.0,

          // Second row
          xy2 + wz2,
          1.0 - (xx2 + zz2),
          yz2 - wx2,
          0.0,

          // Third row
          xz2 - wy2,
          yz2 + wx2,
          1.0 - (xx2 + yy2),
          0.0,

          // Fourth row
          0.0,
          0.0,
          0.0,
          1.0);
    }

    return _matrix4;
  }

  /// Multiplies this [Quaternion] with another [Quaternion] [B], resulting
  /// in a new [Quaternion] that represents the combined rotation.
  Quaternion quaternionProduct(Quaternion B) {
    final x1 = x;
    final y1 = y;
    final z1 = z;
    final w1 = w;

    final x2 = B.x;
    final y2 = B.y;
    final z2 = B.z;
    final w2 = B.w;

    return new Quaternion(
        x1 * w2 + w1 * x2 + y1 * z2 - z1 * y2,
        y1 * w2 + w1 * y2 + z1 * x2 - x1 * z2,
        z1 * w2 + w1 * z2 + x1 * y2 - y1 * x2,
        w1 * w2 - x1 * x2 - y1 * y2 - z1 * z2);
  }

  /// Returns a new [Vector3] that results from rotating the given [vector] by
  /// the rotation represented by this [Quaternion].
  Vector3 vector3Rotation(Vector3 vector) {
    final vx = vector.x;
    final vy = vector.y;
    final vz = vector.z;

    final ix = w * vx + y * vz - z * vy;
    final iy = w * vy + z * vx - x * vz;
    final iz = w * vz + x * vy - y * vx;
    final iw = -x * vx - y * vy - z * vz;

    return new Vector3(
        ix * w + iw * -x + iy * -z - iz * -y,
        iy * w + iw * -y + iz * -x - ix * -z,
        iz * w + iw * -z + ix * -y - iy * -x);
  }

  operator *(value) {
    if (value is Quaternion) {
      return quaternionProduct(value);
    } else if (value is Vector3) {
      return vector3Rotation(value);
    } else {
      throw new ArgumentError('Can only multiply a Quaternion with another '
          'Quaternion or with a Vector3.');
    }
  }

  String toString() => 'Quaternion($x, $y, $z, $w)';

  bool operator ==(other) =>
      identical(other, this) ||
      other is Quaternion &&
          other.x == x &&
          other.y == y &&
          other.z == z &&
          other.w == w;
}
