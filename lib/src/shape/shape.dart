part of shape;

/// 3D shape consisting of geometric primitives for which the shading techniques
/// and parameters are described by a [Material].
///
/// A [PrimitivesShape] consists of a set of geometric [primitives] (points,
/// lines or triangles). The shading techniques and parameters that are to be
/// used to render the [primitives] are described by its [material].
abstract class PrimitivesShape {
  /// A mutable label for this [PrimitivesShape].
  String name;

  /// The sequence of geometric primitives that makes up this
  /// [PrimitivesShape].
  IndexGeometry get primitives;

  Transform get transform;

  /// The [Material] that controls the appearance of the [primitives].
  Material get material;
}

/// A [PrimitivesShape] whose appearance is described by a [ProgramMaterial].
class ProgramPrimitivesShape implements PrimitivesShape {
  String name;

  final IndexGeometry primitives;

  final ProgramMaterial material;

  final Transform transform = new Transform();

  /// Instantiates a new [ProgramPrimitivesShape] from the [primitives] and the
  /// [material].
  ProgramPrimitivesShape(this.primitives, this.material);
}

/// A [PrimitivesShape] described by [Point] primitives whose appearance is
/// described by a [PointMaterial].
class PointsShape implements PrimitivesShape {
  String name;

  final IndexGeometry<Point> primitives;

  final PointMaterial material;

  final Transform transform = new Transform();

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

/// A [PrimitivesShape] described by [Line] primitives whose
/// appearance is described by a [LineMaterial].
class LinesShape implements PrimitivesShape {
  String name;

  final IndexGeometry<Line> primitives;

  final LineMaterial material;

  final Transform transform = new Transform();

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

/// A [PrimitivesShape] described by [Triangle] primitives whose
/// appearance is described by a [ConstantMaterial].
class ConstantTrianglesShape implements PrimitivesShape {
  String name;

  final IndexGeometry<Triangle> primitives;

  final ConstantMaterial material;

  final Transform transform = new Transform();

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

/// A [PrimitivesShape] described by [Triangle] primitives whose
/// appearance is described by a [LambertMaterial].
class LambertTrianglesShape implements PrimitivesShape {
  String name;

  final IndexGeometry<Triangle> primitives;

  final LambertMaterial material;

  final Transform transform = new Transform();

  /// Instantiates a new [LambertTrianglesShape] from the [primitives] and the
  /// [material].
  LambertTrianglesShape(this.primitives, this.material);
}

/// A [PrimitivesShape] described by [Triangle] primitives whose
/// appearance is described by a [PhongMaterial].
class PhongTrianglesShape implements PrimitivesShape {
  String name;

  final IndexGeometry<Triangle> primitives;

  final PhongMaterial material;

  final Transform transform = new Transform();

  /// Instantiates a new [PhongTrianglesShape] from the [primitives] and the
  /// [material].
  PhongTrianglesShape(this.primitives, this.material);
}

/// A [PrimitivesShape] described by [Triangle] primitives whose
/// appearance is described by a [BlinnMaterial].
class BlinnTrianglesShape implements PrimitivesShape {
  String name;

  final IndexGeometry<Triangle> primitives;

  final BlinnMaterial material;

  final Transform transform = new Transform();

  /// Instantiates a new [BlinnTrianglesShape] from the [primitives] and the
  /// [material].
  BlinnTrianglesShape(this.primitives, this.material);
}
