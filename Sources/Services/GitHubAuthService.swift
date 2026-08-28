import Foundation
import Combine

public struct GitHubAccount: Equatable {
    public var username: String
    public var token: String
    public var isLoggedIn: Bool
    public var repos: [String]
    
    public init(username: String = "", token: String = "", isLoggedIn: Bool = false, repos: [String] = []) {
        self.username = username
        self.token = token
        self.isLoggedIn = isLoggedIn
        self.repos = repos
    }
}

public class GitHubAuthService: ObservableObject {
    public static let shared = GitHubAuthService()
    
    @Published public var account: GitHubAccount = GitHubAccount()
    @Published public var isChecking: Bool = false
    @Published public var detectionMessage: String = ""
    
    private init() {
        checkSystemGitHubStatus()
    }
    
    public func checkSystemGitHubStatus() {
        isChecking = true
        
        Task.detached {
            var username = ""
            var token = ""
            var loggedIn = false
            var foundRepos: [String] = []
            
            // 1. Check gh auth status & token
            let ghPaths = ["/opt/homebrew/bin/gh", "/usr/local/bin/gh", "/usr/bin/gh"]
            var ghExecutable: String? = nil
            for p in ghPaths {
                if FileManager.default.fileExists(atPath: p) {
                    ghExecutable = p
                    break
                }
            }
            
            if let gh = ghExecutable {
                // Get token
                let tokenProcess = Process()
                tokenProcess.executableURL = URL(fileURLWithPath: gh)
                tokenProcess.arguments = ["auth", "token"]
                let tokenPipe = Pipe()
                tokenProcess.standardOutput = tokenPipe
                
                if (try? tokenProcess.run()) != nil {
                    tokenProcess.waitUntilExit()
                    let data = tokenPipe.fileHandleForReading.readDataToEndOfFile()
                    if let rawToken = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !rawToken.isEmpty {
                        token = rawToken
                        loggedIn = true
                    }
                }
                
                // Get status / username
                let statusProcess = Process()
                statusProcess.executableURL = URL(fileURLWithPath: gh)
                statusProcess.arguments = ["auth", "status"]
                let statusPipe = Pipe()
                statusProcess.standardOutput = statusPipe
                statusProcess.standardError = statusPipe
                
                if (try? statusProcess.run()) != nil {
                    statusProcess.waitUntilExit()
                    let data = statusPipe.fileHandleForReading.readDataToEndOfFile()
                    if let statusStr = String(data: data, encoding: .utf8) {
                        // Look for "Logged in to github.com account (username)"
                        let lines = statusStr.components(separatedBy: "\n")
                        for line in lines {
                            if line.contains("Logged in to") && line.contains("account") {
                                let parts = line.components(separatedBy: "account ")
                                if parts.count > 1 {
                                    let candidate = parts[1].components(separatedBy: " ").first?.trimmingCharacters(in: .whitespaces) ?? ""
                                    if !candidate.isEmpty {
                                        username = candidate
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Fetch list of recent repos
                if loggedIn && !username.isEmpty {
                    let repoProcess = Process()
                    repoProcess.executableURL = URL(fileURLWithPath: gh)
                    repoProcess.arguments = ["repo", "list", username, "--limit", "10", "--json", "nameWithOwner"]
                    let repoPipe = Pipe()
                    repoProcess.standardOutput = repoPipe
                    
                    if (try? repoProcess.run()) != nil {
                        repoProcess.waitUntilExit()
                        let data = repoPipe.fileHandleForReading.readDataToEndOfFile()
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                            for item in json {
                                if let repoFullName = item["nameWithOwner"] as? String {
                                    foundRepos.append(repoFullName)
                                }
                            }
                        }
                    }
                }
            }
            
            // 2. Fallback to git config if needed
            if username.isEmpty {
                let gitProcess = Process()
                gitProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
                gitProcess.arguments = ["config", "--get", "github.user"]
                let gitPipe = Pipe()
                gitProcess.standardOutput = gitPipe
                if (try? gitProcess.run()) != nil {
                    gitProcess.waitUntilExit()
                    let data = gitPipe.fileHandleForReading.readDataToEndOfFile()
                    if let user = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !user.isEmpty {
                        username = user
                    }
                }
            }
            
            let finalUser = username
            let finalToken = token
            let finalLoggedIn = loggedIn
            let finalRepos = foundRepos
            
            await MainActor.run {
                self.account = GitHubAccount(
                    username: finalUser,
                    token: finalToken,
                    isLoggedIn: finalLoggedIn,
                    repos: finalRepos
                )
                
                if finalLoggedIn {
                    self.detectionMessage = "Connected to @\(finalUser)"
                    // If current app settings has no repo, use first discovered repo
                    if !finalRepos.isEmpty {
                        let activeRepo = finalRepos[0]
                        let parts = activeRepo.components(separatedBy: "/")
                        if parts.count == 2 {
                            if AppSettings.shared.repoOwner == "apple" || AppSettings.shared.repoOwner.isEmpty {
                                AppSettings.shared.repoOwner = parts[0]
                                AppSettings.shared.repoName = parts[1]
                            }
                        }
                    }
                    if !finalToken.isEmpty && AppSettings.shared.githubToken.isEmpty {
                        AppSettings.shared.githubToken = finalToken
                    }
                } else {
                    self.detectionMessage = "No GitHub CLI account detected"
                }
                self.isChecking = false
            }
        }
    }
}
