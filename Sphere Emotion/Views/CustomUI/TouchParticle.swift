import SwiftUI

struct TouchParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
}

struct InteractiveBackground: View {
    @EnvironmentObject var moodData: MoodData
    @Binding var touchParticles: [TouchParticle]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: moodData.themes.first(where: { $0.name == moodData.selectedTheme })?.gradientColors.map { Color(hex: $0) } ?? [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            addTouchParticle(at: value.location)
                        }
                )
            
            ForEach(touchParticles) { particle in
                Circle()
                    .fill(particle.color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
            }
            
            ParticleEffectView()
            
            ForEach(0..<5) { _ in
                FloatingBall()
            }
        }
    }
    
    private func addTouchParticle(at location: CGPoint) {
        let size = CGFloat.random(in: 5...10)
        let colors = moodData.themes.first(where: { $0.name == moodData.selectedTheme })?.gradientColors.map { Color(hex: $0) } ?? [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]
        let particle = TouchParticle(
            position: location,
            size: size,
            color: colors.randomElement() ?? .white,
            opacity: 1.0
        )
        
        touchParticles.append(particle)
        
        let index = touchParticles.count - 1
        withAnimation(.easeOut(duration: 2)) {
            touchParticles[index].position.x += CGFloat.random(in: -50...50)
            touchParticles[index].position.y += CGFloat.random(in: -50...50)
            touchParticles[index].opacity = 0
        }
        
        if touchParticles.count > 50 {
            touchParticles.removeFirst()
        }
    }
}
