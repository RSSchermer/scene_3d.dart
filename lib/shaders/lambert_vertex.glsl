attribute vec4 aPosition;
attribute vec3 aNormal;
attribute vec2 aTexCoord;

uniform mat4 uWorld;
uniform mat4 uViewProjection;
uniform mat3 uNormal;

varying vec4 vPosition;
varying vec3 vNormal;
varying vec2 vTexCoord;
varying vec3 vIrradiance;

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

float lambertianDiffuseIrradiance(vec3 lightDirection, vec3 surfaceNormal) {
  return max(0.0, dot(lightDirection, surfaceNormal));
}

void main(void) {
  vPosition = uWorld * aPosition;
  vNormal = -uNormal * aNormal;
  vTexCoord = aTexCoord;
  vIrradiance = vec3(0.0, 0.0, 0.0);

  #if NUM_DIRECTIONAL_LIGHTS > 0
    for (int i = 0; i < NUM_DIRECTIONAL_LIGHTS; i++) {
      DirectionalLight light = uDirectionalLights[i];

      vIrradiance +=
          lambertianDiffuseIrradiance(light.direction, vNormal) * light.color;
    }
  #endif

  #if NUM_POINT_LIGHTS > 0
    for (int i = 0; i < NUM_POINT_LIGHTS; i++) {
      PointLight light = uPointLights[i];
      vec3 difference = vPosition.xyz - light.position;
      vec3 direction = normalize(difference);
      float distance = length(difference);
      float attenuation = 1.0 / (light.constantAttenuation +
          distance * light.linearAttenuation +
          distance * distance * light.quadraticAttenuation);

      vIrradiance += attenuation *
          lambertianDiffuseIrradiance(direction, vNormal) * light.color;
    }
  #endif

  gl_Position = uViewProjection * vPosition;
}
