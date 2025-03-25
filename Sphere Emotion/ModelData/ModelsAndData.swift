import SwiftUI
import Foundation

struct Mood: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    var color: String // Store color as hex string
    let icon: String
    
    var uiColor: Color {
        Color(hex: color)
    }
}

struct MoodEntry: Codable {
    let date: Date
    let mood: Mood
}

// Achievement model
struct Achievement: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let isUnlocked: Bool
    let dateUnlocked: Date?
}

// Ball design model
struct BallDesign: Identifiable, Codable {
    let id = UUID()
    let name: String
    let cost: Int
    var isUnlocked: Bool
}

class MoodData: ObservableObject {
    @Published var moods: [Date: Mood] = [:] {
        didSet {
            saveMoods()
            updateStreak()
            checkAchievements()
            updateMoodPoints()
        }
    }
    @Published var streak: Int = 0
    @Published var moodPoints: Int = 0
    @Published var achievements: [Achievement] = [
        Achievement(name: "First Mood", description: "Log your first mood", isUnlocked: false, dateUnlocked: nil),
        Achievement(name: "5-Day Streak", description: "Log moods for 5 days in a row", isUnlocked: false, dateUnlocked: nil),
        Achievement(name: "Mood Explorer", description: "Use all 4 moods at least once", isUnlocked: false, dateUnlocked: nil)
    ]
    @Published var ballDesigns: [BallDesign] = [
        BallDesign(name: "Default", cost: 0, isUnlocked: true),
        BallDesign(name: "Glitter", cost: 50, isUnlocked: false),
        BallDesign(name: "Neon", cost: 100, isUnlocked: false)
    ]
    @Published var selectedDesign: String = "Default"
    @Published var customMoodColors: [String: String] = [
        "Happy": "#FF69B4",
        "Sad": "#8A2BE2",
        "Excited": "#FFD700",
        "Calm": "#DDA0DD"
    ]
    @Published var hasSeenOnboarding: Bool = false
    
    init() {
        loadMoods()
        loadAchievements()
        loadBallDesigns()
        loadMoodPoints()
        loadCustomColors()
        loadOnboardingStatus()
        updateStreak()
        checkAchievements()
    }
    
    func saveMoods() {
        let entries = moods.map { MoodEntry(date: $0.key, mood: $0.value) }
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: "moods")
        }
    }
    
    func loadMoods() {
        if let data = UserDefaults.standard.data(forKey: "moods"),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            self.moods = Dictionary(uniqueKeysWithValues: decoded.map { ($0.date, $0.mood) })
        }
    }
    
    func saveAchievements() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: "achievements")
        }
    }
    
    func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "achievements"),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            self.achievements = decoded
        }
    }
    
    func saveBallDesigns() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(ballDesigns) {
            UserDefaults.standard.set(encoded, forKey: "ballDesigns")
        }
    }
    
    func loadBallDesigns() {
        if let data = UserDefaults.standard.data(forKey: "ballDesigns"),
           let decoded = try? JSONDecoder().decode([BallDesign].self, from: data) {
            self.ballDesigns = decoded
        }
    }
    
    func saveMoodPoints() {
        UserDefaults.standard.set(moodPoints, forKey: "moodPoints")
    }
    
    func loadMoodPoints() {
        moodPoints = UserDefaults.standard.integer(forKey: "moodPoints")
    }
    
    func saveCustomColors() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(customMoodColors) {
            UserDefaults.standard.set(encoded, forKey: "customMoodColors")
        }
    }
    
    func loadCustomColors() {
        if let data = UserDefaults.standard.data(forKey: "customMoodColors"),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            self.customMoodColors = decoded
        }
    }
    
    func saveOnboardingStatus() {
        UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
    }
    
    func loadOnboardingStatus() {
        hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
    
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var currentStreak = 0
        var currentDate = today
        
        while moods[currentDate] != nil {
            currentStreak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        streak = currentStreak
    }
    
    func updateMoodPoints() {
        let today = Calendar.current.startOfDay(for: Date())
        if moods[today] != nil {
            moodPoints += 10 // 10 points per day
            saveMoodPoints()
        }
    }
    
    func checkAchievements() {
        var updatedAchievements = achievements
        
        // First Mood
        if !moods.isEmpty && !updatedAchievements[0].isUnlocked {
            updatedAchievements[0] = Achievement(
                name: "First Mood",
                description: "Log your first mood",
                isUnlocked: true,
                dateUnlocked: Date()
            )
        }
        
        // 5-Day Streak
        if streak >= 5 && !updatedAchievements[1].isUnlocked {
            updatedAchievements[1] = Achievement(
                name: "5-Day Streak",
                description: "Log moods for 5 days in a row",
                isUnlocked: true,
                dateUnlocked: Date()
            )
        }
        
        // Mood Explorer
        let uniqueMoods = Set(moods.values.map { $0.name })
        if uniqueMoods.count >= 4 && !updatedAchievements[2].isUnlocked {
            updatedAchievements[2] = Achievement(
                name: "Mood Explorer",
                description: "Use all 4 moods at least once",
                isUnlocked: true,
                dateUnlocked: Date()
            )
        }
        
        achievements = updatedAchievements
        saveAchievements()
    }
    
    func unlockDesign(_ design: BallDesign) {
        if moodPoints >= design.cost, let index = ballDesigns.firstIndex(where: { $0.id == design.id }) {
            moodPoints -= design.cost
            ballDesigns[index].isUnlocked = true
            saveMoodPoints()
            saveBallDesigns()
        }
    }
}
