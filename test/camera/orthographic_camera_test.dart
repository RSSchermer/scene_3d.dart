import 'package:test/test.dart';
import '../helpers.dart';
import 'dart:math';
import 'package:bagl/math.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/camera.dart';

void main() {
  group('OrthographicCamera', () {
    group('default constructor', () {
      test('with a near value that is smaller than 0', () {
        expect(() => new OrthographicCamera(1.0, 1.0, -1.0, 100.0), throwsArgumentError);
      });

      test('with a near value that is greater than the far value throws an ArgumentError', () {
        expect(() => new OrthographicCamera(1.0, 1.0, 100.0, 1.0), throwsArgumentError);
      });
    });

    group('near', () {
      final camera = new OrthographicCamera(1.0, 1.0, 1.0, 100.0);

      group('set', () {
        test('with a value smaller than 0 throws an ArgumentError', () {
          expect(() => camera.near = -1.0, throwsArgumentError);
        });

        test('with a value greater than the current far value throws an ArgumentError', () {
          expect(() => camera.near = 101.0, throwsArgumentError);
        });
      });
    });

    group('far', () {
      final camera = new OrthographicCamera(1.0, 1.0, 1.0, 100.0);

      group('set', () {
        test('with a value smaller than the current near value throws an ArgumentError', () {
          expect(() => camera.far = 0.9, throwsArgumentError);
        });
      });
    });

    group('viewTransform', () {
      final camera = new OrthographicCamera(1.0, 1.0, 1.0, 100.0)
        ..transform.translation = new Vector3(1.0, 2.0, 3.0)
        ..transform.rotation = new Quaternion.fromEulerAnglesXYZ(0.25 * PI, 0.25 * PI, 0.0);

      test('returns the correct value', () {
        expect(camera.worldToCamera.values, orderedCloseTo([
          0.70711, 0.5, -0.5, -0.20711,
          0.0, 0.70711, 0.70711, -3.53553,
          0.70711, -0.5, 0.5, -1.20711,
          0.0, 0.0, 0.0, 1.0
        ], 0.00001));
      });
    });

    group('projectionTransform', () {
      final camera = new OrthographicCamera(20.0, 1.0, 1.0, 100.0);

      test('returns the correct value', () {
        expect(camera.cameraToClip.values, orderedCloseTo([
          0.05, 0.0, 0.0, -0.0,
          0.0, 0.05, 0.0, -0.0,
          0.0, 0.0, -0.0202, -1.0202,
          0.0, 0.0, 0.0, 1.0
        ], 0.00001));
      });
    });

    group('viewProjectionTransform', () {
      final camera = new OrthographicCamera(20.0, 1.0, 1.0, 100.0)
        ..transform.translation = new Vector3(1.0, 2.0, 3.0)
        ..transform.rotation = new Quaternion.fromEulerAnglesXYZ(0.25 * PI, 0.25 * PI, 0.0);

      test('returns the correct value', () {
        expect(camera.worldToClip.values, orderedCloseTo([
          0.03536, 0.025, -0.025, -0.01036,
          0.0, 0.03536, 0.03536, -0.17678,
          -0.01428, 0.0101, -0.0101, -0.99582,
          0.0, 0.0, 0.0, 1.0
        ], 0.00001));
      });
    });
  });
}
