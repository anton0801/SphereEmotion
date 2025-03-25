import SwiftUI

struct MoodPyramidView: View {
    @EnvironmentObject var moodData: MoodData
    @State private var reshuffleTrigger = false
    @State private var selectedMood: Mood? = nil
    @State private var showMoodCount = false
    @State private var appearAnimation = false
    
    // Статистика настроений
    var moodStats: [Mood: Int] {
        var stats: [Mood: Int] = [:]
        for mood in moodData.moods.values {
            stats[mood, default: 0] += 1
        }
        return stats
    }
    
    // Общее количество зафиксированных дней
    var totalDays: Int {
        moodStats.values.reduce(0, +)
    }
    
    // Процентное распределение настроений
    var moodPercentages: [Mood: Double] {
        var percentages: [Mood: Double] = [:]
        for (mood, count) in moodStats {
            percentages[mood] = totalDays > 0 ? (Double(count) / Double(totalDays)) * 100 : 0
        }
        return percentages
    }
    
    // Пирамида настроений
    var moodPyramid: [Mood?] {
        let totalSlots = 15 // 1 + 2 + 3 + 4 + 5
        let sortedMoods = moodStats.sorted { $0.value > $1.value }.flatMap { mood, count in
            Array(repeating: mood, count: count)
        }
        
        var pyramid: [Mood?] = sortedMoods
        while pyramid.count < totalSlots {
            pyramid.append(nil)
        }
        
        return Array(pyramid.prefix(totalSlots))
    }
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Плавающие частицы
            ParticleEffectView()
            
            // Плавающие шары на фоне
            ForEach(0..<5) { _ in
                FloatingBall()
            }
            
            // Основной контент
            VStack {
                Text("Mood Pyramid")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                // Общее количество дней
                Text("Total Days Tracked: \(totalDays)")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.vertical, 10)
                
                // Пирамида
                ZStack {
                    // Эффект свечения вокруг пирамиды
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .blur(radius: 20)
                        .frame(width: 300, height: 300)
                    
                    // Пирамида: 5 уровней (1, 2, 3, 4, 5 шаров)
                    VStack(spacing: 20) {
                        ForEach(0..<5) { level in
                            HStack(spacing: 20) {
                                Spacer()
                                ForEach(0...level, id: \.self) { index in
                                    let slotIndex = (level * (level + 1)) / 2 + index
                                    let mood = slotIndex < moodPyramid.count ? moodPyramid[slotIndex] : nil
                                    Button(action: {
                                        selectedMood = mood
                                        showMoodCount = true
                                    }) {
                                        Circle()
                                            .fill(mood?.uiColor ?? Color.gray.opacity(0.5))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: mood?.icon ?? "circle.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 20))
                                            )
                                            .shadow(radius: 5)
                                            .scaleEffect(appearAnimation ? 1 : 0)
                                            .animation(
                                                .spring(response: 0.5, dampingFraction: 0.6)
                                                .delay(Double(slotIndex) * 0.1),
                                                value: appearAnimation
                                            )
                                            .scaleEffect(reshuffleTrigger ? 0 : 1)
                                            .animation(
                                                .spring(response: 0.5, dampingFraction: 0.6)
                                                .delay(Double(slotIndex) * 0.1),
                                                value: reshuffleTrigger
                                            )
                                            .rotationEffect(.degrees(reshuffleTrigger ? 360 : 0))
                                            .animation(
                                                .easeInOut(duration: 1)
                                                .delay(Double(slotIndex) * 0.1),
                                                value: reshuffleTrigger
                                            )
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .onAppear {
                        appearAnimation = true
                    }
                }
                
                // Кнопка для перераспределения
                Button(action: {
                    reshuffleTrigger.toggle()
                }) {
                    Text("Reshuffle Pyramid")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color(hex: "#FFD700"))
                        )
                        .shadow(radius: 5)
                }
                .padding(.vertical, 20)
                
                // Процентное распределение настроений
                VStack {
                    Text("Mood Distribution")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    ForEach(moodStats.keys.sorted(by: { $0.name < $1.name }), id: \.self) { mood in
                        HStack {
                            Circle()
                                .fill(mood.uiColor)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Image(systemName: mood.icon)
                                        .foregroundColor(.white)
                                        .font(.system(size: 10))
                                )
                            
                            Text("\(mood.name): \(String(format: "%.1f", moodPercentages[mood] ?? 0))% (\(moodStats[mood] ?? 0) days)")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.2))
                )
                .padding(.horizontal)
                
                Spacer()
            }
            
            // Всплывающее окно с количеством настроений
            if showMoodCount, let mood = selectedMood {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showMoodCount = false
                    }
                
                VStack {
                    Circle()
                        .fill(mood.uiColor)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: mood.icon)
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        )
                        .shadow(radius: 5)
                    
                    Text("\(mood.name)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Selected \(moodStats[mood] ?? 0) times")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Button(action: {
                        showMoodCount = false
                    }) {
                        Text("Close")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(Color(hex: "#FFD700"))
                            )
                    }
                    .padding(.top, 20)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                )
                .shadow(radius: 10)
            }
        }
    }
}

struct MoodPyramidView_Previews: PreviewProvider {
    static var previews: some View {
        MoodPyramidView()
            .environmentObject(MoodData())
    }
}
