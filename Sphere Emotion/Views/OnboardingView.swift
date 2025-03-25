import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var moodData: MoodData
    @State private var currentPage = 0
    
    let pages = [
        ("Welcome to Sphere Emotion!", "Track your mood every day with fun balls!", "smiley.fill"),
        ("Earn Points and Achievements", "Log your mood to earn points and unlock new designs!", "trophy.fill"),
        ("Explore Your Mood History", "View your mood calendar and statistics!", "calendar")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ForEach(0..<5) { _ in
                FloatingBall()
            }
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: pages[index].2)
                                        .foregroundColor(.white)
                                        .font(.system(size: 50))
                                )
                                .shadow(radius: 5)
                            
                            Text(pages[index].0)
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                                .multilineTextAlignment(.center)
                            
                            Text(pages[index].1)
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 400)
                
                Button(action: {
                    withAnimation(.linear(duration: 0.3)) {
                        if currentPage < pages.count - 1 {
                            currentPage += 1
                        } else {
                            moodData.hasSeenOnboarding = true
                            moodData.saveOnboardingStatus()
                        }
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(Color(hex: "#FFD700"))
                        )
                        .padding(.horizontal, 50)
                }
                .padding(.bottom, 50)
                
                Spacer()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(MoodData())
    }
}
