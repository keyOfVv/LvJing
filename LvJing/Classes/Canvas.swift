//
//  Canvas.swift
//  LvJing
//
//  Created by Ke Yang on 2020/7/24.
//

import MetalKit
import ModelIO

class Canvas {
   
   let pipelineState: MTLRenderPipelineState
   let vertices: [SIMD4<Float>] = [
      [-1.0, -1.0, 0.0, 1.0],    // bottom left 
      [ 1.0, -1.0, 1.0, 1.0],    // bottom right
      [ 1.0,  1.0, 1.0, 0.0],    // top right
      [-1.0,  1.0, 0.0, 0.0]     // top left
   ]
   let vertexIndices: [UInt16] = [
      0, 1, 2,
      0, 2, 3
   ]
   let vertexBuffer: MTLBuffer
   let indexBuffer: MTLBuffer
   
   init(
      library: MTLLibrary,
      vertexFunctionName: String,
      fragmentFunctionName: String)
   {
      let device = Renderer.device!
      vertexBuffer = device.makeBuffer(
         bytes: vertices,
         length: vertices.count * MemoryLayout<SIMD4<Float>>.stride,
         options: [])!
      indexBuffer = device.makeBuffer(
         bytes: vertexIndices,
         length: vertexIndices.count * MemoryLayout<UInt16>.stride,
         options: [])!
      pipelineState = Self.buildPipelineState(
         library: library,
         vertexFunctionName: vertexFunctionName,
         fragmentFunctionName: fragmentFunctionName)
   }
   
   private static func buildPipelineState(
      library: MTLLibrary,
      vertexFunctionName: String,
      fragmentFunctionName: String) -> MTLRenderPipelineState
   {
      let vertexFunction = library.makeFunction(name: vertexFunctionName)
      let fragmentFunction = library.makeFunction(name: fragmentFunctionName)

      var pipelineState: MTLRenderPipelineState
      let pipelineDescriptor = MTLRenderPipelineDescriptor()
      pipelineDescriptor.vertexFunction = vertexFunction
      pipelineDescriptor.fragmentFunction = fragmentFunction
      pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
      do {
         pipelineState = try Renderer.device
            .makeRenderPipelineState(descriptor: pipelineDescriptor)
      }
      catch let error {
         fatalError(error.localizedDescription)
      }
      return pipelineState
   }
}
