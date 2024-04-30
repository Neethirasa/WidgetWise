//
//  SideMenuViewContents.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-02-26.
//

import SwiftUI
import UIKit

enum DeviceType {
    case iPhone
    case iPad
    case unknown
}

func getDeviceType() -> DeviceType {
    switch UIDevice.current.userInterfaceIdiom {
    case .phone:
        return .iPhone
    case .pad:
        return .iPad
    default:
        return .unknown
    }
}


struct SideMenuViewContents: View {
    @Binding var presentSideMenu: Bool
    @State private var settingsView = false
    @State private var showSignInView = false
    @State private var showFriendsView = false
    @State private var showHistoryView = false
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @Environment(\.horizontalSizeClass) var HsizeClass
    @Environment(\.verticalSizeClass) private var VsizeClass
    
    
    var body: some View {
        ZStack {
            Color.washedBlack.edgesIgnoringSafeArea(.all)
            VStack{
                Spacer().frame(height: UIScreen.main.bounds.height * 0.055)
                List {
                    
                    HStack{
                        Text("Widget Wise")
                            .font(.custom(
                                "Futura-Medium",
                                fixedSize: 20))
                            .foregroundColor(.white)

                    }
                    .listRowBackground(Color.washedBlack)
                    
                    
                    VStack(alignment: .leading, spacing: 0){
                    }
                    .listRowBackground(Color.washedBlack)
                    .frame(height: UIScreen.main.bounds.height * 0.002)
                    .frame(width: UIScreen.main.bounds.width * 10)
                   // .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(hex: "#696969"))

                    NavigationStack{
                        Button(action: {
                            showFriendsView.toggle()
                        }) {
                            Text("Friends")
                                .font(.custom(
                                    "Futura-Medium",
                                    fixedSize: 20))
                                .padding(.horizontal, 2)
                                .background(Color.washedBlack)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .fullScreenCover(isPresented: $showFriendsView, content: {
                            NavigationStack{
                                FriendsView()
                             
                            }
                        })
                    }
                    .listRowBackground(Color.washedBlack)
                    
                    NavigationStack{
                        Button(action: {
                            showHistoryView.toggle()
                        }) {
                            Text("History")
                                .font(.custom(
                                    "Futura-Medium",
                                    fixedSize: 20))
                                .padding(.horizontal, 2)
                                .background(Color.washedBlack)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .fullScreenCover(isPresented: $showHistoryView, content: {
                            NavigationStack{
                                HistoryView()
                             
                            }
                        })
                    }
                    .listRowBackground(Color.washedBlack)
                    
                    if getDeviceType() == .iPad {
                                   Spacer().frame(height: UIScreen.main.bounds.height * 0.55)
                                       .listRowBackground(Color.washedBlack)
                               } else if getDeviceType() == .iPhone {
                                   Spacer().frame(height: UIScreen.main.bounds.height * 0.45)
                                       .listRowBackground(Color.washedBlack)
                               }
                    
                    VStack(alignment: .leading, spacing: 0){
                    }
                    .listRowBackground(Color.washedBlack)
                    .frame(height: UIScreen.main.bounds.height * 0.002)
                    .frame(width: UIScreen.main.bounds.width * 10)
                    .background(Color(hex: "#696969"))
                    
                    NavigationStack{
                        Button(action: {
                            settingsView.toggle()
                        }, label: {
                            HStack {
                              
                                Text("Settings")
                                    .font(.custom("Futura-Medium", fixedSize: 20))
                                    .foregroundColor(.white)
                              
                            }

                        
                            
                        })
                        .fullScreenCover(isPresented: $settingsView, content: {
                            NavigationStack{
                                //SettingsScreen()
                                tempSettingsScreen()
                               // SettingsMenuView()
                            }
                        })
                    }
                    .listRowBackground(Color.washedBlack)
                    
                    
                    VStack{
                        Button(role: .destructive){
                            Task{
                                do{
                                    //settingsView.toggle()
                                    showSignInView = true
                                    try viewModel.signOut()
                                    /*
                                    // Present the RootView
                                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                        let window = windowScene.windows.first {
                                                    window.rootViewController = UIHostingController(rootView: RootView())
                                                }
                                    
                                    */
                                }catch{
                                    print(error)
                                }
                            }
                        }label: {
                            Text("Log Out")
                                .font(.custom(
                                    "Futura-Medium",
                                    fixedSize: 20))
                        }
                        
                    }
                    .listRowBackground(Color.washedBlack)
                    
                }
             
                
                
            }
            .scrollDisabled(false)
            .frame(maxWidth: .infinity)
            .background(Color.washedBlack)
            .scrollContentBackground(.hidden)
        }
    }
    
    func SideMenuTopView() -> some View {
        VStack {

        }
        .frame(maxWidth: .infinity)
        .padding(.leading, 40)
        .padding(.top, 40)
        .padding(.bottom, 30)
    }
}

struct SideMenuViewContents_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TempHomeView()
        }
    }
}
