//
//  Luminosity.metal
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../Common/Common.h"

#define kLuminosityWeights float3(0.2126, 0.7152, 0.0722)

float4 toLuminosity_RGBA(float4 in) {
   return float4(float3(dot(in.rgb, kLuminosityWeights)), in.a);
}

fragment float4 fragment_lum(VertexOut in [[stage_in]],
                             texture2d<float> colorTexture [[texture(0)]],
                             sampler textureSampler [[sampler(0)]])
{
   float4 color = colorTexture.sample(textureSampler, in.uv);
   color = toLuminosity_RGBA(color);
   return color;
}
