import SwiftUI

// MARK: - 1. Attendance Detail
public struct AttendanceDetailScreen: View {
    @EnvironmentObject var themeManager: ThemeManager
    let childName: String
    @State private var selectedMonth = "October 2023"
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Attendance")
            
            ScrollView {
                VStack(spacing: 20) {
                    // Monthly Selector
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(themeManager.primaryColor)
                        }
                        Spacer()
                        Text(selectedMonth)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(themeManager.primaryColor)
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.divider, lineWidth: 1))
                    
                    // Summary Boxes
                    HStack(spacing: 12) {
                        AttendanceSummaryBox(count: "22", label: "Present", color: .green)
                        AttendanceSummaryBox(count: "1", label: "Absent", color: .red)
                        AttendanceSummaryBox(count: "8", label: "Holiday", color: .blue)
                    }
                    
                    // Calendar Grid
                    VStack(spacing: 0) {
                        // Days of week
                        HStack {
                            ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 12)
                        
                        // Dates Grid
                        let days = Array(1...31)
                        let columns = Array(repeating: GridItem(.flexible()), count: 7)
                        
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(days, id: \.self) { day in
                                CalendarDayCell(day: "\(day)", status: getStatus(for: day))
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.divider, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.02), radius: 10)
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    private func getStatus(for day: Int) -> AttendanceDayStatus {
        if day == 12 { return .absent }
        if day > 25 { return .none }
        return .present
    }
}

enum AttendanceDayStatus {
    case present, absent, holiday, none
}

struct AttendanceSummaryBox: View {
    let count: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(count)
                .font(.trackerTitle)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
    }
}

struct CalendarDayCell: View {
    let day: String
    let status: AttendanceDayStatus
    
    var body: some View {
        Text(day)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(status == .none ? AppTheme.textSecondary : AppTheme.textPrimary)
            .frame(width: 32, height: 32)
            .background(backgroundColor)
            .cornerRadius(8)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .present: return Color.green.opacity(0.12)
        case .absent: return Color.red.opacity(0.12)
        case .holiday: return Color.blue.opacity(0.12)
        case .none: return Color.clear
        }
    }
}

// MARK: - 2. Meal Report
public struct MealReportScreen: View {
    let childName: String
    public var body: some View {
        DetailContainer(title: "Meals", icon: "fork.knife", color: .green) {
            VStack(alignment: .leading, spacing: 20) {
                LogMealRow(mealType: "Breakfast", food: "Oatmeal & Bananas", percentage: "100%", time: "8:30 AM")
                LogMealRow(mealType: "Lunch", food: "Chicken Nuggets & Peas", percentage: "75%", time: "12:00 PM")
                LogMealRow(mealType: "Snack", food: "Apple Slices", percentage: "All", time: "3:00 PM")
                LogMealRow(mealType: "Dinner", food: "Pasta & Vegetables", percentage: "Most", time: "6:00 PM")
            }
        }
    }
}

// MARK: - 3. Nap Schedule
public struct NapScheduleScreen: View {
    let childName: String
    public var body: some View {
        DetailContainer(title: "Nap Time", icon: "moon.zzz.fill", color: .indigo) {
            VStack(spacing: 20) {
                StatusRow(label: "Started Nap", value: "1:00 PM", subtext: "Fell asleep easily")
                StatusRow(label: "Woke Up", value: "2:45 PM", subtext: "Happy & rested")
                Divider()
                Text("Total Sleep: 1h 45m")
                    .font(.headline)
            }
        }
    }
}

// MARK: - 4. Activities
public struct ActivitiesLogScreen: View {
    let childName: String
    public var body: some View {
        DetailContainer(title: "Activities", icon: "figure.play", color: .orange) {
            VStack(alignment: .leading, spacing: 16) {
                LogActivityRow(time: "9:30 AM", activity: "Outdoor Play", desc: "Played on swings.")
                LogActivityRow(time: "10:30 AM", activity: "Art Time", desc: "Finger painting.")
            }
        }
    }
}

