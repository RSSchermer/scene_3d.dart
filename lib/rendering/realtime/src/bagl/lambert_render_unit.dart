part of rendering.realtime.bagl;

class LambertRenderUnit extends BaGLRenderUnit {
  static final String vertexShaderSource =
      INLINE_ASSET('package:scene_3d/shaders/lambert_vertex.glsl');

  static final String fragmentShaderSource =
      INLINE_ASSET('package:scene_3d/shaders/lambert_fragment.glsl');

  final LambertMaterial material;

  final PrimitiveSequence primitives;

  final Transform transform;

  final Scene scene;

  final Frame frame;

  final ProgramPool programPool;

  final ObservableValue<double> squaredDistance = new ObservableValue();

  final ObservableValue<Program> program = new ObservableValue();

  final ObservableValue<bool> isTranslucent = new ObservableValue();

  final Map<String, dynamic> _uniforms = {};

  Texture2D _activeDiffuseMap;

  Texture2D _activeEmissionMap;

  Texture2D _activeOpacityMap;

  Texture2D _activeNormalMap;

  List<DirectionalLight> _directionalLights;

  List<PointLight> _pointLights;

  List<SpotLight> _spotLights;

  bool _programNeedsUpdate = true;

  LambertRenderUnit(this.material, this.primitives, this.transform, this.scene,
      this.frame, this.programPool) {
    frame.context.requestExtension('OES_standard_derivatives');

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

    objects.changes.listen((changes) {
      for (var change in changes) {
        final object = change.element;

        if (change.isAdd) {
          if (object is DirectionalLight) {
            _directionalLights.add(object);
            _uniforms['uDirectionalLights'] = _directionalLights;
            _programNeedsUpdate = true;
          } else if (object is PointLight) {
            _pointLights.add(object);
            _uniforms['uPointLights'] = _pointLights;
            _programNeedsUpdate = true;
          } else if (object is SpotLight) {
            _spotLights.add(object);
            _uniforms['uSpotLights'] = _spotLights;
            _programNeedsUpdate = true;
          }
        } else {
          if (object is DirectionalLight) {
            _programNeedsUpdate = _directionalLights.remove(object);

            if (_directionalLights.isEmpty) {
              _uniforms.remove('uDirectionalLights');
            }
          } else if (object is PointLight) {
            _programNeedsUpdate = _pointLights.remove(object);

            if (_pointLights.isEmpty) {
              _uniforms.remove('uPointLights');
            }
          } else if (object is SpotLight) {
            _programNeedsUpdate = _spotLights.remove(object);

            if (_spotLights.isEmpty) {
              _uniforms.remove('uSpotLights');
            }
          }
        }
      }
    });
  }

  void update(Camera camera) {
    _uniforms['uWorld'] = transform.positionToWorld;
    _uniforms['uViewProjection'] = camera.worldToClip;
    _uniforms['uNormal'] = transform.directionToWorld;
    _uniforms['uDiffuseColor'] = material.diffuseColor;
    _uniforms['uEmissionColor'] = material.emissionColor;
    _uniforms['uOpacity'] = material.opacity;

    final diffuseMap = material.diffuseMap;

    if (diffuseMap != _activeDiffuseMap) {
      if (diffuseMap == null) {
        _uniforms.remove('uDiffuseMapSampler');

        _programNeedsUpdate = true;
      } else {
        _uniforms['uDiffuseMapSampler'] = new Sampler2D(diffuseMap);

        if (_activeDiffuseMap == null) {
          _programNeedsUpdate = true;
        }
      }

      _activeDiffuseMap = diffuseMap;
    }

    final emissionMap = material.emissionMap;

    if (emissionMap != _activeEmissionMap) {
      if (emissionMap == null) {
        _uniforms.remove('uEmissionMapSampler');

        _programNeedsUpdate = true;
      } else {
        _uniforms['uEmissionMapSampler'] = new Sampler2D(emissionMap);

        if (_activeEmissionMap == null) {
          _programNeedsUpdate = true;
        }
      }

      _activeEmissionMap = emissionMap;
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

    final normalMap = material.normalMap;

    if (normalMap != _activeNormalMap) {
      if (normalMap == null) {
        _uniforms.remove('uNormalMapSampler');

        _programNeedsUpdate = true;
      } else {
        _uniforms['uNormalMapSampler'] = new Sampler2D(normalMap);

        if (_activeNormalMap == null) {
          _programNeedsUpdate = true;
        }
      }

      _activeNormalMap = normalMap;
    }

    if (_programNeedsUpdate) {
      var defines =
          '#define NUM_DIRECTIONAL_LIGHTS ${_directionalLights.length}\n'
          '#define NUM_POINT_LIGHTS ${_pointLights.length}\n'
          '#define NUM_SPOT_LIGHTS ${_spotLights.length}\n';

      if (_activeDiffuseMap != null) {
        defines += '#define USE_DIFFUSE_MAP\n';
      }

      if (_activeEmissionMap != null) {
        defines += '#define USE_EMISSION_MAP\n';
      }

      if (_activeOpacityMap != null) {
        defines += '#define USE_OPACITY_MAP\n';
      }

      if (_activeNormalMap != null) {
        defines += '#define USE_NORMAL_MAP\n';
      }

      programPool.release(program.value);

      final newProgram = programPool.acquire(
          defines + vertexShaderSource, defines + fragmentShaderSource);

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
            'aTexCoord': 'texCoord',
            'aNormal': 'normal',
            'aTangent': 'tangent',
            'aBitangent': 'bitangent'
          });
    }
  }
}

class LambertRenderUnitFactory extends BaGLRenderUnitFactory {
  final Frame frame;

  final ProgramPool programPool;

  LambertRenderUnitFactory(this.frame, this.programPool);

  BaGLRenderUnit makeRenderUnit(Material material, PrimitiveSequence primitives,
      Transform transform, Scene scene) {
    if (material is LambertMaterial) {
      return new LambertRenderUnit(
          material, primitives, transform, scene, frame, programPool);
    } else {
      return super.makeRenderUnit(material, primitives, transform, scene);
    }
  }
}
