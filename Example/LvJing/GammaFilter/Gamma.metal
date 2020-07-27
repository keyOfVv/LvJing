//
//  Gamma.metal
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "../Common/Common.h"

float4 adjustGamma(float4 in, float power) {
   return float4(pow(in.rgb, power), in.a);
}

fragment float4 fragment_gamma(VertexOut in [[stage_in]],
                               constant float &gamma [[buffer(0)]],
                               texture2d<float> colorTexture [[texture(0)]],
                               sampler textureSampler)
{
   float4 originColor = colorTexture.sample(textureSampler, in.uv);
   if (gamma == 1.0) {
      return originColor;
   }
   return adjustGamma(originColor, gamma);
}
