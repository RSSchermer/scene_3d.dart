import 'dart:html';
import 'dart:math';

import 'package:bagl/bagl.dart';

import 'package:scene_3d/rendering/realtime/bagl.dart';
import 'package:scene_3d/camera.dart';
import 'package:scene_3d/lighting.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/scene.dart';
import 'package:scene_3d/shape/loading/obj.dart';

main() {
  loadObj('stanford_bunny.obj').then((obj) {
    var light = new DirectionalLight()
      ..transform.rotation = new Quaternion.fromEulerAnglesXYZ(0.0, PI, 0.0);
    var camera = new PerspectiveCamera(0.3 * PI, 1.0, 1.0, 100.0)
      ..transform.translation = new Vector3(0.0, 0.0, 20.0);
    var scene = new Scene();

    obj
      ..transform.scaling = new Vector3(70.0, 70.0, 70.0)
      ..transform.translation = new Vector3(0.0, -8.0, 0.0);

    scene.objects.addAll(obj.shapes);
    scene.objects.addAll([light, camera]);

    var canvas = document.querySelector('#main_canvas');
    var renderer = new ForwardRenderer(canvas, scene);

    update(num time) {
      obj.transform.rotation =
          new Quaternion.fromEulerAnglesXYZ(0.0, time / 1000, 0.0);

      renderer.render(camera);

      window.requestAnimationFrame(update);
    }

    window.requestAnimationFrame(update);
  });
}
