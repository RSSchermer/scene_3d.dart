#ifndef TANGENT_TO_CLIP
#define TANGENT_TO_CLIP

#extension GL_OES_standard_derivatives : enable

/// Given the position in clip space or a surface fragment, the corresponding
/// normal vector, and the corresponding texture coordinates, returns a 3x3
/// matrix that transforms texture tangent space directions into clip space
/// directions.
///
/// The resulting matrix is used to transform normal vectors sampled from normal
/// map textures into clip space normals.
///
/// This functions depends fragment shader derivates. As such, it can only be
/// included in a fragment shader.
///
/// Based on: http://hacksoflife.blogspot.nl/2009/11/per-pixel-tangent-space-normal-mapping.html
mat3 tangentToClip(vec4 positionClip, vec3 normalClip, vec2 texCoord) {
  vec3 q0 = dFdx(positionClip.xyz);
  vec3 q1 = dFdy(positionClip.xyz);
  vec2 st0 = dFdx(texCoord.st);
  vec2 st1 = dFdy(texCoord.st);

  vec3 tangent = normalize(q0 * st1.t - q1 * st0.t);
  // TODO: investigate why inverting the result is necessary for correct
  // looking results
  vec3 bitangent = -normalize(-q0 * st1.s + q1 * st0.s);

  return mat3(tangent, bitangent, normalClip);
}

#endif