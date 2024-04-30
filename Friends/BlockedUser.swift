//
//  BlockedUser.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-29.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct BlockedUser: Codable, Identifiable {
    @DocumentID var id: String? // Use Firestore document ID as the ID
    var blockedUserId: String
    var displayName: String
    var timestamp: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id
        case blockedUserId = "blockedUserId"
        case timestamp = "timestamp"
        case displayName

    }
}

