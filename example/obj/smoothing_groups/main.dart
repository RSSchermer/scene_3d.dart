import 'dart:html';
import 'dart:math';

import 'package:bagl/bagl.dart';

import 'package:scene_3d/rendering/realtime/bagl.dart';
import 'package:scene_3d/camera.dart';
import 'package:scene_3d/lighting.dart';
import 'package:scene_3d/material.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/scene.dart';
import 'package:scene_3d/shape/loading/obj.dart';

main() {
  final material = new PhongMaterial()
    ..specularColor = new Vector3(0.3, 0.3, 0.3);

  loadObj('smooth_cylinder.obj', defaultMaterial: material).then((obj) {
    var light = new PointLight()
      ..transform.translation = new Vector3(0.0, 0.0, 10.0)
      ..quadraticAttenuation = 0.001;
    var camera = new PerspectiveCamera(0.3 * PI, 1.0, 1.0, 100.0)
      ..transform.translation = new Vector3(0.0, 0.0, 20.0);
    var scene = new Scene();

    obj.transform.scaling = new Vector3(4.0, 4.0, 4.0);

    scene.objects.addAll(obj.shapes);
    scene.objects.addAll([light, camera]);

    var canvas = document.querySelector('#main_canvas');
    var renderer = new ForwardRenderer(canvas, scene);

    update(num time) {
      obj.transform.rotation =
          new Quaternion.fromEulerAnglesXYZ(time / 5000, time / 1000, 0.0);

      renderer.render(camera);

      window.requestAnimationFrame(update);
    }

    window.requestAnimationFrame(update);
  });
}
