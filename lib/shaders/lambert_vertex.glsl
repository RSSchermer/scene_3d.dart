attribute vec4 aPosition;
attribute vec3 aNormal;
attribute vec2 aTexCoord;

uniform mat4 uWorld;
uniform mat4 uViewProjection;
uniform mat3 uNormal;

varying vec2 vTexCoord;
varying vec3 vIrradiance;

#if NUM_DIRECTIONAL_LIGHTS > 0
  struct DirectionalLight {
    vec3 direction;
    vec3 color;
  };

  uniform DirectionalLight uDirectionalLights[NUM_DIRECTIONAL_LIGHTS];
#endif

float lambertianDiffuseIrradiance(vec3 lightDirection, vec3 surfaceNormal) {
  return max(0.0, dot(lightDirection, surfaceNormal));
}

void main(void) {
  gl_Position = uViewProjection * uWorld * aPosition;
  vec3 normal = uNormal * aNormal;
  vTexCoord = aTexCoord;
  vIrradiance = vec3(0.0, 0.0, 0.0);

  #if NUM_DIRECTIONAL_LIGHTS > 0
    for (int i = 0; i < NUM_DIRECTIONAL_LIGHTS; i++) {
      DirectionalLight light = uDirectionalLights[i];

      vIrradiance +=
          lambertianDiffuseIrradiance(light.direction, normal) * light.color;
    }
  #endif
}
