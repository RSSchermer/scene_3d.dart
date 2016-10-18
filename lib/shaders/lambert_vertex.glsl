attribute vec4 aPosition;
attribute vec3 aNormal;
attribute vec2 aTexCoord;

uniform mat4 uWorld;
uniform mat4 uViewProjection;
uniform mat3 uNormal;

varying vec4 vPosition;
varying vec2 vTexCoord;
varying vec3 vNormal;
varying vec3 vIrradiance;

#ifdef USE_NORMAL_MAP
  attribute vec3 aTangent;
  attribute vec3 aBitangent;

  varying vec3 vTangent;
  varying vec3 vBitangent;
#else
  #if NUM_DIRECTIONAL_LIGHTS > 0
    struct DirectionalLight {
      vec3 direction;
      vec3 color;
    };

    uniform DirectionalLight uDirectionalLights[NUM_DIRECTIONAL_LIGHTS];
  #endif

  #if NUM_POINT_LIGHTS > 0
    struct PointLight {
      vec3 position;
      vec3 color;
      float constantAttenuation;
      float linearAttenuation;
      float quadraticAttenuation;
    };

    uniform PointLight uPointLights[NUM_POINT_LIGHTS];
  #endif
#endif

/// Computes a Lambertian diffuse irradiance factor for a light reflector.
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
float diffuseIrradiance(vec3 lightDirection, vec3 surfaceNormal) {
  return max(0.0, dot(lightDirection, surfaceNormal));
}

void main(void) {
  vPosition = uWorld * aPosition;
  vTexCoord = aTexCoord;
  vIrradiance = vec3(0.0, 0.0, 0.0);

  #ifdef USE_NORMAL_MAP
    vTangent = uNormal * aTangent;
    vBitangent = uNormal * aBitangent;
    vNormal = uNormal * aNormal;
  #else
    vNormal = uNormal * aNormal;

    #if NUM_DIRECTIONAL_LIGHTS > 0
      for (int i = 0; i < NUM_DIRECTIONAL_LIGHTS; i++) {
        DirectionalLight light = uDirectionalLights[i];

        vIrradiance +=
            diffuseIrradiance(-light.direction, vNormal) * light.color;
      }
    #endif

    #if NUM_POINT_LIGHTS > 0
      for (int i = 0; i < NUM_POINT_LIGHTS; i++) {
        PointLight light = uPointLights[i];
        vec3 difference = light.position - vPosition.xyz;
        vec3 direction = normalize(difference);
        float distance = length(difference);
        float attenuation = 1.0 / (light.constantAttenuation +
            distance * light.linearAttenuation +
            distance * distance * light.quadraticAttenuation);

        vIrradiance +=
            attenuation * diffuseIrradiance(direction, vNormal) * light.color;
      }
    #endif
  #endif

  gl_Position = uViewProjection * vPosition;
}
