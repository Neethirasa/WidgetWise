//
//  HistoryView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-04-19.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var quotes: [Quote] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color("WashedBlack").edgesIgnoringSafeArea(.all)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            } else if quotes.isEmpty {
                Text("No quotes available.")
                    .foregroundColor(.white)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(quotes, id: \.id) { quote in  // Ensure you use \.id
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(quote.text)
                                        .foregroundColor(.white)
                                        .font(.custom("Futura-Medium", fixedSize: 16))
                                        .padding(.horizontal, 5)
                                    Spacer()
                                    Text("- \(quote.senderDisplayName)")
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 5)
                                        .font(.custom("Futura-Medium", size: 12))
                                }
                                .padding(.vertical, 7)
                                .padding(.horizontal, 5)
                                .frame(minHeight: 20)
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#333333"))
                                .cornerRadius(10)
                                .padding(.horizontal)
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .background(Color("WashedBlack"))
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 12, height: 12)
                    }
                    .padding(6)
                    .padding(.horizontal,5)
                }
            }
        }
        .toolbar { // Title bar
            ToolbarItem(placement: .principal) {
                Text("Quote History").font(.custom("Futura-Medium", fixedSize: 18))
            }
        }
        .onAppear {
            fetchQuotes()
        }
    }
    
    private func fetchQuotes() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            isLoading = false
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("widgetQuotes")
          .order(by: "timestamp", descending: true)
          .getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                self.quotes = documents.compactMap { doc -> Quote? in
                    guard let text = doc.get("quote") as? String,
                          let senderId = doc.get("senderId") as? String,
                          let senderDisplayName = doc.get("senderDisplayName") as? String,
                          let timestamp = (doc.get("timestamp") as? Timestamp)?.dateValue() else {
                        print("Error decoding one of the documents.")
                        return nil
                    }
                    return Quote(id: doc.documentID, text: text, senderId: senderId, senderDisplayName: senderDisplayName, timestamp: timestamp)
                }
                print("Loaded \(self.quotes.count) quotes.")
                self.isLoading = false
            } else if let error = error {
                print("Error fetching quotes: \(error)")
                self.isLoading = false
            }
        }
    }

}



struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}


