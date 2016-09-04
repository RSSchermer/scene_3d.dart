precision mediump float;

varying vec2 vTexCoord;

uniform vec3 uEmissionColor;
uniform sampler2D uEmissionMapSampler;
uniform bool uHasEmissionMap;

uniform float uTransparency;
uniform sampler2D uTransparencyMapSampler;
uniform bool uHasTransparencyMap;

void main(void) {
  vec3 colorRGB;

  if (uHasEmissionMap) {
    colorRGB = texture2D(uEmissionMapSampler, vTexCoord).rgb;
  } else {
    colorRGB = uEmissionColor;
  }

  float colorAlpha;

  if (uHasTransparencyMap) {
    colorAlpha = 1.0 - texture2D(uTransparencyMapSampler, vTexCoord).a;
  } else {
    colorAlpha = 1.0 - uTransparency;
  }

  gl_FragColor = vec4(colorRGB, colorAlpha);
}
