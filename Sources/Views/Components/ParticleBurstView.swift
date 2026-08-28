import SwiftUI

public struct ParticleItem: Identifiable {
    public let id = UUID()
    public var x: CGFloat
    public var y: CGFloat
    public var scale: CGFloat
    public var opacity: Double
    public var color: Color
    public var angle: Double
    public var speed: Double
}

public struct ParticleBurstView: View {
    public let triggerStatus: WorkflowStatus
    
    @State private var particles: [ParticleItem] = []
    @State private var timer: Timer?
    
    public init(triggerStatus: WorkflowStatus) {
        self.triggerStatus = triggerStatus
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: 6 * p.scale, height: 6 * p.scale)
                        .blur(radius: 0.5)
                        .position(x: p.x, y: p.y)
                        .opacity(p.opacity)
                }
            }
            .onAppear {
                spawnParticles(in: proxy.size)
            }
            .onChange(of: triggerStatus) { _ in
                spawnParticles(in: proxy.size)
            }
        }
    }
    
    private func spawnParticles(in size: CGSize) {
        guard triggerStatus == .success || triggerStatus == .failure else {
            particles = []
            return
        }
        
        let colors: [Color] = (triggerStatus == .success)
            ? [Color.green, Color.mint, Color.cyan, Color.white, Color.yellow]
            : [Color.red, Color.orange, Color.pink, Color.white]
        
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        var newParticles: [ParticleItem] = []
        for _ in 0..<35 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = Double.random(in: 25...90)
            let color = colors.randomElement() ?? .white
            newParticles.append(ParticleItem(
                x: centerX,
                y: centerY,
                scale: CGFloat.random(in: 0.6...1.8),
                opacity: 1.0,
                color: color,
                angle: angle,
                speed: speed
            ))
        }
        
        self.particles = newParticles
        
        withAnimation(.easeOut(duration: 1.2)) {
            for i in 0..<self.particles.count {
                let p = self.particles[i]
                self.particles[i].x = centerX + CGFloat(cos(p.angle) * p.speed * 2.2)
                self.particles[i].y = centerY + CGFloat(sin(p.angle) * p.speed * 2.2)
                self.particles[i].opacity = 0.0
                self.particles[i].scale = 0.2
            }
        }
    }
}
