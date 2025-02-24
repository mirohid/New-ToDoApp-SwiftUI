//
//  TaskViewModel.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.
//


//import Foundation
//import RealmSwift
//
//class TaskViewModel: ObservableObject {
//    private var realm: Realm
//    @Published var tasks: [Task] = []
//    
//    init() {
//        self.realm = try! Realm()
//        fetchTasks()
//    }
//    
//    func fetchTasks() {
//        let realmTasks = realm.objects(Task.self)
//        tasks = Array(realmTasks)
//        objectWillChange.send()
//    }
//    
//    func addTask(title: String, description: String, dueDate: Date, priority: String, category: String) {
//        let task = Task(title: title, description: description, dueDate: dueDate, priority: priority, category: category)
//        try? realm.write {
//            realm.add(task)
//        }
//        fetchTasks()
//    }
//    
//    func deleteTask(_ task: Task) {
//        try? realm.write {
//            realm.delete(task)
//        }
//        fetchTasks()
//    }
//    
//    func toggleTaskCompletion(_ task: Task) {
//        try? realm.write {
//            task.isCompleted.toggle()
//        }
//        fetchTasks()
//    }
//    
//    func filteredTasks(_ searchText: String) -> [Task] {
//        if searchText.isEmpty {
//            return tasks
//        }
//        return tasks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
//    }
//}

import Foundation
import RealmSwift

class TaskViewModel: ObservableObject {
    private var realm: Realm
    private var tasksToken: NotificationToken?
    @Published var tasks: [Task] = []
    
    init() {
        self.realm = try! Realm()
        setupObserver()
    }
    
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
    
    func deleteTask(_ task: Task) {
        guard let thawedTask = task.thaw() else { return }
        try? realm.write {
            realm.delete(thawedTask)
        }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        guard let thawedTask = task.thaw() else { return }
        try? realm.write {
            thawedTask.isCompleted.toggle()
        }
    }
    
    func filteredTasks(_ searchText: String) -> [Task] {
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
    
    deinit {
        tasksToken?.invalidate()
    }
}

// End of file. No additional code.



// End of file. No additional code.
