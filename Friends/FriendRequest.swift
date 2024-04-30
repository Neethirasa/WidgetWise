//
//  FriendRequest.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-18.
//

import Foundation

// Make sure to import FirebaseFirestore if you're using Firestore fields like Timestamp.
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct FriendRequest: Codable, Identifiable {
    @DocumentID var id: String? // Automatically mapped to the Firestore document ID
    var fromUserId: String
    var toUserId: String
    var fromUserDisplayName: String? // This should match exactly how it's stored in Firestore
    var status: String
    // Use Firestore's Timestamp for compatibility
    var timestamp: Timestamp?

    // Custom keys to map Swift property names to Firestore field names
    enum CodingKeys: String, CodingKey {
        case id
        case fromUserId = "fromUserId"
        case toUserId = "toUserId"
        case fromUserDisplayName = "fromUserDisplayName"
        case status = "status"
        // Firestore fields are automatically handled, no need to manually decode/encode Timestamp
        case timestamp = "timestamp"
    }

    // Custom initializer from Firestore document snapshot
    init(from snapshot: DocumentSnapshot) throws {
        let model = try snapshot.data(as: FriendRequest.self)
        self = model
    }

    // Default initializer
    init(id: String? = nil, fromUserId: String, toUserId: String, fromUserDisplayName: String?, status: String, timestamp: Timestamp?) {
        self.id = id
        self.fromUserId = fromUserId
        self.toUserId = toUserId
        self.fromUserDisplayName = fromUserDisplayName
        self.status = status
        self.timestamp = timestamp
    }
}

