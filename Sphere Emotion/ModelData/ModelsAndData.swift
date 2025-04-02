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
    let note: String?
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

struct Theme: Identifiable, Codable {
    let id = UUID()
    let name: String
    let gradientColors: [String]
    let cost: Int
    var isUnlocked: Bool
}

struct RegistrationRequest: Codable {
    let email: String
    let phone: String
    let password: String
    let metod: String
}

// Модель для запроса на авторизацию
struct LoginRequest: Codable {
    let email: String
    let password: String
    let metod: String
}

// Модель для ответа от API
struct APIResponse: Codable {
    let success: String?
    let error: String?
}

//class MoodData: ObservableObject {
//    @Published var moods: [Date: Mood] = [:] {
//        didSet {
//            saveMoods()
//            updateStreak()
//            checkAchievements()
//            updateMoodPoints()
//        }
//    }
//    @Published var streak: Int = 0
//    @Published var moodPoints: Int = 0
//    @Published var achievements: [Achievement] = [
//        Achievement(name: "First Mood", description: "Log your first mood", isUnlocked: false, dateUnlocked: nil),
//        Achievement(name: "5-Day Streak", description: "Log moods for 5 days in a row", isUnlocked: false, dateUnlocked: nil),
//        Achievement(name: "Mood Explorer", description: "Use all 4 moods at least once", isUnlocked: false, dateUnlocked: nil)
//    ]
//    @Published var ballDesigns: [BallDesign] = [
//        BallDesign(name: "Default", cost: 0, isUnlocked: true),
//        BallDesign(name: "Glitter", cost: 50, isUnlocked: false),
//        BallDesign(name: "Neon", cost: 100, isUnlocked: false)
//    ]
//    @Published var selectedDesign: String = "Default"
//    @Published var customMoodColors: [String: String] = [
//        "Happy": "#FF69B4",
//        "Sad": "#8A2BE2",
//        "Excited": "#FFD700",
//        "Calm": "#DDA0DD"
//    ]
//    @Published var hasSeenOnboarding: Bool = false
//    @Published var lastRewardDate: Date? {
//        didSet {
//            UserDefaults.standard.set(lastRewardDate, forKey: "lastRewardDate")
//        }
//    }
//    @Published var dailyRewardClaimed: Bool = false
//    @Published var themes: [Theme] = [
//        Theme(name: "Cosmic Rose", gradientColors: ["#FF69B4", "#8A2BE2"], cost: 0, isUnlocked: true),
//        Theme(name: "Sunset Glow", gradientColors: ["#FF4500", "#FFD700"], cost: 100, isUnlocked: false),
//        Theme(name: "Ocean Breeze", gradientColors: ["#00CED1", "#4682B4"], cost: 100, isUnlocked: false),
//        Theme(name: "Forest Whisper", gradientColors: ["#228B22", "#90EE90"], cost: 150, isUnlocked: false)
//    ] {
//        didSet {
//            saveThemes()
//        }
//    }
//    @Published var selectedTheme: String = "Cosmic Rose"
//    
//    func unlockTheme(_ theme: Theme) {
//        if moodPoints >= theme.cost, let index = themes.firstIndex(where: { $0.id == theme.id }) {
//            moodPoints -= theme.cost
//            themes[index].isUnlocked = true
//            saveMoodPoints()
//            saveThemes()
//        }
//    }
//    
//    init() {
//        loadMoods()
//        loadAchievements()
//        loadBallDesigns()
//        loadMoodPoints()
//        loadCustomColors()
//        loadOnboardingStatus()
//        updateStreak()
//        checkAchievements()
//        lastRewardDate = UserDefaults.standard.object(forKey: "lastRewardDate") as? Date
//        checkDailyReward()
//    }
//    
//    private func checkDailyReward() {
//        let today = Calendar.current.startOfDay(for: Date())
//        if let lastDate = lastRewardDate, Calendar.current.isDate(lastDate, inSameDayAs: today) {
//            dailyRewardClaimed = true
//        } else {
//            dailyRewardClaimed = false
//        }
//    }
//    
//    func claimDailyReward() {
//        let today = Calendar.current.startOfDay(for: Date())
//        lastRewardDate = today
//        dailyRewardClaimed = true
//        moodPoints += 20 // Reward 20 points
//        saveMoodPoints()
//    }
//    
//    func saveMoods() {
//        let entries = moods.map { MoodEntry(date: $0.key, mood: $0.value) }
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(entries) {
//            UserDefaults.standard.set(encoded, forKey: "moods")
//        }
//    }
//    
//    func loadMoods() {
//        if let data = UserDefaults.standard.data(forKey: "moods"),
//           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
//            self.moods = Dictionary(uniqueKeysWithValues: decoded.map { ($0.date, $0.mood) })
//        }
//    }
//    
//    func saveAchievements() {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(achievements) {
//            UserDefaults.standard.set(encoded, forKey: "achievements")
//        }
//    }
//    
//    func loadAchievements() {
//        if let data = UserDefaults.standard.data(forKey: "achievements"),
//           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
//            self.achievements = decoded
//        }
//    }
//    
//    func saveBallDesigns() {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(ballDesigns) {
//            UserDefaults.standard.set(encoded, forKey: "ballDesigns")
//        }
//    }
//    
//    func loadBallDesigns() {
//        if let data = UserDefaults.standard.data(forKey: "ballDesigns"),
//           let decoded = try? JSONDecoder().decode([BallDesign].self, from: data) {
//            self.ballDesigns = decoded
//        }
//    }
//    
//    func saveMoodPoints() {
//        UserDefaults.standard.set(moodPoints, forKey: "moodPoints")
//    }
//    
//    func loadMoodPoints() {
//        moodPoints = UserDefaults.standard.integer(forKey: "moodPoints")
//    }
//    
//    func saveCustomColors() {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(customMoodColors) {
//            UserDefaults.standard.set(encoded, forKey: "customMoodColors")
//        }
//    }
//    
//    func loadCustomColors() {
//        if let data = UserDefaults.standard.data(forKey: "customMoodColors"),
//           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
//            self.customMoodColors = decoded
//        }
//    }
//    
//    func saveOnboardingStatus() {
//        UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
//    }
//    
//    func loadOnboardingStatus() {
//        hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
//    }
//    
//    func updateStreak() {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        var currentStreak = 0
//        var currentDate = today
//        
//        while moods[currentDate] != nil {
//            currentStreak += 1
//            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
//        }
//        
//        streak = currentStreak
//    }
//    
//    func updateMoodPoints() {
//        let today = Calendar.current.startOfDay(for: Date())
//        if moods[today] != nil {
//            moodPoints += 10 // 10 points per day
//            saveMoodPoints()
//        }
//    }
//    
//    func checkAchievements() {
//        var updatedAchievements = achievements
//        
//        // First Mood
//        if !moods.isEmpty && !updatedAchievements[0].isUnlocked {
//            updatedAchievements[0] = Achievement(
//                name: "First Mood",
//                description: "Log your first mood",
//                isUnlocked: true,
//                dateUnlocked: Date()
//            )
//        }
//        
//        // 5-Day Streak
//        if streak >= 5 && !updatedAchievements[1].isUnlocked {
//            updatedAchievements[1] = Achievement(
//                name: "5-Day Streak",
//                description: "Log moods for 5 days in a row",
//                isUnlocked: true,
//                dateUnlocked: Date()
//            )
//        }
//        
//        // Mood Explorer
//        let uniqueMoods = Set(moods.values.map { $0.name })
//        if uniqueMoods.count >= 4 && !updatedAchievements[2].isUnlocked {
//            updatedAchievements[2] = Achievement(
//                name: "Mood Explorer",
//                description: "Use all 4 moods at least once",
//                isUnlocked: true,
//                dateUnlocked: Date()
//            )
//        }
//        
//        achievements = updatedAchievements
//        saveAchievements()
//    }
//    
//    func unlockDesign(_ design: BallDesign) {
//        if moodPoints >= design.cost, let index = ballDesigns.firstIndex(where: { $0.id == design.id }) {
//            moodPoints -= design.cost
//            ballDesigns[index].isUnlocked = true
//            saveMoodPoints()
//            saveBallDesigns()
//        }
//    }
//}

struct Challenge: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let goal: Int
    var progress: Int
    let rewardPoints: Int
    var isCompleted: Bool
}

