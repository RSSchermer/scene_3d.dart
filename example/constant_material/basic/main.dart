import 'dart:html';
import 'dart:math';

import 'package:bagl/bagl.dart';

import 'package:scene_3d/rendering/realtime/bagl.dart';
import 'package:scene_3d/camera.dart';
import 'package:scene_3d/geometry_generators.dart';
import 'package:scene_3d/material.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/scene.dart';
import 'package:scene_3d/shape.dart';

main() {
  var triangles = generateBoxTriangles(10.0, 10.0, 10.0);
  var material = new ConstantMaterial()
    ..emissionColor = new Vector3(1.0, 0.0, 0.0);
  var shape = new ConstantTrianglesShape(triangles, material)
    ..rotation = new Quaternion.fromEulerAnglesXYZ(0.25 * PI, 0.25 * PI, 0.0);
  var camera = new PerspectiveCamera(0.3 * PI, 1.0, 1.0, 100.0)
    ..position = new Vector3(0.0, 0.0, 20.0);
  var scene = new Scene();

  scene.objects.addAll([shape, camera]);

  var canvas = document.querySelector('#main_canvas');
  var renderer = new ForwardRenderer(canvas, scene);

  update(num time) {
    shape.rotation = new Quaternion.fromEulerAnglesXYZ(time / 1000, time / 1000, 0.0);

    renderer.render(camera);

    window.requestAnimationFrame(update);
  }

  window.requestAnimationFrame(update);
}
