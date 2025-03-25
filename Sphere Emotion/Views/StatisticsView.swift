import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var moodData: MoodData
    
    var moodStats: [Mood: Int] {
        var stats: [Mood: Int] = [:]
        for mood in moodData.moods.values {
            stats[mood, default: 0] += 1
        }
        return stats
    }
    
    var mostFrequentMood: (Mood, Int)? {
        moodStats.max(by: { $0.value < $1.value })
    }
    
    var moodTrend: [Mood] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var trend: [Mood] = []
        for i in (0..<7).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today),
               let mood = moodData.moods[date] {
                trend.append(mood)
            }
        }
        return trend
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ForEach(0..<5) { _ in
                FloatingBall()
            }
            
            VStack {
                Text("Your Mood Statistics")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                ScrollView {
                    // Most Frequent Mood
                    if let (mood, count) = mostFrequentMood {
                        VStack {
                            Text("Most Frequent Mood")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Circle()
                                .fill(mood.uiColor)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: mood.icon)
                                        .foregroundColor(.white)
                                        .font(.system(size: 40))
                                )
                                .shadow(radius: 5)
                            
                            Text("\(mood.name): \(count) times")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.2))
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    
                    // Mood Trend
                    VStack {
                        Text("Mood Trend (Last 7 Days)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        if moodTrend.isEmpty {
                            Text("No data available")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            HStack(spacing: 10) {
                                ForEach(moodTrend) { mood in
                                    Circle()
                                        .fill(mood.uiColor)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: mood.icon)
                                                .foregroundColor(.white)
                                                .font(.system(size: 20))
                                        )
                                        .shadow(radius: 5)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.2))
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    // Mood Constellation
                    Text("Mood Constellation")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ZStack {
                        ForEach(Array(moodStats.keys)) { mood in
                            if let count = moodStats[mood] {
                                Circle()
                                    .fill(mood.uiColor)
                                    .frame(width: CGFloat(count * 20), height: CGFloat(count * 20))
                                    .overlay(
                                        Image(systemName: mood.icon)
                                            .foregroundColor(.white)
                                            .font(.system(size: CGFloat(count * 10)))
                                    )
                                    .shadow(radius: 5)
                                    .position(
                                        CGPoint(
                                            x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                                            y: CGFloat.random(in: 100...UIScreen.main.bounds.height - 100)
                                        )
                                    )
                                    .scaleEffect(1.0)
                                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: UUID())
                            }
                        }
                    }
                    .frame(height: 300)
                }
                
                Spacer()
            }
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environmentObject(MoodData())
    }
}
