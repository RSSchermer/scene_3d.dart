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
  #include "lib/spot_light.glsl"

  uniform SpotLight uSpotLights[NUM_SPOT_LIGHTS];
#endif

#ifdef USE_NORMAL_MAP
  #if NUM_DIRECTIONAL_LIGHTS > 0
    #include "lib/directional_light.glsl"

    uniform DirectionalLight uDirectionalLights[NUM_DIRECTIONAL_LIGHTS];
  #endif

  #if NUM_POINT_LIGHTS > 0
    #include "lib/point_light.glsl"

    uniform PointLight uPointLights[NUM_POINT_LIGHTS];
  #endif

  uniform sampler2D uNormalMapSampler;

  #ifdef PRECOMPUTED_TANGENT_BITANGENT
    varying vec3 vTangent;
    varying vec3 vBitangent;
  #else
    #include "lib/tangent_to_clip.glsl"
  #endif
#endif

void main(void) {
  vec3 colorRGB = vec3(0.0, 0.0, 0.0);
  float colorAlpha = 1.0;
  vec3 totalIrradiance = vIrradiance;

  #ifdef USE_NORMAL_MAP
    #ifdef PRECOMPUTED_TANGENT_BITANGENT
      mat3 TBN = mat3(vTangent, vBitangent, vNormal);
    #else
      mat3 TBN = tangentToClip(vPosition, vNormal, vTexCoord);
    #endif

    vec3 normal = normalize(
        TBN * (texture2D(uNormalMapSampler, vTexCoord).xyz * 2.0 - 1.0));
  #else
    vec3 normal = normalize(vNormal);
  #endif

  #ifdef USE_NORMAL_MAP
    #if NUM_DIRECTIONAL_LIGHTS > 0
      for (int i = 0; i < NUM_DIRECTIONAL_LIGHTS; i++) {
        totalIrradiance += irradiance(uDirectionalLights[i], normal);
      }
    #endif

    #if NUM_POINT_LIGHTS > 0
      for (int i = 0; i < NUM_POINT_LIGHTS; i++) {
        totalIrradiance += irradiance(uPointLights[i], vPosition.xyz, normal);
      }
    #endif
  #endif

  #if NUM_SPOT_LIGHTS > 0
    for (int i = 0; i < NUM_SPOT_LIGHTS; i++) {
      totalIrradiance += irradiance(uSpotLights[i], vPosition.xyz, normal);
    }
  #endif

  #ifdef USE_DIFFUSE_MAP
    vec4 s = texture2D(uDiffuseMapSampler, vTexCoord);

    colorRGB += s.rgb * totalIrradiance;
    colorAlpha *= s.a;
  #else
    colorRGB += uDiffuseColor * totalIrradiance;
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