class MoodData: ObservableObject {
    // Вспомогательная структура для кодирования/декодирования
    private struct MoodEntryWrapper: Codable {
        let date: Date
        let entry: MoodEntry
    }
    
    @Published var moods: [Date: MoodEntry] = [:] {
        didSet {
            saveMoods()
            updateStreak()
            checkAchievements()
            updateMoodPoints()
            updateChallenges()
        }
    }
    @Published var streak: Int = 0
    @Published var moodPoints: Int = 0
    @Published var achievements: [Achievement] = [
        Achievement(name: "First Mood", description: "Log your first mood", isUnlocked: false, dateUnlocked: nil),
        Achievement(name: "5-Day Streak", description: "Log moods for 5 days in a row", isUnlocked: false, dateUnlocked: nil),
        Achievement(name: "Mood Explorer", description: "Use all 4 moods at least once", isUnlocked: false, dateUnlocked: nil)
    ]
    @Published var challenges: [Challenge] = [
        Challenge(name: "Happy Streak", description: "Be Happy for 5 days in a row", goal: 5, progress: 0, rewardPoints: 50, isCompleted: false),
        Challenge(name: "Mood Variety", description: "Use all 4 moods in a week", goal: 4, progress: 0, rewardPoints: 30, isCompleted: false)
    ]
    @Published var ballDesigns: [BallDesign] = [
        BallDesign(name: "Default", cost: 0, isUnlocked: true),
        BallDesign(name: "Glitter", cost: 50, isUnlocked: false),
        BallDesign(name: "Neon", cost: 100, isUnlocked: false)
    ]
    @Published var themes: [Theme] = [
        Theme(name: "Cosmic Rose", gradientColors: ["#FF69B4", "#8A2BE2"], cost: 0, isUnlocked: true),
        Theme(name: "Sunset Glow", gradientColors: ["#FF4500", "#FFD700"], cost: 100, isUnlocked: false),
        Theme(name: "Ocean Breeze", gradientColors: ["#00CED1", "#4682B4"], cost: 100, isUnlocked: false)
    ] {
        didSet {
            saveThemes()
        }
    }
    @Published var selectedDesign: String = "Default" {
        didSet {
            UserDefaults.standard.set(selectedDesign, forKey: "selectedDesign")
        }
    }
    @Published var selectedTheme: String = "Cosmic Rose" {
        didSet {
            UserDefaults.standard.set(selectedTheme, forKey: "selectedTheme")
        }
    }
    @Published var customMoodColors: [String: String] = [
        "Happy": "#FF69B4",
        "Sad": "#8A2BE2",
        "Excited": "#FFD700",
        "Calm": "#DDA0DD"
    ]
    @Published var hasSeenOnboarding: Bool = false
    @Published var lastRewardDate: Date?
    @Published var dailyRewardClaimed: Bool = false
    
