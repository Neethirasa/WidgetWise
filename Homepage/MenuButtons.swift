//
//  MenuButtons.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-06.
//

import SwiftUI

struct MenuButtons: View {
    
    var buttonImage: String
    
    @Binding var quote: String
    @Binding  var isExpanded: Bool
    
      var body: some View {
          Button(action: {
              print(buttonImage)
              quote = buttonImage
              isExpanded.toggle()
          }) {
              ZStack {
                  VStack{
                      Text(buttonImage)
                          .foregroundColor(.white)
                          .padding()
                          .font(.custom(
                                  "Futura-Medium",
                                  fixedSize: 12))
                          .frame(width: 350)
                      
                      VStack(alignment: .leading, spacing: 0){
                      }
                      .frame(height: 0.5)
                      .frame(width: UIScreen.main.bounds.width * 0.5)
                     // .frame(maxWidth: .infinity, alignment: .leading)
                      .background(Color.black)
                  }
                  
              }
          }
      }
}
/*
 #Preview {
 MenuButtons()
 }
 */
