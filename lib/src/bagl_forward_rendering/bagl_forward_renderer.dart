part of bagl_forward_rendering;

class ForwardRenderer {
  final CanvasElement canvas;

  final Scene scene;

  final ViewSet _views = new ViewSet(new RenderSortTreeUnits.defaultSorting());

  final Map<Object, ObjectView> _objectViews = {};

  ForwardRenderer(this.canvas, this.scene, [ViewFactory viewFactory]) {
    final programPool = new ProgramPool();

    if (viewFactory == null) {
      final context = RenderingContext.forCanvas(canvas);
      final frame = context.defaultFrame;
      final constantViewFactory =
          new ConstantShapeViewFactory(frame, programPool);
      final lambertViewFactory =
          new LambertShapeViewFactory(frame, programPool);
      final lightViewFactory = new NullViewFactory((o) => o is Light);
      final cameraViewFactory = new NullViewFactory((o) => o is Camera);

      constantViewFactory.nextFactory = lambertViewFactory;
      lambertViewFactory.nextFactory = lightViewFactory;
      lightViewFactory.nextFactory = cameraViewFactory;

      viewFactory = constantViewFactory;
    }

    for (var object in scene.objects) {
      final view = viewFactory.makeView(object, scene);

      _views.add(view);
      _objectViews[object] = view;
    }

    scene.objects.changes.listen((change) {
      for (var object in change.additions) {
        final view = viewFactory.makeView(object, scene);

        _views.add(view);
        _objectViews[object] = view;
      }

      for (var object in change.removals) {
        final view = _objectViews[object];

        if (view != null) {
          _views.remove(view);
          _objectViews.remove(view);
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
