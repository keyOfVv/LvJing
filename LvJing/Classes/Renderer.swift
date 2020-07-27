//
//  Renderer.swift
//  LvJing
//
//  Created by Ke Yang on 2020/7/24.
//

import MetalKit

protocol RendererDelegate: class {
   func setFragmentSamplerStateFor(encoder: MTLRenderCommandEncoder)
   func setFragmentBytesFor(encoder: MTLRenderCommandEncoder)
}

class Renderer: NSObject {
   static var device: MTLDevice!
   static var commandQueue: MTLCommandQueue!
   
   private let canvas: Canvas
   
   var inputs: [MTLTexture?] = []
   
   var output: MTLTexture?
   
   weak var delegate: RendererDelegate?
   
   init(
      metalView: MTKView,
      libraryURL: URL? = nil,
      vertexFunctionName: String,
      fragmentFunctionName: String)
   {
      if Renderer.device == nil {
         let device = MTLCreateSystemDefaultDevice()!
         Renderer.device = device
         Renderer.commandQueue = device.makeCommandQueue()!
      }
      
      metalView.device = Renderer.device
      
      var library: MTLLibrary!
      if let path = libraryURL?.path {
         library = try! Self.device.makeLibrary(filepath: path)
      }
      else {
         library = Self.device.makeDefaultLibrary()!
      }
      
      canvas = Canvas(
         library: library,
         vertexFunctionName: vertexFunctionName,
         fragmentFunctionName: fragmentFunctionName)
      
      super.init()
      
      metalView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 0)
      metalView.delegate = self
   }
}

// MARK: - MTKViewDelegate

extension Renderer: MTKViewDelegate {
   
   func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
      // do nothing...
   }
   
   func draw(in view: MTKView) {
      guard
         let descriptor = view.currentRenderPassDescriptor,
         let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
         let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: descriptor)
         else { return }
      
      renderEncoder.setRenderPipelineState(canvas.pipelineState)
      delegate?.setFragmentSamplerStateFor(encoder: renderEncoder)
      
      renderEncoder.setVertexBuffer(
         canvas.vertexBuffer,
         offset: 0,
         index: 0)
      
      renderEncoder.setFragmentTextures(inputs, range: 0..<inputs.count)
      delegate?.setFragmentBytesFor(encoder: renderEncoder)
      
      renderEncoder.drawIndexedPrimitives(
         type: MTLPrimitiveType.triangle,
         indexCount: canvas.vertexIndices.count,
         indexType: MTLIndexType.uint16,
         indexBuffer: canvas.indexBuffer,
         indexBufferOffset: 0)
      
      renderEncoder.endEncoding()
      output = nil
      guard
         let drawable = view.currentDrawable
         else { return }
      output = drawable.texture
      commandBuffer.present(drawable)
      commandBuffer.commit()
   }
}
