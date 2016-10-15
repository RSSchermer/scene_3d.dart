part of material;

class ConstantMaterial implements Material {
  String name;

  Blending blending = const Blending(
      sourceColorFactor: BlendingFactor.sourceAlpha,
      destinationColorFactor: BlendingFactor.oneMinusSourceAlpha);

  DepthTest depthTest = const DepthTest();

  StencilTest stencilTest;

  CullingMode faceCulling;

  Vector3 emissionColor = new Vector3.zero();

  Texture2D emissionMap;

  double opacity = 1.0;

  Texture2D opacityMap;
}
