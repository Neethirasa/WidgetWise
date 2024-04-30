//
//  FriendsView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-28.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FriendGroup: Identifiable, Codable {
    var id: String
    var name: String
    var members: [String]? // Now optional

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case members = "memberIds"
    }
}


struct FriendsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var friends: [Friend] = []
    @State private var isLoading = true
    @State private var showBlocked = false
    @State private var showConfirmationDialog = false
    @State private var selectedFriend: Friend? = nil // To keep track of which friend's action is selected
    @State private var friendGroups: [FriendGroup] = []
    @State private var selectedGroup: FriendGroup? = nil
    @State private var showGroupDialog = false
    @State private var showConfirmationDialogGroup = false
    
    var body: some View {
        ZStack {
            Color("WashedBlack").edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                ScrollView {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Button(action: {
                                showGroupDialog = true
                            }) {
                                Text("Create Group")
                                    .foregroundColor(.white)
                                    .font(.custom("Futura-Medium", fixedSize: 16))
                                    .padding(.horizontal, 5)
                                    .bold()
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 15)
                                    .frame(minHeight: 20)
                                    .frame(maxWidth: .infinity)
                            }
                            
                        }
                        .background(Color(hex: "#333333"))
                        .cornerRadius(5)
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                    }
                    .padding(.top, 20)
                   
                    /*
                    ForEach(friendGroups) { group in
                        Text(group.name)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
*/
                    
                                   LazyVStack {
                                       if (!friendGroups.isEmpty){
                                           HStack{
                                               Text("Groups")
                                                   .foregroundColor(.white)
                                                   .font(.custom("Futura-Medium", fixedSize: 16))
                                                   .padding(.horizontal, 5)
                                                   .bold()
                                               
                                               Spacer()
                                           }
                                           .padding(.horizontal, 15)
                                       }
                                       ForEach(friendGroups) { group in
                                           VStack(alignment: .leading, spacing: 0) {
                                               HStack {
                                                   Text(group.name)
                                                       .foregroundColor(.white)
                                                       .font(.custom("Futura-Medium", fixedSize: 16))
                                                       .padding(.horizontal, 5)
                                                       .bold()
                                                   Spacer()
                                                   Button(action: {
                                                       // Prepare to show action options for this friend
                                                    
                                                       selectedGroup = group
                                                       showConfirmationDialogGroup = true
                                                   }) {
                                                       Image(systemName: "ellipsis.circle")
                                                           .foregroundStyle(.white)
                                                   }
                                               }
                                               .padding(.vertical, 7)
                                               .padding(.horizontal, 15)
                                               .frame(minHeight: 20)
                                               .frame(maxWidth: .infinity)
                                               .background(Color(hex: "#333333"))
                                               .cornerRadius(5)
                                               .padding(.horizontal)
                                               .padding(.vertical, 2)
                                           }
                                           
                                       }
                                       .padding(.bottom,10)
                                       
                                       HStack{
                                           Text("Friends")
                                               .foregroundColor(.white)
                                               .font(.custom("Futura-Medium", fixedSize: 16))
                                               .padding(.horizontal, 5)
                                               .bold()
                                           
                                           Spacer()
                                       }
                                       .padding(.horizontal, 15)
                                       
                                       
                                       
                                       ForEach(friends) { friend in
                                           VStack(alignment: .leading, spacing: 0) {
                                               HStack {
                                                   Text(friend.displayName)
                                                       .foregroundColor(.white)
                                                       .font(.custom("Futura-Medium", fixedSize: 16))
                                                       .padding(.horizontal, 5)
                                                       .bold()
                                                   Spacer()
                                                   Button(action: {
                                                       // Prepare to show action options for this friend
                                                       selectedFriend = friend
                                                       showConfirmationDialog = true
                                                   }) {
                                                       Image(systemName: "ellipsis.circle")
                                                           .foregroundStyle(.white)
                                                   }
                                               }
                                               .padding(.vertical, 7)
                                               .padding(.horizontal, 15)
                                               .frame(minHeight: 20)
                                               .frame(maxWidth: .infinity)
                                               .background(Color(hex: "#333333"))
                                               .cornerRadius(5)
                                               .padding(.horizontal)
                                               .padding(.vertical, 2)
                                           }
                                       }
                                   }
                                   .padding(.top, 20)
                               }
                               .background(Color("WashedBlack"))
                           }
                       }
        .confirmationDialog("Actions for \(selectedFriend?.displayName ?? "")", isPresented: $showConfirmationDialog, actions: {
            Button("Remove Friend") {
                // Perform removal operation here
                
                if let friend = selectedFriend {
                    removeFriend(friendId: friend.userId)
                }
                
            }
            
            Button("Block") {
                // Perform block operation here
                
                if let friend = selectedFriend {
                    blockFriend(friendId: friend.userId)
                }
                
            }
            
            Button("Cancel", role: .cancel) { }
        })
        .confirmationDialog("Actions for \(selectedGroup?.name ?? "Group")", isPresented: $showConfirmationDialogGroup, actions: {
            Button("Remove Group") {
                guard let groupId = selectedGroup?.id else {
                    print("No group selected or group ID is missing.")
                    return
                }
                Task {
                    do {
                        try await UserManager.shared.removeFriendGroup(groupId: groupId)
                        print("Group successfully deleted.")
                        // Optionally refresh the group list after deletion
                        loadFriendGroups()
                    } catch {
                        print("Failed to delete group: \(error)")
                    }
                }
            }
            
            Button("Cancel", role: .cancel) { }
        })
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button(action: { Task { await refreshRequests() } }) {
                Image(systemName: "arrow.clockwise")
                    .padding(6)
            }
        )
        .fullScreenCover(isPresented: $showGroupDialog, content: {
                                            NavigationStack{
                                                GroupView()
                                            }
                                        })
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
        .toolbar { // <2>
                    ToolbarItem(placement: .principal) { // <3>
              
                            Text("Friends").font(.custom(
                                "Futura-Medium",
                                fixedSize: 18))
                    }
                }
        .onAppear {
            refreshFriendsList()
            loadFriendGroups()
        }
    }
    
    private func refreshRequests() async {
        do {
            refreshFriendsList()
            loadFriendGroups()
        }
    }
    
    private func loadFriendGroups() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No user signed in")
            isLoading = false
            return
        }

        isLoading = true
        let db = Firestore.firestore()
        let groupCollection = db.collection("users").document(currentUserId).collection("friendGroups")

        groupCollection.getDocuments { (snapshot, error) in
            defer { self.isLoading = false }

            if let error = error {
                print("Error fetching groups: \(error)")
                self.friendGroups = []
            } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                self.friendGroups = snapshot.documents.compactMap { doc in
                    do {
                        return try doc.data(as: FriendGroup.self)
                    } catch {
                        print("Error decoding group: \(error)")
                        return nil
                    }
                }
                print("Loaded groups: \(self.friendGroups.count) groups")
            } else {
                print("No groups found or user has not created any groups yet.")
                self.friendGroups = []
            }
        }
    }

    
    private func refreshFriendsList() {
            Task {
                do {
                    let currentUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
                    self.friends = try await UserManager.shared.fetchFriendsList(userId: currentUserId)
                    self.isLoading = false
                } catch {
                    print("Error fetching friends list: \(error)")
                    self.isLoading = false
                }
            }
        }
        
        private func removeFriend(friendId: String) {
            Task {
                do {
                    try await UserManager.shared.removeFriend(currentUserId: AuthenticationManager.shared.getAuthenticatedUser().uid, friendId: friendId)
                    // Refresh the friends list
                    refreshFriendsList()
                } catch {
                    print("Error removing friend: \(error)")
                }
            }
        }
        
        private func blockFriend(friendId: String) {
            Task {
                do {
                    try await UserManager.shared.blockFriend(userId: AuthenticationManager.shared.getAuthenticatedUser().uid, friendId: friendId)
                    // Refresh the friends list
                    refreshFriendsList()
                } catch {
                    print("Error blocking friend: \(error)")
                }
            }
        }
    
        private func createGroup(withName name: String) {
            let newGroup = FriendGroup(id: UUID().uuidString, name: name, members: [])
            friendGroups.append(newGroup)
            // Save to local storage or a database
        }
}

#Preview {
    FriendsView()
}
