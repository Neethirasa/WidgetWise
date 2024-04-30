//
//  sendQuoteView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-02-19.
//

import SwiftUI
import Combine
import WidgetKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

extension View {
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private enum Field: Int, Hashable {
  case yourTextField, yourOtherTextField
}

struct sendQuoteView: View {
    @Environment(\.dismiss) var dismiss
    @State private var quote: String = ""
    let textLimit = 135
    @AppStorage("myDefaultString") var myString = ""
    
    @FocusState private var isTextEditorFocused: Bool
    
    @Binding var firstQuote: String
    @Binding var secondQuote: String
    
    @State var isExpanded = false
    @State private var quotesArray: [String] = []
    @State private var isLoading = true
    
    @State private var friends: [Friend] = []
    //@State private var selectedFriends: Set<String> = []
    @State private var selectedFriends: Set<Friend.ID> = []
    @State private var isAddedToWidget: Bool = false
    
    @State private var lastContactedFriends: [Friend.ID] = UserDefaults.standard.array(forKey: "lastContactedFriends") as? [Friend.ID] ?? []
    
    private var currentUserID: Friend.ID? { Auth.auth().currentUser?.uid }
    @State private var groupSelection: Set<String> = []
    @State private var friendGroups: [FriendGroup] = []
    
    var body: some View {
        ZStack {
            Color.washedBlack.ignoresSafeArea()
                .onTapGesture {
                                    endEditing() // Call to dismiss the keyboard when the background is tapped
                                }
            
            VStack {
                expandableQuotesButton
                    .padding(.top,50)
                    .padding(.horizontal,10)
                
                //Spacer()
                
                VStack{
                    //toggleAddToWidgetButton
                    HStack {
                            Spacer()  // Adds a spacer on the left
                            randomQuoteButton
                            Spacer()  // Adds a spacer on the right
                        }
                        .padding(.horizontal, 15)
                    quoteEditor
                        .padding(.horizontal,30)
            
                    Text("Select Friends to Send Quote")
                        .font(.custom("Futura-Medium", fixedSize: 16))
                        .foregroundColor(.white)
                        //.padding(.leading)
                        //groupList
                        friendsList
                    Spacer()
                    //if !isExpanded {
                    VStack{
                        if !isTextEditorFocused{
                           actionButtons
                        }
                    }
                    
                    //}
                }
                .padding(.top,60)
                .overlay(alignment: .top, content: {
                    if isExpanded {
                        quotesListView
                            .padding(.horizontal,35)
                    }
                })
                Spacer()
            }
            .onChange(of: isExpanded) {
                isTextEditorFocused = false // Dismiss the keyboard when expanding/collapsing the quotes list
            }
            /*
            if isExpanded {
                quotesOverlay
            }
             */
        }
        .onAppear {
            fetchQuotesFromFirestore()
            fetchGroupsAndFriends()
   
    
        }
    }
    
