import SwiftUI

public struct PulsingGlowOrb: View {
    public let status: WorkflowStatus
    public var size: CGFloat = 34
    
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6
    
    public init(status: WorkflowStatus, size: CGFloat = 34) {
        self.status = status
        self.size = size
    }
    
    private var tablerIconType: TablerIconType {
        switch status {
        case .inProgress: return .loader2
        case .success: return .circleCheck
        case .failure: return .circleX
        case .queued, .waiting: return .clock
        case .cancelled: return .alertTriangle
        }
    }
    
    public var body: some View {
        ZStack {
            if status.isRunning {
                // Subtle expanding ripple
                Circle()
                    .stroke(status.primaryColor.opacity(pulseOpacity * 0.35), lineWidth: 1.5)
                    .frame(width: size * 1.45 * pulseScale, height: size * 1.45 * pulseScale)
                
                // Rotating subtle gradient aura
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                status.primaryColor.opacity(0.0),
                                status.primaryColor.opacity(0.2),
                                status.primaryColor.opacity(0.5),
                                status.primaryColor.opacity(0.0)
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        )
                    )
                    .frame(width: size * 1.25, height: size * 1.25)
                    .rotationEffect(.degrees(rotationAngle))
            }
            
            // Solid Orb Core with GitHub / Apple styling
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            status.primaryColor,
                            status.primaryColor.opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: status.primaryColor.opacity(0.4), radius: status.isRunning ? 8 : 4)
            
            // Tabler Icon
            TablerIcon(
                tablerIconType,
                size: size * 0.52,
                color: .white,
                strokeWidth: 2.2,
                isSpinning: status == .inProgress
            )
        }
        .frame(width: size * 1.6, height: size * 1.6)
        .onAppear {
            if status.isRunning {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    pulseScale = 1.2
                    pulseOpacity = 0.05
                }
            }
        }
        .onChange(of: status) { newStatus in
            if newStatus.isRunning {
                withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                    rotationAngle = 360
                }
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    pulseScale = 1.2
                    pulseOpacity = 0.05
                }
            } else {
                rotationAngle = 0
                pulseScale = 1.0
                pulseOpacity = 0.6
            }
        }
    }
}
