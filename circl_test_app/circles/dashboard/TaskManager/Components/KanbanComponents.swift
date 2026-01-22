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
                        },
                        onChangeStatus: { newStatus in
                            persistTaskStatus(taskId: task.id, newStatus: newStatus)
                        }
                    )

                    .onDrag {
                        NSItemProvider(object: String(task.id) as NSString)

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
                   let taskId = Int(taskIdString)
 {
                    
                    DispatchQueue.main.async {
                        updateTaskStatus(taskId: taskId, newStatus: status)
                    }
                }
            }
        }
        return true
    }
    
    private func updateTaskStatus(taskId: Int, newStatus: TaskStatus)
 {
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
    
    private func persistTaskStatus(taskId: Int, newStatus: TaskStatus) {
        Task {
            do {
                let url = URL(string: "\(baseURL)circles/kanban/tasks/\(taskId)/status/")!
                
                let body: [String: Any] = [
                    "status": newStatus.rawValue
                ]
                
                let updated: TaskItem = try await patchJSON(url, body: body)

                await MainActor.run {
                    // standalone
                    if let index = standaloneTasks.firstIndex(where: { $0.id == taskId }) {
                        standaloneTasks[index] = updated
                        return
                    }

                    // project task
                    for projectIndex in projects.indices {
                        if let taskIndex = projects[projectIndex].tasks.firstIndex(where: { $0.id == taskId }) {
                            var updatedProject = projects[projectIndex]
                            updatedProject.tasks[taskIndex] = updated
                            projects[projectIndex] = updatedProject
                            return
                        }
                    }
                }
            } catch {
                print("❌ Failed to update task status:", error)
            }
        }
    }

}

// MARK: - Task Card View
// MARK: - Task Card View
struct TaskCardView: View {
    let task: TaskItem
    let projects: [Project]
    let onTap: () -> Void
    let onChangeStatus: (TaskStatus) -> Void

    private var associatedProject: Project? {
        guard let projectId = task.projectId else { return nil }
        return projects.first { $0.id == projectId }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Title row + ellipsis
            HStack {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 8, height: 8)

                Text(task.title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)

                Spacer()

                Menu {
                    ForEach(TaskStatus.allCases) { status in
                        Button {
                            onChangeStatus(status)
                        } label: {
                            Label(status.rawValue, systemImage: iconForStatus(status))
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
            }

            if !task.description.isEmpty {
                Text(task.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            if let project = associatedProject {
                Text(project.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(project.color.color)
                    .padding(4)
                    .background(project.color.color.opacity(0.1))
                    .cornerRadius(4)
            }

            Spacer(minLength: 4)

            Text(task.endDate, style: .date)
                .font(.system(size: 10))
                .foregroundColor(task.endDate < Date() ? .red : .secondary)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 2)
        .onTapGesture { onTap() }
    }

    private func iconForStatus(_ status: TaskStatus) -> String {
        switch status {
        case .notStarted: return "circle"
        case .inProgress: return "play.circle"
        case .paused: return "pause.circle"
        case .blocked: return "exclamationmark.triangle"
        case .completed: return "checkmark.circle"
        }
    }
}
// MARK: - Simple PATCH helper
func patchJSON<T: Decodable>(_ url: URL, body: [String: Any]) async throws -> T {
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    request.httpBody = try JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: request)

    if let http = response as? HTTPURLResponse {
        print("✅ PATCH \(url.absoluteString) → \(http.statusCode)")
    }

    if let raw = String(data: data, encoding: .utf8) {
        print("⬇️ PATCH RAW RESPONSE:\n\(raw)")
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(T.self, from: data)
}
