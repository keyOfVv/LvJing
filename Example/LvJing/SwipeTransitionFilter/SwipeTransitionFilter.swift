//
//  SwipeTransitionFilter.swift
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import MetalKit
import LvJing

public final class SwipeTransitionFilter: LvJing {
   
   public var progress: Float = 0.5
   
   public init(resolution: CGSize) {
      super.init(
         resolution: resolution,
         libraryURL: nil,
         vertexFunctionName: "vertex_main",
         fragmentFunctionName: "fragment_linearDisplace")
   }
   
   public override func setFragmentBytesFor(encoder: MTLRenderCommandEncoder) {
      encoder.setFragmentBytes(
         &progress,
         length: MemoryLayout<Float>.stride,
         index: Int(0))
   }
}

