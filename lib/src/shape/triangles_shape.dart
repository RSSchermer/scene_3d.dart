part of shape;

class TrianglesShape implements PrimitivesShape<Triangle> {
  String name;

  final String positionAttributeName;

  final String normalAttributeName;

  final String tangentAttributeName;

  final String bitangentAttributeName;

  final String texCoordAttributeName;

  Triangles _primitives;

  final Vector4Attribute _positionAttribute;

  Vector3Attribute _normalAttribute;

  Vector3Attribute _tangentAttribute;

  Vector3Attribute _bitangentAttribute;

  Vector2Attribute _texCoordAttribute;

  SurfaceMaterial material;

  final Transform transform = new Transform();

  factory TrianglesShape(Triangles primitives, Material material,
      {String positionAttributeName: 'position',
      String normalAttributeName: 'normal',
      String tangentAttributeName: 'tangent',
      String bitangentAttributeName: 'bitangent',
      String texCoordAttributeName: 'texCoord'}) {
    final vertexArray = primitives.vertexArray;
    final positionAttribute = vertexArray.attributes[positionAttributeName];
    final normalAttribute = vertexArray.attributes[normalAttributeName];
    final tangentAttribute = vertexArray.attributes[tangentAttributeName];
    final bitangentAttribute = vertexArray.attributes[bitangentAttributeName];
    final texCoordAttribute = vertexArray.attributes[texCoordAttributeName];

    if (positionAttribute == null || positionAttribute is! Vector4Attribute) {
      throw new ArgumentError('The position attribute "$positionAttributeName" '
          'did not resolve to a Vector4Attribute on the provided '
          '`primitives`.');
    } else if (normalAttribute != null &&
        normalAttribute is! Vector3Attribute) {
      throw new ArgumentError('The normal attribute "$normalAttributeName" '
          'did not resolve to a Vector3Attribute on the provided '
          '`primitives`.');
    } else if (tangentAttribute != null &&
        tangentAttribute is! Vector3Attribute) {
      throw new ArgumentError('The tangent attribute "$tangentAttributeName" '
          'did not resolve to a Vector3Attribute on the provided '
          '`primitives`.');
    } else if (bitangentAttribute != null &&
        bitangentAttribute is! Vector3Attribute) {
      throw new ArgumentError('The bttangent attribute '
          '"$bitangentAttributeName" did not resolve to a Vector3Attribute on '
          'the provided `primitives`.');
    } else if (texCoordAttribute != null &&
        texCoordAttribute is! Vector2Attribute) {
      throw new ArgumentError('The texCoord attribute "$texCoordAttributeName" '
          'did not resolve to a Vector3Attribute on the provided '
          '`primitives`.');
    } else {
      return new TrianglesShape._internal(
          primitives,
          material,
          positionAttributeName,
          normalAttributeName,
          tangentAttributeName,
          bitangentAttributeName,
          texCoordAttributeName,
          positionAttribute,
          normalAttribute,
          tangentAttribute,
          bitangentAttribute,
          texCoordAttribute);
    }
  }

  factory TrianglesShape.quad(double width, double height, SurfaceMaterial material) {
    final halfWidth = width / 2;
    final halfHeight = height / 2;

    final pos0 = new Vector3(-halfWidth, halfHeight, 0.0);
    final pos1 = new Vector3(-halfWidth, -halfHeight, 0.0);
    final pos2 = new Vector3(halfWidth, -halfHeight, 0.0);
    final pos3 = new Vector3(halfWidth, halfHeight, 0.0);

    final attributeData = new AttributeDataTable.fromList(15, [
      // position                     texCoord    normal            tangent           bitangent
      pos0.x, pos0.y, pos0.z, 1.0,    0.0, 0.0,   0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,   0.0, -1.0, 0.0,
      pos1.x, pos1.y, pos1.z, 1.0,    0.0, 1.0,   0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,   0.0, -1.0, 0.0,
      pos3.x, pos3.y, pos3.z, 1.0,    1.0, 0.0,   0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,   0.0, -1.0, 0.0,

      pos3.x, pos3.y, pos3.z, 1.0,    1.0, 0.0,   0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,   0.0, -1.0, 0.0,
      pos1.x, pos1.y, pos1.z, 1.0,    0.0, 1.0,   0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,   0.0, -1.0, 0.0,
      pos2.x, pos2.y, pos2.z, 1.0,    1.0, 1.0,   0.0, 0.0, 1.0,    -1.0, 0.0, 0.0,   0.0, -1.0, 0.0,
    ]);

    final vertices = new VertexArray.fromAttributes(<String, VertexAttribute>{
      'position': new Vector4Attribute(attributeData),
      'texCoord': new Vector2Attribute(attributeData, offset: 4),
      'normal': new Vector3Attribute(attributeData, offset: 6),
      'tangent': new Vector3Attribute(attributeData, offset: 9),
      'bitangent': new Vector3Attribute(attributeData, offset: 12)
    });

    final triangles = new Triangles(vertices);

    return new TrianglesShape(triangles, material);
  }

