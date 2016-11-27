import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:bagl/bagl.dart';

import 'package:scene_3d/rendering/realtime/bagl.dart';
import 'package:scene_3d/camera.dart';
import 'package:scene_3d/geometry_generators.dart';
import 'package:scene_3d/lighting.dart';
import 'package:scene_3d/material.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/scene.dart';
import 'package:scene_3d/shape.dart';

main() {
  var backdropTriangles = generateQuadTriangles(10.0, 10.0);
  var backdropMaterial = new ConstantMaterial()
    ..emissionMap = new Texture2D.fromImageURL('checkerboard_color_gradient.png');
  var backdrop = new ConstantTrianglesShape(backdropTriangles, backdropMaterial);

  var cutoutTriangles = generateQuadTriangles(10.0, 10.0);
  var cutoutMaterial = new PhongMaterial()
    ..diffuseColor = new Vector3(1.0, 0.0, 0.0)
    ..opacity = 0.8
    ..opacityMap = new Texture2D.fromImageURL('opacity_map.png');
  var cutout = new PhongTrianglesShape(cutoutTriangles, cutoutMaterial)
    ..position = new Vector3(0.0, 0.0, 2.0);

  var light = new DirectionalLight()
    ..direction = new Vector3(0.0, 0.0, -1.0);
  var camera = new PerspectiveCamera(0.3 * PI, 1.0, 1.0, 100.0)
    ..position = new Vector3(0.0, 0.0, 20.0);
  var scene = new Scene();

  scene.objects.addAll([backdrop, cutout, light, camera]);

  var canvas = document.querySelector('#main_canvas');
  var renderer = new ForwardRenderer(canvas, scene);

  update(num time) {
    cutout.rotation = new Quaternion.fromEulerAnglesXYZ(0.0, time / 1000, 0.0);

    renderer.render(camera);

    window.requestAnimationFrame(update);
  }

  Future.wait([
    backdropMaterial.emissionMap.asFuture(),
    cutoutMaterial.opacityMap.asFuture()
  ]).whenComplete(() {
    window.requestAnimationFrame(update);
  });
}
