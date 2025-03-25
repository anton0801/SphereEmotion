import SwiftUI

@main
struct Sphere_EmotionApp: App {
    @StateObject private var moodData = MoodData()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(moodData)
        }
    }
}
