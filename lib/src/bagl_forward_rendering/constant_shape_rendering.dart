part of bagl_forward_rendering;

class ConstantShapeRenderUnit extends BaGLRenderUnit {
  static final String vertexShaderSource =
      INLINE_ASSET('../../shaders/constant_vertex.glsl');

  static final String fragmentShaderSource =
      INLINE_ASSET('../../shaders/constant_fragment.glsl');

  final ConstantTrianglesShape shape;

  final Scene scene;

  final Frame frame;

  final ProgramPool programPool;

  final ObservableValue<double> squaredDistance = new ObservableValue();

  final ObservableValue<Program> program = new ObservableValue();

  final ObservableValue<bool> isTranslucent = new ObservableValue();

  final Map<String, dynamic> _uniforms = {};

  Texture2D _activeEmissionMap;

  Texture2D _activeTransparencyMap;

  bool _programNeedsUpdate = true;

  ConstantShapeRenderUnit(this.shape, this.scene, this.frame, this.programPool);

  void update(Camera camera) {
    _uniforms['uWorld'] = shape.worldTransform;
    _uniforms['uViewProjection'] = camera.viewProjectionTransform;

    final material = shape.material;

    final emissionMap = material.emissionMap;

    if (emissionMap != _activeEmissionMap) {
      if (emissionMap == null) {
        _uniforms.remove('uEmissionMapSampler');

        _programNeedsUpdate = true;
      } else {
        _uniforms.remove('uEmissionColor');
        _uniforms['uEmissionMapSampler'] = new Sampler2D(emissionMap);

        if (_activeEmissionMap == null) {
          _programNeedsUpdate = true;
        }
      }

      _activeEmissionMap = emissionMap;
    }

    if (_activeEmissionMap == null) {
      _uniforms['uEmissionColor'] = material.emissionColor;
    }

    final transparencyMap = material.transparencyMap;

    if (transparencyMap != _activeTransparencyMap) {
      if (transparencyMap == null) {
        _uniforms.remove('uTransparencyMapSampler');

        _programNeedsUpdate = true;
      } else {
        _uniforms.remove('uTransparency');
        _uniforms['uTransparencyMapSampler'] = new Sampler2D(transparencyMap);

        if (_activeTransparencyMap == null) {
          _programNeedsUpdate = true;
        }
      }

      _activeTransparencyMap = transparencyMap;
    }

    if (_activeTransparencyMap == null) {
      _uniforms['uTransparency'] = material.transparency;
    }

    if (_programNeedsUpdate) {
      var defines = '';

      if (_activeEmissionMap != null) {
        defines += '#define USE_EMISSION_MAP\n';
      }

      if (_activeTransparencyMap != null) {
        defines += '#define USE_TRANSPARENCY_MAP\n';
      }

      programPool.release(program.value);

      final newProgram = programPool.acquire(
          vertexShaderSource, defines + fragmentShaderSource);

      program.value = newProgram;
      _programNeedsUpdate = false;
    }

    isTranslucent.value = material.transparency > 0.0;
    squaredDistance.value = squaredDistance3(shape.position, camera.position);
  }

  void render() {
    final material = shape.material;

    frame.draw(shape.primitives, program.value, _uniforms,
        blending: material.blending,
        depthTest: material.depthTest,
        stencilTest: material.stencilTest,
        faceCulling: material.faceCulling,
        attributeNameMap: const {
          'aPosition': 'position',
          'aTexCoord': 'texCoord'
        });
  }
}

class ConstantShapeView extends DelegatingIterable<AtomicRenderUnit>
    implements ObjectView {
  final ConstantShapeRenderUnit renderUnit;

  final ConstantTrianglesShape shape;

  final Scene scene;

  final Frame frame;

  final ProgramPool programPool;

  ConstantShapeView(ConstantTrianglesShape shape, Scene scene, Frame frame,
      ProgramPool programPool)
      : renderUnit =
            new ConstantShapeRenderUnit(shape, scene, frame, programPool),
        shape = shape,
        scene = scene,
        frame = frame,
        programPool = programPool;

  Object get object => shape;

  Iterable<AtomicRenderUnit> get delegate => [renderUnit];

  ViewChangeRecord update(Camera camera) {
    renderUnit.update(camera);

    return new ViewChangeRecord.empty();
  }
}

class ConstantShapeViewFactory extends ChainableViewFactory {
  final Frame frame;

  final ProgramPool programPool;

  ConstantShapeViewFactory(this.frame, this.programPool);

  ObjectView makeView(Object object, Scene scene) {
    if (object is ConstantTrianglesShape) {
      return new ConstantShapeView(object, scene, frame, programPool);
    } else {
      return super.makeView(object, scene);
    }
  }
}
