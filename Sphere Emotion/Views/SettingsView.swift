import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var moodData: MoodData
    @State private var happyColor: Color = Color(hex: "#FF69B4")
    @State private var sadColor: Color = Color(hex: "#8A2BE2")
    @State private var excitedColor: Color = Color(hex: "#FFD700")
    @State private var calmColor: Color = Color(hex: "#DDA0DD")
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ForEach(0..<5) { _ in
                FloatingBall()
            }
            
            VStack {
                Text("Settings")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                ScrollView {
                    // Mood Colors
                    VStack(alignment: .leading) {
                        Text("Mood Colors")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        ColorPicker("Happy Color", selection: $happyColor)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        ColorPicker("Sad Color", selection: $sadColor)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        ColorPicker("Excited Color", selection: $excitedColor)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        ColorPicker("Calm Color", selection: $calmColor)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Button(action: {
                            moodData.customMoodColors["Happy"] = happyColor.hex
                            moodData.customMoodColors["Sad"] = sadColor.hex
                            moodData.customMoodColors["Excited"] = excitedColor.hex
                            moodData.customMoodColors["Calm"] = calmColor.hex
                            moodData.saveCustomColors()
                        }) {
                            Text("Save Colors")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "#FFD700"))
                                )
                                .padding(.horizontal, 50)
                        }
                        .padding(.top, 20)
                    }
                    
                    // Ball Designs
                    VStack(alignment: .leading) {
                        Text("Ball Designs")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        ForEach(moodData.ballDesigns) { design in
                            HStack {
                                Circle()
                                    .fill(design.isUnlocked ? Color(hex: "#FFD700") : Color.gray.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Image(systemName: design.isUnlocked ? "checkmark.circle.fill" : "lock.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 25))
                                    )
                                    .shadow(radius: 5)
                                
                                VStack(alignment: .leading) {
                                    Text(design.name)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("Cost: \(design.cost) points")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                if !design.isUnlocked {
                                    Button(action: {
                                        moodData.unlockDesign(design)
                                    }) {
                                        Text("Unlock")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                Capsule()
                                                    .fill(moodData.moodPoints >= design.cost ? Color(hex: "#FFD700") : Color.gray)
                                            )
                                    }
                                    .disabled(moodData.moodPoints < design.cost)
                                } else {
                                    Button(action: {
                                        moodData.selectedDesign = design.name
                                    }) {
                                        Text(moodData.selectedDesign == design.name ? "Selected" : "Select")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                Capsule()
                                                    .fill(moodData.selectedDesign == design.name ? Color(hex: "#FFD700") : Color.gray)
                                            )
                                    }
                                }
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
                }
                
                Spacer()
            }
        }
        .onAppear {
            happyColor = Color(hex: moodData.customMoodColors["Happy"] ?? "#FF69B4")
            sadColor = Color(hex: moodData.customMoodColors["Sad"] ?? "#8A2BE2")
            excitedColor = Color(hex: moodData.customMoodColors["Excited"] ?? "#FFD700")
            calmColor = Color(hex: moodData.customMoodColors["Calm"] ?? "#DDA0DD")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MoodData())
    }
}
