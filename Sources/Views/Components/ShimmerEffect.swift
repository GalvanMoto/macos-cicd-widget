import SwiftUI

public struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0
    public var active: Bool = true
    
    public func body(content: Content) -> some View {
        if active {
            content
                .overlay(
                    GeometryReader { geometry in
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.8)
                        .offset(x: phase * geometry.size.width * 2)
                        .blendMode(.screen)
                    }
                )
                .mask(content)
                .onAppear {
                    withAnimation(Animation.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                        phase = 1.0
                    }
                }
        } else {
            content
        }
    }
}

public extension View {
    func shimmer(active: Bool = true) -> some View {
        modifier(ShimmerModifier(active: active))
    }
}
