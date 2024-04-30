//
//  GroupView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-04-26.
//

import SwiftUI

struct GroupView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var groupName: String = ""
    @State private var selectedFriends: Set<String> = []
    @State private var friends: [Friend] = []
    @State private var isLoading = true
    @State private var isExpanded: Bool = false // To control view expansion like in your friendsList
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @FocusState private var isTextEditorFocused: Bool


    var body: some View {
        ZStack {
            Color.washedBlack.edgesIgnoringSafeArea(.all)

            VStack {
                groupNameSection
                    .padding(.bottom,10)
                friendsList
                Spacer()
            }
            .onAppear {
                loadFriends()
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitle("Create Group", displayMode: .inline) .font(.custom("Futura-Medium", fixedSize: 18))
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
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    saveGroup()
                }) {
                    HStack {
                        Text("Save")
                            .font(.custom("Futura-Medium", size: 16))
                            
                        //Text("Home")
                            //.font(.custom("Futura-Medium", size: 18))
                    }
                    .padding(6)
                    .padding(.horizontal,5)
                    
                }
            }
        }
        .alert("Error", isPresented: $showErrorAlert, actions: {
                        Button("OK", role: .cancel) { }
                    }, message: {
                        Text(errorMessage)
                    })
    }

    private var groupNameSection: some View {
        TextField("Enter group name", text: $groupName, prompt: Text("Enter Group Name").font(.custom("Futura-Medium", fixedSize: 16))
            .foregroundColor(.white))
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal)
            .foregroundColor(.white)
            .font(.custom("Futura-Medium", size: 16))
            .padding(.top, 15) // Ensures this is at the top within the VStack
            .focused($isTextEditorFocused)
    }

    private var friendsList: some View {
        ScrollView {
            LazyVStack {
                ForEach(friends, id: \.id) { friend in
                    HStack {
                        Text(friend.displayName)
                            .foregroundColor(.white)
                            .font(.custom("Futura-Medium", fixedSize: 16))
                        Spacer()
                        if selectedFriends.contains(friend.userId) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.customTeal)
                        }
                    }
                    .padding()
                    .background(selectedFriends.contains(friend.userId) ? Color.gray.opacity(0.5) : Color.clear)
                    .cornerRadius(10)
                    .contentShape(Rectangle()) // This ensures the tap gesture is recognized across the entire row
                    .onTapGesture {
                        withAnimation {
                            toggleFriendSelection(friend)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 35)
                    .background(Color(hex: "#333333"))
                    .cornerRadius(7)
                    .onChange(of: selectedFriends) {
                            // Dismiss the keyboard whenever selections change
                            isTextEditorFocused = false
                        }
                }
            }
        }
        .scrollIndicators(.hidden)
        //.frame(maxHeight: 650)
        .padding(.horizontal)
    }

    private func loadFriends() {
        isLoading = true
        Task {
            do {
                self.friends = try await UserManager.shared.fetchFriends()
                isLoading = false
            } catch {
                print("Failed to load friends: \(error.localizedDescription)")
            }
        }
    }

    private func toggleFriendSelection(_ friend: Friend) {
        let id = friend.userId
        if selectedFriends.contains(id) {
            selectedFriends.remove(id)
        } else {
            selectedFriends.insert(id)
        }
    }


    private func saveGroup() {
        if groupName.isEmpty || selectedFriends.count<=2 {
            print("Group name and at least one friend are required.")
            showErrorAlert = true
            errorMessage = "Group name and at least two friends are required."
            return
        }

        Task {
            do {
                try await UserManager.shared.createFriendGroup(name: groupName, memberIds: Array(selectedFriends))
                presentationMode.wrappedValue.dismiss()
            } catch {
                showErrorAlert = true
                errorMessage = "Failed to create group."
            }
        }
    }
}





#Preview {
    GroupView()
}
