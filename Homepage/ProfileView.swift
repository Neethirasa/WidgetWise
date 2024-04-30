//
//  ProfileView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-01-15.
//

import SwiftUI
import Combine

@MainActor
final class ProfileViewModel: ObservableObject{
    
    @Published private(set) var user: DBUser? = nil

    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
}

struct ProfileView: View {
    @State private var username: String = ""
    @State private var displayNameExists = false
    @Binding var nullUsername: Bool
    @State private var showSignInView: Bool = false
    @StateObject private var viewModel = ProfileViewModel()
    
    @FocusState private var isUsernameFocused: Bool // Track the focus state of the text field
    
    let textLimit = 10 //Your limit
    var body: some View {
        NavigationView{
            ZStack{
                ZStack{
                    Color.washedBlack.ignoresSafeArea()
                    VStack{
                        VStack{
                            Text("Create an Account")
                                .foregroundStyle(.white)
                                .font(.custom(
                                        "Futura-Medium",
                                        fixedSize: 40))
                                .padding()
                        }
                        Spacer().frame(height:UIScreen.main.bounds.height * 0.05)
                        
                        VStack{
                            HStack{
                                Text("Username")
                                    .foregroundStyle(.white)
                                    .font(.custom(
                                            "Futura-Medium",
                                            fixedSize: 20))
                                Spacer().frame(width: UIScreen.main.bounds.width * 0.45)
                            }
                            
                            TextField("Enter your username", text: $username) // <1>, <2>
                            .frame(width: UIScreen.main.bounds.width * 0.6 , height: UIScreen.main.bounds.height * 0.02)
                            .font(.custom("Futura-Medium", fixedSize: 16))
                            .foregroundColor(.white)
                            .cornerRadius(.infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(.white, lineWidth: 2))
                            .onReceive(Just(username)) { _ in
                                    limitText(textLimit)
                                    checkDisplayName() // Call checkDisplayName() when the username changes
                                }
                            .focused($isUsernameFocused) // Bind the focus state of the text field
                            .onSubmit { // Detect when the user submits the text field
                                    checkDisplayName()
                                                    }
                            
                        }
                        
                        if displayNameExists {
                               Text("Display name already exists. Please try another one.")
                                   .foregroundColor(.red)
                                   .font(.custom("Futura-Medium", fixedSize: 14))
                                   .padding(.top, 5)
                           }
                        
                        Spacer().frame(height: 30)
                        VStack{
                            Button {
                                createOrUpdateUsername()
                            } label: {
                                Text("Create Account")
                                    .font(.custom("Futura-Medium", fixedSize: 20))
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .background(.customTeal)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(.customTeal, lineWidth: 2))
                            .cornerRadius(10)
                            .disabled(displayNameExists || username.isEmpty || username.trimmingCharacters(in: .whitespaces).isEmpty) // Disable the button if display name exists
                        }
                        
                    }
                    
                    
                }
                .background(.washedBlack)
                .scrollContentBackground(.hidden)
            }
            .onChange(of: displayNameExists) {
                            // Refresh the view when displayNameExists changes
                            self.isUsernameFocused = true
                
            }
        }
        .background(Color.washedBlack.ignoresSafeArea())
    }
    
    //Function to keep text length in limits
        func limitText(_ upper: Int) {
            if username.count > upper {
                username = String(username.prefix(upper))
            }
        }
    
    private func createOrUpdateUsername() {
            Task {
                do {
                    let exists = try await UserManager.shared.displayNameExists(displayName: username)
                    if !exists {
                        try await UserManager.shared.addUsername(name: username)
                        nullUsername = false
                        AuthenticationManager.shared.updateDisplayName(displayName: username)
                        // Navigate away or show success message...
                    } else {
                        displayNameExists = true
                    }
                } catch {
                    print("Failed to update username:", error)
                }
            }
        }
    
    private func checkDisplayName() {
            Task {
                do {
                    displayNameExists = try await UserManager.shared.displayNameExists(displayName: username)
                } catch {
                    print("Error checking display name:", error)
                }
            }
        }
}

#Preview {
    ProfileView(nullUsername: .constant(false))
}
