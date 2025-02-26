//
//  Task.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.

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
    @Persisted var createdAt: Date = Date()
    @Persisted var reminderEnabled: Bool = false
    @Persisted var reminderTime: Date?
    @Persisted var notes: String = ""
    @Persisted var tags: List<String> = List<String>()
    
    convenience init(title: String, description: String, dueDate: Date, priority: String, category: String) {
        self.init()
        self.title = title
        self.desc = description
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
    }
    
    // Helper computed property to determine if task is overdue
    var isOverdue: Bool {
        return !isCompleted && dueDate < Date()
    }
    
    // Helper computed property to get urgency level based on due date
    var urgencyLevel: UrgencyLevel {
        let calendar = Calendar.current
        let now = Date()
        
        if isCompleted {
            return .completed
        } else if dueDate < now {
            return .overdue
        } else if calendar.isDateInToday(dueDate) {
            return .today
        } else if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
                  calendar.isDate(dueDate, inSameDayAs: tomorrow) {
            return .tomorrow
        } else if let nextWeek = calendar.date(byAdding: .day, value: 7, to: now),
                  dueDate <= nextWeek {
            return .thisWeek
        } else {
            return .future
        }
    }
}

enum UrgencyLevel: String, CaseIterable {
    case overdue = "Overdue"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This Week"
    case future = "Future"
    case completed = "Completed"
    
    var color: String {
        switch self {
        case .overdue: return "OverdueColor"
        case .today: return "TodayColor"
        case .tomorrow: return "TomorrowColor"
        case .thisWeek: return "ThisWeekColor"
        case .future: return "FutureColor"
        case .completed: return "CompletedColor"
        }
    }
}
