import SwiftUI

public struct DetailedWidgetView: View {
    public let run: WorkflowRun
    public let theme: WidgetTheme
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Main Top Bar: Status Orb + Run Title + Timer
            HStack(alignment: .center, spacing: 12) {
                PulsingGlowOrb(status: run.status, size: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(run.name)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("#\(run.runNumber)")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(theme.accentColor)
                    }
                    
                    HStack(spacing: 6) {
                        Text(run.status.displayText)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(run.status.primaryColor)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1.5)
                            .background(
                                Capsule()
                                    .fill(run.status.primaryColor.opacity(0.15))
                            )
                        
                        HStack(spacing: 3) {
                            TablerIcon(.gitPullRequest, size: 9, color: .white.opacity(0.5))
                            Text(run.event.capitalized)
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                Spacer()
                
                LiveTimerView(startDate: run.startedAt, status: run.status)
            }
            
            // Commit Box
            VStack(alignment: .leading, spacing: 5) {
                Text(run.commitMessage)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        TablerIcon(.gitBranch, size: 10, color: theme.accentColor)
                        Text(run.branch)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(theme.accentColor)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 4) {
                        TablerIcon(.gitCommit, size: 10, color: .white.opacity(0.5))
                        Text(run.shortSha)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.65))
                    }
                    
                    HStack(spacing: 4) {
                        TablerIcon(.user, size: 10, color: .white.opacity(0.5))
                        Text(run.authorName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(theme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.borderColor, lineWidth: 1)
                    )
            )
            
            // Pipeline steps if present
            if !run.steps.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        TablerIcon(.layers, size: 9, color: .white.opacity(0.45))
                        Text("PIPELINE")
                            .font(.system(size: 8.5, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                            .tracking(0.8)
                    }
                    
                    PipelineGraphView(steps: run.steps, accentColor: theme.accentColor)
                }
            }
        }
        .padding(12)
    }
}
