//
//  ManageFriendRequestsView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-18.
//

import SwiftUI
import FirebaseAuth

struct ManageFriendRequestsView: View {
    @State private var friendRequests: [FriendRequest] = []
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color("WashedBlack").edgesIgnoringSafeArea(.all)
            
            // Check if friend requests are empty to show a message
            if friendRequests.isEmpty {
                Text("You have no friend requests.")
                    .font(.custom(
                        "Futura-Medium",
                        fixedSize: 18))
                    .foregroundColor(.gray)
                    .padding()
            } else {
                // Use ScrollView to ensure the background color fills the entire view
                ScrollView {
                    LazyVStack {
                        ForEach(friendRequests) { request in
                            friendRequestRow(for: request)
                                .padding(.horizontal)
                                .padding(.vertical, 2)
                        }
                        .padding(.top,10)
                    }
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { // <2>
                    ToolbarItem(placement: .principal) { // <3>
              
                            Text("Friend Requests").font(.custom(
                                "Futura-Medium",
                                fixedSize: 18))
                    }
                }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button(action: {
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
            },
            trailing: Button(action: { Task { await refreshFriendRequests() } }) {
                Image(systemName: "arrow.clockwise")
                    .padding(6)
            }
        )
        .onAppear {
            Task {
                await refreshFriendRequests()
            }
        }
        .background(Color("WashedBlack")) // Apply background color to the entire view
    }

    private func friendRequestRow(for request: FriendRequest) -> some View {
        
        VStack(alignment: .leading, spacing: 0){
            
            HStack {
                Text(request.fromUserDisplayName ?? "Unknown User")
                    .font(.custom(
                        "Futura-Medium",
                        fixedSize: 16))
                    .foregroundColor(.white) // Adjust text color for visibility
                    .padding(.horizontal,5)
                    .bold()
                Spacer()
                HStack {
                    Button(action: {
                        Task {
                            do {
                                try await UserManager.shared.acceptFriendRequest(fromUserId: request.fromUserId, toUserId: Auth.auth().currentUser?.uid ?? "")
                                await refreshFriendRequests()
                            } catch {
                                print("Error accepting friend request: \(error)")
                            }
                        }
                    }, label: {
                        Image(systemName: "checkmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    })
                    .foregroundColor(.green)
                   
                }
                .padding(.horizontal,10)
                
                HStack {
                    Button(action: {
                        Task {
                            do {
                                try await UserManager.shared.declineFriendRequest(fromUserId: request.fromUserId, toUserId: Auth.auth().currentUser?.uid ?? "")
                                await refreshFriendRequests()
                            } catch {
                                print("Failed to decline friend request: \(error)")
                            }
                        }
                    }, label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    })
                    .foregroundColor(.red)
                }
                .padding(.horizontal,4)
            }
                
        }
        .padding(.vertical,7)
        .padding(.horizontal,5)
        .frame(minHeight: 20)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#333333"))
        .cornerRadius(5)
        
        //end of vstack
    }

    private func refreshFriendRequests() async {
        do {
            self.friendRequests = try await UserManager.shared.fetchIncomingFriendRequests()
        } catch {
            print("Error fetching friend requests: \(error)")
        }
    }
}

// Make sure to replace "FriendRequest" struct definition with your actual FriendRequest model
// Also ensure that UserManager's functions are correctly implemented to fetch, accept, and decline friend requests

struct ManageFriendRequestsView_Previews: PreviewProvider {
    static var previews: some View {
        ManageFriendRequestsView()
    }
}

