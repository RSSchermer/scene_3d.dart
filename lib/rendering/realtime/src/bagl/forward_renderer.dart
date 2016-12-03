part of rendering.realtime.bagl;

class ForwardRenderer {
  final CanvasElement canvas;

  final Scene scene;

  final ViewSet<BaGLRenderUnit> _views = _makeDefaultViewSet();

  final Map<Object, View> _objectViews = {};

  ForwardRenderer(this.canvas, this.scene,
      {ViewFactory<BaGLRenderUnit> viewFactory}) {
    final programPool = new ProgramPool();

    if (viewFactory == null) {
      final context = RenderingContext.forCanvas(canvas);
      final frame = context.defaultFrame;
      final constantViewFactory =
          new ConstantShapeViewFactory(frame, programPool);
      final lambertViewFactory =
          new LambertShapeViewFactory(frame, programPool);
      final phongViewFactory = new PhongShapeViewFactory(frame, programPool);
      final lightViewFactory =
          new NullViewFactory<BaGLRenderUnit>((o) => o is Light);
      final cameraViewFactory =
          new NullViewFactory<BaGLRenderUnit>((o) => o is Camera);

      constantViewFactory.nextFactory = lambertViewFactory;
      lambertViewFactory.nextFactory = phongViewFactory;
      phongViewFactory.nextFactory = lightViewFactory;
      lightViewFactory.nextFactory = cameraViewFactory;

      viewFactory = constantViewFactory;
    }

    for (var object in scene.objects) {
      final view = viewFactory.makeView(object, scene);

      _views.add(view);
      _objectViews[object] = view;
    }

    scene.objects.changes.listen((changes) {
      for (var change in changes) {
        if (change.isAdd) {
          final view = viewFactory.makeView(change.element, scene);

          _views.add(view);
          _objectViews[change.element] = view;
        } else {
          final view = _objectViews[change.element];

          if (view != null) {
            _views.remove(view);
            _objectViews.remove(view);
          }
        }
      }
    });
  }

  void render(Camera camera) {
    _views.update(camera);

    for (var renderUnit in _views.renderBin) {
      renderUnit.render();
    }
  }
}

ViewSet _makeDefaultViewSet() {
  makeOpaqueUnitNode(BaGLRenderUnit renderUnit) =>
      new RenderUnitNode<BaGLRenderUnit>(renderUnit, new ObservableValue(0));

  makeOpaqueUnitGroupNode(Program program) =>
      new RenderUnitGroupNode<BaGLRenderUnit>(
          new StaticSortCode(0), makeOpaqueUnitNode);

  final opaqueBranch = new GroupingNode<BaGLRenderUnit, Program>(
      (u) => u.program, makeOpaqueUnitGroupNode, new StaticSortCode(0));

  makeTranslucentUnitNode(BaGLRenderUnit renderUnit) =>
      new RenderUnitNode(renderUnit, renderUnit.squaredDistance);

  final translucentBranch = new RenderUnitGroupNode(
      new StaticSortCode(1), makeTranslucentUnitNode,
      sortOrder: SortOrder.descending);

  final renderTree = new GroupingNode<BaGLRenderUnit, bool>(
      (u) => u.isTranslucent,
      (isTranslucent) => isTranslucent ? translucentBranch : opaqueBranch,
      new StaticSortCode(0),
      defaultValue: false,
      sortOrder: SortOrder.ascending);

  return new ViewSet(new SortedRenderUnits<BaGLRenderUnit>(renderTree));
}
