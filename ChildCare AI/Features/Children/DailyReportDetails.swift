import SwiftUI

// MARK: - 1. Attendance Detail
public struct AttendanceDetailScreen: View {
    let childName: String
    public var body: some View {
        DetailContainer(title: "Attendance", icon: "clock.fill", color: .blue) {
            VStack(spacing: 20) {
                StatusRow(label: "Check In", value: "8:15 AM", subtext: "by Mom")
                StatusRow(label: "Check Out", value: "4:30 PM (Expected)", subtext: "by Dad")
                Divider()
                Text("Total Time: 8h 15m")
                    .font(.headline)
            }
        }
    }
}

// MARK: - 2. Meal Report
public struct MealReportScreen: View {
    let childName: String
    public var body: some View {
        DetailContainer(title: "Meals", icon: "fork.knife", color: .green) {
            VStack(alignment: .leading, spacing: 20) {
                MealRow(mealType: "Breakfast", food: "Oatmeal & Bananas", percentage: "100%", time: "8:30 AM")
                MealRow(mealType: "Lunch", food: "Chicken Nuggets & Peas", percentage: "75%", time: "12:00 PM")
                MealRow(mealType: "Snack", food: "Apple Slices", percentage: "All", time: "3:00 PM")
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
                ActivityRow(time: "9:30 AM", activity: "Outdoor Play", desc: "Played on swings.")
                ActivityRow(time: "10:30 AM", activity: "Art Time", desc: "Finger painting.")
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
                ActivityRow(time: "11:00 AM", activity: "Simon Says", desc: "Great listening skills.")
                ActivityRow(time: "2:00 PM", activity: "Building Blocks", desc: "Built a tall tower.")
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
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Photos")
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
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TimelineItem(time: "8:15 AM", title: "Checked In", desc: "Arrived at center.", color: .blue)
                TimelineItem(time: "8:30 AM", title: "Breakfast", desc: "Ate all oatmeal.", color: .green)
                TimelineItem(time: "9:30 AM", title: "Outdoor Play", desc: "Swings and slide.", color: .orange)
                TimelineItem(time: "1:00 PM", title: "Nap Time", desc: "Slept well.", color: .indigo)
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Daily Timeline")
    }
}

// MARK: - Reusable UI Components for these screens
struct DetailContainer<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: () -> Content
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(color)
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                }
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .padding(20)
                .background(AppTheme.surface)
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding(.horizontal, AppTheme.padding)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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
                    .foregroundColor(Color.gray)
            }
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}

struct MealRow: View {
    let mealType: String
    let food: String
    let percentage: String
    let time: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
        }
    }
}

struct ActivityRow: View {
    let time: String
    let activity: String
    let desc: String
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(time)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.primary)
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
                    .fill(Color.gray.opacity(0.3))
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
                        .foregroundColor(color)
                }
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        }
    }
}
