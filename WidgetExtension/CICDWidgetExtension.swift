import WidgetKit
import SwiftUI

public struct CICDTimelineEntry: TimelineEntry {
    public let date: Date
    public let run: WorkflowRun?
    public let repoName: String
    public let isLoggedIn: Bool
    
    public init(date: Date = Date(), run: WorkflowRun? = nil, repoName: String = "GalvanMoto/Personal_OS", isLoggedIn: Bool = true) {
        self.date = date
        self.run = run
        self.repoName = repoName
        self.isLoggedIn = isLoggedIn
    }
}

public struct CICDTimelineProvider: TimelineProvider {
    public func placeholder(in context: Context) -> CICDTimelineEntry {
        return CICDTimelineEntry(date: Date(), run: nil, repoName: "GalvanMoto/Personal_OS", isLoggedIn: true)
    }

    public func getSnapshot(in context: Context, completion: @escaping (CICDTimelineEntry) -> Void) {
        completion(placeholder(in: context))
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<CICDTimelineEntry>) -> Void) {
        let entry = placeholder(in: context)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date().addingTimeInterval(300)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

public struct CICDWidgetEntryView: View {
    public var entry: CICDTimelineEntry
    @Environment(\.widgetFamily) var family

    private var isBuilding: Bool {
        entry.run?.status.isRunning == true
    }

    public var body: some View {
        widgetContent
            .applyWidgetBackground()
    }
    
    @ViewBuilder
    private var widgetContent: some View {
        if isBuilding, let run = entry.run {
            switch family {
            case .systemSmall:
                SmallWidgetView(run: run)
            case .systemMedium:
                MediumWidgetView(run: run)
            case .systemLarge:
                LargeWidgetView(run: run)
            default:
                MediumWidgetView(run: run)
            }
        } else {
            WidgetIdleStateView(lastRun: entry.run, repoName: entry.repoName)
        }
    }
}

private extension View {
    @ViewBuilder
    func applyWidgetBackground() -> some View {
        if #available(macOS 14.0, *) {
            self.containerBackground(for: .widget) {
                Color(red: 0.051, green: 0.067, blue: 0.090) // GitHub Dark #0d1117
            }
        } else {
            self.background(
                Color(red: 0.051, green: 0.067, blue: 0.090)
            )
        }
    }
}

struct SmallWidgetView: View {
    let run: WorkflowRun

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TablerIcon(.brandGithub, size: 14, color: .white.opacity(0.85))
                Spacer()
                PulsingGlowOrb(status: run.status, size: 20)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 2) {
                Text(run.repositoryName.components(separatedBy: "/").last ?? run.repositoryName)
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    TablerIcon(.gitBranch, size: 9, color: .white.opacity(0.6))
                    Text(run.branch)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                }
            }
            
            HStack {
                Text(run.status.displayText)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(run.status.primaryColor)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill(run.status.primaryColor.opacity(0.18))
                    )
                Spacer()
                LiveTimerView(startDate: run.startedAt, status: run.status)
            }
        }
        .padding(10)
    }
}

struct MediumWidgetView: View {
    let run: WorkflowRun

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 8) {
                PulsingGlowOrb(status: run.status, size: 24)
                
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 4) {
                        Text(run.repositoryName)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Text("#\(run.runNumber)")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(red: 0.345, green: 0.651, blue: 1.0))
                    }
                    
                    HStack(spacing: 6) {
                        Text(run.status.displayText)
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(run.status.primaryColor)
                        
                        Text("•")
                            .foregroundColor(.white.opacity(0.3))
                            .font(.system(size: 8))
                        
                        HStack(spacing: 3) {
                            TablerIcon(.gitBranch, size: 9, color: .white.opacity(0.6))
                            Text(run.branch)
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                
                Spacer()
                
                LiveTimerView(startDate: run.startedAt, status: run.status)
            }
            
            // Commit Pill
            HStack(spacing: 6) {
                TablerIcon(.gitCommit, size: 10, color: .white.opacity(0.5))
                Text(run.commitMessage)
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
                
                Spacer()
                
                HStack(spacing: 3) {
                    TablerIcon(.user, size: 9, color: .white.opacity(0.5))
                    Text(run.authorName)
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.129, green: 0.149, blue: 0.176).opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(red: 0.188, green: 0.212, blue: 0.239), lineWidth: 1)
                    )
            )
            
            // Pipeline Graph
            if !run.steps.isEmpty {
                PipelineGraphView(steps: run.steps, accentColor: Color(red: 0.345, green: 0.651, blue: 1.0))
            }
        }
        .padding(12)
    }
}

struct LargeWidgetView: View {
    let run: WorkflowRun

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MediumWidgetView(run: run)
            
            Divider().background(Color.white.opacity(0.1))
            
            Text("WORKFLOW STEPS")
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .tracking(0.8)
            
            ForEach(run.steps.prefix(4)) { step in
                HStack {
                    TablerIcon(
                        step.status == .success ? .circleCheck : (step.status == .inProgress ? .loader2 : .clock),
                        size: 12,
                        color: step.status.primaryColor,
                        isSpinning: step.status == .inProgress
                    )
                    Text(step.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    Spacer()
                    Text(step.status.displayText)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(step.status.primaryColor)
                }
                .padding(.vertical, 2)
            }
            
            Spacer()
        }
        .padding(14)
    }
}

struct WidgetIdleStateView: View {
    let lastRun: WorkflowRun?
    let repoName: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.129, green: 0.149, blue: 0.176).opacity(0.6))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                TablerIcon(.brandGithub, size: 20, color: .white.opacity(0.9))
                
                Circle()
                    .fill(Color(red: 0.137, green: 0.525, blue: 0.212))
                    .frame(width: 7, height: 7)
                    .offset(x: 12, y: 12)
            }
            
            Text("No Active Actions")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
            
            Text("Waiting for next push...")
                .font(.system(size: 9.5))
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(12)
    }
}

@main
struct CICDWidgetBundle: WidgetBundle {
    var body: some Widget {
        CICDWidget()
    }
}

struct CICDWidget: Widget {
    let kind: String = "com.neonpulse.cicdwidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CICDTimelineProvider()) { entry in
            CICDWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("GitHub CI/CD")
        .description("Track latest workflow runs, active builds, and pipeline stages.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
