part of material;

class ConstantMaterial implements Material {
  String name;

  Blending blending;

  DepthTest depthTest = const DepthTest();

  StencilTest stencilTest;

  CullingMode faceCulling;

  Vector3 emissionColor = new Vector3.zero();

  Texture2D emissionMap;

  double transparency = 0.0;

  Texture2D transparencyMap;
}
