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
            fatalError("InputPlaceholder can only act as a upstream node.")
         }
      }
   }
   
   public var inputs: [MTLTexture?] = [] {
      willSet {
         fatalError("InputPlaceholder can only act as a upstream node.")
      }
   }
   
   public var output: MTLTexture?
   
   public weak var to: ChainableFiltering?
   
   public var shouldFlipOutputTexture: Bool {
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
