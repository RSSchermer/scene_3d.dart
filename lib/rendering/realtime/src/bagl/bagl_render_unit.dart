part of rendering.realtime.bagl;

/// Base class for [AtomicRenderUnit]s that use BaGL as the rendering driver.
abstract class BaGLRenderUnit extends AtomicRenderUnit {
  ObservableValue<num> get squaredDistance;

  ObservableValue<Program> get program;

  ObservableValue<bool> get isTranslucent;
}
