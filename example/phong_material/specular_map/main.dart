import 'dart:html';
import 'dart:math';

import 'package:bagl/bagl.dart';

import 'package:scene_3d/rendering/realtime/bagl.dart';
import 'package:scene_3d/camera.dart';
import 'package:scene_3d/lighting.dart';
import 'package:scene_3d/material.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/scene.dart';
import 'package:scene_3d/shape.dart';

main() {
  var material = new PhongMaterial()
    ..diffuseColor = new Vector3(1.0, 0.0, 0.0)
    ..specularMap = new Texture2D.fromImageURL('specular_map.png')
    ..shininess = 10.0;
  var shape = new TrianglesShape.quad(15.0, 15.0, material)
    ..transform.translation = new Vector3(0.0, -5.0, 0.0);
  var light = new PointLight()
    ..transform.translation = new Vector3(0.0, 5.0, 0.0)
    ..quadraticAttenuation = 0.005;
  var camera = new PerspectiveCamera(0.3 * PI, 1.0, 1.0, 100.0)
    ..transform.translation = new Vector3(0.0, 0.0, 20.0);
  var scene = new Scene();

  scene.objects.addAll([shape, light, camera]);

  var canvas = document.querySelector('#main_canvas');
  var renderer = new ForwardRenderer(canvas, scene);

  update(num time) {
    shape.transform.rotation = new Quaternion.fromEulerAnglesXYZ(
        -0.25 * PI - sin(time / 1000) * 0.25 * PI, 0.0, 0.0);

    renderer.render(camera);

    window.requestAnimationFrame(update);
  }

  window.requestAnimationFrame(update);
}
