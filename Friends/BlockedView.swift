//
//  BlockedView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-29.
//

import SwiftUI

struct BlockedView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var blockedUsers: [BlockedUser] = [] // Use BlockedUser here
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color("WashedBlack").edgesIgnoringSafeArea(.all)

            if isLoading {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(blockedUsers) { user in
                            HStack {
                                Text(user.displayName) // Assuming BlockedUser has a displayName property
                                    .foregroundColor(.white)
                                    .font(.custom("Futura-Medium", fixedSize: 16))// Adjust text color for visibility
                                    .padding(.horizontal,5)
                                    .bold()
                                
                                Spacer()
                                
                                Button("Unblock") {
                                    Task {
                                        do {
                                            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                                            try await UserManager.shared.unblockUser(currentUserId: currentUserId, blockedUserId: user.blockedUserId)
                                            self.blockedUsers = try await UserManager.shared.fetchBlockedUsersList(userId: currentUserId)
                                        } catch {
                                            print("Error unblocking user: \(error)")
                                        }
                                    }
                                }
                                .foregroundColor(.red)
                                .padding()
                            }
                            .background(Color(hex: "#333333"))
                            .cornerRadius(5)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            Task {
                do {
                    let currentUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                    self.blockedUsers = try await UserManager.shared.fetchBlockedUsersList(userId: currentUserId)
                    self.isLoading = false
                } catch {
                    print("Error fetching blocked users list: \(error)")
                    self.isLoading = false
                }
            }
        }
        .background(Color("WashedBlack"))
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 12, height: 12)
                            
                        //Text("Home")
                            //.font(.custom("Futura-Medium", size: 18))
                    }
                    .padding(6)
                    .padding(.horizontal,5)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Blocked").font(.custom("Futura-Medium", fixedSize: 18))
            }
        }
    }
}

#Preview {
    BlockedView()
}

#Preview {
    BlockedView()
}

