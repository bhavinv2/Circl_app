//
//  ProjectViews.swift
//  circl_test_app
//
//  Created on 11/2/2025.
//

import Foundation
import SwiftUI

// MARK: - Project Grid View
struct ProjectGridView: View {
    @Binding var projects: [Project]
    @Binding var selectedProject: Project?
    @Binding var showProjectDetails: Bool
    @Binding var selectedTask: TaskItem?
    @Binding var showTaskDetails: Bool
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 300, maximum: 400))
            ], spacing: 16) {
                ForEach(projects) { project in
                    ProjectCardView(project: project) {
                        selectedProject = project
                        showProjectDetails = true
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Project Card View
struct ProjectCardView: View {
    let project: Project
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Project Header
            HStack {
                Circle()
                    .fill(project.color.color)
                    .frame(width: 12, height: 12)
                
                Text(project.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if project.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                }
            }
            
            // Description
            Text(project.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(project.completionPercentage))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(project.color.color)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: geometry.size.width, height: 6)
                        
                        Rectangle()
                            .fill(project.color.color)
                            .frame(width: geometry.size.width * (project.completionPercentage / 100), height: 6)
                    }
                    .cornerRadius(3)
                }
                .frame(height: 6)
            }
            
            // Task Summary
            HStack {
                VStack(alignment: .leading) {
                    Text("\(project.tasks.count)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Tasks")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(project.endDate, style: .date)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(project.endDate < Date() ? .red : .secondary)
                    Text("Due Date")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Project Detail View
struct ProjectDetailView: View {
    @Binding var project: Project
    @Binding var isPresented: Bool
    @Binding var showTaskDetails: Bool
    @Binding var selectedTask: TaskItem?
    @State private var showCreateTask = false
    @State private var showEditProject = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Project Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Circle()
                                .fill(project.color.color)
                                .frame(width: 16, height: 16)
                            
                            Text(project.name)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if project.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20))
                            }
                        }
                        
                        Text(project.description)
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        // Progress Section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Progress")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(Int(project.completionPercentage))%")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(project.color.color)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                    
                                    Rectangle()
                                        .fill(project.color.color)
                                        .frame(width: geometry.size.width * (project.completionPercentage / 100))
                                }
                            }
                            .frame(height: 8)
                            .cornerRadius(4)
                        }
                        
                        // Stats Row
                        HStack(spacing: 20) {
                            VStack(alignment: .leading) {
                                Text("\(project.tasks.count)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primary)
                                Text("Total Tasks")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(alignment: .leading) {
                                Text("\(project.tasks.filter { $0.status == .completed }.count)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.green)
                                Text("Completed")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(alignment: .leading) {
                                Text(project.endDate, style: .date)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(project.endDate < Date() ? .red : .primary)
                                Text("Due Date")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Divider()
                    
                    // Tasks Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Tasks")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                showCreateTask = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add Task")
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: "004aad"))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if project.tasks.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                
                                Text("No tasks yet")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(project.tasks) { task in
                                    ProjectTaskCardView(task: task) {
                                        selectedTask = task
                                        isPresented = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showTaskDetails = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            .navigationTitle("Project Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Done") {
                    isPresented = false
                },
                trailing: Button("Edit") {
                    showEditProject = true
                }
            )
        }
        .sheet(isPresented: $showCreateTask) {
            CreateTaskViewForProject(
                isPresented: $showCreateTask,
                project: $project
            )
        }
        .sheet(isPresented: $showEditProject) {
            EditProjectView(
                project: $project,
                isPresented: $showEditProject
            )
        }
    }
}

// MARK: - Project Task Card View (Simplified for project details)
struct ProjectTaskCardView: View {
    let task: TaskItem
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Priority indicator and title
            HStack {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 8, height: 8)
                
                Text(task.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Spacer()
                
                // Status badge
                Text(task.status.rawValue)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(task.status.color)
                    .cornerRadius(4)
            }
            
            // Description
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // Assignees and dates
            HStack {
                // Assignees
                if !task.assignees.isEmpty {
                    HStack(spacing: -4) {
                        ForEach(Array(task.assignees.prefix(3).enumerated()), id: \.offset) { index, assignee in
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text(String(assignee.prefix(1).uppercased()))
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(.primary)
                                )
                                .background(
                                    Circle()
                                        .stroke(Color(.systemBackground), lineWidth: 2)
                                )
                        }
                        
                        if task.assignees.count > 3 {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text("+\(task.assignees.count - 3)")
                                        .font(.system(size: 8, weight: .semibold))
                                        .foregroundColor(.secondary)
                                )
                        }
                    }
                }
                
                Spacer()
                
                // Due date
                VStack(alignment: .trailing) {
                    Text(task.endDate, style: .date)
                        .font(.system(size: 10))
                        .foregroundColor(task.endDate < Date() ? .red : .secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Create Task View For Project
struct CreateTaskViewForProject: View {
    @Binding var isPresented: Bool
    @Binding var project: Project
    @State private var title = ""
    @State private var description = ""
    @State private var assignees = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var priority: TaskItem.TaskPriority = .medium
    @State private var status: TaskStatus = .notStarted
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Assignment") {
                    TextField("Assignees (comma separated)", text: $assignees)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskItem.TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }.tag(priority)
                        }
                    }
                    
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section("Timeline") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Section("Project") {
                    HStack {
                        Circle()
                            .fill(project.color.color)
                            .frame(width: 12, height: 12)
                        Text(project.name)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Create") {
                    createTask()
                }
                .disabled(title.isEmpty)
            )
        }
    }
    
    private func createTask() {
        let assigneeList = assignees.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let newTask = TaskItem(
            id: Int(Date().timeIntervalSince1970),   // temporary local id
            projectId: project.id,
            title: title,
            description: description,
            status: status,
            assignees: assigneeList,
            startDate: startDate,
            endDate: endDate,
            priority: priority
        )

        
        // Create a copy of the project to trigger SwiftUI update
        var updatedProject = project
        updatedProject.tasks.append(newTask)
        project = updatedProject
        
        isPresented = false
    }
}

