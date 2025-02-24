//
//  Task.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.
//


import Foundation
import RealmSwift

class Task: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var desc: String = ""
    @Persisted var dueDate: Date = Date()
    @Persisted var isCompleted: Bool = false
    @Persisted var priority: String = "Medium"
    @Persisted var category: String = "Personal"
    
    convenience init(title: String, description: String, dueDate: Date, priority: String, category: String) {
        self.init()
        self.title = title
        self.desc = description
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
    }
}

// End of file. No additional code.