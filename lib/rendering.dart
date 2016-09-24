/// Provides data structures that help render a scene.
library rendering;

import 'dart:collection';
import 'dart:html';

import 'package:bagl/index_geometry.dart';
import 'package:bagl/math.dart';
import 'package:bagl/rendering.dart';
import 'package:bagl/texture.dart';
import 'package:inline_assets/inline_assets.dart';
import 'package:quiver/collection.dart';

import 'camera.dart';
import 'lighting.dart';
import 'material.dart';
import 'scene.dart';
import 'shape.dart';

part 'src/rendering/experimentation.dart';

part 'src/rendering/constant_material.dart';
part 'src/rendering/lambert_material.dart';
part 'src/rendering/null_view.dart';
part 'src/rendering/program_material.dart';
part 'src/rendering/program_pool.dart';
part 'src/rendering/scene_renderer.dart';
part 'src/rendering/type_grouped_view_set.dart';
part 'src/rendering/view.dart';
part 'src/rendering/view_factory.dart';
