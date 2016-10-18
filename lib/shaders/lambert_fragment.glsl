precision mediump float;

varying vec4 vPosition;
varying vec2 vTexCoord;
varying vec3 vNormal;
varying vec3 vIrradiance;

#ifdef USE_DIFFUSE_MAP
  uniform sampler2D uDiffuseMapSampler;
#else
  uniform vec3 uDiffuseColor;
#endif

#ifdef USE_EMISSION_MAP
  uniform sampler2D uEmissionMapSampler;
#else
  uniform vec3 uEmissionColor;
#endif

#ifdef USE_OPACITY_MAP
  uniform sampler2D uOpacityMapSampler;
#endif

uniform float uOpacity;

#if NUM_SPOT_LIGHTS > 0
  struct SpotLight {
    vec3 position;
    vec3 direction;
    vec3 color;
    float constantAttenuation;
    float linearAttenuation;
    float quadraticAttenuation;
    float falloffAngleCosine;
    float falloffExponent;
  };

  uniform SpotLight uSpotLights[NUM_SPOT_LIGHTS];
#endif

#ifdef USE_NORMAL_MAP
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

  uniform sampler2D uNormalMapSampler;

  varying vec3 vTangent;
  varying vec3 vBitangent;
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
  vec3 colorRGB = vec3(0.0, 0.0, 0.0);
  float colorAlpha = 1.0;
  vec3 irradiance = vIrradiance;

  #ifdef USE_NORMAL_MAP
    mat3 TBN = mat3(vTangent, vBitangent, vNormal);
    vec3 normal = TBN * (texture2D(uNormalMapSampler, vTexCoord).xyz * 2.0 - 1.0);
  #else
    vec3 normal = vNormal;
  #endif

  #ifdef USE_NORMAL_MAP
    #if NUM_DIRECTIONAL_LIGHTS > 0
      for (int i = 0; i < NUM_DIRECTIONAL_LIGHTS; i++) {
        DirectionalLight light = uDirectionalLights[i];

        irradiance +=
            diffuseIrradiance(-light.direction, normal) * light.color;
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

        irradiance +=
            attenuation * diffuseIrradiance(direction, normal) * light.color;
      }
    #endif
  #endif

  #if NUM_SPOT_LIGHTS > 0
    for (int i = 0; i < NUM_SPOT_LIGHTS; i++) {
      SpotLight light = uSpotLights[i];
      vec3 difference = vPosition.xyz - light.position;
      vec3 direction = normalize(difference);
      float distance = length(difference);
      float attenuation = 1.0 / (light.constantAttenuation +
          distance * light.linearAttenuation +
          distance * distance * light.quadraticAttenuation);
      float angleCosine = dot(direction, light.direction);
      float relativeDif = (angleCosine - light.falloffAngleCosine) /
          (1.0 - light.falloffAngleCosine);
      float falloffFactor =
          pow(clamp(relativeDif, 0.0, 1.0), light.falloffExponent);

      irradiance += attenuation * falloffFactor *
          diffuseIrradiance(direction, normal) * light.color;
    }
  #endif

  #ifdef USE_DIFFUSE_MAP
    vec4 s = texture2D(uDiffuseMapSampler, vTexCoord);

    colorRGB += s.rgb * irradiance;
    colorAlpha *= s.a;
  #else
    colorRGB += uDiffuseColor * irradiance;
  #endif

  #ifdef USE_EMISSION_MAP
    colorRGB += texture2D(uEmissionMapSampler, vTexCoord).rgb;
  #else
    colorRGB += uEmissionColor;
  #endif

  #ifdef USE_OPACITY_MAP
    colorAlpha *= texture2D(uOpacityMapSampler, vTexCoord).a;
  #endif

  colorAlpha *= clamp(uOpacity, 0.0, 1.0);

  gl_FragColor = vec4(colorRGB, colorAlpha);
}
