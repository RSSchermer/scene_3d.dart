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
