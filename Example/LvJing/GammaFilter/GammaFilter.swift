//
//  GammaFilter.swift
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import MetalKit
import LvJing

public final class GammaFilter: LvJing {
   
   public var gamma: Float = 1.0
   
   public init(resolution: CGSize) {
      super.init(
         resolution: resolution,
         libraryURL: nil,
         vertexFunctionName: "vertex_main",
         fragmentFunctionName: "fragment_gamma")
   }
   
   public override func setFragmentBytesFor(encoder: MTLRenderCommandEncoder) {
      encoder.setFragmentBytes(
         &gamma,
         length: MemoryLayout<Float>.stride,
         index: 0)
   }
}
