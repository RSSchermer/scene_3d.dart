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
  #ifdef PRECOMPUTED_TANGENT_BITANGENT
    attribute vec3 aTangent;
    attribute vec3 aBitangent;

    varying vec3 vTangent;
    varying vec3 vBitangent;
  #endif
#else
  #if NUM_DIRECTIONAL_LIGHTS > 0

    #include "lib/directional_light.glsl"

    uniform DirectionalLight uDirectionalLights[NUM_DIRECTIONAL_LIGHTS];
  #endif

  #if NUM_POINT_LIGHTS > 0

    #include "lib/point_light.glsl"

    uniform PointLight uPointLights[NUM_POINT_LIGHTS];
  #endif
#endif

void main(void) {
  vPosition = uWorld * aPosition;
  vTexCoord = aTexCoord;
  vIrradiance = vec3(0.0, 0.0, 0.0);
  vNormal = normalize(uNormal * aNormal);

  #ifdef USE_NORMAL_MAP
    #ifdef PRECOMPUTED_TANGENT_BITANGENT
      vTangent = normalize(uNormal * aTangent);
      vBitangent = normalize(uNormal * aBitangent);
    #endif
  #else
    #if NUM_DIRECTIONAL_LIGHTS > 0
      for (int i = 0; i < NUM_DIRECTIONAL_LIGHTS; i++) {
        vIrradiance += irradiance(uDirectionalLights[i], vNormal);
      }
    #endif

    #if NUM_POINT_LIGHTS > 0
      for (int i = 0; i < NUM_POINT_LIGHTS; i++) {
        vIrradiance += irradiance(uPointLights[i], vPosition.xyz, vNormal);
      }
    #endif
  #endif

  gl_Position = uViewProjection * vPosition;
}
