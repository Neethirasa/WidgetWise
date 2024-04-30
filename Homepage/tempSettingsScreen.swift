//
//  tempSettingsScreen.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct tempSettingsScreen: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isCustomWidget = false
    @State private var isShowingBugView = false
    @State private var isShowingBlockedView = false
    @State private var isShowingPrivacyView = false
    @State private var isShowingTermsService = false
    let authUsername = AuthenticationManager.shared.getDisplayName()
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showDeleteAccountAlert = false // New state variable for showing the alert
    @State private var showReauthAlert = false

    
    private var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    accountSection
                    customizationSection
                    feedbackSection
                    helpSection
                }
                .padding(.horizontal,20)
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 0) {
                    deleteAccountButton
                }
                .padding(.horizontal,50)
                .padding(.top,50)
                .frame(maxWidth: .infinity)
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { // <2>
                        ToolbarItem(placement: .principal) { // <3>
                  
                                Text("Settings").font(.custom(
                                    "Futura-Medium",
                                    fixedSize: 18))
                        }
                    }
            .navigationBarItems(leading: backButton)
            .background(Color("WashedBlack").edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var accountSection: some View {
        Section(header: Text("My Account").foregroundColor(.white).font(.custom(
            "Futura-Medium",
            fixedSize: 16))) {
            VStack(alignment: .leading, spacing: 0){
                
                
                HStack(spacing: 0){
                    Text("Username")
                    .foregroundColor(Color(hex: "#FFFFFF"))
                    .font(.custom(
                            "Futura-Medium",
                            fixedSize: 14))
                    .frame(maxWidth: .infinity,alignment: .leading)
                    //Spacer().frame(width: UIScreen.main.bounds.width * 0.51)
                    .overlay(alignment: .trailing) {
                        Text(authUsername)//take quotes off
                            .foregroundColor(Color.gray)
                            .font(.custom("Futura-Medium",fixedSize: 14))
                            .italic()
                        }
                }
                .padding(.bottom,7)
                
                VStack(alignment: .leading, spacing: 0){
                }
                .frame(height: 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#696969"))
                .padding(.bottom,5)
                
                HStack(spacing: 0){
                    Button {
                        isShowingBlockedView.toggle()
                    } label: {
                        Text("Blocked")
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .font(.custom(
                                "Futura-Medium",
                                fixedSize: 14))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        //Spacer().frame(width: UIScreen.main.bounds.width * 0.51)
                        .overlay(alignment: .trailing) {
                            Image("arrow")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .contrast(10)
                            }
                    }
                    .fullScreenCover(isPresented: $isShowingBlockedView ) {
                        NavigationStack{
                            BlockedView()
                        }
                            }
                }
                
                
                
                
                
            }
            .padding(.vertical,7)
            .padding(.horizontal,5)
            .frame(minHeight: 20)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#333333"))
            .cornerRadius(5)
        }
        .padding(.bottom,5)
        .padding(.top,5)
        .padding(.horizontal,15)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color("WashedBlack")))
    }
    
    var customizationSection: some View {
        Section(header: Text("Customize").foregroundColor(.white).font(.custom(
            "Futura-Medium",
            fixedSize: 16))) {
            VStack(alignment: .leading, spacing: 0){
                
                
                HStack(spacing: 0){
                    Button {
                        isCustomWidget.toggle()
                    } label: {
                        Text("Customize your Widget")
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .font(.custom(
                                "Futura-Medium",
                                fixedSize: 14))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        //Spacer().frame(width: UIScreen.main.bounds.width * 0.51)
                        .overlay(alignment: .trailing) {
                            Image("arrow")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .contrast(10)
                            }
                    }
                    .fullScreenCover(isPresented: $isCustomWidget, content: {
                        tempWidgetCustom()
                    })

                    

                }
                
            }
            .padding(.vertical,6)
            .padding(.horizontal,5)
            .frame(minHeight: 20)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#333333"))
            .cornerRadius(5)
        }
        .padding(.bottom,5)
        .padding(.top,10)
        .padding(.horizontal,15)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color("WashedBlack")))
    }
    
    var feedbackSection: some View {
        Section(header: Text("Send Feedback").foregroundColor(.white).font(.custom(
            "Futura-Medium",
            fixedSize: 16))) {
            VStack(alignment: .leading, spacing: 0){
                HStack(spacing: 0){
                    Button {
                        isShowingBugView.toggle()
                    } label: {
                        Text("I spotted a bug")
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .font(.custom(
                                "Futura-Medium",
                                fixedSize: 14))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        //Spacer().frame(width: UIScreen.main.bounds.width * 0.51)
                        .overlay(alignment: .trailing) {
                            Image("arrow")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .contrast(10)
                            }
                    }
                    .sheet(isPresented: $isShowingBugView ) {
                        BugView()
                            }
                }
                .padding(.bottom,7)
                
                VStack(alignment: .leading, spacing: 0){
                }
                .frame(height: 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#696969"))
                .padding(.bottom,5)
                
                HStack(spacing: 0){
                    Button {
                        isShowingBugView.toggle()
                    } label: {
                        Text("I have a suggestion")
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .font(.custom(
                                "Futura-Medium",
                                fixedSize: 14))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        //Spacer().frame(width: UIScreen.main.bounds.width * 0.51)
                        .overlay(alignment: .trailing) {
                            Image("arrow")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .contrast(10)
                            }
                    }
                    .sheet(isPresented: $isShowingBugView ) {
                        BugView()
                            }
                }
            }
            .padding(.vertical,7)
            .padding(.horizontal,5)
            .frame(minHeight: 20)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#333333"))
            .cornerRadius(5)
        }
        .padding(.bottom,5)
        .padding(.top,10)
        .padding(.horizontal,15)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color("WashedBlack")))
    }
    
    var helpSection: some View {
        Section(header: Text("Help").foregroundColor(.white).font(.custom(
            "Futura-Medium",
            fixedSize: 16))){
            VStack(alignment: .leading, spacing: 0){
                HStack(spacing: 0){
                    Button {
                        isShowingPrivacyView.toggle()
                    } label: {
                        Text("Privacy Policy")
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .font(.custom(
                                "Futura-Medium",
                                fixedSize: 14))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        //Spacer().frame(width: UIScreen.main.bounds.width * 0.51)
                        .overlay(alignment: .trailing) {
                            Image("arrow")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .contrast(10)
                            }
                    }
                    .sheet(isPresented: $isShowingPrivacyView) {
                        PrivacyView(url: URL(string: "https://docs.google.com/document/d/e/2PACX-1vQCfVq7kFa2DR49OehK2p44ZXCaB2VSwJHqiiBVMoveY3eEm_yPB512pJHC4iONCd01f33O-g_-HiaD/pub")!)
                            }
                }
                .padding(.bottom,7)
                
                VStack(alignment: .leading, spacing: 0){
                }
                .frame(height: 1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(hex: "#696969"))
                .padding(.bottom,5)
                
                HStack(spacing: 0){
                    Button {
                        isShowingTermsService.toggle()
                    } label: {
                        Text("Terms of Service")
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .font(.custom(
                                "Futura-Medium",
                                fixedSize: 14))
                        .frame(maxWidth: .infinity,alignment: .leading)
                        //Spacer().frame(width: UIScreen.main.bounds.width * 0.51)
                        .overlay(alignment: .trailing) {
                            Image("arrow")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 20, height: 20)
                                .contrast(10)
                            }
                    }
                    .sheet(isPresented: $isShowingTermsService) {
                        TermsServiceView(url: URL(string: "https://docs.google.com/document/d/e/2PACX-1vQCfVq7kFa2DR49OehK2p44ZXCaB2VSwJHqiiBVMoveY3eEm_yPB512pJHC4iONCd01f33O-g_-HiaD/pub")!)
                            .background(Color.washedBlack)
                            }
                }
                
                
                
                
            }
            .padding(.vertical,7)
            .padding(.horizontal,5)
            .frame(minHeight: 20)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#333333"))
            .cornerRadius(5)
        }
        .padding(.bottom,5)
        .padding(.top,10)
        .padding(.horizontal,15)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color("WashedBlack")))
    }
    
    var deleteAccountButton: some View {
        Button("Delete Account", role: .destructive) {
            // Delete account action
            showDeleteAccountAlert = true
        }
        .font(.custom(
                "Futura-Medium",
                fixedSize: 14))
        .padding()
        .padding(.horizontal,20)
        .frame(maxWidth: .infinity)
        .background(Color.red)
        .foregroundColor(.white)
        .cornerRadius(10)
        .alert("Confirm Account Deletion", isPresented: $showDeleteAccountAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        
                        Task {
                            deleteUserCollections(userId: try AuthenticationManager.shared.getAuthenticatedUser().uid)
                            try await Firestore.firestore().collection("users").document(AuthenticationManager.shared.getAuthenticatedUser().uid).delete()
                            
                            try await AuthenticationManager.shared.delete()
                            //deleteUserAccount()
                            try viewModel.signOut()
                                       }
                    }
                } message: {
                    Text("Are you sure you want to delete your account? This action cannot be undone.")
                }
    }
    
    func deleteUserCollections(userId: String) {
            Task {
                do {
                    try await deleteCollection(collectionPath: "users/\(userId)/friends", batchSize: 10)
                    try await deleteCollection(collectionPath: "users/\(userId)/sentFriendRequests", batchSize: 10)
                    try await deleteCollection(collectionPath: "users/\(userId)/receivedFriendRequests", batchSize: 10)
                    print("All specified collections deleted successfully.")
                } catch {
                    print("Error deleting collections: \(error)")
                }
            }
        }
        
        func deleteCollection(collectionPath: String, batchSize: Int) async throws {
            let collectionRef = Firestore.firestore().collection(collectionPath)
            var querySnapshot = try await collectionRef.limit(to: batchSize).getDocuments()
            
            while !querySnapshot.isEmpty {
                let batch = Firestore.firestore().batch()
                querySnapshot.documents.forEach { batch.deleteDocument($0.reference) }
                
                try await batch.commit()
                querySnapshot = try await collectionRef.limit(to: batchSize).getDocuments()
            }
        }
    
    func deleteUserAccount() {
        let user = Auth.auth().currentUser

        user?.delete { error in
            if let error = error {
                // Handle the error, maybe show an alert to the user
                print("Error deleting account: \(error.localizedDescription)")
            } else {
                // The account is deleted. You might want to redirect the user to a login screen or similar.
                // Cloud Function `deleteUserData` will automatically trigger to clean up user data.
            }
        }
    }


    
    var backButton: some View {
        Button(action: { dismiss() }) {
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
            .foregroundColor(.white)
        }
    }
}

struct tempSettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        tempSettingsScreen()
    }
}

