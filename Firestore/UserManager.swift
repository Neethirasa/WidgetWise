//
//  UserManager.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-10.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth


struct DBUser: Codable {
    var userId: String
    var displayName: String
    var normalizedDisplayName: String
    var email: String?
    var dateCreated: Date?
    
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case displayName
        case normalizedDisplayName
        case email
        case dateCreated = "date_created"
    }
    
    // Firestore's Codable support handles the encoding/decoding, so you don't need a custom init/from decoder method unless you're doing something special
}
/*
struct Quote: Codable {
    
    var text: String
    var senderId: String
    var senderDisplayName: String
    var timestamp: Date
}
*/
/*
struct Quote: Codable, Identifiable {
    var id: String
    var text: String
    var senderId: String
    var senderDisplayName: String
    var timestamp: Date
}
*/



final class UserManager{
    
    
    static let shared = UserManager()
    private init() {}
    
    func userExists(auth: AuthDataResultModel) async throws -> Bool {
            // Get a reference to the user document in Firestore using the user's UID
            let userRef = Firestore.firestore().collection("users").document(auth.uid)
            
            do {
                // Attempt to get the document snapshot
                let documentSnapshot = try await userRef.getDocument()
                
                // Return true if the document exists, false otherwise
                return documentSnapshot.exists
            } catch {
                // If there's an error, print it and return false
                print("Error fetching user document: \(error)")
                return false
            }
        }
    
