//
//  ToDoAppApp.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.


import SwiftUI
import UserNotifications

@main
struct ToDoAppApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    init() {
        // Request notification permissions when app launches
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme == .dark ? .dark : .light)
        }
    }
}

// Theme manager to handle app-wide dark/light mode
class ThemeManager: ObservableObject {
    enum Theme: String {
        case light, dark, system
    }
    
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
        }
    }
    
    init() {
        // Load saved theme or use system as default
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = Theme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }
}
