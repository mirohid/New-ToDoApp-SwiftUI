//
//  TaskViewModel.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.
//


import Foundation
import RealmSwift

class TaskViewModel: ObservableObject {
    private var realm: Realm
    @Published var tasks: [Task] = []
    
    init() {
        self.realm = try! Realm()
        fetchTasks()
    }
    
    func fetchTasks() {
        let realmTasks = realm.objects(Task.self)
        tasks = Array(realmTasks)
        objectWillChange.send()
    }
    
    func addTask(title: String, description: String, dueDate: Date, priority: String, category: String) {
        let task = Task(title: title, description: description, dueDate: dueDate, priority: priority, category: category)
        try? realm.write {
            realm.add(task)
        }
        fetchTasks()
    }
    
    func deleteTask(_ task: Task) {
        try? realm.write {
            realm.delete(task)
        }
        fetchTasks()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        try? realm.write {
            task.isCompleted.toggle()
        }
        fetchTasks()
    }
    
    func filteredTasks(_ searchText: String) -> [Task] {
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
}

// End of file. No additional code.