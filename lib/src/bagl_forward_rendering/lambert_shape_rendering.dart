part of bagl_forward_rendering;

class LambertShapeRenderUnit extends BaGLRenderUnit {
  static final String vertexShaderSource =
  INLINE_ASSET('../../shaders/lambert_vertex.glsl');

  static final String fragmentShaderSource =
  INLINE_ASSET('../../shaders/lambert_fragment.glsl');

  final LambertTrianglesShape shape;

  final Scene scene;

  final Frame frame;

  final ProgramPool programPool;

  final ObservableValue<double> squaredDistance = new ObservableValue();

  final ObservableValue<Program> program = new ObservableValue();

  final ObservableValue<bool> isTranslucent = new ObservableValue();

  final Map<String, dynamic> _uniforms = {};

  Texture2D _activeDiffuseMap;

  Texture2D _activeEmissionMap;

  Texture2D _activeTransparencyMap;

  List<DirectionalLight> _directionalLights;

  List<PointLight> _pointLights;

  List<SpotLight> _spotLights;

  bool _programNeedsUpdate = true;

  LambertShapeRenderUnit(this.shape, this.scene, this.frame, this.programPool) {
    final objects = scene.objects;

    _directionalLights = objects.where((o) => o is DirectionalLight).toList();
    _pointLights = objects.where((o) => o is PointLight).toList();
    _spotLights = objects.where((o) => o is SpotLight).toList();

    if (_directionalLights.isNotEmpty) {
      _uniforms['uDirectionalLights'] = _directionalLights;
    }

    if (_pointLights.isNotEmpty) {
      _uniforms['uPointLights'] = _pointLights;
    }

    if (_spotLights.isNotEmpty) {
      _uniforms['uSpotLights'] = _spotLights;
    }

    objects.changes.listen((change) {
      for (var object in change.additions) {
        if (object is DirectionalLight) {
          _directionalLights.add(object);
          _uniforms['uDirectionalLights'] = _directionalLights;
          _programNeedsUpdate = true;
        } else if (object is SpotLight) {
          _spotLights.add(object);
          _uniforms['uSpotLights'] = _pointLights;
          _programNeedsUpdate = true;
        } else if (object is PointLight) {
          _pointLights.add(object);
          _uniforms['uPointLights'] = _spotLights;
          _programNeedsUpdate = true;
        }
      }

      for (var object in change.removals) {
        if (object is DirectionalLight) {
          _directionalLights.remove(object);
          _programNeedsUpdate = true;

          if (_directionalLights.isEmpty) {
            _uniforms.remove('uDirectionalLights');
          }
        } else if (object is SpotLight) {
          _spotLights.remove(object);
          _programNeedsUpdate = true;

          if (_directionalLights.isEmpty) {
            _uniforms.remove('uSpotLights');
          }
        } else if (object is PointLight) {
          _pointLights.remove(object);
          _programNeedsUpdate = true;

          if (_directionalLights.isEmpty) {
            _uniforms.remove('uPointLights');
          }
        }
      }
    });
  }

  void update(Camera camera) {
    _uniforms['uWorld'] = shape.worldTransform;
    _uniforms['uViewProjection'] = camera.viewProjectionTransform;
    _uniforms['uNormal'] = shape.normalTransform;

    final material = shape.material;

    final diffuseMap = material.diffuseMap;

    if (diffuseMap != _activeDiffuseMap) {
      if (diffuseMap == null) {
        _uniforms.remove('uDiffuseMapSampler');

        _programNeedsUpdate = true;
      } else {
        _uniforms.remove('uDiffuseColor');
        _uniforms['uDiffuseMapSampler'] = new Sampler2D(diffuseMap);

        if (_activeDiffuseMap == null) {
          _programNeedsUpdate = true;
        }
      }

      _activeDiffuseMap = diffuseMap;
    }

    if (_activeDiffuseMap == null) {
      _uniforms['uDiffuseColor'] = material.diffuseColor;
    }

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
      var defines = '#define NUM_DIRECTIONAL_LIGHTS ${_directionalLights.length}\n';

      if (_activeDiffuseMap != null) {
        defines += '#define USE_DIFFUSE_MAP\n';
      }

      if (_activeEmissionMap != null) {
        defines += '#define USE_EMISSION_MAP\n';
      }

      if (_activeTransparencyMap != null) {
        defines += '#define USE_TRANSPARENCY_MAP\n';
      }

      programPool.release(program.value);

      final newProgram = programPool.acquire(
          defines + vertexShaderSource, defines + fragmentShaderSource);

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
          'aNormal': 'normal',
          'aTexCoord': 'texCoord'
        });
  }
}

class LambertShapeView extends DelegatingIterable<AtomicRenderUnit>
    implements ObjectView {
  final LambertShapeRenderUnit renderUnit;

  final LambertTrianglesShape shape;

  final Scene scene;

  final Frame frame;

  final ProgramPool programPool;

  LambertShapeView(LambertTrianglesShape shape, Scene scene, Frame frame,
      ProgramPool programPool)
      : renderUnit =
  new LambertShapeRenderUnit(shape, scene, frame, programPool),
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

class LambertShapeViewFactory extends ChainableViewFactory {
  final Frame frame;

  final ProgramPool programPool;

  LambertShapeViewFactory(this.frame, this.programPool);

  ObjectView makeView(Object object, Scene scene) {
    if (object is LambertTrianglesShape) {
      return new LambertShapeView(object, scene, frame, programPool);
    } else {
      return super.makeView(object, scene);
    }
  }
}