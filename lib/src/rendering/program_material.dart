part of rendering;

/// [ChainableViewFactory] that can make [ProgramPrimitivesShapeView]s for
/// [ProgramPrimitivesShape]s.
class ProgramPrimitivesShapeViewFactory extends ChainableViewFactory {
  /// The BaGL [Frame] that any [ProgramPrimitivesShapeView] made by this
  /// [ProgramPrimitivesShapeViewFactory] will draw to.
  final Frame frame;

  /// The [Scene] that provides the environmental context for
  /// [ProgramPrimitivesShapeView]s made by this
  /// [ProgramPrimitivesShapeViewFactory].
  final Scene scene;

  /// Instantiates a new [ProgramPrimitivesShapeViewFactory].
  ProgramPrimitivesShapeViewFactory(this.scene, this.frame);

  View makeView(dynamic object) {
    if (object is ProgramPrimitivesShape) {
      return new ProgramPrimitivesShapeView(object, scene, frame);
    } else {
      return super.makeView(object);
    }
  }
}

class ProgramPrimitivesShapeView implements View {
  final Frame frame;

  final ProgramPrimitivesShape shape;

  final Scene scene;

  ProgramPrimitivesShapeView(this.shape, this.scene, this.frame);

  bool get isTransparent => shape.material.isTransparent;

  void render(Camera camera) {
    final material = shape.material;
    final uniforms = material.resolveUniforms(shape, camera, scene);

    frame.draw(shape.primitives, material.program, uniforms,
        blending: material.blending,
        depthTest: material.depthTest,
        stencilTest: material.stencilTest,
        faceCulling: material.faceCulling,
        lineWidth: material.lineWidth);
  }

  void decommission() {}
}
