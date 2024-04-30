//
//  AddFriendsView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-18.
//
import SwiftUI
import FirebaseAuth
import Contacts
import MessageUI

struct Contact: Hashable {
    var name: String
    var phoneNumber: String
}

struct AddFriendsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchQuery = ""
    @State private var searchResults: [DBUser] = []
    @State private var showManageRequests = false
    @State private var pendingRequestsCount = 0
    @State private var contacts: [Contact] = []
    @State private var isShowingMessageComposer = false
    @State private var selectedContactNumber = ""
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // Check every 60 seconds

    var body: some View {
        NavigationView {
            List {
                HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding(.leading, 10)

                            TextField("", text: $searchQuery, prompt: Text("Search for Friends").font(.custom("Futura-Medium", fixedSize: 16))
                                .foregroundColor(.white))
                            .foregroundColor(.white)
                            .onSubmit() {
                                performSearch()
                            }
                        }
                        .font(.custom("Futura-Medium", size: 16))
                        .padding()
                        .background(Color(hex: "#333333")) // Background color of the text field
                        .cornerRadius(10)
                        .autocorrectionDisabled()
                        .padding(.top, 20)
                        .listRowBackground(Color.washedBlack)
                
                /*
                TextField("Search by username", text: $searchQuery, onCommit: performSearch)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .listRowBackground(Color.washedBlack)
                    .padding(.top,20)
                    */
                ForEach(searchResults, id: \.userId) { user in
                    HStack {
                        Text(user.displayName)
                            .font(.custom("Futura-Medium", fixedSize: 16))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        AddFriendButton(user: user)
                    }
                    .padding(.horizontal,20)
                    .listRowBackground(Color.washedBlack)
                }
                
                
                /*
                ScrollView {
                    VStack {
                        Text("Invite Friends from Contacts")
                            .font(.custom("Futura-Medium", fixedSize: 16))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .listRowBackground(Color.washedBlack)
                            .padding(.top,25)
                        
                        ForEach(contacts, id: \.self) { contact in
                            HStack {
                                Text(contact.name)
                                    .font(.custom("Futura-Medium", fixedSize: 16))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.washedBlack)
                                    .cornerRadius(10)
                                
                                Button(action: {
                                    selectedContactNumber = contact.phoneNumber
                                    if MFMessageComposeViewController.canSendText() {
                                        isShowingMessageComposer = true
                                    } else {
                                        print("Cannot send text messages from this device")
                                    }
                                }, label: {
                                    Text("Invite")
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 3)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                })
                                .sheet(isPresented: $isShowingMessageComposer) {
                                    MessageComposerView(recipients: [selectedContactNumber], body: "Hi! I'd like to invite you to join WidgetWise.")
                                }
                            }
                            .padding(.bottom, 5)
                        }
                    }
                    .padding()
                }
                .listRowBackground(Color.washedBlack)
*/
                
               /*
                List(contacts, id: \.self) { contact in
                            Text(contact)
                        .font(.custom("Futura-Medium", fixedSize: 16))
                        .foregroundColor(.white)
                        .listRowBackground(Color.washedBlack)
                        }
                .listRowBackground(Color.washedBlack)
                */
            }
            .listStyle(PlainListStyle())
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitle("Add Friends", displayMode: .inline).font(.custom("Futura-Medium", fixedSize: 18))
            
            .navigationBarItems(
                leading: Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
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
                    
                },
                trailing: Button(action: {
                    showManageRequests.toggle()
                }) {
                    Image(systemName: "ellipsis.circle")
                        .padding(6)
                       // .padding(.horizontal,5)
                        .overlay(
                            pendingRequestsCount > 0 ?
                            ZStack {
                                                                                    Circle()
                                                                                        .fill(Color.red)
                                                                                        .frame(width: 15, height: 15) // Adjust size as needed
                                                                                    Text("\(pendingRequestsCount)")
                                                                                        .foregroundColor(.white)
                                                                                        .font(.system(size: 12)) // Adjust font size as needed
                                                                                }
                                    .offset(x: 10, y: -10)
                                : nil
                        )
                }
            )
            .fullScreenCover(isPresented: $showManageRequests, content: {
                                                NavigationStack{
                                                    ManageFriendRequestsView()
                                                }
                                            })
            .background(Color.washedBlack.edgesIgnoringSafeArea(.all))
            .onAppear(perform: fetchPendingRequests)
            .onAppear {
                DispatchQueue.global(qos: .userInitiated).async {
                    requestAndLoadContacts()
                }
            }
            .onReceive(timer) { _ in fetchPendingRequests() }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func inviteContact(_ contact: Contact) {
        selectedContactNumber = contact.phoneNumber // Make sure contact has a phoneNumber attribute
        isShowingMessageComposer = MFMessageComposeViewController.canSendText()
    }

    
    private func requestAndLoadContacts() {
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, error in
                if let error = error {
                    print("Error requesting access: \(error.localizedDescription)")
                    return
                }
                
                if granted {
                    self.loadContacts(store: store)
                } else {
                    print("Access to contacts was denied.")
                }
            }
        }

    private func loadContacts(store: CNContactStore) {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        var fetchedContacts = [Contact]()  // Use the Contact struct

        do {
            try store.enumerateContacts(with: request) { (contact, stop) in
                if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                    let fullName = "\(contact.givenName) \(contact.familyName)"
                    let newContact = Contact(name: fullName, phoneNumber: phoneNumber)
                    fetchedContacts.append(newContact)
                }
            }
            DispatchQueue.main.async {
                self.contacts = fetchedContacts  // Update the state variable with a list of Contact objects
            }
        } catch {
            print("Failed to fetch contacts, error: \(error.localizedDescription)")
        }
    }



    
    private func performSearch() {
        Task {
            do {
                guard let currentUserData = try await UserManager.shared.getCurrentUserData() else { return }
                if searchQuery == currentUserData.normalizedDisplayName || searchQuery == currentUserData.displayName {
                    print("Cannot search for your own display name.")
                    searchResults = []
                    return
                }
                searchResults = try await UserManager.shared.searchUsers(byDisplayName: searchQuery.lowercased())
            } catch {
                print("An error occurred: \(error)")
            }
        }
    }

    private func fetchPendingRequests() {
        Task {
            do {
                let requests = try await UserManager.shared.fetchIncomingFriendRequests()
                DispatchQueue.main.async {
                    pendingRequestsCount = requests.count
                }
            } catch {
                print("Failed to fetch pending friend requests: \(error)")
            }
        }
    }
}

