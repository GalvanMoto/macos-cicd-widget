import SwiftUI

public struct LiveTimerView: View {
    public let startDate: Date
    public let status: WorkflowStatus
    
    @State private var elapsedSeconds: Int = 0
    @State private var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    public init(startDate: Date, status: WorkflowStatus) {
        self.startDate = startDate
        self.status = status
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            TablerIcon(.clock, size: 11, color: status.primaryColor, strokeWidth: 2.0)
            
            Text(formattedDuration)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 3.5)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.3))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onAppear {
            updateElapsed()
        }
        .onReceive(timer) { _ in
            if status.isRunning {
                updateElapsed()
            }
        }
    }
    
    private func updateElapsed() {
        let diff = max(0, Int(Date().timeIntervalSince(startDate)))
        elapsedSeconds = diff
    }
    
    private var formattedDuration: String {
        let mins = elapsedSeconds / 60
        let secs = elapsedSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
