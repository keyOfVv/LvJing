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
   
   var inputs: [MTLTexture?] { set get }

   var output: MTLTexture? { get }
   
   var isEntrance: Bool { get }
   
   var isTerminal: Bool { get }

   func findEntrances() -> [ChainableFiltering]
 
   func findTerminal() -> ChainableFiltering
   
   func process()
   
   func propagate()
   
   func disconnect()
}

extension ChainableFiltering {
   
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
   
   public func disconnect() {
      if isEntrance {
         self.froms.removeAll()
         self.to = nil
      }
      else {
         for from in froms {
            from.disconnect()
         }
         self.froms.removeAll()
         self.to = nil
      }
   }
}
