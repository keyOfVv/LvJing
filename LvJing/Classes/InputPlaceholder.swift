//
//  InputPlaceholder.swift
//  LvJing
//
//  Created by Ke Yang on 2020/7/24.
//

import MetalKit

public class InputPlaceholder: ChainableFiltering {
   
   public var froms: [ChainableFiltering] = [] {
      willSet {
         if !newValue.isEmpty {
            fatalError("占位节点不允许设置上游节点")
         }
      }
   }
   
   public var inputs: [MTLTexture?] = [] {
      willSet {
         fatalError("占位节点不允许设置输入材质")
      }
   }
   
   public var output: MTLTexture?
   
   public weak var to: ChainableFiltering?
   
   public var shouldFlipOutputTexture: Bool {
      // 避免下游节点的材质翻转
      return true
   }
   
   public init(cgImage: CGImage) {
      let textureLoader = MTKTextureLoader(
         device: Renderer.device ?? MTLCreateSystemDefaultDevice()!)
      output = try! textureLoader.newTexture(
         cgImage: cgImage,
         options: defaultTextureLoaderOptions)
   }
   
   deinit {
      #if SDK_DEBUG
//      dog("\(self) DESTROIED")
      #endif
   }
   
   public func process() {
      // do nothing
   }
   
}

extension InputPlaceholder {
   
   private var defaultTextureLoaderOptions: [MTKTextureLoader.Option: Any] {
      if #available(iOS 10.0, *) {
         return [
            .SRGB: false,
            .generateMipmaps: NSNumber(booleanLiteral: false)
         ]
      } else {
         return [
            .SRGB: false
         ]
      }
   }
}
