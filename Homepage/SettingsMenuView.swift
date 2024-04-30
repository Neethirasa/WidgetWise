//
//  SettingsMenuView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-19.
//

import SwiftUI
import MessageUI

struct SettingsMenuView: View {
        @Environment(\.dismiss) var dismiss
       @Environment(\.horizontalSizeClass) var horizontalSizeClass

       @StateObject private var viewModel = SettingsViewModel()

    let authUsername = AuthenticationManager.shared.getDisplayName() // Placeholder for the actual username
       let washedBlack = Color("WashedBlack") // Assuming "WashedBlack" is defined in your asset catalog

       var body: some View {
           NavigationView {
               List {
                   accountSection
                   customizationSection
                   feedbackSection
                   helpSection
                   privacyPolicySection
                   deleteAccountButton
               }
               .listStyle(InsetGroupedListStyle())
               .background(washedBlack) // Setting background color for the list
               .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
               .navigationBarTitle("Settings", displayMode: .large)
               .navigationBarItems(leading: backButton)
           }
           .navigationViewStyle(StackNavigationViewStyle())
           .padding(.top, horizontalSizeClass == .compact ? 0 : 20)
           .background(washedBlack.edgesIgnoringSafeArea(.all)) // Setting background color for the entire view
       }

       private var accountSection: some View {
           Section(header: Text("My Account")) {
               HStack {
                   Text("Username")
                   Spacer()
                   Text(authUsername)
                       .foregroundColor(.gray)
                       .italic()
               }
               .foregroundStyle(Color(hex: "#333333"))
           }
           
       }

       private var customizationSection: some View {
           Section(header: Text("Customize")) {
               Button("Customize your Widget") {
                   // Customize widget action
               }
           }
       }

       private var feedbackSection: some View {
           Section(header: Text("Send Feedback")) {
               Button("I spotted a bug") {
                   // Spotted a bug action
               }
               Button("I have a suggestion") {
                   // Have a suggestion action
               }
           }
       }

       private var helpSection: some View {
           Section(header: Text("Help")) {
               Button("Privacy Policy") {
                   // Privacy Policy action
               }
               Button("Terms of Service") {
                   // Terms of Service action
               }
           }
       }

       private var privacyPolicySection: some View {
           Section {
               Button("Help") {
                   // Help action
               }
           }
       }

       private var deleteAccountButton: some View {
           Section {
               Button("Delete Account", role: .destructive) {
                   // Delete account action
               }
           }
       }

       private var backButton: some View {
           Button(action: {
               dismiss()
           }) {
               HStack {
                   Image(systemName: "chevron.left")
                   Text("Back")
               }
               .foregroundColor(.blue)
           }
       }
}

struct SettingsMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenuView()
            .environment(\.horizontalSizeClass, .compact)
    }
}

