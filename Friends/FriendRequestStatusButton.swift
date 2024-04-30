//
//  FriendRequestStatusButton.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-26.
//

import SwiftUI

struct FriendRequestStatusButton: View {
    let userId: String
    @State private var friendRequestStatus: String?

    var body: some View {
        Button(action: sendOrCancelFriendRequest) {
            Text(buttonText)
                .padding()
                .foregroundColor(.white)
                .background(friendRequestStatus == "pending" ? Color.gray : Color.blue)
                .cornerRadius(8)
        }
        .disabled(friendRequestStatus == "pending")
        .onAppear(perform: fetchFriendRequestStatus)
    }

    var buttonText: String {
        switch friendRequestStatus {
        case "pending":
            return "Request Pending"
        case "accepted":
            return "Friends"
        default:
            return "Add Friend"
        }
    }

    private func fetchFriendRequestStatus() {
        // Implement the logic to fetch the friend request status between the current user and 'userId'
    }

    private func sendOrCancelFriendRequest() {
        // Implement the logic to send a new friend request or cancel an existing one
    }
}

/*
 #Preview {
 FriendRequestStatusButton(userId: Nive)
 }
 */
