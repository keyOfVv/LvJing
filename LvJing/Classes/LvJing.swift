//
//  LvJing.swift
//  LvJing
//
//  Created by Ke Yang on 2020/7/24.
//

import MetalKit

/// Kernel Filter;
open class LvJing: RendererDelegate, ChainableFiltering {
   
   /// size of output image;
   public let resolution: CGSize
   
   private let view: MTKView
   
   private let render: Renderer
   
   public class var sharedDevice: MTLDevice {
      return Renderer.device
   }
   
   private let colorspace: CGColorSpace
   
   private let canvas: Canvas
   
   // MARK: ChainableFiltering
   
   private let context: CIContext
   
   public var froms: [ChainableFiltering]
   
   public weak var to: ChainableFiltering?
   
   open var inputs: [MTLTexture?] {
      return froms.map{ $0.output }
   }
   
   public var output: MTLTexture? {
      return render.output
   }
   
   public var defaultSamplerState: MTLSamplerState
   
   public var waitUntilCompleted: Bool = false {
      willSet {
         render.waitUntilCompleted = newValue
      }
   }
   
   /// Create a filter;
   /// - Parameters:
   ///   - resolution: size of output iamge;
   ///   - libraryURL: url of compiled Metal Shading Language binary, typically `.metallib` file;
   ///   pass `nil` if using default metallib file;
   ///   - vertexFunctionName: vertex function name declared in MSL code;
   ///   - fragmentFunctionName: fragment function name declared in MSL code;
   public init(
      resolution: CGSize,
      libraryURL: URL? = nil,
      vertexFunctionName: String,
      fragmentFunctionName: String,
      enableAutoBlend: Bool = false)
   {
      self.resolution = resolution
      let screenScale = UIScreen.main.scale
      let frame = CGRect(
         x: 0, y: 0,
         width: resolution.width / screenScale,
         height: resolution.height / screenScale)
      view = MTKView(frame: frame)
      view.enableSetNeedsDisplay = false
      view.isPaused = true
      view.framebufferOnly = false
      
      render = Renderer(metalView: view)
      
      var library: MTLLibrary!
      if let path = libraryURL?.path {
         library = try! Self.sharedDevice.makeLibrary(filepath: path)
      }
      else {
         library = Self.sharedDevice.makeDefaultLibrary()!
      }
      
      canvas = Canvas(
         library: library,
         vertexFunctionName: vertexFunctionName,
         fragmentFunctionName: fragmentFunctionName,
         enableAutoBlend: enableAutoBlend)
      
      render.renderPipelineState = canvas.pipelineState
      render.waitUntilCompleted = waitUntilCompleted

      colorspace = CGColorSpaceCreateDeviceRGB()
      context = CIContext()
      froms = []
      defaultSamplerState = Self.createSamplerState(maxAnisotropy: 8)
      render.delegate = self
   }
   
   open func numberOfVertexBuffers() -> Int {
      return 1
   }
   
   open func vertexBufferFor(indexAt index: Int) -> MTLBuffer {
      switch index {
      case 0:
         return canvas.vertexBuffer
      default:
         fatalError()
      }
   }
      
   open func indexCount() -> Int {
      return canvas.vertexIndices.count
   }
   
   open func indexBuffer() -> MTLBuffer {
      return canvas.indexBuffer
   }
   
   open func setVertexBytesFor(encoder: MTLRenderCommandEncoder) {
      // overriding point
   }
   
   open func setFragmentSamplerStateFor(encoder: MTLRenderCommandEncoder) {
      encoder.setFragmentSamplerState(defaultSamplerState, index: 0)
      // overriding point
   }
   
   open func setFragmentBytesFor(encoder: MTLRenderCommandEncoder) {
      // overriding point
   }
   
   open func process() {
      render.inputs = self.inputs
      view.draw()
      render.inputs = []
   }
   
   open func disconnect() {
      froms.removeAll()
      to = nil
   }
   
   open func clear() {
      render.output = nil
      view.releaseDrawables()
   }
}

extension LvJing {
   
   public static func createSamplerState(
      maxAnisotropy: Int,
      addressMode: MTLSamplerAddressMode = .clampToZero) -> MTLSamplerState
   {
      let descriptor = MTLSamplerDescriptor()
      descriptor.sAddressMode = addressMode
      descriptor.tAddressMode = addressMode
      descriptor.mipFilter = .linear
      descriptor.minFilter = .linear
      descriptor.magFilter = .linear
      descriptor.maxAnisotropy = maxAnisotropy
      return Renderer.device.makeSamplerState(descriptor: descriptor)!
   }
   
   var defaultTextureLoaderOptions: [MTKTextureLoader.Option: Any] {
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

// MARK: - Operations

infix operator =>: AdditionPrecedence
infix operator +>: AdditionPrecedence

extension LvJing {
   
   /// Chain two filters together;
   /// - Parameters:
   ///   - lhs: Upstream filter;
   ///   - rhs: Downstream filter;
   /// - Returns: Downstream filter;
   @discardableResult
   public static func +> (lhs: LvJing, rhs: LvJing) -> LvJing {
      lhs.to = rhs
      rhs.froms.append(lhs)
      return rhs
   }
   
   /// Chain input with a filter;
   /// - Parameters:
   ///   - lhs: Input placeholder;
   ///   - rhs: Downstream filter;
   /// - Returns: Downstream filter;
   @discardableResult
   public static func +> (lhs: InputPlaceholder, rhs: LvJing) -> LvJing {
      lhs.to = rhs
      rhs.froms.append(lhs)
      return rhs
   }
   
   /// Chain a source image with a filter;
   /// - Parameters:
   ///   - lhs: Source image as input;
   ///   - rhs: Downstream filter;
   /// - Returns: Downstream filter;
   @discardableResult
   public static func +> (lhs: CGImage, rhs: LvJing) -> LvJing {
      let placeholder = InputPlaceholder()
      lhs => placeholder
      return placeholder +> rhs
   }
   
   /// Draw output of filter into a buffer;
   /// - Parameters:
   ///   - lhs: A filter;
   ///   - rhs: An initialized buffer;
   public static func => (lhs: LvJing, rhs: CVPixelBuffer) {
      guard let outputTexture = lhs.output else {
         print("outputTexture is nil!!!")
         return
      }
      let ciImageOptions = [
         CIImageOption.colorSpace: lhs.colorspace
      ]
      var ciImage: CIImage
      if #available(iOS 11.0, *) {
         ciImage = CIImage(
            mtlTexture: outputTexture,
            options: ciImageOptions)!
            .oriented(CGImagePropertyOrientation.downMirrored)
      } else {
         ciImage = CIImage(
            mtlTexture: outputTexture,
            options: ciImageOptions)!
            .oriented(forExifOrientation: 4)
      }
      lhs.context.render(ciImage, to: rhs)
      lhs.to = nil
      #if SDK_DEBUG
      assert(lhs.to == nil)
      #endif
   }
}

extension MTLClearColor {
   
   public var uiColor: UIColor {
      return UIColor(
         red: CGFloat(red),
         green: CGFloat(green),
         blue: CGFloat(blue),
         alpha: CGFloat(alpha))
   }
}

extension UIColor {
   
   public var mtlColor: MTLClearColor {
      var r: CGFloat = 0.0
      var g: CGFloat = 0.0
      var b: CGFloat = 0.0
      var a: CGFloat = 1.0
      getRed(&r, green: &g, blue: &b, alpha: &a)
      return MTLClearColor(
         red: Double(r),
         green: Double(g),
         blue: Double(b),
         alpha: Double(a))
   }
}
