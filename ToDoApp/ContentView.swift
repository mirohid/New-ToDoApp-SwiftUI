//
//  ContentView.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var showAddTask = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    // Search bar
                    CustomSearchBar(text: $searchText)
                    
                    // Task list
                    // Task list
                    
                    if taskViewModel.filteredTasks(searchText).isEmpty {
                        Text("No tasks found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    List {
                        ForEach(taskViewModel.filteredTasks(searchText)) { task in
                            TaskRowView(task: task, viewModel: taskViewModel)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            taskViewModel.deleteTask(task)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddTask.toggle() }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: taskViewModel)
            }
        }
    }
}

// Custom search bar view
struct CustomSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search tasks...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .onTapGesture {
                        text = ""
                    }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}

// End of file. No additional code.
