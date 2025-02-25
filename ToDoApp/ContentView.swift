//
//  ContentView.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.
//

//import SwiftUI
//import RealmSwift
//
//struct ContentView: View {
//    @StateObject private var taskViewModel = TaskViewModel()
//    @State private var showAddTask = false
//    @State private var searchText = ""
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color("BackgroundColor")
//                    .ignoresSafeArea()
//                
//                VStack(spacing: 15) {
//                    // Search bar
//                    CustomSearchBar(text: $searchText)
//                    
//                    // Task list
//                    // Task list
//                    
//                    if taskViewModel.filteredTasks(searchText).isEmpty {
//                        Text("No tasks found")
//                            .font(.headline)
//                            .foregroundColor(.secondary)
//                    }
//                    
//                    List {
//                        ForEach(taskViewModel.filteredTasks(searchText)) { task in
//                            TaskRowView(task: task, viewModel: taskViewModel)
//                                .listRowInsets(EdgeInsets())
//                                .listRowBackground(Color.clear)
//                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//                                    Button(role: .destructive) {
//                                        withAnimation {
//                                            taskViewModel.deleteTask(task)
//                                        }
//                                    } label: {
//                                        Label("Delete", systemImage: "trash")
//                                    }
//                                }
//                        }
//                        .listRowSeparator(.hidden)
//                    }
//                    .listStyle(.plain)
//                    .padding(.horizontal)
//                }
//            }
//            .navigationTitle("My Tasks")
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button(action: { showAddTask.toggle() }) {
//                        Image(systemName: "plus.circle.fill")
//                            .font(.title2)
//                            .foregroundColor(.blue)
//                    }
//                }
//            }
//            .sheet(isPresented: $showAddTask) {
//                AddTaskView(viewModel: taskViewModel)
//            }
//        }
//    }
//}
//
//// Custom search bar view
//struct CustomSearchBar: View {
//    @Binding var text: String
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.gray)
//            
//            TextField("Search tasks...", text: $text)
//                .textFieldStyle(PlainTextFieldStyle())
//            
//            if !text.isEmpty {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.gray)
//                    .onTapGesture {
//                        text = ""
//                    }
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(10)
//        .padding(.horizontal)
//    }
//}
//
//#Preview {
//    ContentView()
//}

//
//  ContentView.swift
//  ToDoApp
//
//  Created by MacMini6 on 24/02/25.
//

import SwiftUI
import RealmSwift
import Charts

struct ContentView: View {
    @StateObject private var taskViewModel = TaskViewModel()
    @State private var showAddTask = false
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var showFilterSheet = false
    @State private var showSettingsSheet = false
    @EnvironmentObject var themeManager: ThemeManager
    
    let tabs = ["Tasks", "Statistics", "Calendar"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom tab bar
                CustomTabBar(selectedTab: $selectedTab, tabs: tabs)
                
                // Main content based on selected tab
                TabView(selection: $selectedTab) {
                    taskListView
                        .tag(0)
                    
                    statisticsView
                        .tag(1)
                    
                    calendarView
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(tabs[selectedTab])
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if selectedTab == 0 {
                        HStack {
                            // Filter button
                            Button(action: { showFilterSheet.toggle() }) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.title2)
                            }
                            
                            // Add task button
                            Button(action: { showAddTask.toggle() }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            
                            // Settings button
                            Button(action: { showSettingsSheet.toggle() }) {
                                Image(systemName: "gear")
                                    .font(.title2)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: taskViewModel)
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterView(viewModel: taskViewModel)
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView()
            }
        }
    }
    
