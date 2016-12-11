#ifndef TANGENT_TO_CLIP
#define TANGENT_TO_CLIP

mat3 tangentToClip(vec4 position, vec3 normal) {
  vec3 q0 = dFdx(vPosition.xyz);
  vec3 q1 = dFdy(vPosition.xyz);
  vec2 st0 = dFdx(vTexCoord.st);
  vec2 st1 = dFdy(vTexCoord.st);

  vec3 tangent = normalize(q0 * st1.t - q1 * st0.t);
  // TODO: investigate why inverting the result is necessary for correct
  // looking results
  vec3 bitangent = -normalize(-q0 * st1.s + q1 * st0.s);

  return mat3(tangent, bitangent, vNormal);
}

#endif