  factory TrianglesShape.box(double width, double height, double depth, SurfaceMaterial material) {
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
      // position                           texCoord     normal              tangent             bitangent

      // Front face triangle vertices (2 triangles)
      posFTL.x, posFTL.y, posFTL.z, 1.0,    0.0, 0.0,    0.0, 0.0, 1.0,      -1.0, 0.0, 0.0,     0.0, -1.0, 0.0,
      posFBL.x, posFBL.y, posFBL.z, 1.0,    0.0, 1.0,    0.0, 0.0, 1.0,      -1.0, 0.0, 0.0,     0.0, -1.0, 0.0,
      posFTR.x, posFTR.y, posFTR.z, 1.0,    1.0, 0.0,    0.0, 0.0, 1.0,      -1.0, 0.0, 0.0,     0.0, -1.0, 0.0,

      posFTR.x, posFTR.y, posFTR.z, 1.0,    1.0, 0.0,    0.0, 0.0, 1.0,      -1.0, 0.0, 0.0,     0.0, -1.0, 0.0,
      posFBL.x, posFBL.y, posFBL.z, 1.0,    0.0, 1.0,    0.0, 0.0, 1.0,      -1.0, 0.0, 0.0,     0.0, -1.0, 0.0,
      posFBR.x, posFBR.y, posFBR.z, 1.0,    1.0, 1.0,    0.0, 0.0, 1.0,      -1.0, 0.0, 0.0,     0.0, -1.0, 0.0,

      // Back face triangle vertices (2 triangles)
      posBTR.x, posBTR.y, posBTR.z, 1.0,    0.0, 0.0,    0.0, 0.0, -1.0,     1.0, 0.0, 0.0,      0.0, -1.0, 0.0,
      posBBR.x, posBBR.y, posBBR.z, 1.0,    0.0, 1.0,    0.0, 0.0, -1.0,     1.0, 0.0, 0.0,      0.0, -1.0, 0.0,
      posBTL.x, posBTL.y, posBTL.z, 1.0,    1.0, 0.0,    0.0, 0.0, -1.0,     1.0, 0.0, 0.0,      0.0, -1.0, 0.0,

      posBTL.x, posBTL.y, posBTL.z, 1.0,    1.0, 0.0,    0.0, 0.0, -1.0,     1.0, 0.0, 0.0,      0.0, -1.0, 0.0,
      posBBR.x, posBBR.y, posBBR.z, 1.0,    0.0, 1.0,    0.0, 0.0, -1.0,     1.0, 0.0, 0.0,      0.0, -1.0, 0.0,
      posBBL.x, posBBL.y, posBBL.z, 1.0,    1.0, 1.0,    0.0, 0.0, -1.0,     1.0, 0.0, 0.0,      0.0, -1.0, 0.0,

      // Top face triangle vertices (2 triangles)
      posBTL.x, posBTL.y, posBTL.z, 1.0,    0.0, 0.0,    0.0, 1.0, 0.0,      -1.0, 0.0, 0.0,     0.0, 0.0, 1.0,
      posFTL.x, posFTL.y, posFTL.z, 1.0,    0.0, 1.0,    0.0, 1.0, 0.0,      -1.0, 0.0, 0.0,     0.0, 0.0, 1.0,
      posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0,    0.0, 1.0, 0.0,      -1.0, 0.0, 0.0,     0.0, 0.0, 1.0,

      posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0,    0.0, 1.0, 0.0,      -1.0, 0.0, 0.0,     0.0, 0.0, 1.0,
      posFTL.x, posFTL.y, posFTL.z, 1.0,    0.0, 1.0,    0.0, 1.0, 0.0,      -1.0, 0.0, 0.0,     0.0, 0.0, 1.0,
      posFTR.x, posFTR.y, posFTR.z, 1.0,    1.0, 1.0,    0.0, 1.0, 0.0,      -1.0, 0.0, 0.0,     0.0, 0.0, 1.0,

      // Bottom face triangle vertices (2 triangles)
      posBBR.x, posBBR.y, posBBR.z, 1.0,    0.0, 0.0,    0.0, -1.0, 0.0,     1.0, 0.0, 0.0,      0.0, 0.0, 1.0,
      posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, 1.0,    0.0, -1.0, 0.0,     1.0, 0.0, 0.0,      0.0, 0.0, 1.0,
      posBBL.x, posBBL.y, posBBL.z, 1.0,    1.0, 0.0,    0.0, -1.0, 0.0,     1.0, 0.0, 0.0,      0.0, 0.0, 1.0,

      posBBL.x, posBBL.y, posBBL.z, 1.0,    1.0, 0.0,    0.0, -1.0, 0.0,     1.0, 0.0, 0.0,      0.0, 0.0, 1.0,
      posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, 1.0,    0.0, -1.0, 0.0,     1.0, 0.0, 0.0,      0.0, 0.0, 1.0,
      posFBL.x, posFBL.y, posFBL.z, 1.0,    1.0, 1.0,    0.0, -1.0, 0.0,     1.0, 0.0, 0.0,      0.0, 0.0, 1.0,

      // Left face triangle vertices (2 triangles)
      posBTL.x, posBTL.y, posBTL.z, 1.0,    0.0, 0.0,    -1.0, 0.0, 0.0,     0.0, 0.0, -1.0,     0.0, -1.0, 0.0,
      posBBL.x, posBBL.y, posBBL.z, 1.0,    0.0, 1.0,    -1.0, 0.0, 0.0,     0.0, 0.0, -1.0,     0.0, -1.0, 0.0,
      posFTL.x, posFTL.y, posFTL.z, 1.0,    1.0, 0.0,    -1.0, 0.0, 0.0,     0.0, 0.0, -1.0,     0.0, -1.0, 0.0,

      posFTL.x, posFTL.y, posFTL.z, 1.0,    1.0, 0.0,    -1.0, 0.0, 0.0,     0.0, 0.0, -1.0,     0.0, -1.0, 0.0,
      posBBL.x, posBBL.y, posBBL.z, 1.0,    0.0, 1.0,    -1.0, 0.0, 0.0,     0.0, 0.0, -1.0,     0.0, -1.0, 0.0,
      posFBL.x, posFBL.y, posFBL.z, 1.0,    1.0, 1.0,    -1.0, 0.0, 0.0,     0.0, 0.0, -1.0,     0.0, -1.0, 0.0,

      // Right face triangle vertices (2 triangles)
      posFTR.x, posFTR.y, posFTR.z, 1.0,    0.0, 0.0,    1.0, 0.0, 0.0,      0.0, 0.0, 1.0,      0.0, -1.0, 0.0,
      posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, 1.0,    1.0, 0.0, 0.0,      0.0, 0.0, 1.0,      0.0, -1.0, 0.0,
      posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0,    1.0, 0.0, 0.0,      0.0, 0.0, 1.0,      0.0, -1.0, 0.0,

      posBTR.x, posBTR.y, posBTR.z, 1.0,    1.0, 0.0,    1.0, 0.0, 0.0,      0.0, 0.0, 1.0,      0.0, -1.0, 0.0,
      posFBR.x, posFBR.y, posFBR.z, 1.0,    0.0, 1.0,    1.0, 0.0, 0.0,      0.0, 0.0, 1.0,      0.0, -1.0, 0.0,
      posBBR.x, posBBR.y, posBBR.z, 1.0,    1.0, 1.0,    1.0, 0.0, 0.0,      0.0, 0.0, 1.0,      0.0, -1.0, 0.0,
    ]);

    final vertices = new VertexArray.fromAttributes(<String, VertexAttribute>{
      'position': new Vector4Attribute(attributeData),
      'texCoord': new Vector2Attribute(attributeData, offset: 4),
      'normal': new Vector3Attribute(attributeData, offset: 6),
      'tangent': new Vector3Attribute(attributeData, offset: 9),
      'bitangent': new Vector3Attribute(attributeData, offset: 12)
    });

    final triangles = new Triangles(vertices);

    return new TrianglesShape(triangles, material);
  }

  TrianglesShape._internal(
      this._primitives,
      this.material,
      this.positionAttributeName,
      this.normalAttributeName,
      this.tangentAttributeName,
      this.bitangentAttributeName,
      this.texCoordAttributeName,
      this._positionAttribute,
      this._normalAttribute,
      this._tangentAttribute,
      this._bitangentAttribute,
      this._texCoordAttribute);

  Triangles get primitives => _primitives;

  bool get hasNormalAttribute => _normalAttribute != null;

  bool get hasTexCoordAttribute => _texCoordAttribute != null;

  bool get hasTangentAttribute => _tangentAttribute != null;

  bool get hasBitangentAttribute => _bitangentAttribute != null;

  void updateNormals() {
    if (_normalAttribute == null) {
      // Create normal attribute where each normal is set to (0.0, 0.0, 0.0)
      final vertexArray = _primitives.vertexArray;
      final normalData = new AttributeDataTable(3, vertexArray.length);

      _normalAttribute = new Vector3Attribute(normalData);

      final attributeMap =
      new Map<String, VertexAttribute>.from(vertexArray.attributes);

      attributeMap[normalAttributeName] = _normalAttribute;

      final newVertexArray = new VertexArray.fromAttributes(attributeMap);

      _primitives = new Triangles(newVertexArray,
          indexList: _primitives.indexList,
          offset: _primitives.offset,
          count: _primitives.count);
    } else {
      // Reset normals to (0.0, 0.0, 0.0)
      final vertexArray = _primitives.vertexArray;

      for (var triangle in _primitives) {
        final aIndex = vertexArray.indexOf(triangle.a);
        final bIndex = vertexArray.indexOf(triangle.b);
        final cIndex = vertexArray.indexOf(triangle.c);

        _normalAttribute.setValueAtRow(aIndex, new Vector3(0.0, 0.0, 0.0));
        _normalAttribute.setValueAtRow(bIndex, new Vector3(0.0, 0.0, 0.0));
        _normalAttribute.setValueAtRow(cIndex, new Vector3(0.0, 0.0, 0.0));
      }
    }

    final vertexArray = _primitives.vertexArray;

    for (var triangle in _primitives) {
      final aIndex = vertexArray.indexOf(triangle.a);
      final bIndex = vertexArray.indexOf(triangle.b);
      final cIndex = vertexArray.indexOf(triangle.c);

      final aPosition = _positionAttribute.extractValueAtRow(aIndex);
      final bPosition = _positionAttribute.extractValueAtRow(bIndex);
      final cPosition = _positionAttribute.extractValueAtRow(cIndex);

      final normalI =
          (aPosition.y - bPosition.y) * (aPosition.z + bPosition.z) +
              (bPosition.y - cPosition.y) * (bPosition.z + cPosition.z) +
              (cPosition.y - aPosition.y) * (cPosition.z + aPosition.z);
      final normalJ =
          (aPosition.z - bPosition.z) * (aPosition.x + bPosition.x) +
              (bPosition.z - cPosition.z) * (bPosition.x + cPosition.x) +
              (cPosition.z - aPosition.z) * (cPosition.x + aPosition.x);
      final normalK =
          (aPosition.x - bPosition.x) * (aPosition.y + bPosition.y) +
              (bPosition.x - cPosition.x) * (bPosition.y + cPosition.y) +
              (cPosition.x - aPosition.x) * (cPosition.y + aPosition.y);

      final faceNormal = new Vector3(normalI, normalJ, normalK);

      final aNormal = _normalAttribute.extractValueAtRow(aIndex);
      final bNormal = _normalAttribute.extractValueAtRow(bIndex);
      final cNormal = _normalAttribute.extractValueAtRow(cIndex);

      _normalAttribute.setValueAtRow(aIndex, aNormal + faceNormal);
      _normalAttribute.setValueAtRow(bIndex, bNormal + faceNormal);
      _normalAttribute.setValueAtRow(cIndex, cNormal + faceNormal);
    }
  }
}
