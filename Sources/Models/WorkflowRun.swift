import Foundation
import SwiftUI

public enum WorkflowStatus: String, Codable, CaseIterable {
    case queued = "queued"
    case inProgress = "in_progress"
    case success = "success"
    case failure = "failure"
    case cancelled = "cancelled"
    case waiting = "waiting"
    
    public var displayText: String {
        switch self {
        case .queued: return "Queued"
        case .inProgress: return "In Progress"
        case .success: return "Passed"
        case .failure: return "Failed"
        case .cancelled: return "Cancelled"
        case .waiting: return "Waiting"
        }
    }
    
    public var primaryColor: Color {
        switch self {
        case .queued: return Color(red: 0.545, green: 0.580, blue: 0.620) // #8b949e
        case .inProgress: return Color(red: 0.824, green: 0.600, blue: 0.133) // #d29922 (GitHub Yellow)
        case .success: return Color(red: 0.137, green: 0.525, blue: 0.212) // #238636 (GitHub Green)
        case .failure: return Color(red: 0.855, green: 0.212, blue: 0.200) // #da3633 (GitHub Red)
        case .cancelled: return Color(red: 0.431, green: 0.463, blue: 0.506) // #6e7681
        case .waiting: return Color(red: 0.824, green: 0.600, blue: 0.133)
        }
    }
    
    public var glowColor: Color {
        primaryColor.opacity(0.6)
    }
    
    public var isRunning: Bool {
        self == .inProgress || self == .queued || self == .waiting
    }
}

public struct PipelineStep: Identifiable, Codable, Equatable {
    public var id: String
    public var name: String
    public var status: WorkflowStatus
    public var durationSeconds: Int
    public var startedAt: Date?
    
    public init(id: String = UUID().uuidString, name: String, status: WorkflowStatus, durationSeconds: Int = 0, startedAt: Date? = nil) {
        self.id = id
        self.name = name
        self.status = status
        self.durationSeconds = durationSeconds
        self.startedAt = startedAt
    }
}

public struct WorkflowRun: Identifiable, Codable, Equatable {
    public var id: Int
    public var name: String
    public var repositoryName: String
    public var branch: String
    public var commitSha: String
    public var commitMessage: String
    public var authorName: String
    public var authorAvatarURL: URL?
    public var status: WorkflowStatus
    public var htmlURL: URL?
    public var event: String
    public var runNumber: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var startedAt: Date
    public var steps: [PipelineStep]
    
    public init(
        id: Int = 1001,
        name: String = "Deploy to Production",
        repositoryName: String = "GalvanMoto/Personal_OS",
        branch: String = "main",
        commitSha: String = "3315775",
        commitMessage: String = "feat(documents): integrate interactive AI Assistant chat sidebar",
        authorName: String = "GalvanMoto",
        authorAvatarURL: URL? = nil,
        status: WorkflowStatus = .inProgress,
        htmlURL: URL? = nil,
        event: String = "push",
        runNumber: Int = 412,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        startedAt: Date = Date().addingTimeInterval(-220),
        steps: [PipelineStep] = []
    ) {
        self.id = id
        self.name = name
        self.repositoryName = repositoryName
        self.branch = branch
        self.commitSha = commitSha
        self.commitMessage = commitMessage
        self.authorName = authorName
        self.authorAvatarURL = authorAvatarURL
        self.status = status
        self.htmlURL = htmlURL
        self.event = event
        self.runNumber = runNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.startedAt = startedAt
        self.steps = steps
    }
    
    public var shortSha: String {
        String(commitSha.prefix(7))
    }
}
