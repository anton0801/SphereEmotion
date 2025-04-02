import SwiftUI

struct SplashView: View {
    @StateObject var authViewModel = AuthViewModel()
    @EnvironmentObject var moodData: MoodData
    @State private var isCompleted = false
    @State private var balls: [Ball] = []
    @State private var timer: Timer?
    @State private var calledAutorization = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Rising balls animation
            ForEach(balls) { ball in
                Circle()
                    .fill(ball.color)
                    .frame(width: ball.size, height: ball.size)
                    .position(ball.position)
                    .shadow(radius: 5)
                    .opacity(ball.opacity)
                    .overlay(
                        Image(systemName: ball.icon)
                            .foregroundColor(.white)
                            .font(.system(size: ball.size / 2))
                    )
            }
            
            // App title and icon
            VStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#FFD700")]),
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "smiley.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 50))
                    )
                    .shadow(radius: 10)
                    .scaleEffect(isCompleted ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isCompleted)
                
                Text("Sphere Emotion")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
            }
        }
        .onAppear {
            // Start generating balls
            timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
                addBall()
            }
            
            // Simulate loading completion after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                // Speed up balls for transition
                if !calledAutorization {
                    authViewModel.login(email: UserDefaults.standard.string(forKey: "email") ?? "", password: UserDefaults.standard.string(forKey: "password") ?? "")
                }
                withAnimation(.linear(duration: 1)) {
                    for i in 0..<balls.count {
                        balls[i].position.y = -balls[i].size
                        balls[i].opacity = 0
                    }
                }
            }
        }
        .onDisappear {
            // Invalidate the timer when the view disappears
            timer?.invalidate()
            timer = nil
        }
        .fullScreenCover(isPresented: $authViewModel.finishedCall) {
            if authViewModel.shouldShowAlternativeView {
                MoodSphereView()
                    .environmentObject(moodData)
                    .environmentObject(authViewModel)
            } else {
                if authViewModel.isAuthenticated {
                    MainView()
                        .environmentObject(moodData)
                } else {
                    if moodData.hasSeenOnboarding {
                        RegistrationView()
                            .environmentObject(moodData)
                            .environmentObject(authViewModel)
                    } else {
                        OnboardingView()
                            .environmentObject(moodData)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("apnstoken_push")), perform: { notification in
            guard let notificationInfo = notification.userInfo as? [String: Any],
                  let apnsToken = notificationInfo["apns_token"] as? String else { return }
            authViewModel.apnsToken = apnsToken
            authViewModel.login(email: UserDefaults.standard.string(forKey: "email") ?? "", password: UserDefaults.standard.string(forKey: "password") ?? "")
        })
    }
    
    // Function to add a new ball
    private func addBall() {
        let size = CGFloat.random(in: 20...50)
        let xPosition = CGFloat.random(in: 0...UIScreen.main.bounds.width)
        let speed = isCompleted ? 1.0 : Double.random(in: 2...5)
        let icons = ["smiley.fill", "drop.fill", "star.fill", "moon.fill"]
        
        // Create a new ball starting at the bottom
        var newBall = Ball(
            position: CGPoint(x: xPosition, y: UIScreen.main.bounds.height + size),
            size: size,
            color: Color(hex: Bool.random() ? "#FF69B4" : "#8A2BE2"),
            opacity: 1.0,
            icon: icons.randomElement() ?? "smiley.fill"
        )
        
        // Add the ball to the array
        balls.append(newBall)
        
        // Animate the ball to move upwards
        let index = balls.count - 1
        withAnimation(.linear(duration: speed)) {
            balls[index].position.y = -size
            balls[index].opacity = 0
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(MoodData())
    }
}


// Ball model for animation
struct Ball: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
    var icon: String
}
