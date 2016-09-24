library geometry_generators;

import 'package:bagl/index_geometry.dart';
import 'package:bagl/math.dart';
import 'package:bagl/vertex_data.dart';

Triangles generateBoxTriangles(double width, double height, double depth) {
  final halfWidth = width / 2;
  final halfHeight = height / 2;
  final halfDepth = depth / 2;

  final posFTL = new Vector3(-halfWidth, halfHeight, halfDepth);
  final posFTR = new Vector3(halfWidth, halfHeight, halfDepth);
  final posFBL = new Vector3(-halfWidth, -halfHeight, halfDepth);
  final posFBR = new Vector3(halfWidth, -halfHeight, halfDepth);

  final posBTL = new Vector3(-halfWidth, halfHeight, -halfDepth);
  final posBTR = new Vector3(halfWidth, halfHeight, -halfDepth);
  final posBBL = new Vector3(-halfWidth, -halfHeight, -halfDepth);
  final posBBR = new Vector3(halfWidth, -halfHeight, -halfDepth);

  final attributeData = new AttributeDataTable.fromList(9, [
    // position (vec4)                    normal (vec3)     texCoord (vec2)

    // Front face triangle vertices (2 triangles)
    posFTL.x, posFTL.y, posFTL.z, 1.0,    0.0, 0.0, 1.0,    0.0, 0.0,
    posFBL.x, posFBL.y, posFBL.z, 1.0,    0.0, 0.0, 1.0,    0.0, 1.0,
    posFTR.x, posFTR.y, posFTR.z, 1.0,    0.0, 0.0, 1.0,    1.0, 0.0,

    posFTR.x, posFTR.y, posFTR.z, 1.0,    0.0, 0.0, 1.0,    1.0, 0.0,
    posFBL.x, posFBL.y, posFBL.z, 1.0,    0.0, 0.0, 1.0,    0.0, 1.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, 0.0, 1.0,    1.0, 1.0,

    // Back face triangle vertices (2 triangles)
    posBTR.x, posBTR.y, posBTR.z, 1.0,    0.0, 0.0, -1.0,   0.0, 0.0,
    posBBR.x, posBBR.y, posBBR.z, 1.0,    0.0, 0.0, -1.0,   0.0, 1.0,
    posBTL.x, posBTL.y, posBTL.z, 1.0,    0.0, 0.0, -1.0,   1.0, 0.0,

    posBTL.x, posBTL.y, posBTL.z, 1.0,    0.0, 0.0, -1.0,   1.0, 0.0,
    posBBR.x, posBBR.y, posBBR.z, 1.0,    0.0, 0.0, -1.0,   0.0, 1.0,
    posBBL.x, posBBL.y, posBBL.z, 1.0,    0.0, 0.0, -1.0,   1.0, 1.0,

    // Top face triangle vertices (2 triangles)
    posBTL.x, posBTL.y, posBTL.z, 1.0,    0.0, 1.0, 0.0,    0.0, 0.0,
    posFTL.x, posFTL.y, posFTL.z, 1.0,    0.0, 1.0, 0.0,    0.0, 1.0,
    posBTR.x, posBTR.y, posBTR.z, 1.0,    0.0, 1.0, 0.0,    1.0, 0.0,

    posBTR.x, posBTR.y, posBTR.z, 1.0,    0.0, 1.0, 0.0,    1.0, 0.0,
    posFTL.x, posFTL.y, posFTL.z, 1.0,    0.0, 1.0, 0.0,    0.0, 1.0,
    posFTR.x, posFTR.y, posFTR.z, 1.0,    0.0, 1.0, 0.0,    1.0, 1.0,

    // Bottom face triangle vertices (2 triangles)
    posBBR.x, posBBR.y, posBBR.z, 1.0,    0.0, -1.0, 0.0,   0.0, 0.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, -1.0, 0.0,   0.0, 1.0,
    posBBL.x, posBBL.y, posBBL.z, 1.0,    0.0, -1.0, 0.0,   1.0, 0.0,

    posBBL.x, posBBL.y, posBBL.z, 1.0,    0.0, -1.0, 0.0,   1.0, 0.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, -1.0, 0.0,   0.0, 1.0,
    posFBL.x, posFBL.y, posFBL.z, 1.0,    0.0, -1.0, 0.0,   1.0, 1.0,

    // Left face triangle vertices (2 triangles)
    posBTL.x, posBTL.y, posBTL.z, 1.0,    -1.0, 0.0, 0.0,   0.0, 0.0,
    posBBL.x, posBBL.y, posBBL.z, 1.0,    -1.0, 0.0, 0.0,   0.0, 1.0,
    posFTL.x, posFTL.y, posFTL.z, 1.0,    -1.0, 0.0, 0.0,   1.0, 0.0,

    posFTL.x, posFTL.y, posFTL.z, 1.0,    -1.0, 0.0, 0.0,   1.0, 0.0,
    posBBL.x, posBBL.y, posBBL.z, 1.0,    -1.0, 0.0, 0.0,   0.0, 1.0,
    posFBL.x, posFBL.y, posFBL.z, 1.0,    -1.0, 0.0, 0.0,   1.0, 1.0,

    // Right face triangle vertices (2 triangles)
    posFTR.x, posFTR.y, posFTR.z, 1.0,    1.0, 0.0, 0.0,    0.0, 0.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    1.0, 0.0, 0.0,    0.0, 1.0,
    posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0, 0.0,    1.0, 0.0,

    posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0, 0.0,    1.0, 0.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    1.0, 0.0, 0.0,    0.0, 1.0,
    posBBR.x, posBBR.y, posBBR.z, 1.0,    1.0, 0.0, 0.0,    1.0, 1.0
  ]);

  final vertices = new VertexArray.fromAttributes({
    'position': new Vector4Attribute(attributeData),
    'normal': new Vector3Attribute(attributeData, offset: 4),
    'texCoord': new Vector2Attribute(attributeData, offset: 7),
  });

  return new Triangles(vertices, new IndexList.incrementing(36));
}
