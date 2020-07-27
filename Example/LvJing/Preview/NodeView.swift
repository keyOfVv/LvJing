//
//  NodeView.swift
//  LvJing_Example
//
//  Created by Ke Yang on 2020/7/26.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftUI

struct NodeView: View {

   @Binding var stepName: String
   
   @Binding var image: CGImage?
   
   var body: some View {
      VStack {
         
         Spacer()
         
         if image == nil {
            Text("Processing")
         }
         else {
            Image(image!, scale: 1.0, label: Text("Filtered Image"))
               .resizable()
               .aspectRatio(contentMode: ContentMode.fit)
               .border(Color.primary.opacity(0.3), width: 0.3)
         }
         
         Spacer()
         
         Text(stepName)
            .font(Font.system(
               size: 20,
               weight: Font.Weight.ultraLight,
               design: Font.Design.rounded))
//            .frame(width: 44, height: 44)
//            .overlay(
//               RoundedRectangle(cornerRadius: 22)
//                  .stroke(Color.primary, lineWidth: 0.5))
//            .opacity(0.5)
            .padding()
      }
   }
}

struct NodeView_Previews: PreviewProvider {
   static var previews: some View {
      NodeView(
         stepName: Binding<String>.constant("N/A"),
         image: Binding<CGImage?>.constant(nil))
   }
}