// MARK: - 5. Learning
public struct LearningProgressScreen: View {
    let childName: String
    public var body: some View {
        DetailContainer(title: "Learning", icon: "book.fill", color: .cyan) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today's Focus: Letters & Numbers")
                    .font(.headline)
                Text("\(childName) successfully identified letters A through E and counted to 10 with the group.")
                    .font(.body)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}

// MARK: - 6. Games
public struct GamesActivityScreen: View {
    let childName: String
    public var body: some View {
        DetailContainer(title: "Games", icon: "gamecontroller.fill", color: .purple) {
            VStack(alignment: .leading, spacing: 16) {
                LogActivityRow(time: "11:00 AM", activity: "Simon Says", desc: "Great listening skills.")
                LogActivityRow(time: "2:00 PM", activity: "Building Blocks", desc: "Built a tall tower.")
            }
        }
    }
}

// MARK: - 7. Mood
public struct MoodTrackingScreen: View {
    let childName: String
    public var body: some View {
        DetailContainer(title: "Mood Tracker", icon: "face.smiling.fill", color: .yellow) {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    VStack {
                        Image(systemName: "face.smiling.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        Text("Happy")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                Text("\(childName) was in a fantastic mood all day and shared toys with friends.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }
}

// MARK: - 8. Photos
public struct MediaGalleryScreen: View {
    let childName: String
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Photos")
            
            ScrollView {
                VStack(spacing: 16) {
                    // Placeholder images
                    ForEach(0..<3) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .cornerRadius(AppTheme.cornerRadius)
                            .overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray))
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - 9. Care Notes
public struct CareNotesScreen: View {
    let childName: String
    public var body: some View {
        DetailContainer(title: "Provider Notes", icon: "note.text", color: .teal) {
            Text("\(childName) had a wonderful day today. We noticed they are getting much better at using their utensils during lunch. Please remember to bring extra wipes tomorrow. Thank you!")
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .lineSpacing(6)
        }
    }
}

// MARK: - 10. Daily Timeline
public struct DailyTimelineScreen: View {
    let childName: String
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Daily Timeline")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TimelineItem(time: "8:15 AM", title: "Checked In", desc: "Arrived at center.", color: .blue)
                    TimelineItem(time: "8:30 AM", title: "Breakfast", desc: "Ate all oatmeal.", color: .green)
                    TimelineItem(time: "9:30 AM", title: "Outdoor Play", desc: "Swings and slide.", color: .orange)
                    TimelineItem(time: "1:00 PM", title: "Nap Time", desc: "Slept well.", color: .indigo)
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Reusable UI Components for these screens
struct DetailContainer<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: title)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(color.opacity(0.1))
                                .frame(width: 56, height: 56)
                            Image(systemName: icon)
                                .font(.title)
                                .foregroundColor(color)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Latest Update")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        content
                    }
                    .padding(20)
                    .background(AppTheme.cardBackground)
                    .cornerRadius(AppTheme.cornerRadius)
                    .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius).stroke(AppTheme.divider, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, AppTheme.padding)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    let subtext: String
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                Text(subtext)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary.opacity(0.8))
            }
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}

struct LogMealRow: View {
    let mealType: String
    let food: String
    let percentage: String
    let time: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(mealType)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                Spacer()
                Text(time)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Text(food)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            HStack {
                Text("Eaten: ")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text(percentage)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            Divider()
                .background(AppTheme.divider)
        }
    }
}

struct LogActivityRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let time: String
    let activity: String
    let desc: String
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(time)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(themeManager.primaryColor)
                .frame(width: 65, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
        }
        .padding(.bottom, 10)
    }
}

struct TimelineItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let time: String
    let title: String
    let desc: String
    let color: Color
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                Rectangle()
                    .fill(AppTheme.divider)
                    .frame(width: 2, height: 40)
            }
            .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Text(time)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(color == .primary ? themeManager.primaryColor : color)
                }
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.divider, lineWidth: 1))
            .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
        }
    }
}
