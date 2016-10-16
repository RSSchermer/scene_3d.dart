precision mediump float;

varying vec4 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
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

float lambertianDiffuseIrradiance(vec3 lightDirection, vec3 surfaceNormal) {
  return max(0.0, dot(lightDirection, surfaceNormal));
}

void main(void) {
  vec3 colorRGB = vec3(0.0, 0.0, 0.0);
  float colorAlpha = 1.0;
  vec3 irradiance = vIrradiance;

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
          lambertianDiffuseIrradiance(direction, vNormal) * light.color;
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