    func createNewUser(auth: AuthDataResultModel) async throws{
        
        let temp = "nil"
        
        var userData: [String:Any] = [
            "user_id" : auth.uid,
            "date_created" : Timestamp(),
            "normalizedDisplayName" : temp as Any,
            "displayName" : temp as Any
        ]
        
        if let email = auth.email{
            userData["email"] = email
        }
        
        if let photoUrl = auth.photoUrl{
            userData["photo_url"] = photoUrl
        }
        
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getDisplayName(forUserID userID: String) async throws -> String? {
        // Attempt to get the user document from Firestore using the provided userID
        let userRef = Firestore.firestore().collection("users").document(userID)
        
        do {
            let documentSnapshot = try await userRef.getDocument()
            
            // Check if the document exists and has a displayName field
            if let data = documentSnapshot.data(), let displayName = data["displayName"] as? String {
                // Return the displayName if available
                return displayName
            } else {
                // If the document does not exist or does not have a displayName, return nil
                print("Document does not exist or does not have a displayName.")
                return nil
            }
        } catch {
            // If there's an error fetching the document, throw the error
            print("Error fetching user document: \(error)")
            throw error
        }
    }

    
    func displayNameExists(displayName: String) async throws -> Bool {
        let normalizedDisplayName = displayName.lowercased()
        let query = Firestore.firestore().collection("users").whereField("normalizedDisplayName", isEqualTo: normalizedDisplayName)
        
        do {
            // Fetch the documents matching the query
            let querySnapshot = try await query.getDocuments()
            
            // Return true if any documents are found, indicating that the displayName exists
            return !querySnapshot.isEmpty
        } catch {
            // Throw the error to be handled by the caller
            throw error
        }
    }

    
    func addUsername(name: String) async throws {
        guard !name.isEmpty else {
            print("Username is empty. Not updating data.")
            return
        }
        let normalizedDisplayName = name.lowercased()
        let userName: [String:Any] = [
            "displayName" : name,
            "normalizedDisplayName": normalizedDisplayName
        ]
        let uid = try AuthenticationManager.shared.getAuthenticatedUser().uid
        let userRef = Firestore.firestore().collection("users").document(uid)
        
        try await userRef.updateData(userName)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        let documentReference = Firestore.firestore().collection("users").document(userId)
        let documentSnapshot = try await documentReference.getDocument()
        
        // Decode the documentSnapshot directly into a DBUser instance
        guard let user = try? documentSnapshot.data(as: DBUser.self) else {
            throw NSError(domain: "App", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to decode DBUser"])
        }
        
        return user
    }

    
    func isDisplayNameNil(forUserID userID: String) async throws -> Bool {
        // Check if the userID is "nil" or empty
        guard userID != "nil" && !userID.isEmpty else {
            // If the userID is "nil" or empty, return true
            return true
        }
        
        // If the userID is valid, proceed to fetch the user document
        let userRef = Firestore.firestore().collection("users").document(userID)
        
        do {
            let documentSnapshot = try await userRef.getDocument()
            guard let data = documentSnapshot.data(),
                  let displayName = data["displayName"] as? String else {
                // If displayName key doesn't exist or its value is not a String,
                // consider it as nil
                return true
            }
            return displayName == "nil"
        } catch {
            // Print and rethrow any errors that occur during the process
            print("Error fetching user document: \(error)")
            throw error
        }
    }
    
    // Search for users by displayName
    func searchUsers(byDisplayName displayName: String) async throws -> [DBUser] {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AppError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Current user ID not found."])
        }

        // Fetch list of blocked user IDs by current user
        let blockedUsersList = try await fetchBlockedUsersList(userId: currentUserId).map { $0.blockedUserId }

        // Perform search excluding blocked users
        let querySnapshot = try await Firestore.firestore().collection("users")
            .whereField("normalizedDisplayName", isEqualTo: displayName.lowercased())
            .getDocuments()

        let users = querySnapshot.documents.compactMap { document -> DBUser? in
            guard let user = try? document.data(as: DBUser.self), !blockedUsersList.contains(user.userId) else {
                return nil
            }
            return user
        }

        return users
    }
    
    // Search for users by displayName and return the first userId found
    func searchUsersReturnUid(byDisplayName normalizedDisplayName: String) async throws -> String? {
        let querySnapshot = try await Firestore.firestore()
            .collection("users")
            .whereField("normalizedDisplayName", isEqualTo: normalizedDisplayName)
            .getDocuments()

        // Attempt to find the first document that matches the query and return its userId
        let firstUserId = querySnapshot.documents.compactMap { document -> String? in
            guard let user = try? document.data(as: DBUser.self) else {
                return nil
            }
            return user.userId
        }.first
        
        return firstUserId
    }

    func sendFriendRequest(fromUserId: String, toUserId: String, fromUserDisplayName: String) async throws {
        // Check if `fromUserId` is blocked by `toUserId`
        let isBlocked = try await isUserBlocked(byUserId: toUserId, blockedUserId: fromUserId)
        guard !isBlocked else {
            throw NSError(domain: "AppError", code: 101, userInfo: [NSLocalizedDescriptionKey: "Cannot send friend request to user who has blocked you."])
        }

        let friendRequestData: [String: Any] = [
            "fromUserId": fromUserId,
            "toUserId": toUserId,
            "fromUserDisplayName": fromUserDisplayName,
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // Reference to the sender's 'sentFriendRequests' document for this friend request
        let senderRequestRef = Firestore.firestore()
            .collection("users")
            .document(fromUserId)
            .collection("sentFriendRequests")
            .document(toUserId)
        
        let receiverRequestRef = Firestore.firestore().collection("users").document(toUserId).collection("receivedFriendRequests").document(fromUserId)
        try await receiverRequestRef.setData(friendRequestData)
       
        try await senderRequestRef.setData(friendRequestData)
    }

    func isUserBlocked(byUserId userId: String, blockedUserId: String) async throws -> Bool {
        let blockedUserRef = Firestore.firestore().collection("users").document(userId).collection("blockedUsers").document(blockedUserId)
        let document = try await blockedUserRef.getDocument()
        return document.exists
    }
    
    // Checks if there's a pending friend request from `fromUserId` to `toUserId`
        func isFriendRequestPending(fromUserId: String, toUserId: String) async throws -> Bool {
            // Access the collection where friend requests are stored
            let sentRequestRef = Firestore.firestore().collection("users").document(fromUserId).collection("sentFriendRequests").document(toUserId)

            // Attempt to get the document for the friend request
            let documentSnapshot = try await sentRequestRef.getDocument()

            // Check if the document exists and if the status is "pending"
            if let data = documentSnapshot.data(), let status = data["status"] as? String, status == "pending" {
                // If the document exists and status is pending, return true
                return true
            } else {
                // If no document exists or status is not pending, return false
                return false
            }
        }


    func fetchIncomingFriendRequests() async throws -> [FriendRequest] {
            let currentUserId = try AuthenticationManager.shared.getAuthenticatedUser().uid
            
            let querySnapshot = try await Firestore.firestore()
                .collection("users")
                .document(currentUserId)
                .collection("receivedFriendRequests")
                .whereField("status", isEqualTo: "pending")
                .getDocuments()

            let friendRequests = querySnapshot.documents.compactMap { document -> FriendRequest? in
                try? document.data(as: FriendRequest.self)
            }
            return friendRequests
        }

    func acceptFriendRequest(fromUserId: String, toUserId: String) async throws {
        // References for both users' friend requests
        let receiverRequestRef = Firestore.firestore()
            .collection("users")
            .document(toUserId)
            .collection("receivedFriendRequests")
            .document(fromUserId)

        let senderRequestRef = Firestore.firestore()
            .collection("users")
            .document(fromUserId)
            .collection("sentFriendRequests")
            .document(toUserId)

        // Retrieve display names for both users
        let fromDisplayName = try await getDisplayNameByUserId(userId: fromUserId)
        let toDisplayName = try await getDisplayNameByUserId(userId: toUserId)

        // Perform database operations in a batch for atomicity
        let batch = Firestore.firestore().batch()

        // Since the friend request is accepted, it should be removed from both the "receivedFriendRequests"
        // and "sentFriendRequests" collections
        batch.deleteDocument(receiverRequestRef)
        batch.deleteDocument(senderRequestRef)

        // Add each other to friends subcollection with the appropriate display names
        let toUserFriendsRef = Firestore.firestore()
            .collection("users")
            .document(toUserId)
            .collection("friends")
            .document(fromUserId)
        batch.setData(["friendUserId": fromUserId, "displayName": fromDisplayName ?? "Unknown"], forDocument: toUserFriendsRef)

        let fromUserFriendsRef = Firestore.firestore()
            .collection("users")
            .document(fromUserId)
            .collection("friends")
            .document(toUserId)
        batch.setData(["friendUserId": toUserId, "displayName": toDisplayName ?? "Unknown"], forDocument: fromUserFriendsRef)

        // Commit the batch to apply all changes
        try await batch.commit()
    }


    
    // Function to check the status of a friend request
        func checkFriendRequestStatus(fromUserId: String, toUserId: String) async throws -> String {
            let requestRef = Firestore.firestore().collection("users").document(toUserId).collection("receivedFriendRequests").document(fromUserId)
            let snapshot = try await requestRef.getDocument()
            return snapshot.data()?["status"] as? String ?? "none"
        }
    
    
    // This method retrieves the current user's display name.
    func getCurrentUserData() async throws -> DBUser? {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return nil }

        return try await getUser(userId: currentUserId)
    }
    
    // Function to get a user's display name by their userID
       func getDisplayNameByUserId(userId: String) async throws -> String? {
           // Reference to the user document in the Firestore database
           let userRef = Firestore.firestore().collection("users").document(userId)
           
           // Attempt to fetch the user document
           let documentSnapshot = try await userRef.getDocument()
           
           // Check if the document exists and has a displayName field
           if let data = documentSnapshot.data(), let displayName = data["displayName"] as? String {
               // Return the displayName if available
               return displayName
           } else {
               // If the document does not exist or does not have a displayName, return nil
               print("User document does not exist or does not have a displayName.")
               return nil
           }
       }
    
    // Declines a friend request and removes it from both users' collections
    func declineFriendRequest(fromUserId: String, toUserId: String) async throws {
        // Reference to the receiver's 'receivedFriendRequests' document for this friend request
        let receiverRequestRef = Firestore.firestore()
            .collection("users")
            .document(toUserId)
            .collection("receivedFriendRequests")
            .document(fromUserId)
        
        // Reference to the sender's 'sentFriendRequests' document for this friend request
        let senderRequestRef = Firestore.firestore()
            .collection("users")
            .document(fromUserId)
            .collection("sentFriendRequests")
            .document(toUserId)
        
        do {
            // Create a write batch to perform both operations atomically
            let batch = Firestore.firestore().batch()
            
            // Delete the request from the receiver's 'receivedFriendRequests' collection
            batch.deleteDocument(receiverRequestRef)
            
            // Delete the request from the sender's 'sentFriendRequests' collection
            batch.deleteDocument(senderRequestRef)
            
            // Commit the batch
            try await batch.commit()
        } catch let error {
            // Handle any errors that occur during the batch commit
            print("Error declining friend request: \(error)")
            throw error
        }
    }
    
        // Function to fetch list of friends for a given user ID
        func fetchFriendsList(userId: String) async throws -> [Friend] {
            // Reference to the user's "friends" subcollection
            let friendsRef = Firestore.firestore().collection("users").document(userId).collection("friends")
            
            // Fetch documents from the "friends" subcollection
            let querySnapshot = try await friendsRef.getDocuments()
            
            // Map each document to a Friend model
            let friends = querySnapshot.documents.compactMap { document -> Friend? in
                try? document.data(as: Friend.self)
            }
            
            return friends
        }

    func removeFriend(currentUserId: String, friendId: String) async throws {
        let currentUserFriendsRef = Firestore.firestore().collection("users").document(currentUserId).collection("friends").document(friendId)
        let friendUserFriendsRef = Firestore.firestore().collection("users").document(friendId).collection("friends").document(currentUserId)
        
        do {
            let batch = Firestore.firestore().batch()
            batch.deleteDocument(currentUserFriendsRef)
            batch.deleteDocument(friendUserFriendsRef)
            try await batch.commit()
        } catch let error {
            print("Error removing friend: \(error)")
            throw error
        }
    }
    
    func blockFriend(userId: String, friendId: String) async throws {
        // Retrieve displayName of the friend being blocked
        guard let friendDisplayName = try await getDisplayNameByUserId(userId: friendId) else {
            throw NSError(domain: "AppError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve friend's displayName."])
        }
        
        // References to the users' friends documents
        let currentUserFriendsRef = Firestore.firestore().collection("users").document(userId).collection("friends").document(friendId)
        let friendUserFriendsRef = Firestore.firestore().collection("users").document(friendId).collection("friends").document(userId)
        
        // Reference to the blocker's blocked users collection
        let blockedUserRef = Firestore.firestore().collection("users").document(userId).collection("blockedUsers").document(friendId)

        do {
            // Create a batch to perform multiple write operations atomically
            let batch = Firestore.firestore().batch()

            // Remove the friend from each user's friends collection
            batch.deleteDocument(currentUserFriendsRef)
            batch.deleteDocument(friendUserFriendsRef)
            
            // Add the blocked user to the blocker's blockedUsers collection
            // Include the displayName of the blocked friend
            batch.setData([
                "blockedUserId": friendId,
                "displayName": friendDisplayName, // Add displayName here
                "timestamp": FieldValue.serverTimestamp()
            ], forDocument: blockedUserRef)

            // Commit the batch
            try await batch.commit()
        } catch let error {
            print("Error blocking user: \(error)")
            throw error
        }
    }
    
