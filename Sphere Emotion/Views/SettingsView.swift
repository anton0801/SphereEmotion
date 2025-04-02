import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var moodData: MoodData
    @State private var happyColor: Color = Color(hex: "#FF69B4")
    @State private var sadColor: Color = Color(hex: "#8A2BE2")
    @State private var excitedColor: Color = Color(hex: "#FFD700")
    @State private var calmColor: Color = Color(hex: "#DDA0DD")
    @State private var showingColorPicker = false
    @State private var selectedMood: String?
    
    var body: some View {
        ZStack {
//            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
//                           startPoint: .top, endPoint: .bottom)
//                .ignoresSafeArea()
//            
//            ForEach(0..<5) { _ in
//                FloatingBall()
//            }
            InteractiveBackground(touchParticles: .constant([]))
            
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
                    
                    VStack(alignment: .leading) {
                        Text("Themes")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        ForEach(moodData.themes) { theme in
                            HStack {
                                Circle()
                                    .fill(LinearGradient(gradient: Gradient(colors: theme.gradientColors.map { Color(hex: $0) }),
                                                         startPoint: .top, endPoint: .bottom))
                                    .frame(width: 50, height: 50)
                                    .shadow(radius: 5)
                                
                                VStack(alignment: .leading) {
                                    Text(theme.name)
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                    Text("Cost: \(theme.cost) points")
                                        .font(.system(size: 16, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                if !theme.isUnlocked {
                                    Button(action: {
                                        moodData.unlockTheme(theme)
                                    }) {
                                        Text("Unlock")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                Capsule()
                                                    .fill(moodData.moodPoints >= theme.cost ? Color(hex: "#FFD700") : Color.gray)
                                            )
                                    }
                                    .disabled(moodData.moodPoints < theme.cost)
                                } else {
                                    Button(action: {
                                        moodData.selectedTheme = theme.name
                                    }) {
                                        Text(moodData.selectedTheme == theme.name ? "Selected" : "Select")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 10)
                                            .background(
                                                Capsule()
                                                    .fill(moodData.selectedTheme == theme.name ? Color(hex: "#FFD700") : Color.gray)
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
                    
                    
                    
                    VStack(alignment: .leading) {
                        Text("Account Actions")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        // Кнопка Sign Out
                        Button(action: {
                            // authViewModel.signOut()
                            authViewModel.isAuthenticated = false
                            UserDefaults.standard.set(nil, forKey: "email")
                            UserDefaults.standard.set(nil, forKey: "password")
                        }) {
                            Text("Sign Out")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: "#FF4500")) // Красный цвет для выхода
                                )
                                .padding(.horizontal, 50)
                        }
                        .padding(.vertical, 5)
                        
                        // Кнопка Remove Account
                        Button(action: {
                            // showingRemoveAccountConfirmation = true
                            authViewModel.isAuthenticated = false
                            UserDefaults.standard.set(nil, forKey: "email")
                            UserDefaults.standard.set(nil, forKey: "password")
                        }) {
                            Text("Remove Account")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    Capsule()
                                        .fill(Color.red) // Ярко-красный для удаления
                                )
                                .padding(.horizontal, 50)
                        }
                        .padding(.vertical, 5)
                        
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
        .sheet(isPresented: $showingColorPicker) {
            if let mood = selectedMood {
                ColorPickerView(mood: mood, color: Binding(
                    get: { Color(hex: moodData.customMoodColors[mood] ?? "#FFFFFF") },
                    set: { newColor in
                        moodData.customMoodColors[mood] = newColor.toHex()
                        moodData.saveCustomColors()
                    }
                ))
            }
        }
    }
}

struct ColorPickerView: View {
    let mood: String
    @Binding var color: Color
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Pick a color for \(mood)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 20)
            
            ColorPicker("Select Color", selection: $color, supportsOpacity: false)
                .labelsHidden()
                .scaleEffect(1.5)
                .padding()
            
            Button(action: {
                dismiss()
            }) {
                Text("Done")
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
            
            Spacer()
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}

extension Color {
    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MoodData())
            .environmentObject(AuthViewModel())
    }
}
