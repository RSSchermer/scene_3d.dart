part of material;

class PhongMaterial implements SurfaceMaterial {
  String name;

  Blending blending = const Blending(
      sourceColorFactor: BlendingFactor.sourceAlpha,
      destinationColorFactor: BlendingFactor.oneMinusSourceAlpha);

  DepthTest depthTest = const DepthTest();

  StencilTest stencilTest;

  CullingMode faceCulling;

  Vector3 diffuseColor = new Vector3(0.5, 0.5, 0.5);

  Texture2D diffuseMap;

  Vector3 specularColor = new Vector3(1.0, 1.0, 1.0);

  Texture2D specularMap;

  Vector3 emissionColor = new Vector3.zero();

  Texture2D emissionMap;

  double shininess = 30.0;

  double opacity = 1.0;

  Texture2D opacityMap;

  Texture2D normalMap;
}