    func fetchBlockedUsersList(userId: String) async throws -> [BlockedUser] {
        let querySnapshot = try await Firestore.firestore().collection("users").document(userId).collection("blockedUsers").getDocuments()
        
        let blockedUsers = querySnapshot.documents.compactMap { document -> BlockedUser? in
            try? document.data(as: BlockedUser.self)
        }
        
        return blockedUsers
    }
    
    func unblockUser(currentUserId: String, blockedUserId: String) async throws {
        let blockedUserRef = Firestore.firestore().collection("users").document(currentUserId).collection("blockedUsers").document(blockedUserId)
        try await blockedUserRef.delete()
    }
    // Assuming UserManager is a class that handles user information
    func getCurrentUser() -> Friend {
        // Assuming you have an authentication manager or similar to get the current user
        let currentUser = Auth.auth().currentUser
        let displayName = currentUser?.displayName ?? "Unknown User"
        let formattedDisplayName = "\(displayName) (Me)"
        return Friend(id: currentUser?.uid, userId: currentUser?.uid ?? "defaultUserID", displayName: formattedDisplayName)
    }




    func fetchFriends() async throws -> [Friend] {
            // Ensure there's a currently authenticated user
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "AppError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            }

            // Reference to the current user's "friends" collection
            let friendsCollectionRef = Firestore.firestore().collection("users").document(currentUserId).collection("friends")

            // Perform the query
            let snapshot = try await friendsCollectionRef.getDocuments()

            // Map the query snapshot documents to `Friend` objects
            let friends = snapshot.documents.compactMap { document -> Friend? in
                try? document.data(as: Friend.self)
            }

            return friends
        }




