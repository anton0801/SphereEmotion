import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var moodData: MoodData
    
    var moodStats: [Mood: Int] {
        var stats: [Mood: Int] = [:]
        for mood in moodData.moods.values {
            stats[mood.mood, default: 0] += 1
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
               let mood = moodData.moods[date]?.mood {
                trend.append(mood)
            }
        }
        return trend
    }
    
    var moodTrendGraph: [MoodTrendPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var points: [MoodTrendPoint] = []
        for i in (0..<30).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: today),
               let entry = moodData.moods[date] {
                let moodValue: Double
                switch entry.mood.name {
                case "Happy": moodValue = 4
                case "Excited": moodValue = 3
                case "Calm": moodValue = 2
                case "Sad": moodValue = 1
                default: moodValue = 0
                }
                points.append(MoodTrendPoint(date: date, moodValue: moodValue))
            }
        }
        return points
    }
    
    var body: some View {
        ZStack {
            InteractiveBackground(touchParticles: .constant([]))
            
            VStack {
                Text("Your Mood Statistics")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                ScrollView {
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
                    
                    VStack {
                        Text("Mood Trend Graph (Last 30 Days)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        if moodTrendGraph.isEmpty {
                            Text("No data available")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        } else {
                            GeometryReader { geometry in
                                ZStack {
                                    // Grid lines
                                    ForEach(0..<5) { i in
                                        Path { path in
                                            let y = geometry.size.height * (1 - CGFloat(i) / 4)
                                            path.move(to: CGPoint(x: 0, y: y))
                                            path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                                        }
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    }
                                    
                                    // Mood trend line
                                    Path { path in
                                        let stepX = geometry.size.width / CGFloat(moodTrendGraph.count - 1)
                                        for (index, point) in moodTrendGraph.enumerated() {
                                            let x = stepX * CGFloat(index)
                                            let y = geometry.size.height * (1 - point.moodValue / 4)
                                            if index == 0 {
                                                path.move(to: CGPoint(x: x, y: y))
                                            } else {
                                                path.addLine(to: CGPoint(x: x, y: y))
                                            }
                                        }
                                    }
                                    .stroke(Color(hex: "#FFD700"), lineWidth: 2)
                                    
                                    // Points on the graph
                                    ForEach(moodTrendGraph) { point in
                                        let stepX = geometry.size.width / CGFloat(moodTrendGraph.count - 1)
                                        let index = moodTrendGraph.firstIndex(where: { $0.id == point.id })!
                                        let x = stepX * CGFloat(index)
                                        let y = geometry.size.height * (1 - point.moodValue / 4)
                                        Circle()
                                            .fill(Color(hex: "#FFD700"))
                                            .frame(width: 8, height: 8)
                                            .position(x: x, y: y)
                                    }
                                }
                            }
                            .frame(height: 200)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white.opacity(0.2))
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 10)
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

struct MoodTrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let moodValue: Double
}