    init() {
        loadMoods()
        loadAchievements()
        loadChallenges()
        loadBallDesigns()
        loadThemes()
        loadMoodPoints()
        loadCustomColors()
        loadOnboardingStatus()
        loadDailyReward()
        if let savedDesign = UserDefaults.standard.string(forKey: "selectedDesign") {
            selectedDesign = savedDesign
        }
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") {
            selectedTheme = savedTheme
        }
        updateStreak()
        checkAchievements()
        updateChallenges()
        checkDailyReward()
    }
    
    // Save and load methods for moods
    private func saveMoods() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let moodArray = moods.map { MoodEntryWrapper(date: $0.key, entry: $0.value) }
        if let encoded = try? encoder.encode(moodArray) {
            UserDefaults.standard.set(encoded, forKey: "moods")
        }
    }
    
    private func loadMoods() {
        if let data = UserDefaults.standard.data(forKey: "moods") {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode([MoodEntryWrapper].self, from: data) {
                self.moods = Dictionary(uniqueKeysWithValues: decoded.map { ($0.date, $0.entry) })
            }
        }
    }
    
    // Save and load methods for achievements
    private func saveAchievements() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: "achievements")
        }
    }
    
    private func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "achievements") {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let decoded = try? decoder.decode([Achievement].self, from: data) {
                self.achievements = decoded
            }
        }
    }
    
    // Save and load methods for challenges
    private func saveChallenges() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(challenges) {
            UserDefaults.standard.set(encoded, forKey: "challenges")
        }
    }
    
    private func loadChallenges() {
        if let data = UserDefaults.standard.data(forKey: "challenges"),
           let decoded = try? JSONDecoder().decode([Challenge].self, from: data) {
            self.challenges = decoded
        }
    }
    
    // Save and load methods for ball designs
    private func saveBallDesigns() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(ballDesigns) {
            UserDefaults.standard.set(encoded, forKey: "ballDesigns")
        }
    }
    
    private func loadBallDesigns() {
        if let data = UserDefaults.standard.data(forKey: "ballDesigns"),
           let decoded = try? JSONDecoder().decode([BallDesign].self, from: data) {
            self.ballDesigns = decoded
        }
    }
    
    // Save and load methods for themes
    private func saveThemes() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(themes) {
            UserDefaults.standard.set(encoded, forKey: "themes")
        }
    }
    
    private func loadThemes() {
        if let data = UserDefaults.standard.data(forKey: "themes"),
           let decoded = try? JSONDecoder().decode([Theme].self, from: data) {
            self.themes = decoded
        } else {
            self.themes = [
                Theme(name: "Cosmic Rose", gradientColors: ["#FF69B4", "#8A2BE2"], cost: 0, isUnlocked: true),
                Theme(name: "Sunset Glow", gradientColors: ["#FF4500", "#FFD700"], cost: 100, isUnlocked: false),
                Theme(name: "Ocean Breeze", gradientColors: ["#00CED1", "#4682B4"], cost: 100, isUnlocked: false)
            ]
        }
    }
    
    // Save and load methods for mood points
    private func saveMoodPoints() {
        UserDefaults.standard.set(moodPoints, forKey: "moodPoints")
    }
    
    private func loadMoodPoints() {
        moodPoints = UserDefaults.standard.integer(forKey: "moodPoints")
    }
    
    // Save and load methods for custom colors
    func saveCustomColors() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(customMoodColors) {
            UserDefaults.standard.set(encoded, forKey: "customMoodColors")
        }
    }
    
    private func loadCustomColors() {
        if let data = UserDefaults.standard.data(forKey: "customMoodColors"),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            self.customMoodColors = decoded
        }
    }
    
    // Save and load methods for onboarding status
    func saveOnboardingStatus() {
        UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
    }
    
    private func loadOnboardingStatus() {
        hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
    
    // Save and load methods for daily reward
    private func loadDailyReward() {
        lastRewardDate = UserDefaults.standard.object(forKey: "lastRewardDate") as? Date
    }
    
    private func checkDailyReward() {
        let today = Calendar.current.startOfDay(for: Date())
        if let lastDate = lastRewardDate, Calendar.current.isDate(lastDate, inSameDayAs: today) {
            dailyRewardClaimed = true
        } else {
            dailyRewardClaimed = false
        }
    }
    
    func claimDailyReward() {
        let today = Calendar.current.startOfDay(for: Date())
        lastRewardDate = today
        dailyRewardClaimed = true
        moodPoints += 20
        saveMoodPoints()
        UserDefaults.standard.set(lastRewardDate, forKey: "lastRewardDate")
    }
    
    // Update methods
    private func updateStreak() {
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
    
    private func updateMoodPoints() {
        let today = Calendar.current.startOfDay(for: Date())
        if moods[today] != nil {
            moodPoints += 10
            saveMoodPoints()
        }
    }
    
    private func checkAchievements() {
        var updatedAchievements = achievements
        
        if !moods.isEmpty && !updatedAchievements[0].isUnlocked {
            updatedAchievements[0] = Achievement(
                name: "First Mood",
                description: "Log your first mood",
                isUnlocked: true,
                dateUnlocked: Date()
            )
        }
        
        if streak >= 5 && !updatedAchievements[1].isUnlocked {
            updatedAchievements[1] = Achievement(
                name: "5-Day Streak",
                description: "Log moods for 5 days in a row",
                isUnlocked: true,
                dateUnlocked: Date()
            )
        }
        
        let uniqueMoods = Set(moods.values.map { $0.mood.name })
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
    
    private func updateChallenges() {
        var updatedChallenges = challenges
        
        // Happy Streak
        var happyStreak = 0
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var currentDate = today
        while let entry = moods[currentDate], entry.mood.name == "Happy" {
            happyStreak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        updatedChallenges[0].progress = happyStreak
        if happyStreak >= updatedChallenges[0].goal && !updatedChallenges[0].isCompleted {
            updatedChallenges[0].isCompleted = true
            moodPoints += updatedChallenges[0].rewardPoints
            saveMoodPoints()
        }
        
        // Mood Variety
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today)!
        let recentMoods = moods.filter { $0.key >= weekAgo }.values.map { $0.mood.name }
        let uniqueRecentMoods = Set(recentMoods)
        updatedChallenges[1].progress = uniqueRecentMoods.count
        if uniqueRecentMoods.count >= updatedChallenges[1].goal && !updatedChallenges[1].isCompleted {
            updatedChallenges[1].isCompleted = true
            moodPoints += updatedChallenges[1].rewardPoints
            saveMoodPoints()
        }
        
        challenges = updatedChallenges
        saveChallenges()
    }
    
    func unlockDesign(_ design: BallDesign) {
        if moodPoints >= design.cost, let index = ballDesigns.firstIndex(where: { $0.id == design.id }) {
            moodPoints -= design.cost
            ballDesigns[index].isUnlocked = true
            saveMoodPoints()
            saveBallDesigns()
        }
    }
    
    func unlockTheme(_ theme: Theme) {
        if moodPoints >= theme.cost, let index = themes.firstIndex(where: { $0.id == theme.id }) {
            moodPoints -= theme.cost
            themes[index].isUnlocked = true
            saveMoodPoints()
            saveThemes()
        }
    }
}
