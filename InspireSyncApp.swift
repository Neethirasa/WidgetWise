//
//  InspireSyncApp.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-01-11.
//
import SwiftUI
import Firebase
import UIKit
import BackgroundTasks
import WidgetKit
import UserNotifications
import FirebaseMessaging

@main
struct InspireSyncApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .defaultAppStorage(UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync")!)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    let taskId = "group.Nivethikan-Neethirasa.InspireSync.background"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        setupListeners()
        setupQuoteListener()
        registerBackgroundTasks()
        scheduleBackgroundFetchTask()
        // Set minimum background fetch interval
        //FirebaseConfiguration.shared.setLoggerLevel(.debug)
        return true
    }
   
    private func setupListeners() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        registerForPushNotifications()
    }
    
    func registerBackgroundTasks() {
        // Registering a background fetch task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            // Cast the parameter task to an appropriate task type
            self.handleBackgroundFetchTask(task: task as! BGAppRefreshTask)
            print("Background task registered")
        }
    }
    
    private func handleBackgroundFetchTask(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            self.scheduleBackgroundFetchTask()  // Ensure task is rescheduled in case of failure
        }

        fetchData { success in
            task.setTaskCompleted(success: success)
            if success {
                WidgetCenter.shared.reloadAllTimelines()
            } else {
                self.scheduleBackgroundFetchTask()  // Reschedule on failure to fetch data
            }
        }
    }
    
    func fetchData(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("widgetQuotes")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { (snapshot, error) in
                if let snapshot = snapshot, let data = snapshot.documents.first?.data(),
                   let quote = data["quote"] as? String {
                    self.updateWidget(quote: quote, senderId: data["senderId"] as? String, senderName: data["senderDisplayName"] as? String)
                    completion(true)
                } else {
                    print("Error fetching new quote: \(String(describing: error))")
                    completion(false)
                }
            }
        print("Background task Data fetched")
    }
    
    func scheduleBackgroundFetchTask() {
        let request = BGAppRefreshTaskRequest(identifier: taskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 1 * 60 * 60) // 1 hour from now, adjust as necessary
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task Scheduled")
        } catch {
            print("Could not schedule background fetch: \(error)")
        }
        
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let token = fcmToken {
            print("FCM registration token: \(token)")
            uploadTokenToFirestore(token)
            
        }
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print("Permission granted: \(granted)")
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let pushToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Apple Token: \(pushToken)")
        Messaging.messaging().apnsToken = deviceToken
        
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("recieved notification")
        if let aps = userInfo["aps"] as? [String: AnyObject], aps["content-available"] as? Int == 1 {
               updateWidgetData(from: userInfo)
               completionHandler(.newData)
           } else {
               completionHandler(.noData)
           }
           
           if let isLoud = userInfo["isLoud"] as? String, isLoud == "true" {
               // Handle loud notification specific logic
               updateWidgetData(from: userInfo)
               completionHandler(.newData)
           }
    }
    
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    private func updateWidgetData(from userInfo: [AnyHashable: Any]) {
        DispatchQueue.global(qos: .background).async {
            guard let quote = userInfo["quote"] as? String,
                  let senderId = userInfo["senderId"] as? String,
                  let senderName = userInfo["senderDisplayName"] as? String else {
                return
            }

            let defaults = UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync")
            
            // Use the main thread only for UI-related updates
            DispatchQueue.main.async {
                defaults?.set(quote, forKey: "myDefaultString")
                if senderId != Auth.auth().currentUser?.uid {
                    defaults?.set(senderName, forKey: "latestQuoteSender")
                } else {
                    defaults?.set("", forKey: "latestQuoteSender")
                }
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    

    func uploadTokenToFirestore(_ token: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("User not logged in. Cannot upload token.")
            return
        }
        let userDocRef = Firestore.firestore().collection("users").document(userID)
        userDocRef.setData(["deviceToken": token], merge: true) { error in
            if let error = error {
                print("Error updating token: \(error)")
            } else {
                print("Token successfully updated in Firestore")
            }
        }
    }
    
    
    func setupQuoteListener() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("widgetQuotes")
          .order(by: "timestamp", descending: true)
          .limit(to: 1)
          .addSnapshotListener { snapshot, error in
            if let snapshot = snapshot, let data = snapshot.documents.first?.data(), let quote = data["quote"] as? String {
                self.updateWidget(quote: quote, senderId: data["senderId"] as? String, senderName: data["senderDisplayName"] as? String)
            } else {
                print("Error setting up listener: \(String(describing: error))")
            }
        }
    }
    
    private func updateWidget(quote: String, senderId: String?, senderName: String?) {
        DispatchQueue.global(qos: .background).async {
            let defaults = UserDefaults(suiteName: "group.Nivethikan-Neethirasa.InspireSync")
            defaults?.set(quote, forKey: "myDefaultString")
            if senderId != Auth.auth().currentUser?.uid {
                defaults?.set(senderName, forKey: "latestQuoteSender")
            } else {
                defaults?.set("", forKey: "latestQuoteSender")
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

}

class WidgetDataManager {
    static let shared = WidgetDataManager()

    func updateWidgetData() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

