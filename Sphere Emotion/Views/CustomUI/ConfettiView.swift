import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var position: CGPoint
    var rotation: Angle
    var color: Color
}

struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: 10, height: 20)
                    .rotationEffect(piece.rotation)
                    .position(piece.position)
            }
        }
        .onAppear {
            for _ in 0..<50 {
                let piece = ConfettiPiece(
                    position: CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                     y: -20),
                    rotation: Angle(degrees: Double.random(in: 0...360)),
                    color: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2"), Color(hex: "#FFD700")].randomElement()!
                )
                pieces.append(piece)
                
                let index = pieces.count - 1
                withAnimation(.easeIn(duration: 2)) {
                    pieces[index].position.y = UIScreen.main.bounds.height + 20
                    pieces[index].rotation = Angle(degrees: Double.random(in: 0...720))
                }
            }
        }
    }
}

struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiView()
    }
}
