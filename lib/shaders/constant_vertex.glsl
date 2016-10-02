attribute vec4 aPosition;
attribute vec2 aTexCoord;

uniform mat4 uWorld;
uniform mat4 uViewProjection;

varying vec2 vTexCoord;

void main(void) {
  gl_Position = uViewProjection * uWorld * aPosition;
  vTexCoord = aTexCoord;
}
