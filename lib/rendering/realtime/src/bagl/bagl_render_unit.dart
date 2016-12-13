part of rendering.realtime.bagl;

/// Base class for [AtomicRenderUnit]s that use BaGL as the rendering driver.
abstract class BaGLRenderUnit extends AtomicRenderUnit {
  ObservableValue<num> get squaredDistance;

  ObservableValue<Program> get program;

  ObservableValue<bool> get isTranslucent;

  void update(Camera camera);
}

/// Creates [BaGLRenderUnit]s.
abstract class BaGLRenderUnitFactory {
  /// The next [ViewFactory] that a [makeView] will be passed to.
  BaGLRenderUnitFactory nextFactory;

  /// Creates a new [BaGLRenderUnit].
  BaGLRenderUnit makeRenderUnit(Material material, PrimitiveSequence primitives,
      Transform transform, Scene scene) {
    if (nextFactory != null) {
      return nextFactory.makeRenderUnit(material, primitives, transform, scene);
    } else {
      throw new ArgumentError('None of the factories in this chain could '
          'create a render unit for material "$material".');
    }
  }
}
