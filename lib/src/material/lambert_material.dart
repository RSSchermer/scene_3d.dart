part of material;

class LambertMaterial implements SurfaceMaterial {
  String name;

  Blending blending = const Blending(
      sourceColorFactor: BlendingFactor.sourceAlpha,
      destinationColorFactor: BlendingFactor.oneMinusSourceAlpha);

  DepthTest depthTest = const DepthTest();

  StencilTest stencilTest;

  CullingMode faceCulling;

  Vector3 diffuseColor = new Vector3.constant(1.0);

  Texture2D diffuseMap;

  Vector3 emissionColor = new Vector3.zero();

  Texture2D emissionMap;

  double opacity = 1.0;

  Texture2D opacityMap;

  Texture2D normalMap;
}
