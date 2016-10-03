precision mediump float;

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

#ifdef USE_TRANSPARENCY_MAP
  uniform sampler2D uTransparencyMapSampler;
#else
  uniform float uTransparency;
#endif

void main(void) {
  vec3 colorRGB = vec3(0.0, 0.0, 0.0);

  #ifdef USE_DIFFUSE_MAP
    colorRGB += texture2D(uDiffuseMapSampler, vTexCoord).rgb * vIrradiance;
  #else
    colorRGB += uDiffuseColor * vIrradiance;
  #endif

  #ifdef USE_EMISSION_MAP
    colorRGB += texture2D(uEmissionMapSampler, vTexCoord).rgb;
  #else
    colorRGB += uEmissionColor;
  #endif

  float colorAlpha;

  #ifdef USE_TRANSPARENCY_MAP
    colorAlpha = 1.0 - texture2D(uTransparencyMapSampler, vTexCoord).a;
  #else
    colorAlpha = 1.0 - uTransparency;
  #endif

  gl_FragColor = vec4(colorRGB, colorAlpha);
}
