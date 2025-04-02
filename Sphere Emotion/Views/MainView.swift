import SwiftUI
import UIKit

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var moodData: MoodData
    @State private var selectedMood: Mood?
    @State private var ballPosition: CGPoint = .zero
    @State private var showBallAnimation = false
    @State private var showConfetti = false
    @State private var touchParticles: [TouchParticle] = []
    
    @State private var showDailyReward = false
    
    var moods: [Mood] {
        [
            Mood(name: "Happy", color: moodData.customMoodColors["Happy"] ?? "#FF69B4", icon: "smiley.fill"),
            Mood(name: "Sad", color: moodData.customMoodColors["Sad"] ?? "#8A2BE2", icon: "drop.fill"),
            Mood(name: "Excited", color: moodData.customMoodColors["Excited"] ?? "#FFD700", icon: "star.fill"),
            Mood(name: "Calm", color: moodData.customMoodColors["Calm"] ?? "#DDA0DD", icon: "moon.fill")
        ]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                InteractiveBackground(touchParticles: $touchParticles)
                
                if showBallAnimation, let mood = selectedMood {
                    Circle()
                        .fill(mood.uiColor)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: mood.icon)
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        )
                        .position(ballPosition)
                        .onAppear {
                            withAnimation(.easeIn(duration: 2)) {
                                ballPosition.y = UIScreen.main.bounds.height
                            }
                        }
                }
                
                if showConfetti {
                    ConfettiView()
                }
                
                VStack {
                    HStack {
                        Text("Streak: \(moodData.streak) days")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color(hex: "#FFD700").opacity(0.3))
                                    .frame(width: 100, height: 100)
                            )
                            .shadow(radius: 5)
                        
                        Text("Points: \(moodData.moodPoints)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color(hex: "#FFD700").opacity(0.3))
                                    .frame(width: 100, height: 100)
                            )
                            .shadow(radius: 5)
                    }
                    .padding(.top, 50)
                    
                    Text("How do you feel today?")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding(.top, 20)
                    
                    // Mood selection
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(moods) { mood in
                                Button(action: {
//                                    selectedMood = mood
//                                    showBallAnimation = true
//                                    ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
//                                    // Save mood to calendar
//                                    let today = Calendar.current.startOfDay(for: Date())
//                                    let previousStreak = moodData.streak
//                                    moodData.moods[today] = mood
//                                    // Check for streak milestones
//                                    if moodData.streak > previousStreak && [3, 7, 14].contains(moodData.streak) {
//                                        showConfetti = true
//                                        let generator = UINotificationFeedbackGenerator()
//                                        generator.notificationOccurred(.success)
//                                    }
//                                    // Haptic feedback
//                                    let generator = UIImpactFeedbackGenerator(style: .medium)
//                                    generator.impactOccurred()
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                        showBallAnimation = false
//                                    }
                                }) {
                                    Circle()
                                        .fill(mood.uiColor)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Image(systemName: mood.icon)
                                                .foregroundColor(.white)
                                                .font(.system(size: 50))
                                        )
                                        .shadow(radius: 5, x: 0, y: 5)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                                .blur(radius: 5)
                                        ) // Glow effect
                                        .scaleEffect(selectedMood == mood && showBallAnimation ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: showBallAnimation)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            NavigationLink(destination: CalendarView()) {
                                Circle()
                                    .fill(Color(hex: "#8A2BE2"))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "calendar")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    )
                                    .shadow(radius: 5)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                            .blur(radius: 5)
                                    )
                            }
                            
                            NavigationLink(destination: StatisticsView()) {
                                Circle()
                                    .fill(Color(hex: "#FF69B4"))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "chart.pie.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    )
                                    .shadow(radius: 5)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                            .blur(radius: 5)
                                    )
                            }
                            
                            NavigationLink(destination: AchievementsView()) {
                                Circle()
                                    .fill(Color(hex: "#FFD700"))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "trophy.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    )
                                    .shadow(radius: 5)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                            .blur(radius: 5)
                                    )
                            }
                            
                            NavigationLink(destination: SettingsView()
                                .environmentObject(authViewModel)) {
                                Circle()
                                    .fill(Color(hex: "#DDA0DD"))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "gearshape.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    )
                                    .shadow(radius: 5)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                            .blur(radius: 5)
                                    )
                            }
                            
                            NavigationLink(destination: MoodPyramidView()) {
                                Circle()
                                    .fill(Color(hex: "#FF1493"))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "pyramid.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    )
                                    .shadow(radius: 5)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                            .blur(radius: 5)
                                    )
                            }
                            
                            NavigationLink(destination: MoodInsightsView()) {
                                Circle()
                                    .fill(Color(hex: "#00CED1"))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    )
                                    .shadow(radius: 5)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                            .blur(radius: 5)
                                    )
                            }
                            
                            NavigationLink(destination: MoodJournalView()) {
                                Circle()
                                    .fill(Color(hex: "#4682B4"))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "note.text")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    )
                                    .shadow(radius: 5)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                            .blur(radius: 5)
                                    )
                            }
                            
                            NavigationLink(destination: ChallengesView()) {
                                Circle()
                                    .fill(Color(hex: "#FF4500"))
                                    .frame(width: 70, height: 70)
                                    .overlay(
                                        Image(systemName: "flag.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 30))
                                    )
                                    .shadow(radius: 5)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.5), lineWidth: 3)
                                            .blur(radius: 5)
                                    )
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
                
                if showDailyReward {
                    DailyRewardView(showReward: $showDailyReward)
                }
                
            }
            .onAppear {
                if !moodData.dailyRewardClaimed {
                    showDailyReward = true
                }
            }
        }
    }
}


// Floating background ball
struct FloatingBall: View {
    @State private var position: CGPoint = .zero
    
    var body: some View {
        Circle()
            .fill(Color(hex: Bool.random() ? "#FF69B4" : "#8A2BE2").opacity(0.3))
            .frame(width: CGFloat.random(in: 20...50), height: CGFloat.random(in: 20...50))
            .position(position)
            .onAppear {
                position = CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                  y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
                withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                    position.x += CGFloat.random(in: -50...50)
                    position.y += CGFloat.random(in: -50...50)
                }
            }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