    // Function to end editing and dismiss the keyboard
        private func endEditing() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    
    private var expandableQuotesButton: some View {
        Button(action: {
            isExpanded.toggle()
        }) {
            HStack {
                Text("Select Quotes")
                    .font(.custom("Futura-Medium", fixedSize: 16))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.white)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 100).stroke(Color.customTeal, lineWidth: 5))
            .cornerRadius(100)
        }
        .padding(.horizontal)
    }
    /*
    private var groupList: some View {
        ScrollView {
            LazyVStack {
                ForEach(friendGroups) { group in
                    GroupRow(group: group, isSelected: groupSelection.contains(group.id))
                        .onTapGesture {
                            toggleGroupSelection(group)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 35)
                        .background(Color(hex: "#333333"))
                        .cornerRadius(7)
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal,40)
    }
*/
    
    private var friendsList: some View {
            ZStack {
                Color.washedBlack.edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading) {
                    ScrollView {
                        LazyVStack {
                            ForEach(friendGroups) { group in
                                GroupRow(group: group, isSelected: groupSelection.contains(group.id))
                                    .onTapGesture {
                                        //toggleGroupSelection(group)
                                        Task {
                                                    await toggleGroupSelection(group)
                                                }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(maxHeight: 35)
                                    .background(Color(hex: "#333333"))
                                    .cornerRadius(7)
                            }
                            ForEach(friends, id: \.id) { friend in
                                FriendRowView(friend: friend, isSelected: selectedFriends.contains(friend.id!))
                                    .onTapGesture {
                                        toggleFriendSelection(friend)
                                    }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .frame(maxHeight: 400)
                    .padding(.horizontal)

                }
                .padding(.horizontal,20)
            }
        }

    private func toggleGroupSelection(_ group: FriendGroup) async {
        guard let memberIDs = group.members else {
            print("No members found in this group.")
            return
        }

        if groupSelection.contains(group.id) {
            print("Group is currently selected. Deselecting...")
            groupSelection.remove(group.id)
            // Remove the member IDs from the selection list
            memberIDs.forEach { selectedFriends.remove($0) }
        } else {
            print("Group not selected. Selecting...")
            groupSelection.insert(group.id)
            // Add the member IDs to the selection list
            memberIDs.forEach { selectedFriends.insert($0) }
        }
    }




        
    /// Helper function to toggle the selection state of a friend.
    private func toggleFriendSelection(_ friend: Friend) {
        if let friendId = friend.id {
            if selectedFriends.contains(friendId) {
                selectedFriends.remove(friendId)
            } else {
                selectedFriends.insert(friendId)
            }
        }
    }
    
    // Load friends and groups
        private func fetchGroupsAndFriends() {
            Task {
                await fetchFriendsList()
                await loadFriendGroups()
            }
        }
    
    private func fetchFriendsByIds(_ ids: [String]) async -> [Friend] {
        var friends: [Friend] = []
        let db = Firestore.firestore()

        for id in ids {
            do {
                let documentSnapshot = try await db.collection("friends").document(id).getDocument()
                if let friend = try? documentSnapshot.data(as: Friend.self) {
                    friends.append(friend)
                } else {
                    print("Document does not exist or failed to decode.")
                }
            } catch {
                print("Error fetching document for id \(id): \(error)")
            }
        }

        return friends
    }


    
    private func loadFriendGroups() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("No user signed in")
            isLoading = false
            return
        }

        isLoading = true
        let db = Firestore.firestore()
        let groupCollection = db.collection("users").document(currentUserId).collection("friendGroups")

        do {
            let snapshot = try await groupCollection.getDocuments()
            snapshot.documents.forEach { doc in
                print("Group document raw data: \(doc.data())") // Check raw data
            }
            self.friendGroups = snapshot.documents.compactMap { doc in
                try? doc.data(as: FriendGroup.self)
            }
            print("Loaded groups: \(self.friendGroups.count) groups")
        } catch let error {
            print("Error fetching groups: \(error)")
            self.friendGroups = [] // Ensure the array is empty if fetching fails
        }
        isLoading = false
    }


    
    private var quotesListView: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading quotes...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else {
                VStack(spacing: 0) {
                    ForEach(quotesArray, id: \.self) { quote in
                        Button(quote) {
                            self.quote = quote
                            isExpanded.toggle()
                        }
                        .font(.custom("Futura-Medium",fixedSize: 12))
                        .padding(.vertical,15)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        if quote != quotesArray.last{
                            VStack(alignment: .leading, spacing: 0){
                                }
                            .frame(height: 1)
                            .frame(maxWidth: 300)
                            .background(Color.white.opacity(70))
                        }
                    }
                }
                .padding()
                .background(Color(hex: "#333333"))
                .cornerRadius(20)
            }
        }
        .scrollIndicators(.hidden)
        .frame(maxHeight: 350)
        .frame(maxWidth: 340)
    }
    
    private var toggleAddToWidgetButton: some View {
        HStack {
            Text("Add to My Widget")
                .foregroundColor(.white)
                .font(.custom("Futura-Medium", fixedSize: 16))
            Toggle("", isOn: $isAddedToWidget)
                .toggleStyle(SwitchToggleStyle(tint: .customTeal))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 50)/*
        .onChange(of: isAddedToWidget) { newValue in
            // Handle the toggle action, e.g., adding or removing the quote from the widget
        }*/
    }
    
    private var quoteEditor: some View {
        ZStack(alignment: .leading) {
            if quote.isEmpty {
                Text("Enter your quote...")
                    .font(.custom("Futura-Medium", fixedSize: 16))
                    .foregroundColor(.white) // Placeholder text color
                    .padding(.horizontal)
                    .padding(.vertical, 8) // Adjust this to vertically center the placeholder
            }
            
            TextEditor(text: $quote)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .font(.custom("Futura-Medium", fixedSize: 17))
                .padding(.horizontal)
                .frame(height: 130)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.customTeal, lineWidth: 5))
                .cornerRadius(10)
                .focused($isTextEditorFocused)
                .onReceive(Just(quote)) { _ in limitText(textLimit) }
                .transparentScrolling()
                .background(Color.washedBlack)
        }
        .background(Color.washedBlack)
    }
    
    private var quotesOverlay: some View {
            VStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 0) {
                        ForEach(quotesArray, id: \.self) { quote in
                            Button(quote) {
                                self.quote = quote
                                isExpanded.toggle()
                            }
                            .font(.custom("Futura-Medium",fixedSize: 12))
                            .padding(.vertical,15)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            
                            if quote != quotesArray.last{
                                VStack(alignment: .leading, spacing: 0){
                                    }
                                .frame(height: 1)
                                .frame(maxWidth: 300)
                                .background(Color.white.opacity(70))
                            }
                        }
                    }
                    .padding()
                    .background(Color(hex: "#333333"))
                    .cornerRadius(20)
                }
                .background(Color(hex: "#333333"))
                .cornerRadius(15)
            }
            .frame(maxHeight: 500) // Adjust the height of the overlay as needed
            .transition(.move(edge: .bottom)) // Smooth transition for the overlay
            .zIndex(1) // Ensure the overlay is on top
        }
    
    private var actionButtons: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.custom("Futura-Medium", fixedSize: 20))
            .foregroundColor(.red)
            .padding(10)
            .padding(.horizontal,50)

            
            Spacer()
            
            Button("Send") {
                //addQuoteToWidget()
                Task {
                        await sendQuotesToSelectedFriends()
                    }
                dismiss()
            }
            .font(.custom("Futura-Medium", fixedSize: 20))
            .disabled(quote.trimmingCharacters(in: .whitespaces).isEmpty || (selectedFriends.isEmpty && groupSelection.isEmpty)) // Check if quote is not empty and at least one friend or group is selected and at least one friend is selected
            .padding(10)
            .padding(.horizontal,50)
   
        }
    }
    
    private var randomQuoteButton: some View {
        HStack {
            Button(action: {
                quote = quotesArray.randomElement() ?? ""
            }) {
                Image("dice")
                    .foregroundColor(.white)
                    .padding(5) // Adjust padding to ensure a good touch area
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.customTeal, lineWidth: 3))
                    .background(Color.customTeal)
                    .cornerRadius(10)
            }
            // This pushes the button to the left
        }
        .padding(.horizontal) // Add horizontal padding to ensure it does not stick to the edge
    }
    
    private var doneButtons: some View {
        HStack {
            Button("Done Editing") {
                isTextEditorFocused = false
            }
            .font(.custom("Futura-Medium", fixedSize: 20))
            .padding(10)
            .padding(.top,50)
            .padding(.horizontal,40)
            
        }
    }
    
    // Async function to send quote to selected friends and update the last contacted order
    private func sendQuotesToSelectedFriends() async {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let currentUserName = Auth.auth().currentUser?.displayName else {
            print("Authentication details not found.")
            return
        }

        let db = Firestore.firestore()
        for friendId in selectedFriends {
            
            guard friendId != currentUserID else {
                        print("Skipping quote addition for self.")
                        myString = quote
                        WidgetCenter.shared.reloadAllTimelines()
                        continue
                    }
            
            let quoteData: [String: Any] = [
                "quote": quote,
                "senderId": currentUserID,
                "senderDisplayName": currentUserName,
                "timestamp": FieldValue.serverTimestamp()
            ]
            
            let userQuoteRef = db.collection("users").document(friendId!).collection("widgetQuotes")
            
            do {
                try await userQuoteRef.addDocument(data: quoteData)
                print("Quote successfully sent to friend ID: \(String(describing: friendId))")
            } catch {
                print("Error sending quote to friend ID \(String(describing: friendId)): \(error)")
            }
        }

        // Optionally reset selection after sending
        selectedFriends.removeAll()
        groupSelection.removeAll()
    }



    
    func fetchQuotesFromFirestore() {
        Firestore.firestore().collection("quotes").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching quotes: \(error.localizedDescription)")
            } else {
                quotesArray = snapshot?.documents.compactMap { $0["quotetext"] as? String } ?? []
            }
            isLoading = false
        }
    }
    
    
    func limitText(_ upper: Int) {
        if quote.count > upper {
            quote = String(quote.prefix(upper))
        }
    }
    
    private func fetchFriendsList() async {
        do {
            let fetchedFriends = try await UserManager.shared.fetchFriends()
            let currentUser = UserManager.shared.getCurrentUser()

            // Sort within the async context, avoiding capturing mutable outer scope variables
            let sortedFriends = fetchedFriends.sorted { (friend1, friend2) -> Bool in
                let index1 = lastContactedFriends.firstIndex(of: friend1.id) ?? fetchedFriends.count
                let index2 = lastContactedFriends.firstIndex(of: friend2.id) ?? fetchedFriends.count
                return index1 < index2
            }

            // Capture only immutable or explicitly passed data in the async block
            let updatedFriends = [currentUser] + sortedFriends

            DispatchQueue.main.async {
                self.friends = updatedFriends // Update the state on the main thread
            }
        } catch {
            print("Failed to fetch friends: \(error)")
        }
    }


    
 
    
    private var friendsSelectionView: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(friends, id: \.self) { friend in
                        FriendSelectionRow(friend: friend, isSelected: selectedFriends.contains(friend.id ?? ""))
                            .onTapGesture {
                                if let id = friend.id {
                                    if selectedFriends.contains(id) {
                                        selectedFriends.remove(id)
                                    } else {
                                        selectedFriends.insert(id)
                                    }
                                }
                            }
                    }
                }
                .frame(maxHeight: 200)
            }
            .background(Color.washedBlack)
        }
}

struct GroupRow: View {
    let group: FriendGroup
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(group.name)
                .foregroundColor(.white)
                .font(.custom("Futura-Medium", fixedSize: 16))
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .customTeal : .gray)
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(0.5) : Color.clear)
        .cornerRadius(10)
        .contentShape(Rectangle()) // This ensures the tap gesture is recognized across the entire row
    }
}


struct FriendSelectionRow: View {
    let friend: Friend
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(friend.displayName)
                .foregroundColor(.white)
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(10)
    }
}

struct FriendRowView: View {
    var friend: Friend
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(friend.displayName)
                .foregroundColor(.white)
                .font(.custom("Futura-Medium", fixedSize: 16))
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.customTeal)
            }
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(0.5) : Color.clear)
        .cornerRadius(10)
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .frame(maxHeight: 35)
        .background(Color(hex: "#333333"))
        .cornerRadius(7)
    }
}


public extension View {
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}



#Preview {
    sendQuoteView(firstQuote: .constant("Nive"), secondQuote: .constant("Dhanu"))
}
 

