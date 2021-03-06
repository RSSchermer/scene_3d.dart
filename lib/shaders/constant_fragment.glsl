precision mediump float;

uniform vec3 uEmissionColor;
uniform float uOpacity;

varying vec2 vTexCoord;

#ifdef USE_EMISSION_MAP
  uniform sampler2D uEmissionMapSampler;
#endif

#ifdef USE_OPACITY_MAP
  uniform sampler2D uOpacityMapSampler;
#endif

void main(void) {
  vec3 colorRGB;

  #ifdef USE_EMISSION_MAP
    colorRGB = uEmissionColor * texture2D(uEmissionMapSampler, vTexCoord).rgb;
  #else
    colorRGB = uEmissionColor;
  #endif

  float colorAlpha = 1.0;

  #ifdef USE_OPACITY_MAP
    colorAlpha *= texture2D(uOpacityMapSampler, vTexCoord).a;
  #endif

  colorAlpha *= clamp(uOpacity, 0.0, 1.0);

  gl_FragColor = vec4(colorRGB, colorAlpha);
}
