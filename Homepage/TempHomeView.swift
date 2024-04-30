//
//  TempHomeView.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-03-25.
//

import SwiftUI
import WidgetKit
import Combine
import BackgroundTasks

@MainActor
final class TempHomeViewModel: ObservableObject {
    @Published var authProviders: [AuthProviderOption] = []
    // @Published private(set) var user: DBUser? = nil

    func signOut() throws {
        AuthenticationManager.shared.signOut()
    }
}

struct TempHomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingQuote = false
    @AppStorage("myDefaultString") var myString = ""
    @State private var firstQuote = QuoteManager.shared.getFirstQuote()
    @State private var secondQuote = QuoteManager.shared.getSecondQuote()
    @State private var thirdQuote = QuoteManager.shared.getThirdQuote()
    @State private var fourthQuote = QuoteManager.shared.getFourthQuote()
    @State private var presentSideMenu = false
    @State private var showingAlert = false
    @State private var homeUsername = " "
    @State private var isTimerActive = true
    @State private var settingsView = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.washedBlack.edgesIgnoringSafeArea(.all)
         
                VStack {
                    topBar
                        .padding(.bottom,30)
                    
                    ScrollView{
                        addContent
                        
                        mainContent
                        .background(Color.washedBlack.opacity(0.8))
                    }
                    //.overlay(topBar, alignment: .top)
                                    }
                .fullScreenCover(isPresented: $showingQuote, content: {
                    NavigationStack{
                        sendQuoteView(firstQuote: $firstQuote, secondQuote: $secondQuote)
                    }
                })
            
            
            
            

            SideMenu()
        }
    }

    private var mainContent: some View {
        VStack(spacing: 20) {
            quoteButton(firstQuote, quote: $firstQuote)
                .padding(.vertical,10)
            quoteButton(secondQuote, quote: $secondQuote)
                .padding(.vertical,10)
            quoteButton(thirdQuote, quote: $thirdQuote)
                .padding(.vertical,10)
            quoteButton(fourthQuote, quote: $fourthQuote)
                .padding(.vertical,10)
        }
        .padding(.horizontal,40)
    }
    
    private var addContent: some View {
        VStack(spacing: 0) {
            addButton("+", quote: $firstQuote)
                .padding(.vertical,20)
        }
        .padding(.horizontal,40)
        .padding(.top, 20)

    }

    private func addButton(_ add: String, quote: Binding<String>) -> some View {
        Button(action: {
            showingQuote.toggle()
        }) {
            Text(add)
                .frame(maxWidth: .infinity, minHeight: 100)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.customTeal, lineWidth: 5))
                .font(.custom("Futura-Medium", size: add == "+" ? 60 : 18))
                .foregroundColor(.white)
                .lineLimit(4)
        }
        
    }
    
    private func quoteButton(_ title: String, quote: Binding<String>) -> some View {
        Button(action: {
            myString = quote.wrappedValue
            clearSenderName()
            showingAlert = true
        }) {
            Text(title)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 175)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.customTeal, lineWidth: 5))
                .font(.custom("Futura-Medium", size: title == "+" ? 60 : 18))
                .foregroundColor(.white)
                .lineLimit(4)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Widget Updated"), dismissButton: .default(Text("OK")))
        }
    }
    
    private func clearSenderName() {
        let defaults = UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync")
        defaults?.set("", forKey: "latestQuoteSender")  // Clear the sender's name
        WidgetCenter.shared.reloadAllTimelines()  // Update the widget to reflect this change
    }

    private var topBar: some View {
        HStack {
            Button(action: { presentSideMenu.toggle() }) {
                Image("menuIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }
            .padding()

            Spacer()

            Text("Welcome \(homeUsername)")
                .font(.custom("Futura-Medium", size: 18))
                .foregroundColor(.white)
                .onReceive(timer) { _ in
                    
                    self.homeUsername = AuthenticationManager.shared.getDisplayName()
                }

            Spacer()

            Button(action: { settingsView.toggle()}) {
               // Text("         ")
              
                Image(systemName: "person.crop.circle.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
                 

            }
            .fullScreenCover(isPresented: $settingsView, content: {
                AddFriendsView()
                //tempAddFriendsView()
            })
            .padding()
            .padding(.horizontal,-5)
 
        }
        .padding(.top,40)
        .padding(.horizontal,20)
        .frame(height: 60)
        .background(Color.washedBlack)
    }

    @ViewBuilder
    private func SideMenu() -> some View {
        SideView(isShowing: $presentSideMenu, direction: .leading) {
            SideMenuViewContents(presentSideMenu: $presentSideMenu)
                .frame(width: 200)
        }
    }
}

struct TempHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TempHomeView().previewDevice("iPhone 13")
        }
    }
}


#Preview {
    TempHomeView()
}
