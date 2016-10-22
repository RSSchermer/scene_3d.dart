#ifndef DIRECTIONAL_LIGHT
#define DIRECTIONAL_LIGHT

#include "diffuse_irradiance.glsl"

/// Represents a light source for which all rays travel parallel paths.
struct DirectionalLight {
  /// A unit vector representing the direction towards which this
  /// DirectionalLight's rays travel.
  vec3 direction;

  /// The intensity of each color component for this DirectionalLight.
  vec3 color;
};

/// Calculates the irradiance for each color component that a point on a surface
/// with the given `normal` receives from the `light`.
vec3 irradiance(DirectionalLight light, vec3 normal) {
  return irradianceFactor(-light.direction, normal) * light.color;
}
#endif