// MARK: - Edit Project View
struct EditProjectView: View {
    @Binding var project: Project
    @Binding var isPresented: Bool
    @State private var editedName: String
    @State private var editedDescription: String
    @State private var editedColor: Project.ProjectColor
    @State private var editedStartDate: Date
    @State private var editedEndDate: Date
    
    init(project: Binding<Project>, isPresented: Binding<Bool>) {
        self._project = project
        self._isPresented = isPresented
        self._editedName = State(initialValue: project.wrappedValue.name)
        self._editedDescription = State(initialValue: project.wrappedValue.description)
        self._editedColor = State(initialValue: project.wrappedValue.color)
        self._editedStartDate = State(initialValue: project.wrappedValue.startDate)
        self._editedEndDate = State(initialValue: project.wrappedValue.endDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $editedName)
                    TextField("Description", text: $editedDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Appearance") {
                    Picker("Color", selection: $editedColor) {
                        ForEach(Project.ProjectColor.allCases, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(color.color)
                                    .frame(width: 16, height: 16)
                                Text(color.rawValue)
                            }.tag(color)
                        }
                    }
                }
                
                Section("Timeline") {
                    DatePicker("Start Date", selection: $editedStartDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $editedEndDate, displayedComponents: .date)
                }
                
                Section("Project Info") {
                    HStack {
                        Text("Total Tasks")
                        Spacer()
                        Text("\(project.tasks.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Completed Tasks")
                        Spacer()
                        Text("\(project.tasks.filter { $0.status == .completed }.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(project.createdAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Project")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    saveChanges()
                }
            )
        }
    }
    
    private func saveChanges() {
        project.name = editedName
        project.description = editedDescription
        project.color = editedColor
        project.startDate = editedStartDate
        project.endDate = editedEndDate
        
        isPresented = false
    }
}
