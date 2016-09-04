part of material;

class LambertMaterial implements Material {
  String name;

  Blending blending;

  DepthTest depthTest;

  StencilTest stencilTest;

  CullingMode faceCulling;

  Vector3 diffuseColor;

  Texture2D diffuseMap;

  Vector3 emissionColor;

  Texture2D emissionMap;

  double transparency;

  Texture2D transparencyMap;

  Texture2D bumpMap;

  Texture2D normalMap;
}
