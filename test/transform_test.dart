import 'dart:math';
import 'package:bagl/math.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/transform.dart';
import 'package:test/test.dart';
import 'helpers.dart';

void main() {
  group('Transform', () {
    group('an instance', () {
      final transform = new Transform();

      test('parentTransform returns the correct value', () {
        expect(transform.parentTransform, isNull);
      });

      test('translation returns the correct value', () {
        expect(transform.translation, equals(new Vector3(0.0, 0.0, 0.0)));
      });

      test('rotation returns the correct value', () {
        expect(transform.rotation, equals(new Quaternion(0.0, 0.0, 0.0, 1.0)));
      });

      test('scaling returns the correct value', () {
        expect(transform.scaling, equals(new Vector3(1.0, 1.0, 1.0)));
      });

      test('position returns the correct value', () {
        expect(transform.position, equals(new Vector3(0.0, 0.0, 0.0)));
      });

      test('right returns the correct value', () {
        expect(transform.right, equals(new Vector3(1.0, 0.0, 0.0)));
      });

      test('up returns the correct value', () {
        expect(transform.up, equals(new Vector3(0.0, 1.0, 0.0)));
      });

      test('forward returns the correct value', () {
        expect(transform.forward, equals(new Vector3(0.0, 0.0, 1.0)));
      });

      test('positionToWorld returns the correct value', () {
        expect(transform.positionToWorld, equals(new Matrix4.identity()));
      });

      test('directionToWorld returns the correct value', () {
        expect(transform.directionToWorld, equals(new Matrix3.identity()));
      });

      group('after modifying the translation', () {
        setUp(() {
          transform.translation = new Vector3(1.0, 2.0, 3.0);
        });

        tearDown(() {
          transform.translation = new Vector3(0.0, 0.0, 0.0);
        });

        test('translation returns the correct value', () {
          expect(transform.translation, equals(new Vector3(1.0, 2.0, 3.0)));
        });

        test('position returns the correct value', () {
          expect(transform.position, equals(new Vector3(1.0, 2.0, 3.0)));
        });

        test('right returns the correct value', () {
          expect(transform.right, equals(new Vector3(1.0, 0.0, 0.0)));
        });

        test('up returns the correct value', () {
          expect(transform.up, equals(new Vector3(0.0, 1.0, 0.0)));
        });

        test('forward returns the correct value', () {
          expect(transform.forward, equals(new Vector3(0.0, 0.0, 1.0)));
        });

        test('positionToWorld returns the correct value', () {
          expect(transform.positionToWorld, equals(new Matrix4(
              1.0, 0.0, 0.0, 1.0,
              0.0, 1.0, 0.0, 2.0,
              0.0, 0.0, 1.0, 3.0,
              0.0, 0.0, 0.0, 1.0
          )));
        });

        test('directionToWorld returns the correct value', () {
          expect(transform.directionToWorld, equals(new Matrix3.identity()));
        });
      });

      group('after modifying the rotation', () {
        setUp(() {
          transform.rotation = new Quaternion.fromEulerAnglesXYZ(0.1 * PI, 0.2 * PI, 0.3 * PI);
        });

        tearDown(() {
          transform.rotation = new Quaternion(0.0, 0.0, 0.0, 1.0);
        });

        test('translation returns the correct value', () {
          expect(transform.rotation, equals(new Quaternion.fromEulerAnglesXYZ(0.1 * PI, 0.2 * PI, 0.3 * PI)));
        });

        test('position returns the correct value', () {
          expect(transform.position, equals(new Vector3(0.0, 0.0, 0.0)));
        });

        test('right returns the correct value', () {
          expect(transform.right.values, orderedCloseTo([0.47553, 0.87618, -0.07858], 0.00001));
        });

        test('up returns the correct value', () {
          expect(transform.up.values, orderedCloseTo([-0.65451, 0.41207, 0.63389], 0.00001));
        });

        test('forward returns the correct value', () {
          expect(transform.forward.values, orderedCloseTo([0.58779, -0.25, 0.76942], 0.00001));
        });

        test('positionToWorld returns the correct value', () {
          expect(transform.positionToWorld.values, orderedCloseTo([
             0.47553, -0.65451,  0.58779, 0.0,
             0.87618,  0.41207, -0.25000, 0.0,
            -0.07858,  0.63389,  0.76942, 0.0,
             0.00000,  0.00000,  0.00000, 1.0
          ], 0.00001));
        });

        test('directionToWorld returns the correct value', () {
          expect(transform.directionToWorld.values, orderedCloseTo([
             0.47553, -0.65451,  0.58779,
             0.87618,  0.41207, -0.25000,
            -0.07858,  0.63389,  0.76942
          ], 0.00001));
        });
      });

      group('after modifying the scaling', () {
        setUp(() {
          transform.scaling = new Vector3(1.0, 2.0, 3.0);
        });

        tearDown(() {
          transform.scaling = new Vector3(1.0, 1.0, 1.0);
        });

        test('scaling returns the correct value', () {
          expect(transform.scaling, equals(new Vector3(1.0, 2.0, 3.0)));
        });

        test('position returns the correct value', () {
          expect(transform.position, equals(new Vector3(0.0, 0.0, 0.0)));
        });

        test('right returns the correct value', () {
          expect(transform.right, equals(new Vector3(1.0, 0.0, 0.0)));
        });

        test('up returns the correct value', () {
          expect(transform.up, equals(new Vector3(0.0, 1.0, 0.0)));
        });

        test('forward returns the correct value', () {
          expect(transform.forward, equals(new Vector3(0.0, 0.0, 1.0)));
        });

        test('positionToWorld returns the correct value', () {
          expect(transform.positionToWorld, equals(new Matrix4(
              1.0, 0.0, 0.0, 0.0,
              0.0, 2.0, 0.0, 0.0,
              0.0, 0.0, 3.0, 0.0,
              0.0, 0.0, 0.0, 1.0
          )));
        });

        test('directionToWorld returns the correct value', () {
          expect(transform.directionToWorld.values, orderedCloseTo([
            1.0, 0.0, 0.0,
            0.0, 0.5, 0.0,
            0.0, 0.0, 0.33333
          ], 0.00001));
        });
      });

      group('after setting a parent transform', () {
        final parentTransform = new Transform()
          ..translation = new Vector3(1.0, 2.0, 3.0)
          ..rotation = new Quaternion.fromEulerAnglesXYZ(0.1 * PI, 0.2 * PI, 0.3 * PI)
          ..scaling = new Vector3(1.0, 2.0, 3.0);

        setUp(() {
          transform.parentTransform = parentTransform;
        });

        tearDown(() {
          transform.parentTransform = null;
        });

        test('parentTransform returns the correct value', () {
          expect(transform.parentTransform, equals(parentTransform));
        });

        test('position returns the correct value', () {
          expect(transform.position, equals(new Vector3(1.0, 2.0, 3.0)));
        });

        test('right returns the correct value', () {
          expect(transform.right.values, orderedCloseTo([0.47553, 0.87618, -0.07858], 0.00001));
        });

        test('up returns the correct value', () {
          expect(transform.up.values, orderedCloseTo([-0.65451, 0.41207, 0.63389], 0.00001));
        });

        test('forward returns the correct value', () {
          expect(transform.forward.values, orderedCloseTo([0.58779, -0.25, 0.76942], 0.00001));
        });

        test('positionToWorld returns the correct value', () {
          expect(transform.positionToWorld.values, orderedCloseTo([
             0.47553, -1.30902,  1.76336, 1.0,
             0.87618,  0.82414, -0.75000, 2.0,
            -0.07858,  1.26778,  2.30826, 3.0,
             0.00000,  0.00000,  0.00000, 1.0
          ], 0.00001));
        });

        test('directionToWorld returns the correct value', () {
          expect(transform.directionToWorld.values, orderedCloseTo([
             0.47553, -0.32725,  0.19593,
             0.87618,  0.20604, -0.08333,
            -0.07858,  0.31694,  0.25647
          ], 0.00001));
        });

        group('after setting a non-zero translation', () {
          setUp(() {
            transform.translation = new Vector3(1.0, 2.0, 3.0);
          });

          tearDown(() {
            transform.translation = new Vector3(0.0, 0.0, 0.0);
          });

          test('position returns the correct value', () {
            expect(transform.position.values, orderedCloseTo([4.14756, 2.27447, 12.38177], 0.00001));
          });

          test('right returns the correct value', () {
            expect(transform.right.values, orderedCloseTo([0.47553, 0.87618, -0.07858], 0.00001));
          });

          test('up returns the correct value', () {
            expect(transform.up.values, orderedCloseTo([-0.65451, 0.41207, 0.63389], 0.00001));
          });

          test('forward returns the correct value', () {
            expect(transform.forward.values, orderedCloseTo([0.58779, -0.25, 0.76942], 0.00001));
          });

          test('positionToWorld returns the correct value', () {
            expect(transform.positionToWorld.values, orderedCloseTo([
               0.47553, -1.30902,  1.76336,  4.14756,
               0.87618,  0.82414, -0.75000,  2.27447,
              -0.07858,  1.26778,  2.30826, 12.38177,
               0.00000,  0.00000,  0.00000,  1.00000
            ], 0.00001));
          });

          test('directionToWorld returns the correct value', () {
            expect(transform.directionToWorld.values, orderedCloseTo([
               0.47553, -0.32725,  0.19593,
               0.87618,  0.20604, -0.08333,
              -0.07858,  0.31694,  0.25647
            ], 0.00001));
          });
        });

        group('after setting the parent transform back to null', () {
          setUp(() {
            transform.parentTransform = null;
          });

          tearDown(() {
            transform.parentTransform = parentTransform;
          });

          test('parentTransform returns the correct value', () {
            expect(transform.parentTransform, isNull);
          });

          test('position returns the correct value', () {
            expect(transform.position, equals(new Vector3(0.0, 0.0, 0.0)));
          });

          test('right returns the correct value', () {
            expect(transform.right, equals(new Vector3(1.0, 0.0, 0.0)));
          });

          test('up returns the correct value', () {
            expect(transform.up, equals(new Vector3(0.0, 1.0, 0.0)));
          });

          test('forward returns the correct value', () {
            expect(transform.forward, equals(new Vector3(0.0, 0.0, 1.0)));
          });

          test('positionToWorld returns the correct value', () {
            expect(transform.positionToWorld, equals(new Matrix4.identity()));
          });

          test('directionToWorld returns the correct value', () {
            expect(transform.directionToWorld, equals(new Matrix3.identity()));
          });
        });
      });
    });
  });
}
