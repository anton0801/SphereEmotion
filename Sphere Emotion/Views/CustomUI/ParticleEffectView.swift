import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}

struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
            }
        }
        .onAppear {
            // Запускаем таймер для добавления новых частиц
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                addParticle()
            }
        }
    }
    
    // Функция для добавления новой частицы
    private func addParticle() {
        let size = CGFloat.random(in: 2...5)
        let newParticle = Particle(
            position: CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                             y: CGFloat.random(in: 0...UIScreen.main.bounds.height)),
            size: size,
            opacity: Double.random(in: 0.2...0.5)
        )
        
        particles.append(newParticle)
        
        let index = particles.count - 1
        withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
            particles[index].position.x += CGFloat.random(in: -50...50)
            particles[index].position.y += CGFloat.random(in: -50...50)
            particles[index].opacity = Double.random(in: 0.1...0.5)
        }
        
        // Удаляем старые частицы, чтобы не перегружать память
        if particles.count > 50 {
            particles.removeFirst()
        }
    }
}

#Preview {
    ParticleEffectView()
}
