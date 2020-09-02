//
//  ChainableFiltering.swift
//  LvJing
//
//  Created by Ke Yang on 2020/7/24.
//

import MetalKit

public protocol ChainableFiltering: class {
   
   var froms: [ChainableFiltering] { set get }
   
   var to: ChainableFiltering? { set get }
   
   var inputs: [MTLTexture?] { get }

   var output: MTLTexture? { get }
   
   var isEntrance: Bool { get }
   
   var isTerminal: Bool { get }
   
   var numberOfUpstreamFilters: Int { get }

   func findEntrances() -> [ChainableFiltering]
 
   func findTerminal() -> ChainableFiltering
   
   func process()
   
   func propagate()
   
   func disconnect()
   
   func breakDown()
   
   func clear()
   
   func clearAll()
   
   func renderIn(pixelBuffer: CVPixelBuffer)
}

infix operator =>: AdditionPrecedence
infix operator +>: AdditionPrecedence

/// Chain two chainable units together;
/// - Parameters:
///   - lhs: Upstream unit;
///   - rhs: Downstream unit;
/// - Returns: Downstream unit;
@discardableResult
public func +> (lhs: ChainableFiltering, rhs: ChainableFiltering) -> ChainableFiltering {
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
public func +> (lhs: CGImage, rhs: ChainableFiltering) -> ChainableFiltering {
   let placeholder = InputPlaceholder()
   lhs => placeholder
   return placeholder +> rhs
}

/// Draw output of unit into a buffer;
/// - Parameters:
///   - lhs: An unit;
///   - rhs: An initialized buffer;
public func => (lhs: ChainableFiltering, rhs: CVPixelBuffer) {
   lhs.renderIn(pixelBuffer: rhs)
}

extension ChainableFiltering {
   
   public var numberOfUpstreamFilters: Int {
      if isEntrance {
         return 1
      }
      else {
         var n = 0
         for from in froms {
            n += from.numberOfUpstreamFilters
         }
         return n
      }
   }
   
   public func propagate() {
      if isEntrance {
         process()
      }
      else {
         for from in froms {
            from.propagate()
         }
         process()
      }
   }
   
   public var isEntrance: Bool {
      return froms.isEmpty
   }
   
   public func findEntrances() -> [ChainableFiltering] {
      var allEntrances: [ChainableFiltering] = []
      if isEntrance {
         allEntrances.append(self)
      }
      else {
         for from in froms {
            allEntrances.append(contentsOf: from.findEntrances())
         }
      }
      return allEntrances
   }
   
   public var isTerminal: Bool {
      return to == nil
   }
   
   public func findTerminal() -> ChainableFiltering {
      if isTerminal {
         return self
      }
      else {
         var terminal = self.to!
         while !terminal.isTerminal {
            terminal = terminal.to!
         }
         return terminal
      }
   }
   
   public func breakDown() {
      if !isEntrance {
         for from in froms {
            from.breakDown()
         }
      }
      disconnect()
   }
   
   public func clearAll() {
      if !isEntrance {
         for from in froms {
            from.clearAll()
         }
      }
      clear()
   }
   

}
