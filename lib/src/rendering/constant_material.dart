part of rendering;

/// WebGL (BaGL) renderer for [ConstantTrianglesShape]s.
class ConstantTrianglesShapeRenderer {
  /// The BaGL frame to which this [ConstantTriangleShapeRenderer] draws.
  final Frame frame;

  /// The [Scene] that provides the environmental context for this
  /// [ConstantTrianglesShapeRenderer].
  final Scene scene;

  final Program _program = new Program(
      INLINE_ASSET('../../shaders/constant_material_vertex.glsl'),
      INLINE_ASSET('../../shaders/constant_material_fragment.glsl'));

  final Expando<Sampler2D> textureSampler2D = new Expando();

  /// Instantiates a new [ConstantTrianglesShapeRenderer].
  ConstantTrianglesShapeRenderer(this.frame, this.scene);

  /// Renders the [shape] for this [ConstantTrianglesShapeRenderer]'s [frame]
  /// from the perspective of the [camera].
  void render(ConstantTrianglesShape shape, Camera camera) {
    final material = shape.material;
    final emissionMapSampler = _resolveSampler2D(material.emissionMap);
    final transparencyMapSampler = _resolveSampler2D(material.transparencyMap);

    frame.draw(
        shape.primitives,
        _program,
        {
          'uWorld': shape.worldTransform,
          'uViewProjection': camera.viewProjectionTransform,
          'uEmissionColor': material.emissionColor,
          'uEmissionMapSampler': emissionMapSampler,
          'uHasEmissionMap': emissionMapSampler != null,
          'uTransparency': material.transparency,
          'uTransparencyMapSampler': transparencyMapSampler,
          'uHasTransparencyMap': transparencyMapSampler != null
        },
        blending: material.blending,
        depthTest: material.depthTest,
        stencilTest: material.stencilTest,
        faceCulling: material.faceCulling,
        attributeNameMap: const {
          'aPosition': 'position',
          'aTexCoord': 'texCoord'
        });
  }

  Sampler2D _resolveSampler2D(Texture2D texture) {
    if (texture != null) {
      var sampler = textureSampler2D[texture];

      if (sampler == null) {
        sampler = new Sampler2D(texture);
        textureSampler2D[texture] = sampler;
      }

      return sampler;
    } else {
      return null;
    }
  }
}

/// A [View] for a [ConstantTrianglesShape].
class ConstantTrianglesShapeView implements View {
  /// The [ConstantTrianglesShapeRenderer] used to draw the [shape].
  final ConstantTrianglesShapeRenderer renderer;

  /// The [ConstantTrianglesShape] for which this is a [View].
  final ConstantTrianglesShape shape;

  /// Instantiates a new [ConstantTrianglesShapeView].
  ConstantTrianglesShapeView(this.shape, this.renderer);

  bool get isTransparent =>
      shape.material.transparency < 1.0 ||
      shape.material.transparencyMap != null;

  void render(Camera camera) {
    renderer.render(shape, camera);
  }

  void decommission() {}
}

/// [ChainableViewFactory] which can make [ConstantTrianglesShapeView]s for
/// [ConstantTrianglesShape]s.
class ConstantTrianglesShapeViewFactory extends ChainableViewFactory {
  /// The [ConstantTrianglesShapeRenderer] that any [ConstantTrianglesShapeView]
  /// made by this [ConstantTrianglesShapeViewFactory] will use to draw their
  /// shape.
  final ConstantTrianglesShapeRenderer renderer;

  /// Instantiates a new [ConstantTrianglesShapeViewFactory].
  ConstantTrianglesShapeViewFactory(this.renderer);

  View makeView(Object object) {
    if (object is ConstantTrianglesShape) {
      return new ConstantTrianglesShapeView(object, renderer);
    } else {
      return super.makeView(object);
    }
  }
}
