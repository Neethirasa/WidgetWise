//
//  Friend.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-29.
//

import Foundation
// Make sure to import FirebaseFirestore if you're using Firestore fields like Timestamp.
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct Friend: Codable, Identifiable, Hashable {
    @DocumentID var id: String? // Use Firestore document ID as the ID
    var userId: String
    var displayName: String
    
    enum CodingKeys: String, CodingKey {
        case id // This is needed to tell Firestore to use the document ID as this property
        case userId = "friendUserId" // Map the userId to the friendUserId field in your documents
        case displayName
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(userId)
        hasher.combine(displayName)
    }

    static func == (lhs: Friend, rhs: Friend) -> Bool {
        lhs.id == rhs.id && lhs.userId == rhs.userId && lhs.displayName == rhs.displayName
    }
}

