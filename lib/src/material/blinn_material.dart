part of material;

class BlinnMaterial implements SurfaceMaterial {
  String name;

  Blending blending;

  DepthTest depthTest;

  StencilTest stencilTest;

  CullingMode faceCulling;
}
