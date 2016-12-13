part of shape;

/// 3D shape consisting of geometric primitives for which the shading techniques
/// and parameters are described by a [Material].
///
/// A [PrimitivesShape] consists of a set of geometric [primitives] (points,
/// lines or triangles). The shading techniques and parameters that are to be
/// used to render the [primitives] are described by its [material].
abstract class PrimitivesShape<Primitive> {
  /// A mutable label for this [PrimitivesShape].
  String name;

  /// The name of the position attribute on the vertices that define the
  /// geometry of this [PrimitivesShape].
  String get positionAttributeName;

  /// The sequence of geometric primitives that makes up this
  /// [PrimitivesShape].
  PrimitiveSequence<Primitive> get primitives;

  Transform get transform;

  /// The [Material] that controls the appearance of the [primitives].
  Material get material;
}

class PointsShape implements PrimitivesShape<Point> {
  String name;

  final Points primitives;

  final String positionAttributeName;

  final Transform transform = new Transform();

  PointMaterial material;

  factory PointsShape(Points primitives, Material material,
      {String positionAttributeName: 'position'}) {
    final vertexArray = primitives.vertexArray;
    final positionAttribute = vertexArray.attributes[positionAttributeName];

    if (positionAttribute == null || positionAttribute is! Vector4Attribute) {
      throw new ArgumentError('The position attribute "$positionAttributeName" '
          'did not resolve to a Vector4Attribute on the provided '
          '`primitives`.');
    } else {
      return new PointsShape._internal(
          primitives, material, positionAttributeName);
    }
  }

  PointsShape._internal(
      this.primitives, this.material, this.positionAttributeName);
}

class LinesShape implements PrimitivesShape<Line> {
  String name;

  final Lines primitives;

  final String positionAttributeName;

  final Transform transform = new Transform();

  LineMaterial material;

  factory LinesShape(Lines primitives, Material material,
      {String positionAttributeName: 'position'}) {
    final vertexArray = primitives.vertexArray;
    final positionAttribute = vertexArray.attributes[positionAttributeName];

    if (positionAttribute == null || positionAttribute is! Vector4Attribute) {
      throw new ArgumentError('The position attribute "$positionAttributeName" '
          'did not resolve to a Vector4Attribute on the provided '
          '`primitives`.');
    } else {
      return new LinesShape._internal(
          primitives, material, positionAttributeName);
    }
  }

  LinesShape._internal(
      this.primitives, this.material, this.positionAttributeName);
}

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
