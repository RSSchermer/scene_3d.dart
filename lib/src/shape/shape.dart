part of shape;

/// 3D shape consisting of geometric primitives for which the shading techniques
/// and parameters are described by a [Material].
///
/// A [MaterialShadedPrimitivesShape] consists of a set of geometric
/// [primitives] (points, lines or triangles). The shading techniques and
/// parameters that are to be used to render the [primitives] are described by
/// the [material].
abstract class MaterialShadedPrimitivesShape {
  /// A mutable label for this [MaterialShadedPrimitivesShape].
  String name;

  Vector3 _position = new Vector3(0.0, 0.0, 0.0);

  Quaternion _rotation = new Quaternion(0.0, 0.0, 0.0, 1.0);

  Vector3 _scale = new Vector3(1.0, 1.0, 1.0);

  Matrix4 _positionTransform;

  Matrix4 _rotationTransform;

  Matrix4 _scaleTransform;

  Matrix4 _worldTransform;

  Matrix3 _normalTransform;

  /// The sequence of geometric primitives that makes up this
  /// [MaterialShadedPrimitivesShape].
  IndexGeometry get primitives;

  /// The [Material] that controls the appearance of the [primitives].
  Material get material;

  /// The position of this [MaterialShadedPrimitivesShape] in a [Scene].
  Vector3 get position => _position;

  void set position(Vector3 value) {
    _position = value;
    _positionTransform = null;
    _worldTransform = null;
  }

  /// The rotation of this [MaterialShadedPrimitivesShape] in a [Scene].
  Quaternion get rotation => _rotation;

  void set rotation(Quaternion value) {
    _rotation = value;
    _rotationTransform = null;
    _worldTransform = null;
    _normalTransform = null;
  }

  /// The scale of this [MaterialShadedPrimitivesShape] in a [Scene].
  Vector3 get scale => _scale;

  void set scale(Vector3 value) {
    _scale = value;
    _scaleTransform = null;
    _worldTransform = null;
    _normalTransform = null;
  }

  /// Matrix that transforms coordinates local to this
  /// [MaterialShadedPrimitivesShape] into world coordinates.
  ///
  /// Combines this [MaterialShadedPrimitivesShape]'s [position], [rotation] and
  /// [scale] into a single [Matrix4] transformation. When this transform is
  /// applied to a [Vector4] that represents coordinates relative to this
  /// [MaterialShadedPrimitivesShape] origin, then these coordinates are
  /// transformed into coordinates that are relative to a [Scene]'s world
  /// origin.
  Matrix4 get worldTransform {
    _positionTransform ??=
    new Matrix4.translation(position.x, position.y, position.z);

    _rotationTransform ??= rotation.asMatrix4();

    _scaleTransform ??= new Matrix4.scale(scale.x, scale.y, scale.z);

    _worldTransform ??=
        _positionTransform * _scaleTransform * _rotationTransform;

    return _worldTransform;
  }

  Matrix3 get normalTransform {
    if (_normalTransform == null) {
      final w = worldTransform;
      final m = new Matrix3(
          w.r0c0,
          w.r0c1,
          w.r0c2,
          w.r1c0,
          w.r1c1,
          w.r1c2,
          w.r2c0,
          w.r2c1,
          w.r2c2);

      _normalTransform = m.inverse.transpose;
    }

    return _normalTransform;
  }
}

/// A [MaterialShadedPrimitivesShape] whose appearance is described by a
/// [ProgramMaterial].
class ProgramPrimitivesShape extends MaterialShadedPrimitivesShape {
  final IndexGeometry primitives;

  final ProgramMaterial material;

  /// Instantiates a new [ProgramPrimitivesShape] from the [primitives] and the
  /// [material].
  ProgramPrimitivesShape(this.primitives, this.material);
}

/// A [MaterialShadedPrimitivesShape] described by [Point] primitives whose
/// appearance is described by a [PointMaterial].
class PointsShape extends MaterialShadedPrimitivesShape {
  final IndexGeometry<Point> primitives;

  final PointMaterial material;

  /// Instantiates a new [PointsShape] from the [primitives] and the
  /// [material].
  PointsShape(this.primitives, this.material) {
    if (!primitives.vertices.hasAttribute('position')) {
      throw new ArgumentError('The vertices for the primitives must define a '
          '"position" attribute.');
    } else if (!primitives.vertices.hasAttribute('color')) {
      throw new ArgumentError('The vertices for the primitives must define a '
          '"color" attribute.');
    }
  }
}

/// A [MaterialShadedPrimitivesShape] described by [Line] primitives whose
/// appearance is described by a [LineMaterial].
class LinesShape extends MaterialShadedPrimitivesShape {
  final IndexGeometry<Line> primitives;

  final LineMaterial material;

  /// Instantiates a new [LineMaterial] from the [primitives] and the
  /// [material].
  LinesShape(this.primitives, this.material) {
    if (!primitives.vertices.hasAttribute('position')) {
      throw new ArgumentError('The vertices for the primitives must define a '
          '"position" attribute.');
    } else if (!primitives.vertices.hasAttribute('color')) {
      throw new ArgumentError('The vertices for the primitives must define a '
          '"color" attribute.');
    }
  }
}

/// A [MaterialShadedPrimitivesShape] described by [Triangle] primitives whose
/// appearance is described by a [ConstantMaterial].
class ConstantTrianglesShape extends MaterialShadedPrimitivesShape {
  final IndexGeometry<Triangle> primitives;

  final ConstantMaterial material;

  /// Instantiates a new [ConstantTrianglesShape] from the [primitives] and the
  /// [material].
  ConstantTrianglesShape(this.primitives, this.material) {
    if (!primitives.vertices.hasAttribute('position')) {
      throw new ArgumentError('The vertices for the primitives must define a '
          '"position" attribute.');
    } else if (!primitives.vertices.hasAttribute('texCoord')) {
      throw new ArgumentError('The vertices for the primitives must define a '
          '"texCoord" attribute.');
    }
  }
}

/// A [MaterialShadedPrimitivesShape] described by [Triangle] primitives whose
/// appearance is described by a [LambertMaterial].
class LambertTrianglesShape extends MaterialShadedPrimitivesShape {
  final IndexGeometry<Triangle> primitives;

  final LambertMaterial material;

  /// Instantiates a new [LambertTrianglesShape] from the [primitives] and the
  /// [material].
  LambertTrianglesShape(this.primitives, this.material);
}

/// A [MaterialShadedPrimitivesShape] described by [Triangle] primitives whose
/// appearance is described by a [PhongMaterial].
class PhongTrianglesShape extends MaterialShadedPrimitivesShape {
  final IndexGeometry<Triangle> primitives;

  final PhongMaterial material;

  /// Instantiates a new [PhongTrianglesShape] from the [primitives] and the
  /// [material].
  PhongTrianglesShape(this.primitives, this.material);
}

/// A [MaterialShadedPrimitivesShape] described by [Triangle] primitives whose
/// appearance is described by a [BlinnMaterial].
class BlinnTrianglesShape extends MaterialShadedPrimitivesShape {
  final IndexGeometry<Triangle> primitives;

  final BlinnMaterial material;

  /// Instantiates a new [BlinnTrianglesShape] from the [primitives] and the
  /// [material].
  BlinnTrianglesShape(this.primitives, this.material);
}
