/// Provides a [Light] data structures for representing the lighting in a scene.
library lighting;

import 'dart:math';

import 'package:bagl/math.dart';
import 'package:bagl/struct.dart';

import 'quaternion.dart';

part 'src/lighting/directional_light.dart';
part 'src/lighting/light.dart';
part 'src/lighting/point_light.dart';
part 'src/lighting/spot_light.dart';
