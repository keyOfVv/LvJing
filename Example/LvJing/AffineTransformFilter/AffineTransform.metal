//
//  AffineTransform.metal
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/25.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../Common/Common.h"

float2 apply(float4x4 transform, float2 in, float2 resolution) {
   float2 st = resolution * in;
   st += resolution * -0.5;
   st = (transform * float4(st, 0.0, 1.0)).xy;
   st += resolution * 0.5;
   st /= resolution;
   return st;
}

fragment float4 fragment_affine(VertexOut in [[stage_in]],
                                constant float2 &resolution [[buffer(AffineTransformFilterResolutionBufferIndex)]],
                                constant float4x4 &transform [[buffer(AffineTransformFilterTransformBufferIndex)]],
                                texture2d<float> texture [[texture(AffineTransfromFilterOriginTextureIndex)]],
                                sampler textureSampler [[sampler(AffineTransformFilterDefaultSamplerIndex)]])
{
   float2 st = apply(transform, in.uv, resolution);
   return texture.sample(textureSampler, st);
}
