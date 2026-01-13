//
//  TaskViews.swift
//  circl_test_app
//
//  Created on 11/2/2025.
//

import Foundation
import SwiftUI

// MARK: - Create Task View
struct CreateTaskView: View {
    @Binding var isPresented: Bool
    @Binding var standaloneTasks: [TaskItem]
    @Binding var projects: [Project]
    @Binding var title: String
    @Binding var description: String
    @Binding var assignees: String
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var priority: TaskItem.TaskPriority
    @Binding var status: TaskStatus
    @Binding var selectedProject: Project?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Project Assignment") {
                    Picker("Assign to Project", selection: $selectedProject) {
                        Text("Standalone Task").tag(Project?.none)
                        ForEach(projects) { project in
                            HStack {
                                Circle()
                                    .fill(project.color.color)
                                    .frame(width: 12, height: 12)
                                Text(project.name)
                            }.tag(Project?.some(project))
                        }
                    }
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
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    resetForm()
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
            title: title,
            description: description,
            status: status,
            projectId: selectedProject?.id,
            assignees: assigneeList,
            startDate: startDate,
            endDate: endDate,
            priority: priority
        )
        
        if let project = selectedProject {
            // Add task to project
            if let projectIndex = projects.firstIndex(where: { $0.id == project.id }) {
                // Create a copy of the project to trigger SwiftUI update
                var updatedProject = projects[projectIndex]
                updatedProject.tasks.append(newTask)
                projects[projectIndex] = updatedProject
            }
        } else {
            // Add as standalone task
            standaloneTasks.append(newTask)
        }
        
        resetForm()
        isPresented = false
    }
    
    private func resetForm() {
        title = ""
        description = ""
        assignees = ""
        startDate = Date()
        endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        priority = .medium
        status = .notStarted
        selectedProject = nil
    }
}

// MARK: - Create Project View
struct CreateProjectView: View {
    @Binding var isPresented: Bool
    @Binding var projects: [Project]
    @Binding var name: String
    @Binding var description: String
    @Binding var color: Project.ProjectColor
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        NavigationView {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Appearance") {
                    Picker("Color", selection: $color) {
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
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    resetForm()
                    isPresented = false
                },
                trailing: Button("Create") {
                    createProject()
                }
                .disabled(name.isEmpty)
            )
        }
    }
    
    private func createProject() {
        let newProject = Project(
            name: name,
            description: description,
            color: color,
            startDate: startDate,
            endDate: endDate
        )
        
        projects.append(newProject)
        resetForm()
        isPresented = false
    }
    
    private func resetForm() {
        name = ""
        description = ""
        color = .blue
        startDate = Date()
        endDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    }
}

// MARK: - Task Detail View  
struct TaskDetailView: View {
    @Binding var task: TaskItem
    @Binding var isPresented: Bool
    @Binding var projects: [Project]
    @Binding var standaloneTasks: [TaskItem]
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var editedAssignees: String
    @State private var editedPriority: TaskItem.TaskPriority
    @State private var editedStatus: TaskStatus
    @State private var editedStartDate: Date
    @State private var editedEndDate: Date
    @State private var selectedProject: Project?
    
    init(task: Binding<TaskItem>, isPresented: Binding<Bool>, projects: Binding<[Project]>, standaloneTasks: Binding<[TaskItem]>) {
        self._task = task
        self._isPresented = isPresented
        self._projects = projects
        self._standaloneTasks = standaloneTasks
        self._editedTitle = State(initialValue: task.wrappedValue.title)
        self._editedDescription = State(initialValue: task.wrappedValue.description)
        self._editedAssignees = State(initialValue: task.wrappedValue.assignees.joined(separator: ", "))
        self._editedPriority = State(initialValue: task.wrappedValue.priority)
        self._editedStatus = State(initialValue: task.wrappedValue.status)
        self._editedStartDate = State(initialValue: task.wrappedValue.startDate)
        self._editedEndDate = State(initialValue: task.wrappedValue.endDate)
        
        // Find the current project
        if let projectId = task.wrappedValue.projectId {
            self._selectedProject = State(initialValue: projects.wrappedValue.first { $0.id == projectId })
        } else {
            self._selectedProject = State(initialValue: nil)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task Title", text: $editedTitle)
                    TextField("Description", text: $editedDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Project Assignment") {
                    Picker("Assign to Project", selection: $selectedProject) {
                        Text("Standalone Task").tag(Project?.none)
                        ForEach(projects) { project in
                            HStack {
                                Circle()
                                    .fill(project.color.color)
                                    .frame(width: 12, height: 12)
                                Text(project.name)
                            }.tag(Project?.some(project))
                        }
                    }
                }
                
                Section("Assignment") {
                    TextField("Assignees (comma separated)", text: $editedAssignees)
                    
                    Picker("Priority", selection: $editedPriority) {
                        ForEach(TaskItem.TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.color)
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }.tag(priority)
                        }
                    }
                    
                    Picker("Status", selection: $editedStatus) {
                        ForEach(TaskStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }
                
                Section("Timeline") {
                    DatePicker("Start Date", selection: $editedStartDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $editedEndDate, displayedComponents: .date)
                }
                
                Section("Task Info") {
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(task.createdAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    if task.completedAt != nil {
                        HStack {
                            Text("Completed")
                            Spacer()
                            Text(task.completedAt!, style: .date)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let projectId = task.projectId,
                       let project = projects.first(where: { $0.id == projectId }) {
                        HStack {
                            Text("Project")
                            Spacer()
                            HStack {
                                Circle()
                                    .fill(project.color.color)
                                    .frame(width: 12, height: 12)
                                Text(project.name)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
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
        task.title = editedTitle
        task.description = editedDescription
        task.assignees = editedAssignees.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        task.projectId = selectedProject?.id
        task.priority = editedPriority
        task.status = editedStatus
        task.startDate = editedStartDate
        task.endDate = editedEndDate
        
        if editedStatus == .completed && task.completedAt == nil {
            task.completedAt = Date()
        } else if editedStatus != .completed {
            task.completedAt = nil
        }
        
        isPresented = false
    }
}
