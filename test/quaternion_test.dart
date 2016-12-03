import 'package:test/test.dart';
import 'helpers.dart';

import 'dart:math';

import 'package:bagl/math.dart';
import 'package:scene_3d/quaternion.dart';

void main() {
  group('Quaternion', () {
    group('fromList constructor', () {
      test('throws an error if the lists length is smaller than 4', () {
        expect(() => new Quaternion.fromList([0.0, 1.0, 2.0]), throwsArgumentError);
      });

      test('throws an error if the lists length is greater than 4', () {
        expect(() => new Quaternion.fromList([0.0, 1.0, 2.0, 3.0, 4.0]), throwsArgumentError);
      });

      group('with a list of length 4', () {
        final quaternion = new Quaternion.fromList([0.0, 1.0, 2.0, 3.0]);

        test('instantiates a new instance with the correct x value', () {
          expect(quaternion.x, equals(0.0));
        });

        test('instantiates a new instance with the correct y value', () {
          expect(quaternion.y, equals(1.0));
        });

        test('instantiates a new instance with the correct z value', () {
          expect(quaternion.z, equals(2.0));
        });

        test('instantiates a new instance with the correct w value', () {
          expect(quaternion.w, equals(3.0));
        });
      });
    });

    group('fromAxisAngle constructor', () {
      final quaternion = new Quaternion.fromAxisAngle(new Vector3(0.43644, 0.21823, 0.87287), 0.5 * PI);

      test('returns a new instance with the correct x value', () {
        expect(quaternion.x, closeTo(0.30861, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.y, closeTo(0.15431, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.z, closeTo(0.61721, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.w, closeTo(0.70711, 0.00001));
      });
    });

    group('fromEulerAnglesXYZ constructor', () {
      final quaternion = new Quaternion.fromEulerAnglesXYZ(0.2 * PI, 0.3 * PI, 0.4 * PI);

      test('returns a new instance with the correct x value', () {
        expect(quaternion.x, closeTo(0.47654, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.y, closeTo(0.18747, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.z, closeTo(0.61159, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.w, closeTo(0.60310, 0.00001));
      });
    });

    group('fromEulerAnglesXZY constructor', () {
      final quaternion = new Quaternion.fromEulerAnglesXZY(0.2 * PI, 0.4 * PI, 0.3 * PI);

      test('returns a new instance with the correct x value', () {
        expect(quaternion.x, closeTo(-0.03104, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.y, closeTo(0.18747, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.z, closeTo(0.61159, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.w, closeTo(0.76802, 0.00001));
      });
    });

    group('fromEulerAnglesYXZ constructor', () {
      final quaternion = new Quaternion.fromEulerAnglesYXZ(0.3 * PI, 0.2 * PI, 0.4 * PI);

      test('returns a new instance with the correct x value', () {
        expect(quaternion.x, closeTo(0.47654, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.y, closeTo(0.18747, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.z, closeTo(0.38459, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.w, closeTo(0.76802, 0.00001));
      });
    });

    group('fromEulerAnglesYZX constructor', () {
      final quaternion = new Quaternion.fromEulerAnglesYZX(0.3 * PI, 0.4 * PI, 0.2 * PI);

      test('returns a new instance with the correct x value', () {
        expect(quaternion.x, closeTo(0.47654, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.y, closeTo(0.51115, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.z, closeTo(0.38459, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.w, closeTo(0.60310, 0.00001));
      });
    });

    group('fromEulerAnglesZXY constructor', () {
      final quaternion = new Quaternion.fromEulerAnglesZXY(0.4 * PI, 0.2 * PI, 0.3 * PI);

      test('returns a new instance with the correct x value', () {
        expect(quaternion.x, closeTo(-0.03104, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.y, closeTo(0.51115, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.z, closeTo(0.61159, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.w, closeTo(0.60310, 0.00001));
      });
    });

    group('fromEulerAnglesZYX constructor', () {
      final quaternion = new Quaternion.fromEulerAnglesZYX(0.4 * PI, 0.3 * PI, 0.2 * PI);

      test('returns a new instance with the correct x value', () {
        expect(quaternion.x, closeTo(-0.03104, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.y, closeTo(0.51115, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.z, closeTo(0.38459, 0.00001));
      });

      test('returns a new instance with the correct x value', () {
        expect(quaternion.w, closeTo(0.76802, 0.00001));
      });
    });

    group('instance (1.0, 2.0, 3.0, 4.0)', () {
      final quaternion = new Quaternion(1.0, 2.0, 3.0, 4.0);

      test('magnitude returns the correct value', () {
        expect(quaternion.magnitude, closeTo(5.47723, 0.00001));
      });

      group('unitQuaternion', () {
        final unit = quaternion.unitQuaternion;

        test('returns a quaternion with the correct x value', () {
          expect(unit.x, closeTo(0.18257, 0.00001));
        });

        test('returns a quaternion with the correct y value', () {
          expect(unit.y, closeTo(0.36515, 0.00001));
        });

        test('returns a quaternion with the correct z value', () {
          expect(unit.z, closeTo(0.54772, 0.00001));
        });

        test('returns a quaternion with the correct w value', () {
          expect(unit.w, closeTo(0.73030, 0.00001));
        });
      });

      test('isUnit returns false', () {
        expect(quaternion.isUnit, isFalse);
      });

      group('toString', () {
        final quaternion = new Quaternion(1.0, 2.0, 3.0, 4.0);

        test('returns the correct value', () {
          expect(quaternion.toString(), equals('Quaternion(1.0, 2.0, 3.0, 4.0)'));
        });
      });

      group('== operator', () {
        group('with another Quaterion that has the same x, y, z and w values', () {
          final q1 = new Quaternion(1.0, 2.0, 3.0, 4.0);
          final q2 = new Quaternion(1.0, 2.0, 3.0, 4.0);

          test('returns true', () {
            expect(q1 == q2, isTrue);
          });
        });

        group('with another Quaterion that has different x, y, z and w values', () {
          final q1 = new Quaternion(1.0, 2.0, 3.0, 4.0);
          final q2 = new Quaternion(4.0, 3.0, 2.0, 1.0);

          test('returns false', () {
            expect(q1 == q2, isFalse);
          });
        });
      });
    });

    group('instance from Euler angles XYZ(0.2 * PI, 0.3 * PI, 0.4 * PI)', () {
      final quaternion = new Quaternion.fromEulerAnglesXYZ(0.2 * PI, 0.3 * PI, 0.4 * PI);

      group('vector3Rotation', () {
        final vector = new Vector3(1.0, 2.0, 3.0);
        final rotated = quaternion.vector3Rotation(vector);

        test('returns a new Vector3 with the correct values', () {
          expect(rotated.values, orderedCloseTo([1.49065, -0.52462, 3.39157], 0.00001));
        });
      });

      group('asMatrix3', () {
        final matrix = quaternion.asMatrix3();

        test('returns a matrix with the correct values', () {
          expect(matrix.values, orderedCloseTo([
            0.18164, -0.55902,  0.80902,
            0.91637, -0.20225, -0.34549,
            0.35676,  0.80411,  0.47553
          ], 0.00001));
        });
      });

      group('asMatrix4', () {
        final matrix = quaternion.asMatrix4();

        test('returns a matrix with the correct values', () {
          expect(matrix.values, orderedCloseTo([
            0.18164, -0.55902,  0.80902, 0.0,
            0.91637, -0.20225, -0.34549, 0.0,
            0.35676,  0.80411,  0.47553, 0.0,
            0.0,      0.0,      0.0, 1.0
          ], 0.00001));
        });
      });

      group('quaternionProduct', () {
        final other = new Quaternion.fromEulerAnglesXYZ(0.3 * PI, 0.4 * PI, 0.2 * PI);
        final product = quaternion.quaternionProduct(other);

        test('returns a quaternion with the correct x value', () {
          expect(product.x, closeTo(0.44980, 0.00001));
        });

        test('returns a quaternion with the correct y value', () {
          expect(product.y, closeTo(0.43053, 0.00001));
        });

        test('returns a quaternion with the correct z value', () {
          expect(product.z, closeTo(0.74369, 0.00001));
        });

        test('returns a quaternion with the correct w value', () {
          expect(product.w, closeTo(-0.24340, 0.00001));
        });
      });
    });

    group('instance (0.26726, 0.53452, 0.80178, 0.0)', () {
      final quaternion = new Quaternion(0.26726, 0.53452, 0.80178, 0.0);

      test('magnitude returns the correct value', () {
        expect(quaternion.magnitude, equals(1.0));
      });

      group('unitQuaternion', () {
        final unit = quaternion.unitQuaternion;

        test('returns a quaternion with the correct x value', () {
          expect(unit.x, closeTo(0.26726, 0.00001));
        });

        test('returns a quaternion with the correct y value', () {
          expect(unit.y, closeTo(0.53452, 0.00001));
        });

        test('returns a quaternion with the correct z value', () {
          expect(unit.z, closeTo(0.80178, 0.00001));
        });

        test('returns a quaternion with the correct w value', () {
          expect(unit.w, closeTo(0.0, 0.00001));
        });
      });

      test('isUnit is true', () {
        expect(quaternion.isUnit, isTrue);
      });
    });
  });
}
