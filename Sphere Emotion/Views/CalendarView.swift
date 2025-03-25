import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var moodData: MoodData
    @State private var selectedDate = Date()
    
    var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = 2 // Start week on Monday
        return cal
    }
    
    var daysInMonth: [Date] {
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        return range.map { day in
            calendar.date(bySetting: .day, value: day, of: selectedDate)!
        }
    }
    
    var firstDayOfMonth: Date {
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        return calendar.date(from: components)!
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#FF69B4"), Color(hex: "#8A2BE2")]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ForEach(0..<5) { _ in
                FloatingBall()
            }
            
            VStack {
                Text("Your Mood Calendar")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                    .padding(.top, 50)
                
                // Month/Year Picker
                HStack {
                    Button(action: {
                        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate)!
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                    
                    Text("\(selectedDate, formatter: monthFormatter)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate)!
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal)
                
                // Weekday headers
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                    ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                // Calendar grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 15) {
                        // Add empty spaces for days before the first day of the month
                        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - calendar.firstWeekday
                        let offset = firstWeekday < 0 ? firstWeekday + 7 : firstWeekday
                        ForEach(0..<offset, id: \.self) { _ in
                            Color.clear.frame(width: 50, height: 50)
                        }
                        
                        // Days of the month
                        ForEach(daysInMonth, id: \.self) { date in
                            let isToday = calendar.isDate(date, inSameDayAs: Date())
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(isToday ? Color.white : Color.clear, lineWidth: 3)
                                            .blur(radius: 5)
                                    ) // Glow effect for today
                                
                                if let mood = moodData.moods[calendar.startOfDay(for: date)] {
                                    Circle()
                                        .fill(mood.uiColor)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Image(systemName: mood.icon)
                                                .foregroundColor(.white)
                                                .font(.system(size: 20))
                                        )
                                        .shadow(radius: 5)
                                } else {
                                    Text("\(calendar.component(.day, from: date))")
                                        .foregroundColor(.white)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
        }
    }
}

private let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}()

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
            .environmentObject(MoodData())
    }
}
