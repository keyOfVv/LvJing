//
//  Common.h
//  LvJing
//
//  Created by Ke Yang on 2020/7/25.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

#ifndef Common_h
#define Common_h

#include "../AffineTransformFilter/AffineTransform.h"

#if __METAL_MACOS__ || __METAL_IOS__
#include <metal_stdlib>
using namespace metal;

struct VertexOut {
   float4 position [[position]];
   float2 uv;
};

#endif /* __METAL_MACOS__ || __METAL_IOS__ */

#endif /* Common_h */
