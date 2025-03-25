import SwiftUI

struct MoodDetailView: View {
    let mood: Mood
    let date: Date
    @State private var note: String = ""
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ForEach(0..<5) { _ in
                FloatingBall()
            }
            
            VStack {
                Text("Mood on \(date, formatter: dateFormatter)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                Circle()
                    .fill(mood.uiColor) // Use uiColor instead of color
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: mood.icon)
                            .foregroundColor(.white)
                            .font(.system(size: 50))
                    )
                    .shadow(radius: 5)
                
                Text(mood.name)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                
                TextField("Add a note...", text: $note)
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding()
                
                Spacer()
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct MoodDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MoodDetailView(
            mood: Mood(name: "Happy", color: "#FF69B4", icon: "smiley.fill"),
            date: Date()
        )
    }
}
