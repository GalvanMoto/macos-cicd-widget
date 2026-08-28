import SwiftUI

public struct EmptyStateView: View {
    @ObservedObject var authService: GitHubAuthService = .shared
    @ObservedObject var settings: AppSettings = .shared
    
    var onOpenSettings: () -> Void
    
    public var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                
                TablerIcon(.brandGithub, size: 24, color: .white.opacity(0.85))
            }
            
            VStack(spacing: 4) {
                Text(authService.account.isLoggedIn ? "No Workflow Runs Found" : "No GitHub Account Connected")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(authService.account.isLoggedIn 
                     ? "No recent GitHub Actions runs found for \(settings.repositoryFullName.isEmpty ? "selected repo" : settings.repositoryFullName)."
                     : "Sign in with `gh auth login` in Terminal or enter your repository in settings.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: 280)
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    authService.checkSystemGitHubStatus()
                }) {
                    HStack(spacing: 5) {
                        TablerIcon(.refresh, size: 12, color: .white, isSpinning: authService.isChecking)
                        Text(authService.isChecking ? "Checking..." : "Re-check CLI")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: onOpenSettings) {
                    HStack(spacing: 5) {
                        TablerIcon(.settings, size: 12, color: .white)
                        Text("Settings")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(red: 0.137, green: 0.525, blue: 0.212)) // GitHub Green
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}
