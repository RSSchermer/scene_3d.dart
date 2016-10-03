library bagl_forward_rendering;

import 'dart:html';
import 'dart:collection';

import 'package:bagl/bagl.dart';
import 'package:inline_assets/inline_assets.dart';
import 'package:quiver/collection.dart';

import 'camera.dart';
import 'lighting.dart';
import 'observable_value.dart';
import 'scene.dart';
import 'shape.dart';
import 'render_sorting.dart';
import 'util.dart';

part 'src/bagl_forward_rendering/bagl_render_unit.dart';
part 'src/bagl_forward_rendering/bagl_forward_renderer.dart';
part 'src/bagl_forward_rendering/blinn_rendering.dart';
part 'src/bagl_forward_rendering/constant_shape_rendering.dart';
part 'src/bagl_forward_rendering/lambert_shape_rendering.dart';
part 'src/bagl_forward_rendering/null_view.dart';
part 'src/bagl_forward_rendering/object_views.dart';
part 'src/bagl_forward_rendering/phong_rendering.dart';
part 'src/bagl_forward_rendering/program_pool.dart';
