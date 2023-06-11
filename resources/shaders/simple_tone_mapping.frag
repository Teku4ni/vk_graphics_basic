#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_GOOGLE_include_directive : require

#include "common.h"

layout (location = 0) out vec4 out_fragColor;

layout (location = 0 ) in VS_OUT
{
  vec2 texCoord;
} surf;

layout (binding = 0, set = 0) uniform AppData
{
  UniformParams Params;
};

layout (binding = 1) uniform sampler2D hdrImage;


// https://64.github.io/tonemapping/
vec4 reinhard_luminance(vec4 v)
{
    float l_old = dot(v.rgb, vec3(0.2126f, 0.7152f, 0.0722f));
    float l_new = l_old / (1.0f + l_old);
    v = v * (l_new / l_old);
    return vec4(v.rgb, 1.0f);
}

void main()
{
  const vec4 hdrColor = texture(hdrImage, surf.texCoord);
  if (Params.toneMapping)
  {
    out_fragColor = reinhard_luminance(hdrColor);
  }
  else
  {
    out_fragColor = clamp(hdrColor, vec4(0.0f), vec4(1.0f));
  }
}