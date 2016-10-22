#ifndef POINT_LIGHT
#define POINT_LIGHT

#include "diffuse_irradiance.glsl"

/// Represents a point light source that emits rays equally in all directions.
struct PointLight {
  /// The position of this PointLight in world space.
  vec3 position;

  /// The intensity of each color component for this PointLight.
  vec3 color;

  /// An attenuation factor that remains constant as the distance from this
  /// PointLight increases.
  float constantAttenuation;

  /// An attenuation factor that increases linearly as the distance from this
  /// PointLight increases.
  float linearAttenuation;

  /// An attenuation factor that increases quadratically as the distance from
  /// this PointLight increases.
  float quadraticAttenuation;
};

/// Calculates the attenuation factor for the `light` at a given distance away
/// from the `light`'s position.
float attenuation(PointLight light, float distance) {
  return 1.0 / (light.constantAttenuation +
               distance * light.linearAttenuation +
               distance * distance * light.quadraticAttenuation);
}

/// Calculates the irradiance for each color component that a point on a surface
/// with the given `normal` at the given `position` (in world  space) receives
/// from the `light`.
vec3 irradiance(PointLight light, vec3 position, vec3 normal) {
  vec3 difference = light.position - position;
  vec3 direction = normalize(difference);
  float distance = length(difference);
  float attenuationFactor = attenuation(light, distance);

  return attenuationFactor * irradianceFactor(direction, normal) * light.color;
}
#endif
