part of material;

abstract class Material {
  /// A mutable label for this [Material].
  String name;

  Blending blending;

  DepthTest depthTest;

  StencilTest stencilTest;

  CullingMode faceCulling;
}
