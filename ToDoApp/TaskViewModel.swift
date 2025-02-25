//
//  TaskViewModel.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.


//import Foundation
//import RealmSwift
//
//class TaskViewModel: ObservableObject {
//    private var realm: Realm
//    private var tasksToken: NotificationToken?
//    @Published var tasks: [Task] = []
//    
//    init() {
//        self.realm = try! Realm()
//        setupObserver()
//    }
//    
//    private func setupObserver() {
//        let results = realm.objects(Task.self)
//        tasksToken = results.observe { [weak self] changes in
//            self?.tasks = Array(results)
//            self?.objectWillChange.send()
//        }
//    }
//    
//    func addTask(title: String, description: String, dueDate: Date, priority: String, category: String) {
//        let task = Task(title: title, description: description, dueDate: dueDate, priority: priority, category: category)
//        try? realm.write {
//            realm.add(task)
//        }
//    }
//    
//    func deleteTask(_ task: Task) {
//        guard let thawedTask = task.thaw() else { return }
//        try? realm.write {
//            realm.delete(thawedTask)
//        }
//    }
//    
//    func toggleTaskCompletion(_ task: Task) {
//        guard let thawedTask = task.thaw() else { return }
//        try? realm.write {
//            thawedTask.isCompleted.toggle()
//        }
//    }
//    
//    func filteredTasks(_ searchText: String) -> [Task] {
//        if searchText.isEmpty {
//            return tasks
//        }
//        return tasks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
//    }
//    
//    deinit {
//        tasksToken?.invalidate()
//    }
//}


//
//  TaskViewModel.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.

import Foundation
import RealmSwift
import UserNotifications

class TaskViewModel: ObservableObject {
    private var realm: Realm
    private var tasksToken: NotificationToken?
    @Published var tasks: [Task] = []
    @Published var filterCategory: String? = nil
    @Published var filterPriority: String? = nil
    @Published var sortOption: SortOption = .dueDate
    @Published var showCompletedTasks = true
    
    enum SortOption: String, CaseIterable, Identifiable {
        case dueDate = "Due Date"
        case priority = "Priority"
        case title = "Title"
        case createdAt = "Created Date"
        
        var id: String { self.rawValue }
    }
    
