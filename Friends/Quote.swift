//
//  Quote.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-04-21.
//

import Foundation

struct Quote: Codable, Identifiable {
    let id: String
    var text: String
    var senderId: String
    var senderDisplayName: String
    var timestamp: Date

    init(id: String = UUID().uuidString, text: String, senderId: String, senderDisplayName: String, timestamp: Date) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.senderDisplayName = senderDisplayName
        self.timestamp = timestamp
    }
}

