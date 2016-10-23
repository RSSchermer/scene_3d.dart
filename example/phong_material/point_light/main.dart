import 'dart:html';
import 'dart:math';

import 'package:bagl/bagl.dart';

import 'package:scene_3d/bagl_forward_rendering.dart';
import 'package:scene_3d/camera.dart';
import 'package:scene_3d/geometry_generators.dart';
import 'package:scene_3d/lighting.dart';
import 'package:scene_3d/material.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/scene.dart';
import 'package:scene_3d/shape.dart';

main() {
  var triangles = generateBoxTriangles(10.0, 10.0, 10.0);
  var material = new PhongMaterial()
    ..diffuseColor = new Vector3(1.0, 0.0, 0.0);
  var shape = new PhongTrianglesShape(triangles, material)
    ..rotation = new Quaternion.fromEulerAnglesXYZ(0.25 * PI, 0.25 * PI, 0.0);
  var light = new PointLight()
    ..position = new Vector3(0.0, 5.0, 15.0)
    ..quadraticAttenuation = 0.01;
  var camera = new PerspectiveCamera(0.3 * PI, 1.0, 1.0, 100.0)
    ..position = new Vector3(0.0, 0.0, 20.0);
  var scene = new Scene();

  scene.objects.addAll([shape, light, camera]);

  var canvas = document.querySelector('#main_canvas');
  var renderer = new ForwardRenderer(canvas, scene);

  update(num time) {
    shape.rotation = new Quaternion.fromEulerAnglesXYZ(time / 1000, time / 1000, 0.0);

    renderer.render(camera);

    window.requestAnimationFrame(update);
  }

  window.requestAnimationFrame(update);
}
