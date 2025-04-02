import SwiftUI

struct ChallengesView: View {
    @EnvironmentObject var moodData: MoodData
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: moodData.themes.first(where: { $0.name == moodData.selectedTheme })?.gradientColors.map { Color(hex: $0) } ?? [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ParticleEffectView()
            
            ForEach(0..<5) { _ in
                FloatingBall()
            }
            
            VStack {
                Text("Mood Challenges")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                ScrollView {
                    ForEach(moodData.challenges) { challenge in
                        HStack {
                            Circle()
                                .fill(challenge.isCompleted ? Color(hex: "#FFD700") : Color.gray.opacity(0.5))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: challenge.isCompleted ? "checkmark.circle.fill" : "circle.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 25))
                                )
                                .shadow(radius: 5)
                            
                            VStack(alignment: .leading) {
                                Text(challenge.name)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                Text(challenge.description)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Progress: \(challenge.progress)/\(challenge.goal)")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                                if challenge.isCompleted {
                                    Text("Reward: \(challenge.rewardPoints) points")
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

struct ChallengesView_Previews: PreviewProvider {
    static var previews: some View {
        ChallengesView()
            .environmentObject(MoodData())
    }
}
