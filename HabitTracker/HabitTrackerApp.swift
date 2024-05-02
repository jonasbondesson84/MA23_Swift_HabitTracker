//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import SwiftUI
import FirebaseCore
import NotificationCenter



class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct HabitTrackerApp: App {
    @StateObject var userData = UserViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    

    
    var body: some Scene {
        WindowGroup {
            
            MainView()
                .environmentObject(userData)
                .onAppear() {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
                        if success {
                            // Got access
                        } else if let error = error {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
        }
    }
}
