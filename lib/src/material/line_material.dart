part of material;

class LineMaterial implements Material {
  String name;

  Blending blending;

  DepthTest depthTest;

  StencilTest stencilTest;

  CullingMode faceCulling;

  double lineWidth;
}
