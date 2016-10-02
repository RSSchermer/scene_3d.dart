library util;

import 'dart:math';

import 'package:bagl/math.dart';

double distance3(Vector3 a, Vector3 b) => sqrt(squaredDistance3(a, b));

double squaredDistance3(Vector3 a, Vector3 b) {
  final xDiff = a.x - b.x;
  final yDiff = a.y - b.y;
  final zDiff = a.z - b.z;

  return xDiff * xDiff + yDiff * yDiff + zDiff * zDiff;
}

double distance4(Vector4 a, Vector4 b) => sqrt(squaredDistance4(a, b));

double squaredDistance4(Vector4 a, Vector4 b) {
  final xDiff = a.x - b.x;
  final yDiff = a.y - b.y;
  final zDiff = a.z - b.z;

  return xDiff * xDiff + yDiff * yDiff + zDiff * zDiff;
}
