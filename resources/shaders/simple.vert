#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_GOOGLE_include_directive : require

#include "unpack_attributes.h"


layout(location = 0) in vec4 vPosNorm;
layout(location = 1) in vec4 vTexCoordAndTang;

layout(binding = 2, set = 0) buffer PositionMatrices {
  mat4 positionMatrices[];
};

layout(binding = 3, set = 0) buffer VisibleObjectsIndices {
  uint indicesOfVisibleObjects[];
};

layout(push_constant) uniform params_t
{
    mat4 mProjView;
    mat4 mModel;
} params;


layout (location = 0 ) out VS_OUT
{
    vec3 wPos;
    vec3 wNorm;
    vec3 wTangent;
    vec2 texCoord;

} vOut;

out gl_PerVertex { vec4 gl_Position; };
void main(void)
{
    const vec4 wNorm = vec4(DecodeNormal(floatBitsToInt(vPosNorm.w)),         0.0f);
    const vec4 wTang = vec4(DecodeNormal(floatBitsToInt(vTexCoordAndTang.z)), 0.0f);

    mat4 new_model = positionMatrices[indicesOfVisibleObjects[gl_InstanceIndex]] * params.mModel;
    vOut.wPos      = (new_model * vec4(vPosNorm.xyz, 1.0f)).xyz;
    vOut.wNorm     = normalize(mat3(transpose(inverse(new_model))) * wNorm.xyz);
    vOut.wTangent  = normalize(mat3(transpose(inverse(new_model))) * wTang.xyz);
    vOut.texCoord  = vTexCoordAndTang.xy;

    gl_Position   = params.mProjView * vec4(vOut.wPos, 1.0);
}