    // MARK: - Task List View
    private var taskListView: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 15) {
                // Search bar
                CustomSearchBar(text: $searchText)
                
                // Task summary
                TaskSummaryView(viewModel: taskViewModel)
                
                // Filter indicators
                HStack {
                    if let category = taskViewModel.filterCategory {
                        FilterTag(text: category, iconName: "folder.fill")
                            .onTapGesture {
                                taskViewModel.filterCategory = nil
                            }
                    }
                    
                    if let priority = taskViewModel.filterPriority {
                        FilterTag(text: priority, iconName: "flag.fill")
                            .onTapGesture {
                                taskViewModel.filterPriority = nil
                            }
                    }
                    
                    Spacer()
                    
                    // Sort menu
                    Menu {
                        ForEach(TaskViewModel.SortOption.allCases) { option in
                            Button(action: {
                                taskViewModel.sortOption = option
                            }) {
                                HStack {
                                    Text(option.rawValue)
                                    if taskViewModel.sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Task list
                if taskViewModel.filteredTasks(searchText).isEmpty {
                    VStack {
                        Spacer()
                        VStack(spacing: 15) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No tasks found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Try adjusting your filters or add a new task")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button(action: { showAddTask.toggle() }) {
                                Text("Add Task")
                                    .font(.headline)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(taskViewModel.filteredTasks(searchText)) { task in
                            NavigationLink {
                                TaskDetailView(task: task, viewModel: taskViewModel)
                            } label: {
                                TaskRowView(task: task, viewModel: taskViewModel)
                            }
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
                            .swipeActions(edge: .leading) {
                                Button {
                                    taskViewModel.toggleTaskCompletion(task)
                                } label: {
                                    Label(task.isCompleted ? "Mark Incomplete" : "Complete",
                                          systemImage: task.isCompleted ? "xmark.circle" : "checkmark.circle")
                                }
                                .tint(task.isCompleted ? .orange : .green)
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - Statistics View
    private var statisticsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Completion Rate
                VStack(alignment: .leading, spacing: 10) {
                    Text("Task Completion Rate")
                        .font(.headline)
                    
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 24)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.green)
                            .frame(width: max(CGFloat(taskViewModel.getCompletionRate()) * UIScreen.main.bounds.width - 40, 0), height: 24)
                        
                        Text("\(Int(taskViewModel.getCompletionRate() * 100))%")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.leading, 10)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Tasks by Urgency
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tasks by Urgency")
                        .font(.headline)
                    
                    Chart {
                        ForEach(Array(taskViewModel.getTasksByUrgency().keys), id: \.self) { key in
                            BarMark(
                                x: .value("Count", taskViewModel.getTasksByUrgency()[key] ?? 0),
                                y: .value("Urgency", key.rawValue)
                            )
                            .foregroundStyle(by: .value("Urgency", key.rawValue))
                        }
                    }
                    .frame(height: 200)
                    .chartForegroundStyleScale(["Overdue": Color.red, "Today": Color.orange, "Tomorrow": Color.yellow, "This Week": Color.blue, "Future": Color.green, "Completed": Color.gray])
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // Tasks by Category
                VStack(alignment: .leading, spacing: 10) {
                    Text("Tasks by Category")
                        .font(.headline)
                    
                    if taskViewModel.getTasksByCategory().isEmpty {
                        Text("No data available")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        Chart {
                            ForEach(Array(taskViewModel.getTasksByCategory().keys), id: \.self) { key in
                                if #available(iOS 17.0, *) {
                                    SectorMark(
                                        angle: .value("Count", taskViewModel.getTasksByCategory()[key] ?? 0),
                                        innerRadius: .ratio(0.5),
                                        angularInset: 1.5
                                    )
                                    .cornerRadius(5)
                                    .foregroundStyle(by: .value("Category", key))
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                        }
                        .frame(height: 200)
                    }
                    
                    // Chart legend
                    VStack(alignment: .leading) {
                        ForEach(Array(taskViewModel.getTasksByCategory().keys.sorted()), id: \.self) { category in
                            HStack {
                                Circle()
                                    .fill(categoryToColor(category))
                                    .frame(width: 10, height: 10)
                                Text(category)
                                    .font(.caption)
                                Spacer()
                                Text("\(taskViewModel.getTasksByCategory()[category] ?? 0)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color("BackgroundColor").ignoresSafeArea())
    }
    
    // MARK: - Calendar View
    private var calendarView: some View {
        CalendarTaskView(viewModel: taskViewModel)
            .background(Color("BackgroundColor").ignoresSafeArea())
    }
    
    private func categoryToColor(_ category: String) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .yellow]
        let index = abs(category.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Helper Views
struct TaskSummaryView: View {
    let viewModel: TaskViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            SummaryCard(title: "Total", count: viewModel.tasks.count, color: .blue)
            SummaryCard(title: "Done", count: viewModel.tasks.filter { $0.isCompleted }.count, color: .green)
            SummaryCard(title: "Pending", count: viewModel.tasks.filter { !$0.isCompleted }.count, color: .orange)
        }
        .padding(.horizontal)
    }
}

struct SummaryCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// CustomTabBar implementation
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [String]
    
    var body: some View {
        HStack {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: getIconForTab(index))
                            .font(.system(size: 20))
                        Text(tabs[index])
                            .font(.caption)
                    }
                    .foregroundColor(selectedTab == index ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selectedTab == index ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
        .background(Color(.systemBackground))
    }
    
    private func getIconForTab(_ index: Int) -> String {
        switch index {
        case 0: return "checklist"
        case 1: return "chart.pie"
        case 2: return "calendar"
        default: return "square"
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

struct FilterTag: View {
    let text: String
    let iconName: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.caption)
            Text(text)
                .font(.caption)
            Image(systemName: "xmark")
                .font(.caption)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TaskViewModel
    
    let categories = ["Personal", "Work", "Shopping", "Health", "Education"]
    let priorities = ["High", "Medium", "Low"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Filter Options")) {
                    Toggle("Show Completed Tasks", isOn: $viewModel.showCompletedTasks)
                }
                
                Section(header: Text("Category")) {
                    Picker("Select Category", selection: $viewModel.filterCategory) {
                        Text("All Categories").tag(nil as String?)
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category as String?)
                        }
                    }
                }
                
                Section(header: Text("Priority")) {
                    Picker("Select Priority", selection: $viewModel.filterPriority) {
                        Text("All Priorities").tag(nil as String?)
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority).tag(priority as String?)
                        }
                    }
                }
            }
            .navigationTitle("Filter Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $themeManager.currentTheme) {
                        Text("Light").tag(ThemeManager.Theme.light)
                        Text("Dark").tag(ThemeManager.Theme.dark)
                        Text("System").tag(ThemeManager.Theme.system)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CalendarTaskView: View {
    @ObservedObject var viewModel: TaskViewModel
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack {
            // Simple calendar view
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            
            // Tasks for selected date
            VStack(alignment: .leading) {
                Text("Tasks for \(selectedDate.formatted(date: .long, time: .omitted))")
                    .font(.headline)
                    .padding(.horizontal)
                
                let tasksForDate = viewModel.tasks.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate) }
                
                if tasksForDate.isEmpty {
                    VStack {
                        Text("No tasks for this date")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(tasksForDate) { task in
                                TaskRowView(task: task, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
            
            Spacer()
        }
    }
}

struct TaskDetailView: View {
    let task: Task
    let viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var dueDate: Date = Date()
    @State private var priority: String = "Medium"
    @State private var category: String = "Personal"
    @State private var notes: String = ""
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Date()
    @State private var newTag: String = ""
    
    let priorities = ["High", "Medium", "Low"]
    let categories = ["Personal", "Work", "Shopping", "Health", "Education"]
    
    var body: some View {
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
            
            Section(header: Text("Reminder")) {
                Toggle("Enable Reminder", isOn: $reminderEnabled)
                
                if reminderEnabled {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: [.date, .hourAndMinute])
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: $notes)
                    .frame(height: 100)
            }
            
            Section(header: HStack {
                Text("Tags")
                Spacer()
                
                Button(action: {
                    if !newTag.isEmpty {
                        viewModel.addTag(to: task, tag: newTag)
                        newTag = ""
                    }
                }) {
                    Image(systemName: "plus.circle")
                }
                .disabled(newTag.isEmpty)
            }) {
                HStack {
                    TextField("Add new tag", text: $newTag)
                        .submitLabel(.done)
                        .onSubmit {
                            if !newTag.isEmpty {
                                viewModel.addTag(to: task, tag: newTag)
                                newTag = ""
                            }
                        }
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(task.tags.enumerated()), id: \.element) { index, tag in
                            HStack {
                                Text(tag)
                                    .font(.caption)
                                
                                Button(action: {
                                    viewModel.removeTag(from: task, at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
            }
            
            Section {
                Button("Delete Task", role: .destructive) {
                    viewModel.deleteTask(task)
                    dismiss()
                }
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.updateTask(
                        task,
                        title: title,
                        description: description,
                        dueDate: dueDate,
                        priority: priority,
                        category: category,
                        notes: notes,
                        reminderEnabled: reminderEnabled,
                        reminderTime: reminderEnabled ? reminderTime : nil
                    )
                    dismiss()
                }
                .disabled(title.isEmpty)
            }
        }
        .onAppear {
            // Load task data
            title = task.title
            description = task.desc
            dueDate = task.dueDate
            priority = task.priority
            category = task.category
            notes = task.notes
            reminderEnabled = task.reminderEnabled
            if let reminderTime = task.reminderTime {
                self.reminderTime = reminderTime
            }
        }
    }
}

#Preview {
    ContentView()
}
