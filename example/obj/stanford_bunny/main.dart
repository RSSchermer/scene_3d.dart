import 'dart:html';
import 'dart:math';

import 'package:bagl/bagl.dart';
import 'package:resource/resource.dart';

import 'package:scene_3d/rendering/realtime/bagl.dart';
import 'package:scene_3d/camera.dart';
import 'package:scene_3d/lighting.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/scene.dart';
import 'package:scene_3d/obj_loading.dart';

main() {
  final resource = new Resource('stanford_bunny.obj');

  loadObjResource(resource).then((shapes) {
    var light = new DirectionalLight()
      ..transform.rotation = new Quaternion.fromEulerAnglesXYZ(0.0, PI, 0.0);
    var camera = new PerspectiveCamera(0.3 * PI, 1.0, 1.0, 100.0)
      ..transform.translation = new Vector3(0.0, 0.0, 20.0);
    var scene = new Scene();

    shapes.forEach((shape) {
      shape
        ..transform.scaling = new Vector3(70.0, 70.0, 70.0)
        ..transform.translation = new Vector3(0.0, -8.0, 0.0);
    });

    scene.objects.addAll(shapes);
    scene.objects.addAll([light, camera]);

    var canvas = document.querySelector('#main_canvas');
    var renderer = new ForwardRenderer(canvas, scene);

    update(num time) {
      shapes.forEach((shape) {
        shape.transform.rotation = new Quaternion.fromEulerAnglesXYZ(0.0, time / 1000, 0.0);
      });

      renderer.render(camera);

      window.requestAnimationFrame(update);
    }

    window.requestAnimationFrame(update);
  });
}
