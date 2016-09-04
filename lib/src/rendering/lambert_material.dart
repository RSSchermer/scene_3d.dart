part of rendering;

class LambertTrianglesShapeRenderer {
  final Scene scene;

  final Frame frame;

  Program _program;

  List<DirectionalLight> _directionalLights;

  List<SpotLight> _spotLights;

  List<PointLight> _pointLights;

  final Expando<Sampler2D> _textureSampler2D = new Expando();

  LambertTrianglesShapeRenderer(this.scene, this.frame) {
    final objects = scene.objects;

    _directionalLights = objects.where((o) => o is DirectionalLight).toList();
    _spotLights = objects.where((o) => o is SpotLight).toList();
    _pointLights = objects.where((o) => o is PointLight).toList();

    objects.changes.listen((changeRecord) {
      changeRecord.additions.forEach((object) {
        if (object is DirectionalLight) {
          _directionalLights.add(object);
        } else if (object is SpotLight) {
          _spotLights.add(object);
        } else if (object is PointLight) {
          _pointLights.add(object);
        }
      });

      changeRecord.removals.forEach((object) {
        if (object is DirectionalLight) {
          _directionalLights.remove(object);
        } else if (object is SpotLight) {
          _spotLights.remove(object);
        } else if (object is PointLight) {
          _pointLights.remove(object);
        }
      });
    });
  }

  void render(LambertTrianglesShape shape, Camera camera) {
    final material = shape.material;
    final diffuseMapSampler = _resolveSampler2D(material.diffuseMap);
    final emissionMapSampler = _resolveSampler2D(material.emissionMap);
    final transparencyMapSampler = _resolveSampler2D(material.transparencyMap);
    final bumpMapSampler = _resolveSampler2D(material.bumpMap);
    final normalMapSampler = _resolveSampler2D(material.normalMap);

    frame.draw(
        shape.primitives,
        _program,
        {
          'uWorld': shape.worldTransform,
          'uViewProjection': camera.viewProjectionTransform,
          'uAmbientColor': scene.ambientColor,
          'uDirectionalLights': _directionalLights,
          'uSpotLights': _spotLights,
          'uPointLights': _pointLights,
          'uDiffuseColor': material.diffuseColor,
          'uDiffuseMapSampler': diffuseMapSampler,
          'uHasDiffuseMap': diffuseMapSampler != null,
          'uEmissionColor': material.emissionColor,
          'uEmissionMapSampler': emissionMapSampler,
          'uHasEmissionMap': emissionMapSampler != null,
          'uTransparency': material.transparency,
          'uTransparencyMapSampler': transparencyMapSampler,
          'uHasTransparencyMap': transparencyMapSampler != null,
          'uBumpMapSampler': bumpMapSampler,
          'uHasBumpMap': bumpMapSampler != null && normalMapSampler == null,
          'uNormalMapSampler': normalMapSampler,
          'uHasNormalMap': normalMapSampler != null
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
      var sampler = _textureSampler2D[texture];

      if (sampler == null) {
        sampler = new Sampler2D(texture);
        _textureSampler2D[texture] = sampler;
      }

      return sampler;
    } else {
      return null;
    }
  }
}

class LambertTrianglesShapeView implements View {
  final LambertTrianglesShapeRenderer renderer;

  final LambertTrianglesShape shape;

  LambertTrianglesShapeView(this.shape, this.renderer);

  bool get isTransparent => shape.material.transparency < 1.0;

  void render(Camera camera) {
    renderer.render(shape, camera);
  }

  void decommission() {}
}

class LambertShapeInstanceViewFactory extends ChainableViewFactory {
  final LambertTrianglesShapeRenderer renderer;

  LambertShapeInstanceViewFactory(this.renderer);

  View makeView(Object object) {
    if (object is LambertTrianglesShape) {
      return new LambertTrianglesShapeView(object, renderer);
    } else {
      return super.makeView(object);
    }
  }
}
