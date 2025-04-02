import SwiftUI

struct Insight: Identifiable {
    let id = UUID()
    let message: String
    let suggestion: String
}

struct MoodInsightsView: View {
    @EnvironmentObject var moodData: MoodData
    
    var insights: [Insight] {
        var insights: [Insight] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate mood statistics
        let recentMoods = moodData.moods.filter { $0.key >= calendar.date(byAdding: .day, value: -7, to: today)! }
        let moodCounts = Dictionary(grouping: recentMoods.values, by: { $0.mood.name })
            .mapValues { $0.count }
        
        let happyCount = moodCounts["Happy"] ?? 0
        let sadCount = moodCounts["Sad"] ?? 0
        let excitedCount = moodCounts["Excited"] ?? 0
        let calmCount = moodCounts["Calm"] ?? 0
        
        // Insight 1: Frequent Happy
        if happyCount >= 5 {
            insights.append(Insight(message: "You've been Happy for \(happyCount) days this week!", suggestion: "Keep spreading positivity—maybe share your joy with a friend!"))
        }
        
        // Insight 2: Frequent Sad
        if sadCount >= 3 {
            insights.append(Insight(message: "You've felt Sad \(sadCount) times this week.", suggestion: "Try listening to some uplifting music or talking to a loved one."))
        }
        
        // Insight 3: Frequent Excited
        if excitedCount >= 4 {
            insights.append(Insight(message: "You're full of energy with \(excitedCount) Excited days!", suggestion: "Channel that energy into a fun activity like dancing or a workout."))
        }
        
        // Insight 4: Frequent Calm
        if calmCount >= 4 {
            insights.append(Insight(message: "You've been Calm for \(calmCount) days this week.", suggestion: "Enhance your relaxation with a meditation session or a warm bath."))
        }
        
        // Insight 5: Balanced Moods
        if happyCount > 0 && sadCount > 0 && excitedCount > 0 && calmCount > 0 {
            insights.append(Insight(message: "You've experienced all moods this week!", suggestion: "You're embracing a full emotional spectrum—keep exploring your feelings."))
        }
        
        // Insight 6: Long Happy Streak
//        if moodData.streak >= 5 && recentMoods.values.last?.mood.name == "Happy" {
//            insights.append(Insight(message: "You're on a \(moodData.streak)-day Happy streak!", suggestion: "Celebrate your positivity with a treat or a fun outing."))
//        }
        
        // Insight 7: Sad Streak
        var sadStreak = 0
        var currentDate = today
        while let entry = moodData.moods[currentDate], entry.mood.name == "Sad" {
            sadStreak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        if sadStreak >= 3 {
            insights.append(Insight(message: "You've been Sad for \(sadStreak) days in a row.", suggestion: "Consider journaling your thoughts or reaching out to a friend for support."))
        }
        
        // Insight 8: Calm Evenings (simulated)
        if calmCount >= 2 && Date().hour >= 18 {
            insights.append(Insight(message: "You often feel Calm in the evenings.", suggestion: "Try a relaxing evening routine like reading or sipping herbal tea."))
        }
        
        // Insight 9: Excited Mornings (simulated)
        if excitedCount >= 2 && Date().hour < 12 {
            insights.append(Insight(message: "You often feel Excited in the mornings!", suggestion: "Start your day with a productive task to make the most of your energy."))
        }
        
        // Insight 10: Mood Variety
        let uniqueMoods = Set(recentMoods.values.map { $0.mood.name })
        if uniqueMoods.count >= 3 {
            insights.append(Insight(message: "You've felt \(uniqueMoods.count) different moods this week.", suggestion: "Reflect on what’s been influencing your emotions—maybe write about it in your journal."))
        }
        
        // Insight 11: Low Activity
        if recentMoods.count < 3 {
            insights.append(Insight(message: "You haven't logged many moods this week.", suggestion: "Set a daily reminder to check in with your emotions—it can help you stay mindful!"))
        }
        
        // Insight 12: High Activity
        if recentMoods.count >= 7 {
            insights.append(Insight(message: "You've logged your mood every day this week!", suggestion: "Great job staying consistent—keep it up!"))
        }
        
        // Insight 13: Sad After Happy
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           let yesterdayMood = moodData.moods[yesterday]?.mood.name,
           let todayMood = moodData.moods[today]?.mood.name,
           yesterdayMood == "Happy" && todayMood == "Sad" {
            insights.append(Insight(message: "You felt Happy yesterday but Sad today.", suggestion: "It’s okay to have ups and downs—try a comforting activity like watching a favorite movie."))
        }
        
        // Insight 14: Calm After Excited
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           let yesterdayMood = moodData.moods[yesterday]?.mood.name,
           let todayMood = moodData.moods[today]?.mood.name,
           yesterdayMood == "Excited" && todayMood == "Calm" {
            insights.append(Insight(message: "You were Excited yesterday and Calm today.", suggestion: "Balance your energy with a grounding activity like yoga or a nature walk."))
        }
        
        // Insight 15: No Sad Days
        if sadCount == 0 && recentMoods.count >= 5 {
            insights.append(Insight(message: "You haven't felt Sad this week!", suggestion: "That’s amazing—keep nurturing your positive vibes!"))
        }
        
        return insights.isEmpty ? [Insight(message: "Not enough data to provide insights yet.", suggestion: "Keep logging your moods daily to get personalized suggestions!")] : insights
    }
    
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
                Text("Mood Insights")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                ScrollView {
                    ForEach(insights) { insight in
                        VStack(alignment: .leading) {
                            Text(insight.message)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text(insight.suggestion)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
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

extension Date {
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
}

#Preview {
    MoodInsightsView()
        .environmentObject(MoodData())
}
