import SwiftUI

public struct DailyReportOverviewView: View {
    let childName: String
    
    // We strictly use NavigationLink to isolated screens
    // No collapsible or reused views
    
    public init(childName: String) {
        self.childName = childName
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 4) {
                    Text("Today's Report")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Tuesday, Oct 24")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // 10 Fixed Navigation Buttons
                VStack(spacing: 12) {
                    ReportNavButton(title: "Attendance", icon: "clock.fill", color: .blue, destination: AnyView(AttendanceDetailScreen(childName: childName)))
                    ReportNavButton(title: "Meals", icon: "fork.knife", color: .green, destination: AnyView(MealReportScreen(childName: childName)))
                    ReportNavButton(title: "Nap", icon: "moon.zzz.fill", color: .indigo, destination: AnyView(NapScheduleScreen(childName: childName)))
                    ReportNavButton(title: "Activities", icon: "figure.play", color: .orange, destination: AnyView(ActivitiesLogScreen(childName: childName)))
                    ReportNavButton(title: "Learning", icon: "book.fill", color: .cyan, destination: AnyView(LearningProgressScreen(childName: childName)))
                    ReportNavButton(title: "Games", icon: "gamecontroller.fill", color: .purple, destination: AnyView(GamesActivityScreen(childName: childName)))
                    ReportNavButton(title: "Mood", icon: "face.smiling.fill", color: .yellow, destination: AnyView(MoodTrackingScreen(childName: childName)))
                    ReportNavButton(title: "Photos", icon: "photo.fill", color: .pink, destination: AnyView(MediaGalleryScreen(childName: childName)))
                    ReportNavButton(title: "Notes", icon: "note.text", color: .teal, destination: AnyView(CareNotesScreen(childName: childName)))
                    ReportNavButton(title: "Timeline", icon: "list.bullet.rectangle.portrait", color: .gray, destination: AnyView(DailyTimelineScreen(childName: childName)))
                }
                .padding(.horizontal, AppTheme.padding)
                
                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("\(childName)'s Daily Report")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ReportNavButton: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding(12)
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        }
    }
}
