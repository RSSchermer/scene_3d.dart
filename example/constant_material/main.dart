import 'dart:html';
import 'dart:math';

import 'package:bagl/bagl.dart';
import 'package:scene_3d/camera.dart';
import 'package:scene_3d/material.dart';
import 'package:scene_3d/quaternion.dart';
import 'package:scene_3d/rendering.dart';
import 'package:scene_3d/scene.dart';
import 'package:scene_3d/shape.dart';

main() {
  var vertices = new VertexArray([
    // Back
    new Vertex({
      'position': new Vector4(-5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(1.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, 5.0, -5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, 5.0, -5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, 5.0, -5.0, 1.0),
      'texCoord': new Vector2(0.0, 0.0)
    }),

    // Left
    new Vertex({
      'position': new Vector4(-5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, 5.0, -5.0, 1.0),
      'texCoord': new Vector2(0.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, -5.0, 5.0, 1.0),
      'texCoord': new Vector2(1.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    }),

    // Right
    new Vertex({
      'position': new Vector4(5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(1.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, 5.0, -5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(0.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(1.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(0.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, -5.0, 5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),

    // Top
    new Vertex({
      'position': new Vector4(-5.0, 5.0, -5.0, 1.0),
      'texCoord': new Vector2(0.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(1.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, 5.0, -5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, 5.0, -5.0, 1.0),
      'texCoord': new Vector2(0.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(1.0, 1.0)
    }),

    // Bottom
    new Vertex({
      'position': new Vector4(-5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(0.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, -5.0, 5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, -5.0, -5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, -5.0, 5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, -5.0, 5.0, 1.0),
      'texCoord': new Vector2(1.0, 1.0)
    }),

    // Front
    new Vertex({
      'position': new Vector4(-5.0, -5.0, 5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, -5.0, 5.0, 1.0),
      'texCoord': new Vector2(1.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(0.0, 0.0)
    }),
    new Vertex({
      'position': new Vector4(-5.0, -5.0, 5.0, 1.0),
      'texCoord': new Vector2(0.0, 1.0)
    }),
    new Vertex({
      'position': new Vector4(5.0, 5.0, 5.0, 1.0),
      'texCoord': new Vector2(1.0, 0.0)
    })
  ]);

  var triangles = new Triangles(vertices, new IndexList.incrementing(36));
  var material = new ConstantMaterial()
    ..emissionColor = new Vector3(1.0, 0.0, 0.0);
  var shape = new ConstantTrianglesShape(triangles, material)
    ..rotation = new Quaternion.fromEulerAnglesXYZ(0.5 * PI, 0.5 * PI, 0.0);
  var camera = new PerspectiveCamera(0.3 * PI, 1.0, 1.0, 100.0)
    ..position = new Vector4(0.0, 0.0, 20.0, 1.0);
  var scene = new Scene();

  scene.objects.addAll([shape, camera]);

  var canvas = document.querySelector('#main_canvas');
  var renderer = new WebGLSceneRenderer(scene, canvas);

  renderer.render(camera);
}
