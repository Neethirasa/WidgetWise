//
//  RootView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-01-11.
//

import SwiftUI


struct RootView: View {
    
    @State private var showSignInView: Bool = false
    @State private var nullUsername: Bool = false
    @State private var Rootusername = "null"
    
    var body: some View {
            ZStack{
                if !showSignInView{
                    ZStack{
                        NavigationStack{
                            //SettingsView(showSignInView: $showSignInView)
                            //HomeView()
                            TempHomeView()
                        }
                    }
                    .onAppear{
                        //let authUsername = AuthenticationManager.shared.getDisplayName()
                        //self.nullUsername = authUsername == "nil"
                        Task {
                            await loadNullUsername()
                        }

                    }
                    .fullScreenCover(isPresented: $nullUsername, content: {
                        NavigationStack{
                            ProfileView(nullUsername: $nullUsername)
                        }
                    })
                    
                }
            }
            .onAppear{
                let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
                self.showSignInView = authUser == nil
            }
            .fullScreenCover(isPresented: $showSignInView, content: {
                NavigationStack{
                    AuthenticationView(showSignInView: $showSignInView)
                    
                }
            })
        /*
        .onAppear{
            let authUsername = try? AuthenticationManager.shared.getAuthenticatedUser().username
            self.nullUsername = authUsername == nil
        }
        .fullScreenCover(isPresented: $nullUsername, content: {
            NavigationStack{
                ProfileView(nullUsername: $nullUsername)
            }
        })
         */
    }
    
    func loadNullUsername() async {
        do {
            let isNull = await AuthenticationManager.shared.isDisplayNameNull()
            self.nullUsername = isNull
        }
    }
}



#Preview {
    RootView()
}
