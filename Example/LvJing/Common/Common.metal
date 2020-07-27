//
//  Common.metal
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/25.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include "Common.h"

vertex VertexOut vertex_main(const constant float4 *vertexArray [[buffer(0)]],
                             unsigned int vid [[vertex_id]])
{
   float4 currentVertex = vertexArray[vid];
   VertexOut out {
      .position = float4(currentVertex.x, currentVertex.y, 0, 1),
      .uv = float2(currentVertex.z, currentVertex.w)
   };
   return out;
}

