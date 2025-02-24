//
//  AddTaskView.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.
//


import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: TaskViewModel
    
    @State private var title = ""
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var priority = "Medium"
    @State private var category = "Personal"
    
    let priorities = ["High", "Medium", "Low"]
    let categories = ["Personal", "Work", "Shopping", "Health", "Education"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Due Date")) {
                    DatePicker("Select Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Priority")) {
                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Category")) {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                }
            }
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        viewModel.addTask(
                            title: title,
                            description: description,
                            dueDate: dueDate,
                            priority: priority,
                            category: category
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

// End of file. No additional code.