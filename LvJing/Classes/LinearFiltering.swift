//
//  LinearFiltering.swift
//  LvJing
//
//  Created by Ke Yang on 2020/9/2.
//

import Foundation

/// entrance +> filterA +> filterB +> terminal
public protocol LinearFiltering: class {
   
   var entrance: ChainableFiltering { get }
   
   var terminal: ChainableFiltering { get }
   
   func buildUp()
   
   func propagate()
   
   func breakDown()
}

extension LinearFiltering {
   
   public func propagate() {
      self.terminal.propagate()
   }
   
   public func breakDown() {
      self.terminal.breakDown()
   }
}

@discardableResult
public func +> (lhs: ChainableFiltering, rhs: LinearFiltering) -> LinearFiltering {
   lhs +> rhs.entrance
   return rhs
}

@discardableResult
public func +> (lhs: LinearFiltering, rhs: ChainableFiltering) -> ChainableFiltering {
   lhs.terminal +> rhs
   return rhs
}

@discardableResult
public func +> (lhs: LinearFiltering, rhs: LinearFiltering) -> LinearFiltering {
   lhs.terminal +> rhs.entrance
   return rhs
}

@discardableResult
public func +> (lhs: InputPlaceholder, rhs: LinearFiltering) -> LinearFiltering {
   lhs +> rhs.entrance
   return rhs
}

public func => (lhs: LinearFiltering, rhs: CVPixelBuffer) {
   lhs.terminal.renderIn(pixelBuffer: rhs)
}
