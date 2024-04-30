//
//  CustomGoogleSignInButton.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-15.
//

import SwiftUI

struct CustomGoogleSignInButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image("googleIcon") // Ensure you have a Google icon asset
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Text("Sign in with Google")
                    .foregroundColor(.white)
                    .font(.system(size: 17, weight: .semibold))
            }
            .padding()
            .frame(height: UIScreen.main.bounds.height * 0.055)
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .background(Color.black)
            .cornerRadius(8)
        }
        .padding(.horizontal)
    }
}
/*
 #Preview {
 CustomGoogleSignInButton(action: () -> Void)
 }
 */
