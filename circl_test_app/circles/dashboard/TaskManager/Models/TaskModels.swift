//
//  TaskModels.swift
//  circl_test_app
//
//  Created on 11/2/2025.
//

import Foundation
import SwiftUI

// MARK: - Task Status Enum
enum TaskStatus: String, CaseIterable, Identifiable, Codable {
    case notStarted = "Not Started"
    case inProgress = "In Progress"
    case paused = "Paused"
    case blocked = "Blocked"
    case completed = "Completed"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .notStarted: return .gray
        case .inProgress: return .blue
        case .paused: return .orange
        case .blocked: return .red
        case .completed: return .green
        }
    }
}

// MARK: - Project Model
struct Project: Identifiable, Codable, Hashable {
    var id: Int

    var name: String
    var description: String
    var color: ProjectColor
    var startDate: Date
    var endDate: Date
    var isCompleted: Bool = false
    var tasks: [TaskItem] = []
    var createdAt: Date = Date()
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Project, rhs: Project) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum ProjectColor: String, CaseIterable, Codable {
        case blue = "Blue"
        case green = "Green"
        case purple = "Purple"
        case orange = "Orange"
        case red = "Red"
        case teal = "Teal"
        
        var color: Color {
            switch self {
            case .blue: return .blue
            case .green: return .green
            case .purple: return .purple
            case .orange: return .orange
            case .red: return .red
            case .teal: return .teal
            }
        }
    }
    
    var completionPercentage: Double {
        guard !tasks.isEmpty else { return 0 }
        let completedTasks = tasks.filter { $0.status == .completed }.count
        return Double(completedTasks) / Double(tasks.count) * 100
    }
}

// MARK: - Task Item Model
struct TaskItem: Identifiable, Codable, Hashable {
    var id: Int
    var projectId: Int?

    var title: String
    var description: String
    var status: TaskStatus

    var assignees: [String]
    var startDate: Date
    var endDate: Date
    var priority: TaskPriority
    var createdAt: Date = Date()
    var completedAt: Date?
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TaskItem, rhs: TaskItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum TaskPriority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .yellow
            case .high: return .orange
            case .critical: return .red
            }
        }
    }
}
