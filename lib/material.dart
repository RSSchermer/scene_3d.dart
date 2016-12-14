/// Provides [Material] data structures for controlling the way in which
/// geometry is rendered.
library material;

import 'package:bagl/math.dart';
import 'package:bagl/rendering.dart';
import 'package:bagl/texture.dart';

import 'camera.dart';
import 'scene.dart';
import 'shape.dart';

part 'src/material/constant_material.dart';
part 'src/material/lambert_material.dart';
part 'src/material/line_material.dart';
part 'src/material/material.dart';
part 'src/material/phong_material.dart';
part 'src/material/point_material.dart';
part 'src/material/program_material.dart';
part 'src/material/surface_material.dart';
