import SwiftUI

public struct DailyTimelineView: View {
    @State private var timelineItems: [TimelineItem] = []
    @State private var isLoading = false
    
    // Assume childId 1 for Leo Johnson in demo
    private let childId = 1
    
    public init() {}
    
    struct TimelineItem: Identifiable {
        let id = UUID()
        let title: String
        let time: String
        let description: String
        let icon: String
        let color: Color
        let date: Date
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Daily Timeline")
            
            ScrollView(showsIndicators: false) {
                    if isLoading {
                        ProgressView().padding(.top, 40)
                    } else if timelineItems.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "clock.badge.exclamationmark")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.3))
                            Text("No activities logged for today.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 60)
                    } else {
                        ForEach(0..<timelineItems.count, id: \.self) { index in
                            TimelineNode(
                                title: timelineItems[index].title,
                                time: timelineItems[index].time,
                                description: timelineItems[index].description,
                                icon: timelineItems[index].icon,
                                color: timelineItems[index].color,
                                isFirst: index == 0,
                                isLast: index == timelineItems.count - 1
                            )
                        }
                    }
                }
                .padding(24)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            loadTimeline()
        }
    }
    
    private func loadTimeline() {
        isLoading = true
        Task {
            do {
                let meals = try await MealService.shared.fetchChildMeals(childId: childId)
                let activities = try await ActivityService.shared.fetchChildActivities(childId: childId)
                
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                var items: [TimelineItem] = []
                
                // Add Meals
                for meal in meals {
                    let date = dateFormatter.date(from: meal.created_at) ?? Date()
                    let timeStr = formatTime(date)
                    items.append(TimelineItem(
                        title: meal.meal_type,
                        time: timeStr,
                        description: "\(meal.food_item) (\(meal.amount_eaten))",
                        icon: "fork.knife",
                        color: .orange,
                        date: date
                    ))
                }
                
                // Add Activities
                for activity in activities {
                    let date = dateFormatter.date(from: activity.created_at) ?? Date()
                    let timeStr = formatTime(date)
                    items.append(TimelineItem(
                        title: activity.activity_type,
                        time: timeStr,
                        description: activity.notes ?? "No notes added",
                        icon: iconForType(activity.activity_type),
                        color: colorForType(activity.activity_type),
                        date: date
                    ))
                }
                
                let sorted = items.sorted { $0.date > $1.date }
                
                DispatchQueue.main.async {
                    self.timelineItems = sorted
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "Nap": return "moon.fill"
        case "Play": return "gamecontroller.fill"
        case "Learning": return "book.fill"
        default: return "star.fill"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "Nap": return .blue
        case "Play": return .green
        case "Learning": return .purple
        default: return .indigo
        }
    }
}

struct TimelineNode: View {
    let title: String
    let time: String
    let description: String
    let icon: String
    let color: Color
    var isFirst: Bool = false
    var isLast: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // Timeline Line & Icon
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 2, height: 20)
                }
                
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 12))
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                    Text(time)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.01), radius: 5)
                .padding(.bottom, 24)
            }
        }
    }
}
