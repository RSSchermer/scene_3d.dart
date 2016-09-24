part of bagl_forward_rendering;

class BaGLForwardSceneRenderer {
  final CanvasElement canvas;

  final Scene scene;

  int _requestId;

  BaGLForwardSceneRenderer(this.canvas, this.scene) {

  }

  void start() {
    loop(num time) {
      _requestId = window.requestAnimationFrame(loop);
    };

    loop(0);
  }

  void stop() {
    if (_requestId != null) {
      window.cancelAnimationFrame(_requestId);

      _requestId = null;
    }
  }
}

class ObjectPresenter {
  final SortedRenderBin renderBin;


}
