part of rendering;

abstract class WebGLSceneRenderer {
  factory WebGLSceneRenderer(Scene scene, CanvasElement canvas) {
    final context = RenderingContext.forCanvas(canvas);
    final constantRenderer =
        new ConstantTrianglesShapeRenderer(context.defaultFrame, scene);
    final constantViewFactory =
        new ConstantTrianglesShapeViewFactory(constantRenderer);
    final lightViewFactory = new NullViewFactory((o) => o is Light);
    final cameraViewFactory = new NullViewFactory((o) => o is Camera);

    constantViewFactory.nextFactory = lightViewFactory;
    lightViewFactory.nextFactory = cameraViewFactory;

    return new ViewSetRenderer.managed(scene, constantViewFactory);
  }

  Scene get scene;

  void render(Camera camera);
}

class ViewSetRenderer implements WebGLSceneRenderer {
  final Scene scene;

  final Set<View> viewSet;

  final Map<Object, View> _objectViews = {};

  ViewSetRenderer(this.scene, this.viewSet);

  ViewSetRenderer.managed(this.scene, ViewFactory viewFactory)
      : viewSet = new TypeGroupedViewSet() {
    for (var object in scene.objects) {
      viewSet.add(viewFactory.makeView(object));
    }

    scene.objects.changes.listen((changeRecord) {
      for (var object in changeRecord.additions) {
        viewSet.add(viewFactory.makeView(object));
      }

      for (var object in changeRecord.removals) {
        final view = _objectViews[object];

        if (view != null) {
          view.decommission();
          viewSet.remove(view);
          _objectViews.remove(object);
        }
      }
    });
  }

  void render(Camera camera) {
    final transparentViews = new Queue<View>();

    for (var view in viewSet) {
      if (view.isTransparent) {
        transparentViews.addFirst(view);
      } else {
        view.render(camera);
      }
    }

    for (var view in transparentViews) {
      view.render(camera);
    }
  }
}
