#ifndef DIFFUSE_IRRADIANCE
#define DIFFUSE_IRRADIANCE

/// Computes the Lambertian irradiance factor for a point on a surface.
///
/// Takes the following parameters:
///
/// - `lightDirection`: The direction of the incoming light. The vector should
///   point from the surface towards the light (not from the light to the
///   surface).
/// - `surfaceNormal`: A unit vector perpendicular to the reflection surface.
///   Points away from the front-face.
///
/// Returns an irradiance factor ranging from `1.0` when the `lightDirection`
/// and the `surfaceNormal` are identical to `0.0` when the angle between the
/// `lightDirection` and `surfaceNormal` is `0.5 * PI` (90 degrees) or greater.
float irradianceFactor(vec3 lightDirection, vec3 surfaceNormal) {
  return max(0.0, dot(lightDirection, surfaceNormal));
}
#endif
