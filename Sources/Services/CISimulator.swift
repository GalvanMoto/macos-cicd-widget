import Foundation
import Combine

public class CISimulator: ObservableObject {
    public static let shared = CISimulator()
    
    @Published public var simulatedRun: WorkflowRun
    @Published public var isSimulating: Bool = true
    
    private var timer: Timer?
    private var currentStepIndex: Int = 2
    private var loopCounter: Int = 0
    
    private let sampleStepNames = [
        "Checkout Repository",
        "Set up Node & Toolchains",
        "Run ESLint & TypeCheck",
        "Execute Unit Test Suite",
        "Build Production Bundle",
        "Deploy to Kubernetes (Prod)"
    ]
    
    public init() {
        let now = Date()
        let initialSteps = [
            PipelineStep(id: "1", name: "Checkout Repository", status: .success, durationSeconds: 4),
            PipelineStep(id: "2", name: "Set up Node & Toolchains", status: .success, durationSeconds: 12),
            PipelineStep(id: "3", name: "Run ESLint & TypeCheck", status: .inProgress, durationSeconds: 18),
            PipelineStep(id: "4", name: "Execute Unit Test Suite", status: .queued, durationSeconds: 0),
            PipelineStep(id: "5", name: "Build Production Bundle", status: .queued, durationSeconds: 0),
            PipelineStep(id: "6", name: "Deploy to Kubernetes (Prod)", status: .queued, durationSeconds: 0)
        ]
        
        self.simulatedRun = WorkflowRun(
            id: 8849201,
            name: "Deploy • Stellar Engine",
            repositoryName: "supernova/quantum-core",
            branch: "feat/turbo-pipeline",
            commitSha: "89e1fa4c90d",
            commitMessage: "✨ Add GPU-accelerated raytracer shader pipeline",
            authorName: "Sarah Chen",
            authorAvatarURL: nil,
            status: .inProgress,
            htmlURL: URL(string: "https://github.com"),
            event: "push",
            runNumber: 1337,
            createdAt: now.addingTimeInterval(-48),
            updatedAt: now,
            startedAt: now.addingTimeInterval(-48),
            steps: initialSteps
        )
        
        startSimulation()
    }
    
    public func startSimulation() {
        timer?.invalidate()
        isSimulating = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            self?.tickSimulation()
        }
    }
    
    public func stopSimulation() {
        timer?.invalidate()
        timer = nil
        isSimulating = false
    }
    
    public func setSimulatedState(_ status: WorkflowStatus) {
        simulatedRun.status = status
        if status == .success {
            for i in 0..<simulatedRun.steps.count {
                simulatedRun.steps[i].status = .success
            }
        } else if status == .failure {
            for i in 0..<min(3, simulatedRun.steps.count) {
                simulatedRun.steps[i].status = .success
            }
            if simulatedRun.steps.indices.contains(3) {
                simulatedRun.steps[3].status = .failure
            }
            for i in 4..<simulatedRun.steps.count {
                simulatedRun.steps[i].status = .cancelled
            }
        } else if status == .queued {
            for i in 0..<simulatedRun.steps.count {
                simulatedRun.steps[i].status = .queued
            }
        } else if status == .inProgress {
            currentStepIndex = 1
            resetToInProgress()
        }
    }
    
    private func resetToInProgress() {
        let now = Date()
        simulatedRun.startedAt = now
        simulatedRun.status = .inProgress
        simulatedRun.runNumber += 1
        
        var newSteps: [PipelineStep] = []
        for (idx, name) in sampleStepNames.enumerated() {
            let s: WorkflowStatus = (idx == 0) ? .inProgress : .queued
            newSteps.append(PipelineStep(id: "\(idx+1)", name: name, status: s))
        }
        simulatedRun.steps = newSteps
        currentStepIndex = 0
    }
    
    private func tickSimulation() {
        guard isSimulating else { return }
        
        if simulatedRun.status != .inProgress {
            loopCounter += 1
            if loopCounter > 2 {
                loopCounter = 0
                resetToInProgress()
            }
            return
        }
        
        if currentStepIndex < simulatedRun.steps.count {
            simulatedRun.steps[currentStepIndex].status = .success
            currentStepIndex += 1
            
            if currentStepIndex < simulatedRun.steps.count {
                simulatedRun.steps[currentStepIndex].status = .inProgress
            } else {
                simulatedRun.status = .success
            }
        }
    }
}
