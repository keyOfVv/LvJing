//
//  Renderer.swift
//  LvJing
//
//  Created by Ke Yang on 2020/7/24.
//

import MetalKit

protocol RendererDelegate: class {

   func numberOfVertexBuffers() -> Int
   func vertexBufferFor(indexAt index: Int) -> MTLBuffer
   func indexCount() -> Int
   func indexBuffer() -> MTLBuffer
   
   func setVertexBytesFor(encoder: MTLRenderCommandEncoder)
   func setFragmentSamplerStateFor(encoder: MTLRenderCommandEncoder)
   func setFragmentBytesFor(encoder: MTLRenderCommandEncoder)
}

class Renderer: NSObject {
   
   static var device: MTLDevice!
   
   static var commandQueue: MTLCommandQueue!
   
   var inputs: [MTLTexture?] = []
   
   var output: MTLTexture?
   
   var renderPipelineState: MTLRenderPipelineState!
   
   var waitUntilCompleted: Bool = false
   
   weak var delegate: RendererDelegate?
   
   init(metalView: MTKView) {
      if Renderer.device == nil {
         let device = MTLCreateSystemDefaultDevice()!
         Renderer.device = device
         Renderer.commandQueue = device.makeCommandQueue()!
      }
      
      metalView.device = Renderer.device
      
      super.init()
      metalView.clearColor = MTLClearColor(red: 0,
                                           green: 0,
                                           blue: 0,
                                           alpha: 0)
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
      
      renderEncoder.setRenderPipelineState(renderPipelineState)
      delegate?.setFragmentSamplerStateFor(encoder: renderEncoder)
      
      let nVertexBuffer = delegate?.numberOfVertexBuffers() ?? 0
      for i in 0..<nVertexBuffer {
         renderEncoder.setVertexBuffer(
            delegate?.vertexBufferFor(indexAt: i),
            offset: 0,
            index: i)
      }
      delegate?.setVertexBytesFor(encoder: renderEncoder)
      
      renderEncoder.setFragmentTextures(inputs, range: 0..<inputs.count)
      delegate?.setFragmentBytesFor(encoder: renderEncoder)

      renderEncoder.drawIndexedPrimitives(
         type: MTLPrimitiveType.triangle,
         indexCount: delegate?.indexCount() ?? 0,
         indexType: MTLIndexType.uint16,
         indexBuffer: delegate!.indexBuffer(),
         indexBufferOffset: 0)
      
      renderEncoder.endEncoding()
      output = nil
      guard
         let drawable = view.currentDrawable
         else { return }
      output = drawable.texture
      commandBuffer.present(drawable)
      commandBuffer.commit()
      if waitUntilCompleted {
         commandBuffer.waitUntilCompleted()
      }
   }
}
