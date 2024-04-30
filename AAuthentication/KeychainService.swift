//
//  KeychainService.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-15.
//

import Foundation
import KeychainSwift

class KeychainService {
    private let keychain = KeychainSwift()
    
    static let shared = KeychainService()
    
    private init() {} // Private initializer to enforce singleton pattern

    func storeOriginalUserID(_ userID: String) {
        keychain.set(userID, forKey: "originalUserID")
    }

    func getOriginalUserID() -> String? {
        return keychain.get("originalUserID")
    }
    
    // Add more methods here for other Keychain operations as needed
}
