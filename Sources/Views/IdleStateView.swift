import SwiftUI
import AppKit

public struct IdleStateView: View {
    public let lastRun: WorkflowRun?
    public let recentPush: RecentPushInfo?
    public let username: String
    
    public init(lastRun: WorkflowRun? = nil, recentPush: RecentPushInfo? = nil, username: String = "GalvanMoto") {
        self.lastRun = lastRun
        self.recentPush = recentPush
        self.username = username
    }
    
    private var hasActivePush: Bool {
        recentPush?.isVeryRecent == true
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            if hasActivePush, let push = recentPush {
                // Active Push Detected State
                ZStack {
                    Circle()
                        .fill(Color.cyan.opacity(0.15))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color.cyan.opacity(0.6), lineWidth: 1.5)
                        )
                        .shadow(color: Color.cyan.opacity(0.4), radius: 8)
                    
                    TablerIcon(.gitBranch, size: 20, color: .cyan)
                }
                
                VStack(spacing: 2) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.cyan)
                            .frame(width: 6, height: 6)
                        
                        Text("Active Push: \(push.repositoryName.components(separatedBy: "/").last ?? push.repositoryName)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    Text("Pushed to \(push.branch) • Triggering CI/CD Actions...")
                        .font(.system(size: 10.5))
                        .foregroundColor(.cyan.opacity(0.9))
                }
            } else {
                // Ambient GitHub Octocat Badge
                ZStack {
                    Circle()
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.8))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle()
                                .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
                        )
                    
                    TablerIcon(.brandGithub, size: 24, color: .primary)
                    
                    // Small green dot for active monitoring
                    Circle()
                        .fill(Color(red: 0.137, green: 0.525, blue: 0.212))
                        .frame(width: 8, height: 8)
                        .offset(x: 15, y: 15)
                        .overlay(
                            Circle()
                                .stroke(Color(nsColor: .windowBackgroundColor), lineWidth: 1.5)
                                .offset(x: 15, y: 15)
                        )
                }
                
                VStack(spacing: 2) {
                    Text("No Active Actions")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Monitoring @\(username) • Ready for next push")
                        .font(.system(size: 10.5))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}
