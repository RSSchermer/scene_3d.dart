part of bagl_forward_rendering;

/// Base class for [AtomicRenderUnit]s that use BaGL as the rendering driver.
abstract class BaGLRenderUnit extends AtomicRenderUnit
    with TranslucencyGroupable, ProgramGroupable, SquaredDistanceSortable {}
