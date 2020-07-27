//
//  SwipeTransitionFilter.metal
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../Common/Common.h"

float4 linearDisplace(float2 st,
                      texture2d<float> from,
                      texture2d<float> to,
                      sampler textureSampler,
                      float percent)
{
   if (st.x <= 1.0 - percent) {
      return from.sample(textureSampler, st);
   }
   else {
      return to.sample(textureSampler, st);
   }
}

fragment float4 fragment_linearDisplace(VertexOut in [[stage_in]],
                                        constant float &percent [[buffer(0)]],
                                        texture2d<float> firstTexture [[texture(0)]],
                                        texture2d<float> secondTexture [[texture(1)]],
                                        sampler textureSampler [[sampler(0)]])
{
   return linearDisplace(in.uv,
                         firstTexture,
                         secondTexture,
                         textureSampler,
                         percent);
}
