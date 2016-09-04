part of material;

class PointMaterial implements Material {
  String name;

  Blending blending;

  DepthTest depthTest;

  StencilTest stencilTest;

  CullingMode faceCulling;

  double pointSize;
}
