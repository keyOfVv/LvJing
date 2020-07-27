//
//  Utilities.swift
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

func loadImage(url: URL) -> CGImage? {
   let source = CGImageSourceCreateWithURL(
      url as CFURL,
      nil)!
   return CGImageSourceCreateImageAtIndex(source, 0, nil)
}

func makePool(resolution: CGSize) -> CVPixelBufferPool {
   var pool: CVPixelBufferPool?
   let pixelBufferAttributes = [
      kCVPixelBufferMemoryAllocatorKey: kCFAllocatorDefault as Any,
      kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32ARGB as Any,
      kCVPixelBufferWidthKey: resolution.width as CFNumber,
      kCVPixelBufferHeightKey: resolution.height as CFNumber,
      kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue as Any,
      kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue as Any,
      kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary] as CFDictionary
   let success = CVPixelBufferPoolCreate(
      kCFAllocatorDefault,
      nil,
      pixelBufferAttributes,
      &pool)
   guard success == kCVReturnSuccess else { fatalError() }
   return pool!
}

extension CGImage {
   
   var size: CGSize {
      return CGSize(width: width, height: height)
   }
   
   class func make(pixelBuffer: CVPixelBuffer) -> CGImage? {
      CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
      defer {
         CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)         
      }
      let baseAddr = CVPixelBufferGetBaseAddress(pixelBuffer)
      let colorSpace = CGColorSpaceCreateDeviceRGB()
      let pixelFormatType = CVPixelBufferGetPixelFormatType(pixelBuffer)
      var bitmapInfo: CGBitmapInfo
      switch pixelFormatType {
      case kCVPixelFormatType_32ARGB:
         bitmapInfo =
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
      case kCVPixelFormatType_32BGRA:
         bitmapInfo =
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
               .union(.byteOrder32Little)
      default:
         fatalError()
      }

      let cgContext = CGContext(
         data: baseAddr,
         width: CVPixelBufferGetWidth(pixelBuffer),
         height: CVPixelBufferGetHeight(pixelBuffer),
         bitsPerComponent: 8,
         bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
         space: colorSpace,
         bitmapInfo: bitmapInfo.rawValue)!
      let cgImage = cgContext.makeImage()
      return cgImage
   }

}
