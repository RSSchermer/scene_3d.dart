part of material;

class LambertMaterial implements Material {
  String name;

  Blending blending;

  DepthTest depthTest = const DepthTest();

  StencilTest stencilTest;

  CullingMode faceCulling;

  Vector3 diffuseColor = new Vector3(0.5, 0.5, 0.5);

  Texture2D diffuseMap;

  Vector3 emissionColor = new Vector3.zero();

  Texture2D emissionMap;

  double transparency = 0.0;

  Texture2D transparencyMap;

  Texture2D bumpMap;

  Texture2D normalMap;
}