        // New method to fetch the latest quote for the widget display
        func fetchLatestQuoteForWidget(userId: String) async throws -> String? {
            let db = Firestore.firestore()
            let querySnapshot = try await db.collection("users").document(userId).collection("widgetQuotes")
                .order(by: "timestamp", descending: true)
                .limit(to: 1)
                .getDocuments()

            return querySnapshot.documents.first?.data()["quote"] as? String
        }
    // UserManager.swift

    func areUsersFriends(currentUser: String, otherUser: String) async throws -> Bool {
        let userFriendsRef = Firestore.firestore().collection("users").document(currentUser).collection("friends")
        do {
            let document = try await userFriendsRef.document(otherUser).getDocument()
            print("Friendship status between \(currentUser) and \(otherUser): \(document.exists)")
            return document.exists
        } catch {
            print("Failed to check friendship status for \(currentUser) and \(otherUser): \(error)")
            throw error
        }
    }
    
    // Creates a new friend group and updates each member's group subcollection.
    func createFriendGroup(name: String, memberIds: [String]) async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Current user ID not available"])
        }
        
        let db = Firestore.firestore()
        let groupCollection = db.collection("users").document(currentUserId).collection("friendGroups")
        let newGroupId = UUID().uuidString  // Generate a unique ID for the new group

        // Check member existence and permissions here if necessary

        // Create a new group object in the friendGroups collection
        let newGroupData: [String: Any] = [
            "id": newGroupId,
            "name": name,
            "memberIds": memberIds
        ]

        // Start a batch to ensure atomic operations
        let batch = Firestore.firestore().batch()

        // Create the group in the global groups collection
        let groupDocRef = groupCollection.document(newGroupId)
        batch.setData(newGroupData, forDocument: groupDocRef)

        // Add a reference to this group in each member's 'groups' subcollection
        for memberId in memberIds {
            let memberGroupRef = db.collection("users").document(memberId).collection("groups").document(newGroupId)
            let groupReferenceData: [String: Any] = [
                "groupId": newGroupId,
                "groupName": name
            ]
            batch.setData(groupReferenceData, forDocument: memberGroupRef)
        }

        // Commit the batch
        do {
            try await batch.commit()
        } catch let error {
            print("Error creating group: \(error)")
            throw error
        }
    }

    // Function to load friend groups from Firestore
        func loadFriendGroups() async throws -> [FriendGroup] {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Current user ID not available"])
            }

            let db = Firestore.firestore()
            let groupCollection = db.collection("users").document(currentUserId).collection("friendGroups")

            // Fetch the documents in the friendGroups subcollection
            let snapshot = try await groupCollection.getDocuments()

            // Map the documents to the FriendGroup model
            let groups = snapshot.documents.compactMap { document -> FriendGroup? in
                try? document.data(as: FriendGroup.self)
            }

            return groups
        }
    // Function to remove a friend group for the current authenticated user
        func removeFriendGroup(groupId: String) async throws {
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "Current user ID not available"])
            }
            
            let db = Firestore.firestore()
            
            // Reference to the specific group document under the current user's 'friendGroups' collection
            let groupDocRef = db.collection("users").document(currentUserId).collection("friendGroups").document(groupId)
            
            do {
                // Delete the group document
                try await groupDocRef.delete()
                print("Group successfully deleted")
            } catch let error {
                print("Error removing group: \(error)")
                throw error
            }
        }


}



