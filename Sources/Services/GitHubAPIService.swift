import Foundation
import UserNotifications
import AppKit

public enum PushCIStatus: Equatable {
    case triggering
    case noWorkflowConfigured
    case synced
}

public struct RecentPushInfo: Equatable {
    public var id: String
    public var repositoryName: String
    public var pushedDate: Date
    public var branch: String
    public var ciStatus: PushCIStatus = .triggering
    public var displayedAt: Date = Date()
    
    public var isVeryRecent: Bool {
        Date().timeIntervalSince(displayedAt) < 180
    }
}

public class GitHubAPIService: ObservableObject {
    public static let shared = GitHubAPIService()
    
    @Published public var currentRun: WorkflowRun?
    @Published public var recentRuns: [WorkflowRun] = []
    @Published public var recentPush: RecentPushInfo?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var lastRefreshedAt: Date?
    
    private var timer: Timer?
    private var pushDismissTimer: Timer?
    private var lastObservedRunId: Int?
    private var lastObservedStatus: WorkflowStatus?
    private var lastSeenPushEventId: String?
    private var isFirstPoll: Bool = true
    
    private init() {
        requestNotificationPermission()
    }
    
    public func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in }
    }
    
    public func startPolling(settings: AppSettings) {
        stopPolling()
        refresh(settings: settings)
        
        // Fast 3.5-second polling for real-time push detection
        timer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !settings.isSimulatorEnabled {
                self.refresh(settings: settings)
            }
        }
    }
    
    public func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    public func refresh(settings: AppSettings) {
        var token = settings.githubToken.trimmingCharacters(in: .whitespacesAndNewlines)
        if token.isEmpty {
            token = GitHubAuthService.shared.account.token
        }
        
        // Fallback to gh CLI token
        if token.isEmpty {
            let ghPaths = ["/opt/homebrew/bin/gh", "/usr/local/bin/gh", "/usr/bin/gh"]
            for p in ghPaths {
                if FileManager.default.fileExists(atPath: p) {
                    let task = Process()
                    task.executableURL = URL(fileURLWithPath: p)
                    task.arguments = ["auth", "token"]
                    let pipe = Pipe()
                    task.standardOutput = pipe
                    if (try? task.run()) != nil {
                        task.waitUntilExit()
                        let data = pipe.fileHandleForReading.readDataToEndOfFile()
                        if let readTok = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !readTok.isEmpty {
                            token = readTok
                            settings.githubToken = readTok
                        }
                    }
                    break
                }
            }
        }
        
        isLoading = true
        let resolvedToken = token
        let username = !GitHubAuthService.shared.account.username.isEmpty ? GitHubAuthService.shared.account.username : settings.repoOwner
        
        Task { @MainActor in
            do {
                // 1. Check Real-Time Push Events via GitHub Events API
                if !resolvedToken.isEmpty && !username.isEmpty {
                    await self.checkRealtimePushEvents(username: username, token: resolvedToken)
                }
                
                // 2. Fetch Recent Workflow Runs
                var discoveredRuns: [WorkflowRun] = []
                if !resolvedToken.isEmpty {
                    discoveredRuns = await self.fetchRecentRunsAcrossAccount(token: resolvedToken)
                }
                
                // Fallback to specific repo in settings
                if discoveredRuns.isEmpty && !settings.repoOwner.isEmpty && !settings.repoName.isEmpty {
                    if let singleRun = await self.fetchRunForRepo(owner: settings.repoOwner, repo: settings.repoName, token: resolvedToken) {
                        discoveredRuns.append(singleRun)
                    }
                }
                
                if discoveredRuns.isEmpty {
                    self.currentRun = nil
                    self.isLoading = false
                    return
                }
                
                let chosenRun = discoveredRuns.first(where: { $0.status.isRunning }) ?? discoveredRuns.first!
                
                // Fetch job steps
                let parts = chosenRun.repositoryName.components(separatedBy: "/")
                var finalRun = chosenRun
                if parts.count == 2 {
                    let steps = await self.fetchJobsForRun(owner: parts[0], repo: parts[1], runId: chosenRun.id, token: resolvedToken)
                    finalRun.steps = steps
                }
                
                self.checkAndNotifyStatusChange(newRun: finalRun)
                
                self.currentRun = finalRun
                self.recentRuns = discoveredRuns
                self.errorMessage = nil
                self.lastRefreshedAt = Date()
                self.isLoading = false
            }
        }
    }
    
    // Real-Time GitHub Push Event Stream
    private func checkRealtimePushEvents(username: String, token: String) async {
        guard let url = URL(string: "https://api.github.com/users/\(username)/events?per_page=5") else { return }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("macOS-CICD-Widget/1.0", forHTTPHeaderField: "User-Agent")
        
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
              let events = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return
        }
        
        // Find latest PushEvent
        guard let latestPushEvent = events.first(where: { ($0["type"] as? String) == "PushEvent" }),
              let eventId = latestPushEvent["id"] as? String,
              let repoDict = latestPushEvent["repo"] as? [String: Any],
              let repoFullName = repoDict["name"] as? String else {
            return
        }
        
        let payload = latestPushEvent["payload"] as? [String: Any]
        let rawRef = payload?["ref"] as? String ?? "refs/heads/main"
        let branch = rawRef.replacingOccurrences(of: "refs/heads/", with: "")
        
        let createdAtStr = latestPushEvent["created_at"] as? String ?? ""
        let isoFormatter = ISO8601DateFormatter()
        let createdDate = isoFormatter.date(from: createdAtStr) ?? Date()
        
        if self.isFirstPoll {
            // Store baseline event on first poll
            self.lastSeenPushEventId = eventId
            self.isFirstPoll = false
            return
        }
        
        if let lastId = self.lastSeenPushEventId, lastId != eventId {
            // BRAND NEW PUSH DETECTED!
            self.lastSeenPushEventId = eventId
            
            let repoShort = repoFullName.components(separatedBy: "/").last ?? repoFullName
            let parts = repoFullName.components(separatedBy: "/")
            var ciStatus: PushCIStatus = .triggering
            
            if parts.count == 2 {
                let repoRuns = await self.fetchRunForRepo(owner: parts[0], repo: parts[1], token: token)
                if repoRuns == nil {
                    ciStatus = .noWorkflowConfigured
                    self.sendNotification(
                        title: "📦 Code Synced: \(repoShort)",
                        body: "Pushed to \(branch) • Latest commit is up to date"
                    )
                } else if repoRuns?.status.isRunning == true {
                    ciStatus = .triggering
                    self.sendNotification(
                        title: "🚀 Active Push: \(repoShort)",
                        body: "Pushed to \(branch) • GitHub Actions workflow triggered"
                    )
                } else {
                    ciStatus = .synced
                    self.sendNotification(
                        title: "📦 Code Synced: \(repoShort)",
                        body: "Pushed to \(branch) • Latest commit is up to date"
                    )
                }
            }
            
            let newPushInfo = RecentPushInfo(
                id: eventId,
                repositoryName: repoFullName,
                pushedDate: createdDate,
                branch: branch,
                ciStatus: ciStatus,
                displayedAt: Date()
            )
            
            self.recentPush = newPushInfo
            
            // Auto dismiss after 5 seconds
            self.pushDismissTimer?.invalidate()
            self.pushDismissTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
                DispatchQueue.main.async {
                    GitHubAPIService.shared.recentPush = nil
                }
            }
        }
    }
    
    private func fetchRecentRunsAcrossAccount(token: String) async -> [WorkflowRun] {
        guard let url = URL(string: "https://api.github.com/user/repos?sort=pushed&per_page=8") else { return [] }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("macOS-CICD-Widget/1.0", forHTTPHeaderField: "User-Agent")
        
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
              let repos = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        return await withTaskGroup(of: WorkflowRun?.self) { group in
            for r in repos {
                guard let fullName = r["full_name"] as? String else { continue }
                let parts = fullName.components(separatedBy: "/")
                guard parts.count == 2 else { continue }
                let owner = parts[0]
                let repo = parts[1]
                
                group.addTask {
                    return await self.fetchRunForRepo(owner: owner, repo: repo, token: token)
                }
            }
            
            var collected: [WorkflowRun] = []
            for await run in group {
                if let r = run {
                    collected.append(r)
                }
            }
            
            return collected.sorted { (r1, r2) in
                if r1.status.isRunning && !r2.status.isRunning { return true }
                if !r1.status.isRunning && r2.status.isRunning { return false }
                return r1.createdAt > r2.createdAt
            }
        }
    }
    
    private func fetchRunForRepo(owner: String, repo: String, token: String) async -> WorkflowRun? {
        guard let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/actions/runs?per_page=1") else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("macOS-CICD-Widget/1.0", forHTTPHeaderField: "User-Agent")
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let runs = json["workflow_runs"] as? [[String: Any]],
              let latest = runs.first else {
            return nil
        }
        
        let id = latest["id"] as? Int ?? 0
        let name = latest["name"] as? String ?? "GitHub Actions"
        let branch = latest["head_branch"] as? String ?? "main"
        let sha = latest["head_sha"] as? String ?? "0000000"
        let commitMessage = (latest["head_commit"] as? [String: Any])?["message"] as? String ?? "Update"
        let author = (latest["actor"] as? [String: Any])?["login"] as? String ?? "Developer"
        let avatarStr = (latest["actor"] as? [String: Any])?["avatar_url"] as? String
        let avatarURL = avatarStr != nil ? URL(string: avatarStr!) : nil
        let htmlUrlStr = latest["html_url"] as? String
        let htmlURL = htmlUrlStr != nil ? URL(string: htmlUrlStr!) : nil
        let event = latest["event"] as? String ?? "push"
        let runNumber = latest["run_number"] as? Int ?? 1
        
        let statusStr = latest["status"] as? String ?? "in_progress"
        let conclusionStr = latest["conclusion"] as? String
        
        let isoFormatter = ISO8601DateFormatter()
        let createdAtStr = latest["created_at"] as? String ?? ""
        let updatedAtStr = latest["updated_at"] as? String ?? ""
        let runStartedAtStr = latest["run_started_at"] as? String ?? createdAtStr
        
        let createdAt = isoFormatter.date(from: createdAtStr) ?? Date()
        let updatedAt = isoFormatter.date(from: updatedAtStr) ?? Date()
        let startedAt = isoFormatter.date(from: runStartedAtStr) ?? createdAt
        
        let status: WorkflowStatus
        if statusStr == "completed" {
            if conclusionStr == "success" {
                status = .success
            } else if conclusionStr == "cancelled" {
                status = .cancelled
            } else {
                status = .failure
            }
        } else if statusStr == "queued" {
            status = .queued
        } else if statusStr == "waiting" {
            status = .waiting
        } else {
            status = .inProgress
        }
        
        return WorkflowRun(
            id: id,
            name: name,
            repositoryName: "\(owner)/\(repo)",
            branch: branch,
            commitSha: sha,
            commitMessage: commitMessage.components(separatedBy: "\n").first ?? commitMessage,
            authorName: author,
            authorAvatarURL: avatarURL,
            status: status,
            htmlURL: htmlURL,
            event: event,
            runNumber: runNumber,
            createdAt: createdAt,
            updatedAt: updatedAt,
            startedAt: startedAt,
            steps: []
        )
    }
    
    private func fetchJobsForRun(owner: String, repo: String, runId: Int, token: String) async -> [PipelineStep] {
        guard let url = URL(string: "https://api.github.com/repos/\(owner)/\(repo)/actions/runs/\(runId)/jobs") else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.setValue("macOS-CICD-Widget/1.0", forHTTPHeaderField: "User-Agent")
        if !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                return []
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            guard let jobs = json?["jobs"] as? [[String: Any]] else { return [] }
            
            var allSteps: [PipelineStep] = []
            for job in jobs {
                if let rawSteps = job["steps"] as? [[String: Any]], !rawSteps.isEmpty {
                    for s in rawSteps {
                        let stepName = s["name"] as? String ?? "Step"
                        let sStatusStr = s["status"] as? String ?? "completed"
                        let sConclusionStr = s["conclusion"] as? String
                        
                        let stepStatus: WorkflowStatus
                        if sStatusStr == "completed" {
                            if sConclusionStr == "success" {
                                stepStatus = .success
                            } else if sConclusionStr == "cancelled" {
                                stepStatus = .cancelled
                            } else {
                                stepStatus = .failure
                            }
                        } else if sStatusStr == "in_progress" {
                            stepStatus = .inProgress
                        } else {
                            stepStatus = .queued
                        }
                        
                        allSteps.append(PipelineStep(
                            id: "\(s["number"] as? Int ?? UUID().hashValue)",
                            name: stepName,
                            status: stepStatus
                        ))
                    }
                } else {
                    let jobName = job["name"] as? String ?? "Job"
                    let jStatusStr = job["status"] as? String ?? "in_progress"
                    let jConclusionStr = job["conclusion"] as? String
                    
                    let jobStatus: WorkflowStatus
                    if jStatusStr == "completed" {
                        jobStatus = (jConclusionStr == "success") ? .success : .failure
                    } else {
                        jobStatus = .inProgress
                    }
                    
                    allSteps.append(PipelineStep(
                        id: "\(job["id"] as? Int ?? UUID().hashValue)",
                        name: jobName,
                        status: jobStatus
                    ))
                }
            }
            
            return allSteps
        } catch {
            return []
        }
    }
    
    public func sendNotification(title: String, body: String) {
        // 1. UNUserNotificationCenter
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        
        // 2. NSUserNotificationCenter
        DispatchQueue.main.async {
            let notif = NSUserNotification()
            notif.title = title
            notif.informativeText = body
            notif.soundName = NSUserNotificationDefaultSoundName
            NSUserNotificationCenter.default.deliver(notif)
        }
        
        // 3. Process osascript execution (works from non-sandboxed host app)
        let escapedTitle = title.replacingOccurrences(of: "\"", with: "\\\"")
        let escapedBody = body.replacingOccurrences(of: "\"", with: "\\\"")
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            task.arguments = ["-e", "display notification \"\(escapedBody)\" with title \"\(escapedTitle)\" sound name \"default\""]
            try? task.run()
        }
    }
    
    private func checkAndNotifyStatusChange(newRun: WorkflowRun) {
        guard let prevStatus = lastObservedStatus, let prevId = lastObservedRunId else {
            lastObservedRunId = newRun.id
            lastObservedStatus = newRun.status
            return
        }
        
        if prevId == newRun.id && prevStatus != newRun.status {
            let repoShort = newRun.repositoryName.components(separatedBy: "/").last ?? newRun.repositoryName
            if newRun.status == .success {
                sendNotification(
                    title: "✅ Build Passed: \(repoShort)",
                    body: "\(newRun.name) #\(newRun.runNumber) succeeded on \(newRun.branch)"
                )
            } else if newRun.status == .failure {
                sendNotification(
                    title: "❌ Build Failed: \(repoShort)",
                    body: "\(newRun.name) #\(newRun.runNumber) failed on \(newRun.branch)"
                )
            }
        }
        
        lastObservedRunId = newRun.id
        lastObservedStatus = newRun.status
    }
}
