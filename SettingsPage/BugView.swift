//
//  BugView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-07.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

extension View {
    func endEditing1() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private enum Field: Int, Hashable {
  case yourTextField, yourOtherTextField
}

struct BugView: View {
    @FocusState private var focusedField: Field?
    @State private var message: String = ""
    @State private var email: String = ""
    @State private var username: String = AuthenticationManager.shared.getDisplayName()
    @Environment(\.presentationMode) var presentationMode
    @State private var remainingTime: String = ""
    @State private var showAlert = false
    
    
    var body: some View {
        ZStack{
            //Color.washedBlack.edgesIgnoringSafeArea(.all)
            Color("WashedBlack").edgesIgnoringSafeArea(.all)
            
            VStack{
                Text("Enter your Email below")
                    .foregroundColor(.white)
                    .font(.custom(
                            "Futura-Medium",
                            fixedSize: 18))
                
                TextField("Enter your email", text: $email, axis: .vertical)// <1>, <2>
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .disableAutocorrection(true)
                    .frame(width: UIScreen.main.bounds.width * 0.76 , height: UIScreen.main.bounds.height * 0.05)
                    .focused($focusedField, equals: .yourOtherTextField)
                     .contentShape(RoundedRectangle(cornerRadius: 5))
                     .onTapGesture { focusedField = .yourOtherTextField }
                    .border(.secondary)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .cornerRadius(.infinity)
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color("customTeal"), lineWidth: 3))
                Spacer().frame(height: UIScreen.main.bounds.height * 0.5)
                
                    }
            
            
            VStack {
                VStack{
                    Text("Enter your suggestion below")
                        .foregroundColor(.white)
                        .font(.custom(
                                "Futura-Medium",
                                fixedSize: 18))
                    
                    TextField("Describe", text: $message, axis: .vertical)// <1>, <2>
                    
                        .multilineTextAlignment(.center)
                        .lineLimit(10)
                        .frame(width: UIScreen.main.bounds.width * 0.76 , height: UIScreen.main.bounds.height * 0.2)
                        .focused($focusedField, equals: .yourTextField)
                         .contentShape(RoundedRectangle(cornerRadius: 5))
                         .onTapGesture { focusedField = .yourTextField }
                        .border(.secondary)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .cornerRadius(.infinity)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color("customTeal"), lineWidth: 3))
                        }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom) // Ensure constant height
                .contentShape(Rectangle())
                .onTapGesture {
                    let keyWindow = UIApplication.shared.connectedScenes
                        .filter({$0.activationState == .foregroundActive})
                        .map({$0 as? UIWindowScene})
                        .compactMap({$0})
                        .first?.windows
                        .filter({$0.isKeyWindow}).first
                    keyWindow!.endEditing(true)
                }
            .onLongPressGesture(pressing: { isPressed in if isPressed { self.endEditing1() } }, perform: {})
                
                Spacer().frame(height: UIScreen.main.bounds.height * 0.3)
            }
            
            VStack{
                
                Spacer().frame(height: UIScreen.main.bounds.height * 0.7)
                
                HStack{
                    Button(role: .destructive){
                        presentationMode.wrappedValue.dismiss()
                    }label: {
                    Text("Cancel")
                  }
                    .font(.custom(
                            "Futura-Medium",
                            fixedSize: 20))
                Spacer().frame(width: UIScreen.main.bounds.width * 0.55)
                }

            }
            
            VStack{
                Spacer().frame(height: UIScreen.main.bounds.height * 0.7)
                HStack{
                    Spacer().frame(width: UIScreen.main.bounds.width * 0.4)
                    if (!message.isEmpty && !email.isEmpty && !message.trimmingCharacters(in: .whitespaces).isEmpty && !email.trimmingCharacters(in: .whitespaces).isEmpty) {
                        Button(){
                            sendMessage()
                            //dismiss()
                            
                        }label: {
                        Text("Send")
                      }
                        .font(.custom(
                                "Futura-Medium",
                                fixedSize: 20))
                        //Spacer().frame(width: UIScreen.main.bounds.width * 0)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                    Alert(title: Text("Please wait"),
                          message: Text("You can send another message in \(remainingTime). Email nivethikan@hotmail.com for other questions."),
                          dismissButton: .default(Text("OK")))
                }
        }
        .background(Color("WashedBlack"))
        .scrollContentBackground(.hidden)
    }
    
    func sendMessage() {
        // Check if the last sent message time is greater than or equal to 24 hours ago
        guard let lastSentTime = UserDefaults.standard.object(forKey: "lastSentTime") as? Date else {
            sendToFirestore()
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        let currentDate = Date()
        let timeDifference = currentDate.timeIntervalSince(lastSentTime)
        let twentyFourHoursInSeconds: TimeInterval = 24 * 60 * 60
        
        if timeDifference >= twentyFourHoursInSeconds {
            sendToFirestore()
            presentationMode.wrappedValue.dismiss()
        } else {
            // Calculate remaining time
            let remainingSeconds = twentyFourHoursInSeconds - timeDifference
            let hours = Int(remainingSeconds) / 3600
            let minutes = Int(remainingSeconds) / 60 % 60
            let seconds = Int(remainingSeconds) % 60
            
            remainingTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            
            // Show a popup informing the user to wait
            showAlert = true
        }
    }
        
        func sendToFirestore() {
            // Reference to the Firestore database
            let db = Firestore.firestore()
            
            // Create a dictionary to represent the data
            let data: [String: Any] = [
                "user_name" : username,
                "email": email,
                "message": message,
                "timestamp": Date()
            ]
            
            // Add a new document with a generated ID to the "userMessages" collection
            db.collection("userMessages").addDocument(data: data) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added to Firestore")
                    
                    // Save the current time as the last sent message time
                    UserDefaults.standard.set(Date(), forKey: "lastSentTime")
                }
            }
        }
}



#Preview {
    BugView()
}