struct MessageComposerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    var recipients: [String]
    var body: String

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.messageComposeDelegate = context.coordinator
        controller.recipients = recipients
        controller.body = body
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // Not used here
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposerView

        init(_ parent: MessageComposerView) {
            self.parent = parent
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct AddFriendButton: View {
    var user: DBUser
    @State private var buttonLabel = "Add Friend"
    @State private var isButtonDisabled = false

    var body: some View {
        Button(action: sendFriendRequest) {
            Text(buttonLabel)
                .padding(.horizontal, 10)
                .background(isButtonDisabled ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .disabled(isButtonDisabled)
        .onAppear(perform: checkFriendshipStatus)
    }

    private func checkFriendshipStatus() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Current user ID is not available.")
            return
        }
        Task {
            do {
                let isFriend = try await UserManager.shared.areUsersFriends(currentUser: currentUserId, otherUser: user.userId)
                if isFriend {
                    updateButton(for: .friends)
                    print("Friend")
                } else {
                    let isPending = try await UserManager.shared.isFriendRequestPending(fromUserId: currentUserId, toUserId: user.userId)
                    updateButton(for: isPending ? .pending : .notFriends)
                    print("pending: \(isPending)")
                }
            } catch {
                print("Error checking friendship status: \(error)")
            }
        }
    }

    private func updateButton(for status: FriendshipStatus) {
        DispatchQueue.main.async {
            switch status {
            case .friends:
                buttonLabel = "Friend"
                isButtonDisabled = true
            case .pending:
                buttonLabel = "Pending"
                isButtonDisabled = true
            case .notFriends:
                buttonLabel = "Add Friend"
                isButtonDisabled = false
            }
        }
    }

    private func sendFriendRequest() {
        guard !isButtonDisabled, let currentUserId = Auth.auth().currentUser?.uid else {
            print("Button is disabled or user ID is not available.")
            return
        }
        Task {
            do {
                try await UserManager.shared.sendFriendRequest(fromUserId: currentUserId, toUserId: user.userId, fromUserDisplayName: AuthenticationManager.shared.getDisplayName())
                updateButton(for: .pending)
            } catch {
                print("Failed to send friend request: \(error)")
            }
        }
    }
}

enum FriendshipStatus {
    case friends
    case pending
    case notFriends
}

struct AddFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        AddFriendsView()
    }
}





