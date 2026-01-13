//
//  KanbanComponents.swift
//  circl_test_app
//
//  Created on 11/2/2025.
//

import Foundation
import SwiftUI

// MARK: - Kanban Board View
struct KanbanBoardView: View {
    let tasks: [TaskItem]
    @Binding var standaloneTasks: [TaskItem]
    @Binding var projects: [Project]
    @Binding var selectedTask: TaskItem?
    @Binding var showTaskDetails: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(TaskStatus.allCases) { status in
                    KanbanColumnView(
                        status: status,
                        tasks: tasks.filter { $0.status == status },
                        standaloneTasks: $standaloneTasks,
                        projects: $projects,
                        selectedTask: $selectedTask,
                        showTaskDetails: $showTaskDetails
                    )
                    .frame(width: 280)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Kanban Column View
struct KanbanColumnView: View {
    let status: TaskStatus
    let tasks: [TaskItem]
    @Binding var standaloneTasks: [TaskItem]
    @Binding var projects: [Project]
    @Binding var selectedTask: TaskItem?
    @Binding var showTaskDetails: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Column Header
            HStack {
                RoundedRectangle(cornerRadius: 3)
                    .fill(status.color)
                    .frame(width: 6, height: 16)
                
                Text(status.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(tasks.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }
            
            // Task Cards
            LazyVStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskCardView(
                        task: task,
                        projects: projects,
                        onTap: {
                            selectedTask = task
                            showTaskDetails = true
                        }
                    )
                    .onDrag {
                        NSItemProvider(object: task.id.uuidString as NSString)
                    }
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .onDrop(of: [.text], isTargeted: nil) { providers in
            handleDrop(providers: providers)
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.text", options: nil) { (item, error) in
                if let data = item as? Data,
                   let taskIdString = String(data: data, encoding: .utf8),
                   let taskId = UUID(uuidString: taskIdString) {
                    
                    DispatchQueue.main.async {
                        updateTaskStatus(taskId: taskId, newStatus: status)
                    }
                }
            }
        }
        return true
    }
    
    private func updateTaskStatus(taskId: UUID, newStatus: TaskStatus) {
        // Check standalone tasks
        if let index = standaloneTasks.firstIndex(where: { $0.id == taskId }) {
            standaloneTasks[index].status = newStatus
            return
        }
        
        // Check project tasks
        for projectIndex in projects.indices {
            if let taskIndex = projects[projectIndex].tasks.firstIndex(where: { $0.id == taskId }) {
                // Create a copy of the project to trigger SwiftUI update
                var updatedProject = projects[projectIndex]
                updatedProject.tasks[taskIndex].status = newStatus
                projects[projectIndex] = updatedProject
                return
            }
        }
    }
}

// MARK: - Task Card View
struct TaskCardView: View {
    let task: TaskItem
    let projects: [Project]
    let onTap: () -> Void
    
    private var associatedProject: Project? {
        guard let projectId = task.projectId else { return nil }
        return projects.first { $0.id == projectId }
    }
    
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
            }
            
            // Description
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Project tag
            if let project = associatedProject {
                HStack {
                    Circle()
                        .fill(project.color.color)
                        .frame(width: 8, height: 8)
                    
                    Text(project.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(project.color.color)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(project.color.color.opacity(0.1))
                .cornerRadius(4)
            } else {
                // Standalone task indicator
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Text("Standalone")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
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
