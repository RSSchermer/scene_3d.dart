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
  /// The [ProgramPool] used by this [ConstantTrianglesShapeView].
  final ProgramPool programPool;

  /// The [ConstantTrianglesShape] for which this is a [View].
  final ConstantTrianglesShape shape;

  static final String vertexShaderSource = INLINE_ASSET('../../shaders/constant_material_vertex.glsl');

  static final String fragmentShaderSource = INLINE_ASSET('../../shaders/constant_material_fragment.glsl');

  final ConstantMaterial _material;

  Program _program;

  bool _useTransparencyMap = false;

  bool _useEmissionMap = false;

  bool _programNeedsUpdate = true;

  /// Instantiates a new [ConstantTrianglesShapeView].
  ConstantTrianglesShapeView(ConstantTrianglesShape shape, this.programPool)
      : shape = shape,
        _material = shape.material;

  bool get isTransparent =>
      shape.material.transparency < 1.0 ||
      shape.material.transparencyMap != null;

  void render(Camera camera) {
    if ((_material.emissionMap != null) != _useEmissionMap) {
      _useEmissionMap = !_useEmissionMap;
      _programNeedsUpdate = true;
    }

    if ((_material.transparencyMap != null) != _useTransparencyMap) {
      _useTransparencyMap = !_useTransparencyMap;
      _programNeedsUpdate = true;
    }

    if (_programNeedsUpdate) {
      _updateProgram();
    }

    final uniforms = <String, dynamic>{
      'uWorld': shape.worldTransform,
      'uViewProjection': camera.viewProjectionTransform
    };

    if (_useEmissionMap) {
      uniforms['uEmissionMapSampler'] = _resolveSampler2D(_material.emissionMap);
    } else {
      uniforms['uEmissionColor'] = _material.emissionColor;
    }

    if (_useTransparencyMap) {
      uniforms['uTransparencyMapSampler'] = _resolveSampler2D(_material.transparencyMap);
    } else {
      uniforms['uTransparency'] = _material.transparency;
    }

    frame.draw(
        shape.primitives,
        _program,
        uniforms,
        blending: _material.blending,
        depthTest: _material.depthTest,
        stencilTest: _material.stencilTest,
        faceCulling: _material.faceCulling,
        attributeNameMap: const {
          'aPosition': 'position',
          'aTexCoord': 'texCoord'
        });
  }

  void decommission() {
    programPool.release(_program);
  }

  void _updateProgram() {
    final fragmentDefines = """
    #define USE_EMISSION_MAP ${_useEmissionMap}
    #define USE_TRANSPARENCY_MAP ${_useTransparencyMap}
    """;

    if (_program != null) {
      programPool.release(_program);
    }

    _program = programPool.acquire(vertexShaderSource, fragmentDefines + fragmentShaderSource);
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

/// [ChainableViewFactory] which can make [ConstantTrianglesShapeView]s for
/// [ConstantTrianglesShape]s.
class ConstantTrianglesShapeViewFactory extends ChainableViewFactory {
  /// The [ProgramPool] which [ConstantTrianglesShapeView]s made by this factory
  /// will use.
  final ProgramPool programPool;

  /// Instantiates a new [ConstantTrianglesShapeViewFactory].
  ConstantTrianglesShapeViewFactory(this.programPool);

  View makeView(Object object) {
    if (object is ConstantTrianglesShape) {
      return new ConstantTrianglesShapeView(object, programPool);
    } else {
      return super.makeView(object);
    }
  }
}
