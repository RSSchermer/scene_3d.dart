part of rendering.realtime.bagl;

class ConstantRenderUnit extends BaGLRenderUnit {
  static final String vertexShaderSource =
      INLINE_ASSET('package:scene_3d/shaders/constant_vertex.glsl');

  static final String fragmentShaderSource =
      INLINE_ASSET('package:scene_3d/shaders/constant_fragment.glsl');

  final ConstantMaterial material;

  final PrimitiveSequence primitives;

  final Transform transform;

  final Scene scene;

  final Frame frame;

  final ProgramPool programPool;

  final ObservableValue<double> squaredDistance = new ObservableValue();

  final ObservableValue<Program> program = new ObservableValue();

  final ObservableValue<bool> isTranslucent = new ObservableValue();

  final Map<String, dynamic> _uniforms = {};

  Texture2D _activeEmissionMap;

  Texture2D _activeOpacityMap;

  bool _programNeedsUpdate = true;

  ConstantRenderUnit(this.material, this.primitives, this.transform, this.scene,
      this.frame, this.programPool);

  void update(Camera camera) {
    _uniforms['uWorld'] = transform.positionToWorld;
    _uniforms['uViewProjection'] = camera.worldToClip;

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

    final opacityMap = material.opacityMap;

    if (opacityMap != _activeOpacityMap) {
      if (opacityMap == null) {
        _uniforms.remove('uOpacityMapSampler');

        _programNeedsUpdate = true;
      } else {
        _uniforms['uOpacityMapSampler'] = new Sampler2D(opacityMap);

        if (_activeOpacityMap == null) {
          _programNeedsUpdate = true;
        }
      }

      _activeOpacityMap = opacityMap;
    }

    _uniforms['uOpacity'] = material.opacity;

    if (_programNeedsUpdate) {
      var defines = '';

      if (_activeEmissionMap != null) {
        defines += '#define USE_EMISSION_MAP\n';
      }

      if (_activeOpacityMap != null) {
        defines += '#define USE_OPACITY_MAP\n';
      }

      programPool.release(program.value);

      final newProgram = programPool.acquire(
          vertexShaderSource, defines + fragmentShaderSource);

      program.value = newProgram;
      _programNeedsUpdate = false;
    }

    isTranslucent.value = material.opacity < 1.0;
    squaredDistance.value =
        squaredDistance3(transform.position, camera.transform.position);
  }

  void render() {
    if (material.opacity > 0.05) {
      frame.draw(primitives, program.value, _uniforms,
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
}

class ConstantShapeView extends DelegatingIterable<ConstantRenderUnit>
    implements View<ConstantRenderUnit> {
  final ConstantRenderUnit renderUnit;

  final ConstantTrianglesShape shape;

  final Scene scene;

  final Frame frame;

  final ProgramPool programPool;

  ConstantShapeView(ConstantTrianglesShape shape, Scene scene, Frame frame,
      ProgramPool programPool)
      : renderUnit = new ConstantRenderUnit(shape.material, shape.primitives,
            shape.transform, scene, frame, programPool),
        shape = shape,
        scene = scene,
        frame = frame,
        programPool = programPool;

  Object get object => shape;

  Iterable<ConstantRenderUnit> get delegate => [renderUnit];

  ViewChangeRecord<ConstantRenderUnit> update(Camera camera) {
    renderUnit.update(camera);

    return new ViewChangeRecord.empty();
  }
}

class ConstantShapeViewFactory extends ChainableViewFactory<BaGLRenderUnit> {
  final Frame frame;

  final ProgramPool programPool;

  ConstantShapeViewFactory(this.frame, this.programPool);

  View<BaGLRenderUnit> makeView(Object object, Scene scene) {
    if (object is ConstantTrianglesShape) {
      return new ConstantShapeView(object, scene, frame, programPool);
    } else {
      return super.makeView(object, scene);
    }
  }
}
