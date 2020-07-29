//
//  BinaryTreePreview.swift
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI
import LvJing

struct BinaryTreePreview: View {
   
   @State private var originImageA: CGImage!
   
   @State private var originImageB: CGImage!
   
   @State private var bufferPool: CVPixelBufferPool!
   
   @State private var inputA: InputPlaceholder!
   
   @State private var inputB: InputPlaceholder!
   
   @State private var alphaFilterA: AffineTransformFilter!
   
   @State private var alphaFilterB: GammaFilter!
   
   @State private var betaFilterA: AffineTransformFilter!
   
   @State private var betaFilterB: LuminosityFilter!
   
   @State private var terminal: SwipeTransitionFilter!
   
   @State private var finalOuput: CGImage!
   
   @State private var alphaBranchOutputs = [CGImage?](repeating: nil, count: 3)
   
   @State private var betaBranchOutputs = [CGImage?](repeating: nil, count: 3)
   
   private var alphaFilters: [LvJing] {
      return [alphaFilterA, alphaFilterB]
   }
   
   private var betaFilters: [LvJing] {
      return [betaFilterA, betaFilterB]
   }
   
   private var stepsOfBranchAlpha: [String] {
      return ["Input A", "Scale x2.0", "Gamma"]
   }
   
   private var stepsOfBranchBeta: [String] {
      return ["Input B", "Rotation pi", "Luminosity"]
   }
   
   var body: some View {
      HStack {
         VStack {
            HStack {
               ForEach(0..<alphaBranchOutputs.count) {
                  NodeView(
                     stepName: Binding<String>.constant(self.stepsOfBranchAlpha[$0]),
                     image: Binding<CGImage?>.constant(self.alphaBranchOutputs[$0]))
               }
            }
            HStack {
               ForEach(0..<betaBranchOutputs.count) {
                  NodeView(
                     stepName: Binding<String>.constant(self.stepsOfBranchBeta[$0]),
                     image: Binding<CGImage?>.constant(self.betaBranchOutputs[$0]))
               }
            }
         }
         
         NodeView(
            stepName: Binding<String>.constant("A to B Transition 40%"),
            image: Binding<CGImage?>.constant(self.finalOuput))
      }
      .onAppear {
         self.originImageA = loadImage(
            url: Bundle.main.url(forResource: "base", withExtension: "jpg")!)!
         self.inputA = InputPlaceholder()
         
         self.originImageB = loadImage(
            url: Bundle.main.url(forResource: "desert", withExtension: "jpg")!)!
         self.inputB = InputPlaceholder()
         
         let resolution = self.originImageA.size
         self.bufferPool = makePool(resolution: resolution)
         
         self.alphaFilterA = AffineTransformFilter(resolution: resolution)
         self.alphaFilterA.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
         
         self.alphaFilterB = GammaFilter(resolution: resolution)
         self.alphaFilterB.gamma = 2.0
         
         self.betaFilterA = AffineTransformFilter(resolution: resolution)
         self.betaFilterA.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
         
         self.betaFilterB = LuminosityFilter(resolution: resolution)
         
         self.terminal = SwipeTransitionFilter(resolution: resolution)
         self.terminal.progress = 0.4
         
         self.buildUp()
         self.process()
         self.breakDown()
      }
   }
   
   func buildUp() {
      print("build up")
      
      self.originImageA => self.inputA +> self.alphaFilterA +> self.alphaFilterB +> self.terminal
      
      self.originImageB => self.inputB +> self.betaFilterA +> self.betaFilterB +> self.terminal
   }
   
   func breakDown() {
      self.terminal.disconnect()
      print("break down")
   }
   
   func process() {
      self.finalOuput = nil
      
      var alphaOutputs = [CGImage?]()
      alphaOutputs.append(originImageA)
      self.alphaFilters.forEach { (filter) in
         var buffer: CVPixelBuffer?
         let success = CVPixelBufferPoolCreatePixelBuffer(
            nil,
            self.bufferPool!,
            &buffer)
         guard success == kCVReturnSuccess else { return }
         filter.propagate()
         filter => buffer!
         let filteredImage = CGImage.make(pixelBuffer: buffer!)
         alphaOutputs.append(filteredImage)
      }
      
      var betaOutputs = [CGImage?]()
      betaOutputs.append(originImageB)
      self.betaFilters.forEach { (filter) in
         var buffer: CVPixelBuffer?
         let success = CVPixelBufferPoolCreatePixelBuffer(
            nil,
            self.bufferPool!,
            &buffer)
         guard success == kCVReturnSuccess else { return }
         filter.propagate()
         filter => buffer!
         let filteredImage = CGImage.make(pixelBuffer: buffer!)
         betaOutputs.append(filteredImage)
      }
      
      var buffer: CVPixelBuffer?
      let success = CVPixelBufferPoolCreatePixelBuffer(
         nil,
         self.bufferPool!,
         &buffer)
      guard success == kCVReturnSuccess else { return }
      self.terminal.propagate()
      self.terminal => buffer!
      self.finalOuput = CGImage.make(pixelBuffer: buffer!)
      
      self.alphaBranchOutputs = alphaOutputs
      self.betaBranchOutputs = betaOutputs
   }
}

struct BinaryTreePreview_Previews: PreviewProvider {
   static var previews: some View {
      BinaryTreePreview()
   }
}
