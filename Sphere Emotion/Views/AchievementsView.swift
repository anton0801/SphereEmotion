import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var moodData: MoodData
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ForEach(0..<5) { _ in
                FloatingBall()
            }
            
            VStack {
                Text("Achievements")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                ScrollView {
                    ForEach(moodData.achievements) { achievement in
                        HStack {
                            Circle()
                                .fill(achievement.isUnlocked ? Color(hex: "#FFD700") : Color.gray.opacity(0.5))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: achievement.isUnlocked ? "trophy.fill" : "lock.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 25))
                                )
                                .shadow(radius: 5)
                            
                            VStack(alignment: .leading) {
                                Text(achievement.name)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(achievement.description)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                if let dateUnlocked = achievement.dateUnlocked {
                                    Text("Unlocked on \(dateUnlocked, formatter: dateFormatter)")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.2))
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
                
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

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        AchievementsView()
            .environmentObject(MoodData())
    }
}
