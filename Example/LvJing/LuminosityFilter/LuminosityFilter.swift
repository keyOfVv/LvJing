//
//  LuminosityFilter.swift
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import MetalKit
import LvJing

public final class LuminosityFilter: LvJing {
   
   public init(resolution: CGSize) {
      super.init(
         resolution: resolution,
         libraryURL: nil,
         vertexFunctionName: "vertex_main",
         fragmentFunctionName: "fragment_lum")
   }
}

