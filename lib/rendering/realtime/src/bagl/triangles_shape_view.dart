part of rendering.realtime.bagl;

class TrianglesShapeView extends DelegatingIterable<BaGLRenderUnit>
    implements View<BaGLRenderUnit> {
  BaGLRenderUnit _renderUnit;

  final TrianglesShape shape;

  final Scene scene;

  final BaGLRenderUnitFactory renderUnitFactory;

  SurfaceMaterial _activeMaterial;

  TrianglesShapeView(this.shape, this.scene, this.renderUnitFactory) {
    _renderUnit = renderUnitFactory.makeRenderUnit(
        shape.material, shape.primitives, shape.transform, scene);
    _activeMaterial = shape.material;

    if (!shape.hasNormalAttribute) {
      shape.updateNormals();
    }
  }

  TrianglesShape get object => shape;

  Iterable<BaGLRenderUnit> get delegate => [_renderUnit];

  ViewChangeRecord<BaGLRenderUnit> update(Camera camera) {
    if (shape.material != _activeMaterial) {
      final oldRenderUnit = _renderUnit;

      _renderUnit = renderUnitFactory.makeRenderUnit(
          shape.material, shape.primitives, shape.transform, scene);
      _activeMaterial = shape.material;

      return new ViewChangeRecord([oldRenderUnit], [_renderUnit]);
    } else {
      _renderUnit.update(camera);

      return new ViewChangeRecord.empty();
    }
  }
}

class TrianglesShapeViewFactory extends ChainableViewFactory<BaGLRenderUnit> {
  final BaGLRenderUnitFactory renderUnitFactory;

  TrianglesShapeViewFactory(this.renderUnitFactory);

  View<BaGLRenderUnit> makeView(Object object, Scene scene) {
    if (object is TrianglesShape) {
      return new TrianglesShapeView(object, scene, renderUnitFactory);
    } else {
      return super.makeView(object, scene);
    }
  }
}
