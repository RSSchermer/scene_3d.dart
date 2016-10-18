library geometry_generators;

import 'package:bagl/index_geometry.dart';
import 'package:bagl/math.dart';
import 'package:bagl/vertex_data.dart';

Triangles generateQuadTriangles(double width, double height) {
  final halfWidth = width / 2;
  final halfHeight = height / 2;

  final pos0 = new Vector3(-halfWidth, halfHeight, 0.0);
  final pos1 = new Vector3(-halfWidth, -halfHeight, 0.0);
  final pos2 = new Vector3(halfWidth, -halfHeight, 0.0);
  final pos3 = new Vector3(halfWidth, halfHeight, 0.0);

  final attributeData = new AttributeDataTable.fromList(15, [
    // position (vec4)              texCoord (vec2)    normal (vec3)     tangent (vec3)    bitangent (vec3)
    pos0.x, pos0.y, pos0.z, 1.0,    0.0, 0.0,          0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    pos1.x, pos1.y, pos1.z, 1.0,    0.0, 1.0,          0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    pos3.x, pos3.y, pos3.z, 1.0,    1.0, 0.0,          0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,

    pos3.x, pos3.y, pos3.z, 1.0,    1.0, 0.0,          0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    pos1.x, pos1.y, pos1.z, 1.0,    0.0, 1.0,          0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    pos2.x, pos2.y, pos2.z, 1.0,    1.0, 1.0,          0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
  ]);

  final vertices = new VertexArray.fromAttributes(<String, VertexAttribute>{
    'position': new Vector4Attribute(attributeData),
    'texCoord': new Vector2Attribute(attributeData, offset: 4),
    'normal': new Vector3Attribute(attributeData, offset: 6),
    'tangent': new Vector3Attribute(attributeData, offset: 9),
    'bitangent': new Vector3Attribute(attributeData, offset: 12)
  });

  return new Triangles(vertices, new IndexList.incrementing(6));
}

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

  final attributeData = new AttributeDataTable.fromList(15, [
    // position (vec4)                    texCoord (vec2)    normal (vec3)      tangent (vec3)     bitangent (vec3)

    // Front face triangle vertices (2 triangles)
    posFTL.x, posFTL.y, posFTL.z, 1.0,    0.0, 0.0,          0.0, 0.0, 1.0,     -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    posFBL.x, posFBL.y, posFBL.z, 1.0,    0.0, 1.0,          0.0, 0.0, 1.0,     -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    posFTR.x, posFTR.y, posFTR.z, 1.0,    1.0, 0.0,          0.0, 0.0, 1.0,     -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,

    posFTR.x, posFTR.y, posFTR.z, 1.0,    1.0, 0.0,          0.0, 0.0, 1.0,     -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    posFBL.x, posFBL.y, posFBL.z, 1.0,    0.0, 1.0,          0.0, 0.0, 1.0,     -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    1.0, 1.0,          0.0, 0.0, 1.0,     -1.0, 0.0, 0.0,    0.0, -1.0, 0.0,

    // Back face triangle vertices (2 triangles)
    posBTR.x, posBTR.y, posBTR.z, 1.0,    0.0, 0.0,          0.0, 0.0, -1.0,    1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    posBBR.x, posBBR.y, posBBR.z, 1.0,    0.0, 1.0,          0.0, 0.0, -1.0,    1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    posBTL.x, posBTL.y, posBTL.z, 1.0,    1.0, 0.0,          0.0, 0.0, -1.0,    1.0, 0.0, 0.0,    0.0, -1.0, 0.0,

    posBTL.x, posBTL.y, posBTL.z, 1.0,    1.0, 0.0,          0.0, 0.0, -1.0,    1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    posBBR.x, posBBR.y, posBBR.z, 1.0,    0.0, 1.0,          0.0, 0.0, -1.0,    1.0, 0.0, 0.0,    0.0, -1.0, 0.0,
    posBBL.x, posBBL.y, posBBL.z, 1.0,    1.0, 1.0,          0.0, 0.0, -1.0,    1.0, 0.0, 0.0,    0.0, -1.0, 0.0,

    // Top face triangle vertices (2 triangles)
    posBTL.x, posBTL.y, posBTL.z, 1.0,    0.0, 0.0,          0.0, 1.0, 0.0,     -1.0, 0.0, 0.0,    0.0, 0.0, 1.0,
    posFTL.x, posFTL.y, posFTL.z, 1.0,    0.0, 1.0,          0.0, 1.0, 0.0,     -1.0, 0.0, 0.0,    0.0, 0.0, 1.0,
    posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0,          0.0, 1.0, 0.0,     -1.0, 0.0, 0.0,    0.0, 0.0, 1.0,

    posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0,          0.0, 1.0, 0.0,     -1.0, 0.0, 0.0,    0.0, 0.0, 1.0,
    posFTL.x, posFTL.y, posFTL.z, 1.0,    0.0, 1.0,          0.0, 1.0, 0.0,     -1.0, 0.0, 0.0,    0.0, 0.0, 1.0,
    posFTR.x, posFTR.y, posFTR.z, 1.0,    1.0, 1.0,          0.0, 1.0, 0.0,     -1.0, 0.0, 0.0,    0.0, 0.0, 1.0,

    // Bottom face triangle vertices (2 triangles)
    posBBR.x, posBBR.y, posBBR.z, 1.0,    0.0, 0.0,          0.0, -1.0, 0.0,    1.0, 0.0, 0.0,    0.0, 0.0, 1.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, 1.0,          0.0, -1.0, 0.0,    1.0, 0.0, 0.0,    0.0, 0.0, 1.0,
    posBBL.x, posBBL.y, posBBL.z, 1.0,    1.0, 0.0,          0.0, -1.0, 0.0,    1.0, 0.0, 0.0,    0.0, 0.0, 1.0,

    posBBL.x, posBBL.y, posBBL.z, 1.0,    1.0, 0.0,          0.0, -1.0, 0.0,    1.0, 0.0, 0.0,    0.0, 0.0, 1.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, 1.0,          0.0, -1.0, 0.0,    1.0, 0.0, 0.0,    0.0, 0.0, 1.0,
    posFBL.x, posFBL.y, posFBL.z, 1.0,    1.0, 1.0,          0.0, -1.0, 0.0,    1.0, 0.0, 0.0,    0.0, 0.0, 1.0,

    // Left face triangle vertices (2 triangles)
    posBTL.x, posBTL.y, posBTL.z, 1.0,    0.0, 0.0,          -1.0, 0.0, 0.0,    0.0, 0.0, -1.0,    0.0, -1.0, 0.0,
    posBBL.x, posBBL.y, posBBL.z, 1.0,    0.0, 1.0,          -1.0, 0.0, 0.0,    0.0, 0.0, -1.0,    0.0, -1.0, 0.0,
    posFTL.x, posFTL.y, posFTL.z, 1.0,    1.0, 0.0,          -1.0, 0.0, 0.0,    0.0, 0.0, -1.0,    0.0, -1.0, 0.0,

    posFTL.x, posFTL.y, posFTL.z, 1.0,    1.0, 0.0,          -1.0, 0.0, 0.0,    0.0, 0.0, -1.0,    0.0, -1.0, 0.0,
    posBBL.x, posBBL.y, posBBL.z, 1.0,    0.0, 1.0,          -1.0, 0.0, 0.0,    0.0, 0.0, -1.0,    0.0, -1.0, 0.0,
    posFBL.x, posFBL.y, posFBL.z, 1.0,    1.0, 1.0,          -1.0, 0.0, 0.0,    0.0, 0.0, -1.0,    0.0, -1.0, 0.0,

    // Right face triangle vertices (2 triangles)
    posFTR.x, posFTR.y, posFTR.z, 1.0,    0.0, 0.0,          1.0, 0.0, 0.0,     0.0, 0.0, 1.0,     0.0, -1.0, 0.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, 1.0,          1.0, 0.0, 0.0,     0.0, 0.0, 1.0,     0.0, -1.0, 0.0,
    posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0,          1.0, 0.0, 0.0,     0.0, 0.0, 1.0,     0.0, -1.0, 0.0,

    posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0,          1.0, 0.0, 0.0,     0.0, 0.0, 1.0,     0.0, -1.0, 0.0,
    posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, 1.0,          1.0, 0.0, 0.0,     0.0, 0.0, 1.0,     0.0, -1.0, 0.0,
    posBBR.x, posBBR.y, posBBR.z, 1.0,    1.0, 1.0,          1.0, 0.0, 0.0,     0.0, 0.0, 1.0,     0.0, -1.0, 0.0,
  ]);

  final vertices = new VertexArray.fromAttributes(<String, VertexAttribute>{
    'position': new Vector4Attribute(attributeData),
    'texCoord': new Vector2Attribute(attributeData, offset: 4),
    'normal': new Vector3Attribute(attributeData, offset: 6),
    'tangent': new Vector3Attribute(attributeData, offset: 9),
    'bitangent': new Vector3Attribute(attributeData, offset: 12)
  });

  return new Triangles(vertices, new IndexList.incrementing(36));
}
