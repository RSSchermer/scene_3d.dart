attribute vec4 aPosition;
attribute vec3 aNormal;
attribute vec2 aTexCoord;

uniform mat4 uWorld;
uniform mat4 uViewProjection;
uniform mat3 uNormal;

varying vec4 vPosition;
varying vec2 vTexCoord;
varying vec3 vNormal;

#ifdef USE_NORMAL_MAP
  attribute vec3 aTangent;
  attribute vec3 aBitangent;

  varying vec3 vTangent;
  varying vec3 vBitangent;
#endif

void main(void) {
  vPosition = uWorld * aPosition;
  vTexCoord = aTexCoord;
  vNormal = uNormal * aNormal;

  #ifdef USE_NORMAL_MAP
    vTangent = uNormal * aTangent;
    vBitangent = uNormal * aBitangent;
  #endif

  gl_Position = uViewProjection * vPosition;
}
