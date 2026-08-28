import SwiftUI

public struct CompactWidgetView: View {
    public let run: WorkflowRun
    public let theme: WidgetTheme
    
    public var body: some View {
        HStack(spacing: 10) {
            PulsingGlowOrb(status: run.status, size: 26)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(run.repositoryName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text("#\(run.runNumber)")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(theme.accentColor)
                }
                
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        TablerIcon(.gitBranch, size: 10, color: .white.opacity(0.65))
                        Text(run.branch)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.75))
                            .lineLimit(1)
                    }
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.system(size: 9))
                    
                    Text(run.status.displayText)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(run.status.primaryColor)
                }
            }
            
            Spacer()
            
            LiveTimerView(startDate: run.startedAt, status: run.status)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
