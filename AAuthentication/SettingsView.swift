//
//  SettingsView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-01-11.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

@MainActor
final class SettingsViewModel: ObservableObject{
    
    @Published var authProviders: [AuthProviderOption] = []
    
    private let functions = Functions.functions()

        func startAccountDeletionProcess() {
            // Step 1: Call the function to generate a custom token
            functions.httpsCallable("generateDeleteToken").call { result, error in
                guard error == nil, let customToken = result?.data as? String else {
                    print("Error generating custom token: \(String(describing: error))")
                    return
                }

                // Step 2: Use the custom token to re-authenticate the user
                Auth.auth().signIn(withCustomToken: customToken) { authResult, error in
                    guard error == nil else {
                        print("Re-authentication failed: \(String(describing: error))")
                        return
                    }

                    // Step 3: User is re-authenticated, now call the function to delete the user account
                    self.functions.httpsCallable("deleteUserAccount").call { result, error in
                        if let error = error {
                            print("Error deleting user account: \(error.localizedDescription)")
                        } else {
                            print("User account deleted successfully")
                            // Handle user sign-out and UI updates as needed
                        }
                    }
                }
            }
        }
    func  loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders(){
            authProviders = providers
        }
    }
    
    func signOut() throws{
        AuthenticationManager.shared.signOut()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first {
                        window.rootViewController = UIHostingController(rootView: RootView())
                    }
        
    }
    
    func deleteAccount() async throws{
        
        try await AuthenticationManager.shared.delete()
    }
    
    
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    //@Binding var showSignInView: Bool
    
    @State private var settingsView = false
    @State private var showSignInView = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ZStack{
            Color.washedBlack.ignoresSafeArea()
            
            HStack{
                
                /*
                VStack{
                    
                    Spacer().frame(height: 25)
                    Text("Settings")
                        .font(.system(size: 30, weight: .heavy))
                        .font(.custom(
                                "Futura-Medium",
                                fixedSize: 30))
                        .foregroundStyle(.white)
                    Spacer()
                     
                }
                 */
                     
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    //print("Settings")
                                    // 2
                                    dismiss()

                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.backward")
                                            .foregroundColor(.white)
                                        Text("Settings")
                                            .foregroundColor(.white)
                                            .font(.custom(
                                                    "Futura-Medium",
                                                    fixedSize: 20))
                                    }
                                }
                            }
                        }
          
            
            VStack{
                //Spacer().frame(height: 50)
                
                
                Button(role: .destructive){
                    Task{
                        do{
                            try viewModel.signOut()
                            showSignInView = true
                            
                        }catch{
                            print(error)
                        }
                    }
                }label: {
                Text("Delete Account")
              }
                
                .listRowBackground(Color.washedBlack)
                    .font(.custom(
                            "Futura-Medium",
                            fixedSize: 20))
                
                Spacer().frame(height: 15)
                
                Button(role: .destructive){
                    Task{
                        do{
                            settingsView.toggle()
                            showSignInView = true
                            try viewModel.signOut()
                            
                        }catch{
                            print(error)
                        }
                    }
                    
                }label: {
                    Text("Log Out")
                  }
                .listRowBackground(Color.washedBlack)
                .font(.custom(
                        "Futura-Medium",
                        fixedSize: 20))
                
                .onAppear{
                    viewModel.loadAuthProviders()
                }
                .navigationBarTitle("")
                .fullScreenCover(isPresented: $showSignInView, content: {
                    NavigationStack{
                        AuthenticationView(showSignInView: $showSignInView)
                    }
                })
                Spacer().frame(height: 15)
                
            }
            
        }
        .background(.washedBlack)
        .scrollContentBackground(.hidden)
        }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView()
        }
    }
}

