//
//  AuthenticationManager.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-01-11.
//

import Foundation
import SwiftUI
import FirebaseAuth
import KeychainSwift

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let displayName: String?
    let normalizedDisplayName: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        //self.username = ""
        self.displayName = nil //change to nil for username view
        self.normalizedDisplayName = nil
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case apple = "apple.com"
    case google = "google.com"
    
    // Handle unknown provider IDs by returning nil
    init?(rawValue: String) {
        switch rawValue {
        case "password":
            self = .email
        case "apple.com":
            self = .apple
        case "google.com":
            self = .google
        default:
            // If the provider ID is unknown, return nil
            return nil
        }
    }
}


// Define custom error type
enum AuthError: Error {
    case noProviderData
}

final class AuthenticationManager{
    
    static let shared = AuthenticationManager()
    @State private var showSignInView = false
    
    private init() { }
    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw AuthError.noProviderData
        }
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        print(providers)
        return providers
    }
   
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        } catch{
            print("Error signing out: %@")
        }
        
    }
    
    func updateDisplayName(displayName: String){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = displayName
        changeRequest?.commitChanges { error in
          // ...
        }
    }
    
    func getDisplayName() -> String {
        
        return Auth.auth().currentUser?.displayName ?? "nil"
    }
    
    func getUserID() -> String {
        return Auth.auth().currentUser?.uid ?? "nil"
    }
    
    func isDisplayNameNull() async -> Bool {
        do {
            // Get the current user's UID
            guard let uid = Auth.auth().currentUser?.uid else {
                // If the current user is not authenticated, return false
                return false
            }
            
            // Call the asynchronous function to check if the display name is nil or empty
            let isNull = try await UserManager.shared.isDisplayNameNil(forUserID: uid)
            
            // Return true if the display name is nil or empty, otherwise return false
            return isNull
        } catch {
            // Handle any errors that occur during the process
            print("Error checking if display name is nil or empty: \(error)")
            return false // Return false by default in case of errors
        }
    }


    
    
    
    func delete() async throws{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        try await user.delete()
         
    }
    
}

extension AuthenticationManager{
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    @discardableResult
    func signInWithApple(tokens: signInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
}

