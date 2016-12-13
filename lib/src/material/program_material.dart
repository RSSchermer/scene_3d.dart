part of material;

typedef Map<String, dynamic> UniformResolver(
    ProgramPrimitivesShape shape, Camera camera, Scene scene);

class ProgramMaterial implements Material {
  String name;

  Blending blending;

  DepthTest depthTest;

  StencilTest stencilTest;

  CullingMode faceCulling;

  num lineWidth;

  bool isTransparent;

  Program program;

  UniformResolver resolveUniforms;

  ProgramMaterial(this.program, this.resolveUniforms,
      {this.blending: const Blending(),
      this.depthTest: const DepthTest(),
      this.stencilTest: null,
      this.faceCulling: null,
      this.lineWidth: 1.0,
      this.isTransparent: false});
}
