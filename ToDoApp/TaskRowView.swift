//
//  TaskRowView.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.
//


import SwiftUI

struct TaskRowView: View {
    let task: Task
    let viewModel: TaskViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(task.title)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                
                Text(task.desc)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                HStack {
                    PriorityBadge(priority: task.priority)
                    CategoryBadge(category: task.category)
                    Spacer()
                    Text(task.dueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: { viewModel.toggleTaskCompletion(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct PriorityBadge: View {
    let priority: String
    
    var color: Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        default: return .green
        }
    }
    
    var body: some View {
        Text(priority)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

struct CategoryBadge: View {
    let category: String
    
    var body: some View {
        Text(category)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(8)
    }
}

// End of file. No additional code.