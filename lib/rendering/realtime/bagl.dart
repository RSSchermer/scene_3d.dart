library rendering.realtime.bagl;

import 'dart:html';
import 'dart:collection';

import 'package:bagl/bagl.dart';
import 'package:inline_assets/inline_assets.dart';
import 'package:quiver/collection.dart';

import 'package:scene_3d/camera.dart';
import 'package:scene_3d/lighting.dart';
import 'package:scene_3d/material.dart';
import 'package:scene_3d/observable_value.dart';
import 'package:scene_3d/scene.dart';
import 'package:scene_3d/shape.dart';
import 'package:scene_3d/transform.dart';
import 'package:scene_3d/util.dart';

import 'atomic_render_unit.dart';
import 'sorting.dart';

part 'src/bagl/bagl_render_unit.dart';
part 'src/bagl/forward_renderer.dart';
part 'src/bagl/blinn_rendering.dart';
part 'src/bagl/constant_shape_rendering.dart';
part 'src/bagl/lambert_shape_rendering.dart';
part 'src/bagl/null_view.dart';
part 'src/bagl/object_views.dart';
part 'src/bagl/phong_shape_rendering.dart';
part 'src/bagl/program_pool.dart';
