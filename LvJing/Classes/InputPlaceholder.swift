//
//  InputPlaceholder.swift
//  LvJing
//
//  Created by Ke Yang on 2020/7/24.
//

import MetalKit

public class InputPlaceholder: ChainableFiltering {
   
   static let textureLoader: MTKTextureLoader =
      MTKTextureLoader(device:
         Renderer.device
            ?? MTLCreateSystemDefaultDevice()!)
   
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
   
   public init() {}
   
   public func process() {
      // do nothing
   }
   
   public func clear() {
      output = nil
   }
   
   public func disconnect() {
      self.output = nil
      self.to = nil
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

extension InputPlaceholder {
   
   @discardableResult
   public static func => (lhs: CGImage, rhs: InputPlaceholder) -> InputPlaceholder {
      rhs.output = try! textureLoader.newTexture(
         cgImage: lhs,
         options: rhs.defaultTextureLoaderOptions)
      return rhs
   }
   
   @discardableResult
   public static func => (lhs: CVPixelBuffer, rhs: InputPlaceholder) -> InputPlaceholder {
      CVPixelBufferLockBaseAddress(lhs, CVPixelBufferLockFlags.readOnly)
      let w = CVPixelBufferGetWidth(lhs)
      let h = CVPixelBufferGetHeight(lhs)
      let format = MTLPixelFormat.bgra8Unorm
      var textureRef: CVMetalTexture?
      var textureCache: CVMetalTextureCache!
      CVMetalTextureCacheCreate(
         kCFAllocatorDefault,
         nil,
         Renderer.device,
         nil,
         &textureCache)
      CVMetalTextureCacheCreateTextureFromImage(
         nil,
         textureCache,
         lhs,
         nil,
         format,
         w,
         h,
         0,
         &textureRef)
      let texture = CVMetalTextureGetTexture(textureRef!)
      rhs.output = texture
      CVPixelBufferUnlockBaseAddress(lhs, CVPixelBufferLockFlags.readOnly)
      return rhs
   }
}
