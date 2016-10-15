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

#ifdef USE_OPACITY_MAP
  uniform sampler2D uOpacityMapSampler;
#endif

uniform float uOpacity;

void main(void) {
  vec3 colorRGB = vec3(0.0, 0.0, 0.0);
  float colorAlpha = 1.0;

  #ifdef USE_DIFFUSE_MAP
    vec4 s = texture2D(uDiffuseMapSampler, vTexCoord);

    colorRGB += s.rgb * vIrradiance;
    colorAlpha *= s.a;
  #else
    colorRGB += uDiffuseColor * vIrradiance;
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
