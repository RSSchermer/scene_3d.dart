#ifndef SPOT_LIGHT
#define SPOT_LIGHT

#include "diffuse_irradiance.glsl"

/// Represents a conical light source.
struct SpotLight {
  /// The position of this SpotLight in world space.
  vec3 position;

  /// The direction towards which this SpotLight is pointing.
  vec3 direction;

  /// The intensity of each color component for this SpotLight.
  vec3 color;

  /// An attenuation factor that remains constant as the distance from this
  /// SpotLight increases.
  float constantAttenuation;

  /// An attenuation factor that increases linearly as the distance from this
  /// SpotLight increases.
  float linearAttenuation;

  /// An attenuation factor that increases quadratically as the distance from
  /// this SpotLight increases.
  float quadraticAttenuation;

  /// The cosine of the falloff angle for this SpotLight.
  float falloffAngleCosine;

  /// The falloff exponent used to attenuate this SpotLight's intensity as the
  /// angle approaches the falloff angle.
  float falloffExponent;
};

/// Calculates the attenuation factor for the `light` at a given distance away
/// from the `light`'s position.
float attenuation(SpotLight light, float distance) {
  return 1.0 / (light.constantAttenuation +
               distance * light.linearAttenuation +
               distance * distance * light.quadraticAttenuation);
}

/// Calculates the irradiance for each color component that a point on a surface
/// with the given `normal` at the given `position` (in world  space) receives
/// from the `light`.
vec3 irradiance(SpotLight light, vec3 position, vec3 normal) {
  vec3 difference = position - light.position;
  vec3 direction = normalize(difference);
  float distance = length(difference);
  float attenuationFactor = attenuation(light, distance);
  float angleCosine = dot(direction, light.direction);
  float relativeDif = (angleCosine - light.falloffAngleCosine) /
      (1.0 - light.falloffAngleCosine);
  float falloffFactor =
      pow(clamp(relativeDif, 0.0, 1.0), light.falloffExponent);

  return attenuationFactor * falloffFactor *
      irradianceFactor(-direction, normal) * light.color;
}

vec3 specularity(SpotLight light, vec3 viewDirection, vec3 position, vec3 normal, float shininess) {
  vec3 difference = position - light.position;
  vec3 direction = normalize(difference);
  float distance = length(difference);
  float attenuationFactor = attenuation(light, distance);
  float angleCosine = dot(direction, light.direction);
  float relativeDif = (angleCosine - light.falloffAngleCosine) /
      (1.0 - light.falloffAngleCosine);
  float falloffFactor =
      pow(clamp(relativeDif, 0.0, 1.0), light.falloffExponent);

  return attenuationFactor * falloffFactor *
      specularityFactor(-direction, viewDirection, normal, shininess) *
      light.color;
}
#endif
