import SwiftUI

public struct PipelineGraphView: View {
    public let steps: [PipelineStep]
    public let accentColor: Color
    
    public init(steps: [PipelineStep], accentColor: Color) {
        self.steps = steps
        self.accentColor = accentColor
    }
    
    private func iconFor(status: WorkflowStatus) -> TablerIconType {
        switch status {
        case .inProgress: return .loader2
        case .success: return .circleCheck
        case .failure: return .circleX
        case .queued, .waiting: return .clock
        case .cancelled: return .alertTriangle
        }
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    HStack(spacing: 0) {
                        // Step Node Card
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(step.status.primaryColor.opacity(0.15))
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        Circle()
                                            .stroke(step.status.primaryColor.opacity(0.5), lineWidth: 1)
                                    )
                                
                                TablerIcon(
                                    iconFor(status: step.status),
                                    size: 13,
                                    color: step.status.primaryColor,
                                    strokeWidth: 2.0,
                                    isSpinning: step.status == .inProgress
                                )
                            }
                            
                            Text(step.name)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(1)
                                .frame(maxWidth: 95)
                            
                            Text(step.status.displayText)
                                .font(.system(size: 8.5, weight: .semibold))
                                .foregroundColor(step.status.primaryColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.04))
                        )
                        
                        // Connector Line between steps
                        if index < steps.count - 1 {
                            let nextStep = steps[index + 1]
                            let isLineActive = step.status == .success || step.status == .inProgress
                            
                            ZStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 18, height: 2)
                                
                                if isLineActive {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [step.status.primaryColor, nextStep.status.primaryColor],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: 18, height: 2)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
        }
    }
}