    init() {
        // Set up the migration configuration
        let config = Realm.Configuration(
            schemaVersion: 1, // Increment this when you change your model
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Initialize new properties with default values
                    migration.enumerateObjects(ofType: Task.className()) { oldObject, newObject in
                        // Set default values for new properties
                        newObject?["createdAt"] = Date()
                        newObject?["reminderEnabled"] = false
                        newObject?["notes"] = ""
                        // reminderTime is optional so it can be nil
                        // tags will be initialized as an empty List by Realm
                    }
                }
            },
            deleteRealmIfMigrationNeeded: false // Set to true only during development
        )
        
        // Use this configuration
        Realm.Configuration.defaultConfiguration = config
        
        // Initialize Realm with the configuration
        do {
            self.realm = try Realm()
            setupObserver()
        } catch {
            print("Failed to open Realm: \(error)")
            // Provide a fallback for release builds
            // In a real app, you might want to show an error to the user
            fatalError("Could not open Realm: \(error)")
        }
    }
    
    // The rest of your code remains the same
    
    private func setupObserver() {
        let results = realm.objects(Task.self)
        tasksToken = results.observe { [weak self] changes in
            self?.tasks = Array(results)
            self?.objectWillChange.send()
        }
    }
    
    func addTask(title: String, description: String, dueDate: Date, priority: String, category: String) {
        let task = Task(title: title, description: description, dueDate: dueDate, priority: priority, category: category)
        try? realm.write {
            realm.add(task)
        }
    }
    
    func updateTask(_ task: Task, title: String, description: String, dueDate: Date, priority: String, category: String, notes: String, reminderEnabled: Bool, reminderTime: Date?) {
        guard let thawedTask = task.thaw() else { return }
        try? realm.write {
            thawedTask.title = title
            thawedTask.desc = description
            thawedTask.dueDate = dueDate
            thawedTask.priority = priority
            thawedTask.category = category
            thawedTask.notes = notes
            thawedTask.reminderEnabled = reminderEnabled
            thawedTask.reminderTime = reminderTime
            
            // Handle reminder notification
            if reminderEnabled, let reminderTime = reminderTime {
                scheduleReminder(for: thawedTask)
            } else {
                cancelReminder(for: thawedTask)
            }
        }
    }
    
    func deleteTask(_ task: Task) {
        guard let thawedTask = task.thaw() else { return }
        // Cancel any scheduled notifications
        cancelReminder(for: thawedTask)
        
        try? realm.write {
            realm.delete(thawedTask)
        }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        guard let thawedTask = task.thaw() else { return }
        try? realm.write {
            thawedTask.isCompleted.toggle()
            
            // If task is completed, cancel any reminders
            if thawedTask.isCompleted {
                cancelReminder(for: thawedTask)
            } else if thawedTask.reminderEnabled, let reminderTime = thawedTask.reminderTime, reminderTime > Date() {
                // If uncompleted and reminder time is in future, reschedule
                scheduleReminder(for: thawedTask)
            }
        }
    }
    
    func addTag(to task: Task, tag: String) {
        guard let thawedTask = task.thaw() else { return }
        try? realm.write {
            if !thawedTask.tags.contains(tag) {
                thawedTask.tags.append(tag)
            }
        }
    }
    
    func removeTag(from task: Task, at index: Int) {
        guard let thawedTask = task.thaw(), index < thawedTask.tags.count else { return }
        try? realm.write {
            thawedTask.tags.remove(at: index)
        }
    }
    
    func scheduleReminder(for task: Task) {
        guard task.reminderEnabled, let reminderTime = task.reminderTime, reminderTime > Date() else { return }
        
        // Cancel existing reminders first
        cancelReminder(for: task)
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        content.userInfo = ["taskId": task.id.stringValue]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "task_\(task.id.stringValue)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func cancelReminder(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["task_\(task.id.stringValue)"])
    }
    
    func getTasksByCategory() -> [String: Int] {
        var result: [String: Int] = [:]
        let allTasks = tasks
        
        for task in allTasks {
            if let count = result[task.category] {
                result[task.category] = count + 1
            } else {
                result[task.category] = 1
            }
        }
        
        return result
    }
    
    func getTasksByPriority() -> [String: Int] {
        var result: [String: Int] = [:]
        let allTasks = tasks
        
        for task in allTasks {
            if let count = result[task.priority] {
                result[task.priority] = count + 1
            } else {
                result[task.priority] = 1
            }
        }
        
        return result
    }
    
    func getTasksByUrgency() -> [UrgencyLevel: Int] {
        var result: [UrgencyLevel: Int] = [:]
        let allTasks = tasks
        
        for task in allTasks {
            let urgency = task.urgencyLevel
            if let count = result[urgency] {
                result[urgency] = count + 1
            } else {
                result[urgency] = 1
            }
        }
        
        return result
    }
    
    func getCompletionRate() -> Double {
        let allTasks = tasks
        guard !allTasks.isEmpty else { return 0 }
        
        let completedTasks = allTasks.filter { $0.isCompleted }
        return Double(completedTasks.count) / Double(allTasks.count)
    }
    
    func filteredTasks(_ searchText: String) -> [Task] {
        var filtered = tasks
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.desc.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Filter by completion status
        if !showCompletedTasks {
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        // Filter by category
        if let category = filterCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by priority
        if let priority = filterPriority {
            filtered = filtered.filter { $0.priority == priority }
        }
        
        // Sort tasks
        return sortTasks(filtered)
    }
    
    private func sortTasks(_ tasks: [Task]) -> [Task] {
        switch sortOption {
        case .dueDate:
            return tasks.sorted { $0.dueDate < $1.dueDate }
        case .priority:
            return tasks.sorted { priorityToInt($0.priority) > priorityToInt($1.priority) }
        case .title:
            return tasks.sorted { $0.title < $1.title }
        case .createdAt:
            return tasks.sorted { $0.createdAt < $1.createdAt }
        }
    }
    
    private func priorityToInt(_ priority: String) -> Int {
        switch priority {
        case "High": return 3
        case "Medium": return 2
        case "Low": return 1
        default: return 0
        }
    }
    
    deinit {
        tasksToken?.invalidate()
    }
}
