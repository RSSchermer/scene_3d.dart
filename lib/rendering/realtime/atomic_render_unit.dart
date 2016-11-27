library rendering.realtime.atomic_render_unit;

/// Atomic unit of rendering.
///
/// Rendering an [AtomicRenderUnit] typically results in a single draw call.
/// Splitting up the rendering process into these small units allows them to be
/// sorted in ways that may improve rendering performance (for example, by
/// reducing the number of GPU state changes or by taking advantage early-z
/// optimizations).
abstract class AtomicRenderUnit {
  void render();
}
