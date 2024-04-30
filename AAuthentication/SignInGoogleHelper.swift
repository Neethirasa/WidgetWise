//
//  SignInGoogleHelper.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-01-14.
//

import Foundation
import GoogleSignIn
import Firebase
import GoogleSignInSwift

struct GoogleSignInResultModel{
    let idToken: String
    let accessToken: String
    let email: String?
}

final class SignInGoogleHelper {
    
    
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel{
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            
            throw URLError(.badURL)
        }
                
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
                
        GIDSignIn.sharedInstance.configuration = config
        
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        //let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, email: email)
        return tokens
    }
    
    
}
