import SwiftUI

struct DailyRewardView: View {
    @EnvironmentObject var moodData: MoodData
    @Binding var showReward: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    showReward = false
                }
            
            VStack {
                Text("Daily Reward!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                Circle()
                    .fill(Color(hex: "#FFD700"))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "gift.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 50))
                    )
                    .shadow(radius: 5)
                
                Text("You’ve earned 20 Mood Points for logging in today!")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    moodData.claimDailyReward()
                    showReward = false
                }) {
                    Text("Claim Reward")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color(hex: "#FFD700"))
                        )
                        .shadow(radius: 5)
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

struct DailyRewardView_Previews: PreviewProvider {
    static var previews: some View {
        DailyRewardView(showReward: .constant(true))
            .environmentObject(MoodData())
    }
}
