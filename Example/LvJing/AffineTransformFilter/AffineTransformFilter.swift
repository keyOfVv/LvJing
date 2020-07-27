//
//  AffineTransformFilter.swift
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/25.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import MetalKit
import LvJing

public final class AffineTransformFilter: LvJing {
   
   public var transform: CGAffineTransform = .identity
   
   public init(resolution: CGSize) {
      super.init(
         resolution: resolution,
         libraryURL: nil,
         vertexFunctionName: "vertex_main",
         fragmentFunctionName: "fragment_affine")
   }
   
   public override func setFragmentBytesFor(encoder: MTLRenderCommandEncoder) {
      var floatResolution = [Float(resolution.width), Float(resolution.height)]
      encoder.setFragmentBytes(
         &floatResolution,
         length: MemoryLayout<SIMD2<Float>>.stride,
         index: Int(AffineTransformFilterResolutionBufferIndex.rawValue))

      let t3d = CATransform3DMakeAffineTransform(self.transform.inverted())
      var transform4x4 = float4x4(
         [Float(t3d.m11), Float(t3d.m12), Float(t3d.m13), Float(t3d.m14)], // col 1
         [Float(t3d.m21), Float(t3d.m22), Float(t3d.m23), Float(t3d.m24)], // col 2
         [Float(t3d.m31), Float(t3d.m32), Float(t3d.m33), Float(t3d.m34)], // col 3
         [Float(t3d.m41), Float(t3d.m42), Float(t3d.m43), Float(t3d.m44)]) // col 4
      encoder.setFragmentBytes(
         &transform4x4,
         length: MemoryLayout<float4x4>.stride,
         index: Int(AffineTransformFilterTransformBufferIndex.rawValue))
   }
}
