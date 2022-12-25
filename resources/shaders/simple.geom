#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_GOOGLE_include_directive : require

#include "common.h"

layout (triangles) in;
layout (triangle_strip, max_vertices = 5) out;

layout (push_constant) uniform params_t {
    mat4 mProjView;
    mat4 mModel;
} params;

layout (location = 0) in VS_IN {
    vec3 wPos;
    vec3 wNorm;
    vec3 wTangent;
    vec2 texCoord;
} vIn[];

layout (location = 0) out VS_OUT {
    vec3 wPos;
    vec3 wNorm;
    vec3 wTangent;
    vec2 texCoord;
} vOut;

layout (binding = 0, set = 0) uniform data
{
    UniformParams Params;
};

void createVertex(vec3 Norm, vec3 Pos, vec3 Tangent, vec2 texCoord) {
    vOut.wNorm    = Norm;
    vOut.wPos     = Pos;
    vOut.wTangent = Tangent;
    vOut.texCoord = texCoord;
    gl_Position = params.mProjView * vec4(Pos, 1.0f);
    EmitVertex();
}

void main(void) {
    createVertex(vIn[0].wNorm, vIn[0].wPos, vIn[0].wTangent, vIn[0].texCoord);
    createVertex(vIn[1].wNorm, vIn[1].wPos, vIn[1].wTangent, vIn[1].texCoord);
    vec3 centroidNorm     = normalize(vIn[0].wNorm + vIn[1].wNorm + vIn[2].wNorm);
    vec3 centroidPos      = (vIn[0].wPos + vIn[1].wPos + vIn[2].wPos) / 3.f + (0.02f + 0.02f * centroidNorm) * abs(sin(10. * Params.time));
    vec3 centroidTangent  = normalize(vIn[0].wTangent + vIn[1].wTangent + vIn[2].wTangent);
    vec2 centroidTexCoord = (vIn[0].texCoord + vIn[1].texCoord + vIn[2].texCoord) / 3.f;
    createVertex(centroidNorm, centroidPos, centroidTangent, centroidTexCoord);
    createVertex(vIn[2].wNorm, vIn[2].wPos, vIn[2].wTangent, vIn[2].texCoord);
    createVertex(vIn[0].wNorm, vIn[0].wPos, vIn[0].wTangent, vIn[0].texCoord);
    EndPrimitive();
}