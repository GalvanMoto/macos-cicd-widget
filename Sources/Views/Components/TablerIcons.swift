import SwiftUI

public enum TablerIconType {
    case brandGithub
    case gitBranch
    case gitCommit
    case gitPullRequest
    case circleCheck
    case circleX
    case loader2
    case clock
    case alertTriangle
    case settings
    case refresh
    case externalLink
    case user
    case layers
    case check
    case terminal
}

public struct TablerIcon: View {
    public let type: TablerIconType
    public var size: CGFloat = 16
    public var color: Color = .primary
    public var strokeWidth: CGFloat = 2.0
    public var isSpinning: Bool = false
    
    @State private var spinAngle: Double = 0
    
    public init(_ type: TablerIconType, size: CGFloat = 16, color: Color = .primary, strokeWidth: CGFloat = 2.0, isSpinning: Bool = false) {
        self.type = type
        self.size = size
        self.color = color
        self.strokeWidth = strokeWidth
        self.isSpinning = isSpinning
    }
    
    public var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 24.0
            var path = Path()
            
            switch type {
            case .brandGithub:
                // Tabler Brand GitHub Octocat Shape 24x24
                path.move(to: CGPoint(x: 9, y: 19))
                path.addCurve(to: CGPoint(x: 3, y: 16), control1: CGPoint(x: 4.7, y: 20.4), control2: CGPoint(x: 4.7, y: 16.5))
                path.move(to: CGPoint(x: 16, y: 22))
                path.addLine(to: CGPoint(x: 16, y: 18.5))
                path.addCurve(to: CGPoint(x: 15.5, y: 16.5), control1: CGPoint(x: 16, y: 17.5), control2: CGPoint(x: 16.1, y: 17.1))
                path.addCurve(to: CGPoint(x: 21, y: 10.5), control1: CGPoint(x: 18.3, y: 16.2), control2: CGPoint(x: 21, y: 15.1))
                path.addCurve(to: CGPoint(x: 19.7, y: 7.3), control1: CGPoint(x: 21, y: 8.9), control2: CGPoint(x: 20.5, y: 7.8))
                path.addCurve(to: CGPoint(x: 19.6, y: 4.1), control1: CGPoint(x: 19.7, y: 6.5), control2: CGPoint(x: 19.7, y: 5.3))
                path.addCurve(to: CGPoint(x: 16.1, y: 5.4), control1: CGPoint(x: 18.5, y: 4.1), control2: CGPoint(x: 16.1, y: 5.4))
                path.addCurve(to: CGPoint(x: 9.9, y: 5.4), control1: CGPoint(x: 14.1, y: 4.8), control2: CGPoint(x: 11.9, y: 4.8))
                path.addCurve(to: CGPoint(x: 6.4, y: 4.1), control1: CGPoint(x: 9.9, y: 5.4), control2: CGPoint(x: 7.5, y: 4.1))
                path.addCurve(to: CGPoint(x: 6.3, y: 7.3), control1: CGPoint(x: 6.3, y: 5.3), control2: CGPoint(x: 6.3, y: 6.5))
                path.addCurve(to: CGPoint(x: 5, y: 10.5), control1: CGPoint(x: 5.5, y: 7.8), control2: CGPoint(x: 5, y: 8.9))
                path.addCurve(to: CGPoint(x: 10.5, y: 16.5), control1: CGPoint(x: 5, y: 15.1), control2: CGPoint(x: 7.7, y: 16.2))
                path.addCurve(to: CGPoint(x: 10, y: 18.5), control1: CGPoint(x: 9.9, y: 17.1), control2: CGPoint(x: 10, y: 17.5))
                path.addLine(to: CGPoint(x: 10, y: 22))
                
            case .gitBranch:
                path.addEllipse(in: CGRect(x: 5, y: 16, width: 4, height: 4))
                path.addEllipse(in: CGRect(x: 15, y: 4, width: 4, height: 4))
                path.addEllipse(in: CGRect(x: 5, y: 4, width: 4, height: 4))
                path.move(to: CGPoint(x: 7, y: 8))
                path.addLine(to: CGPoint(x: 7, y: 16))
                path.move(to: CGPoint(x: 7, y: 12))
                path.addCurve(to: CGPoint(x: 17, y: 8), control1: CGPoint(x: 7, y: 8), control2: CGPoint(x: 17, y: 12))
                
            case .gitCommit:
                path.addEllipse(in: CGRect(x: 9, y: 9, width: 6, height: 6))
                path.move(to: CGPoint(x: 3, y: 12))
                path.addLine(to: CGPoint(x: 9, y: 12))
                path.move(to: CGPoint(x: 15, y: 12))
                path.addLine(to: CGPoint(x: 21, y: 12))
                
            case .gitPullRequest:
                path.addEllipse(in: CGRect(x: 4, y: 16, width: 4, height: 4))
                path.addEllipse(in: CGRect(x: 4, y: 4, width: 4, height: 4))
                path.addEllipse(in: CGRect(x: 16, y: 16, width: 4, height: 4))
                path.move(to: CGPoint(x: 6, y: 8))
                path.addLine(to: CGPoint(x: 6, y: 16))
                path.move(to: CGPoint(x: 18, y: 16))
                path.addCurve(to: CGPoint(x: 6, y: 11), control1: CGPoint(x: 18, y: 11), control2: CGPoint(x: 12, y: 11))
                
            case .circleCheck:
                path.addEllipse(in: CGRect(x: 3, y: 3, width: 18, height: 18))
                path.move(to: CGPoint(x: 9, y: 12))
                path.addLine(to: CGPoint(x: 11, y: 14))
                path.addLine(to: CGPoint(x: 15, y: 10))
                
            case .circleX:
                path.addEllipse(in: CGRect(x: 3, y: 3, width: 18, height: 18))
                path.move(to: CGPoint(x: 10, y: 10))
                path.addLine(to: CGPoint(x: 14, y: 14))
                path.move(to: CGPoint(x: 14, y: 10))
                path.addLine(to: CGPoint(x: 10, y: 14))
                
            case .loader2:
                path.move(to: CGPoint(x: 12, y: 3))
                path.addArc(center: CGPoint(x: 12, y: 12), radius: 9, startAngle: .degrees(-90), endAngle: .degrees(180), clockwise: false)
                
            case .clock:
                path.addEllipse(in: CGRect(x: 3, y: 3, width: 18, height: 18))
                path.move(to: CGPoint(x: 12, y: 7))
                path.addLine(to: CGPoint(x: 12, y: 12))
                path.addLine(to: CGPoint(x: 15, y: 14))
                
            case .alertTriangle:
                path.move(to: CGPoint(x: 12, y: 4))
                path.addLine(to: CGPoint(x: 21, y: 19))
                path.addLine(to: CGPoint(x: 3, y: 19))
                path.closeSubpath()
                path.move(to: CGPoint(x: 12, y: 10))
                path.addLine(to: CGPoint(x: 12, y: 14))
                path.move(to: CGPoint(x: 12, y: 17))
                path.addLine(to: CGPoint(x: 12.01, y: 17))
                
            case .settings:
                path.addEllipse(in: CGRect(x: 9, y: 9, width: 6, height: 6))
                path.move(to: CGPoint(x: 10.3, y: 4.3))
                path.addLine(to: CGPoint(x: 13.7, y: 4.3))
                path.addLine(to: CGPoint(x: 14.3, y: 6.5))
                path.addLine(to: CGPoint(x: 16.3, y: 7.7))
                path.addLine(to: CGPoint(x: 18.5, y: 7.1))
                path.addLine(to: CGPoint(x: 20.2, y: 10.1))
                path.addLine(to: CGPoint(x: 18.6, y: 11.9))
                path.addLine(to: CGPoint(x: 18.6, y: 12.1))
                path.addLine(to: CGPoint(x: 20.2, y: 13.9))
                path.addLine(to: CGPoint(x: 18.5, y: 16.9))
                path.addLine(to: CGPoint(x: 16.3, y: 16.3))
                path.addLine(to: CGPoint(x: 14.3, y: 17.5))
                path.addLine(to: CGPoint(x: 13.7, y: 19.7))
                path.addLine(to: CGPoint(x: 10.3, y: 19.7))
                path.addLine(to: CGPoint(x: 9.7, y: 17.5))
                path.addLine(to: CGPoint(x: 7.7, y: 16.3))
                path.addLine(to: CGPoint(x: 5.5, y: 16.9))
                path.addLine(to: CGPoint(x: 3.8, y: 13.9))
                path.addLine(to: CGPoint(x: 5.4, y: 12.1))
                path.addLine(to: CGPoint(x: 5.4, y: 11.9))
                path.addLine(to: CGPoint(x: 3.8, y: 8.9))
                path.addLine(to: CGPoint(x: 5.5, y: 7.1))
                path.addLine(to: CGPoint(x: 7.7, y: 7.7))
                path.addLine(to: CGPoint(x: 9.7, y: 6.5))
                path.closeSubpath()
                
            case .refresh:
                path.move(to: CGPoint(x: 20, y: 11))
                path.addArc(center: CGPoint(x: 12, y: 12), radius: 8, startAngle: .degrees(-10), endAngle: .degrees(-190), clockwise: true)
                path.move(to: CGPoint(x: 4, y: 13))
                path.addArc(center: CGPoint(x: 12, y: 12), radius: 8, startAngle: .degrees(170), endAngle: .degrees(-10), clockwise: true)
                path.move(to: CGPoint(x: 20, y: 7))
                path.addLine(to: CGPoint(x: 20, y: 11))
                path.addLine(to: CGPoint(x: 16, y: 11))
                path.move(to: CGPoint(x: 4, y: 17))
                path.addLine(to: CGPoint(x: 4, y: 13))
                path.addLine(to: CGPoint(x: 8, y: 13))
                
            case .externalLink:
                path.move(to: CGPoint(x: 12, y: 6))
                path.addLine(to: CGPoint(x: 6, y: 6))
                path.addLine(to: CGPoint(x: 6, y: 18))
                path.addLine(to: CGPoint(x: 18, y: 18))
                path.addLine(to: CGPoint(x: 18, y: 12))
                path.move(to: CGPoint(x: 13, y: 5))
                path.addLine(to: CGPoint(x: 19, y: 5))
                path.addLine(to: CGPoint(x: 19, y: 11))
                path.move(to: CGPoint(x: 11, y: 13))
                path.addLine(to: CGPoint(x: 19, y: 5))
                
            case .user:
                path.addEllipse(in: CGRect(x: 8, y: 4, width: 8, height: 8))
                path.move(to: CGPoint(x: 6, y: 20))
                path.addCurve(to: CGPoint(x: 18, y: 20), control1: CGPoint(x: 6, y: 16), control2: CGPoint(x: 18, y: 16))
                
            case .layers:
                path.move(to: CGPoint(x: 12, y: 4))
                path.addLine(to: CGPoint(x: 20, y: 8))
                path.addLine(to: CGPoint(x: 12, y: 12))
                path.addLine(to: CGPoint(x: 4, y: 8))
                path.closeSubpath()
                path.move(to: CGPoint(x: 4, y: 12))
                path.addLine(to: CGPoint(x: 12, y: 16))
                path.addLine(to: CGPoint(x: 20, y: 12))
                path.move(to: CGPoint(x: 4, y: 16))
                path.addLine(to: CGPoint(x: 12, y: 20))
                path.addLine(to: CGPoint(x: 20, y: 16))
                
            case .check:
                path.move(to: CGPoint(x: 5, y: 12))
                path.addLine(to: CGPoint(x: 10, y: 17))
                path.addLine(to: CGPoint(x: 20, y: 7))
                
            case .terminal:
                path.move(to: CGPoint(x: 5, y: 7))
                path.addLine(to: CGPoint(x: 10, y: 12))
                path.addLine(to: CGPoint(x: 5, y: 17))
                path.move(to: CGPoint(x: 13, y: 17))
                path.addLine(to: CGPoint(x: 19, y: 17))
            }
            
            let transform = CGAffineTransform(scaleX: scale, y: scale)
            let scaledPath = path.applying(transform)
            
            context.stroke(
                scaledPath,
                with: .color(color),
                style: StrokeStyle(lineWidth: strokeWidth * scale, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(width: size, height: size)
        .rotationEffect(.degrees(isSpinning ? spinAngle : 0))
        .onAppear {
            if isSpinning {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    spinAngle = 360
                }
            }
        }
    }
}
