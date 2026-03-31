import SwiftUI
import Combine

public struct DailyReportOverviewView: View {
    let childId: Int
    let childName: String
    @State private var meals: [MealModel] = []
    @State private var activities: [ActivityModel] = []
    @State private var photos: [PhotoModel] = []
    @State private var isLoading = false
    @State private var reportSummary: String = ""
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    public init(childId: Int, childName: String) {
        self.childId = childId
        self.childName = childName
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Daily Report")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Profile
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(childName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("ChildCare Center")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "calendar")
                            Text(Date(), style: .date)
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    // Attendance Card
                    HStack(spacing: 0) {
                        let attendance = activities.filter { $0.activity_type == "Attendance" }
                        let checkIn = attendance.filter { $0.notes?.contains("Checked In") ?? false }.last
                        let checkOut = attendance.filter { $0.notes?.contains("Checked Out") ?? false }.first
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                                .padding(10)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text("Check In")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(checkIn != nil ? formatActivityTime(checkIn!.created_at) : "--:--")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider().frame(height: 40)
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Duration")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(calculateDuration(checkIn: checkIn?.created_at, checkOut: checkOut?.created_at))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // Today's Mood
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "face.smiling")
                                .foregroundColor(.orange)
                            Text("Today's Mood")
                                .font(.headline)
                        }
                        
                        let moodActivity = activities.filter { $0.activity_type == "Mood" }.last
                        let moodNotes = moodActivity?.notes?.replacingOccurrences(of: "Today's mood: ", with: "") ?? "Happy"
                        
                        HStack(spacing: 8) {
                            MoodBadge(title: moodNotes, color: .yellow)
                        }
                        
                        Text(reportSummary)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // Daily Photos
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.blue)
                            Text("Daily Photos")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        if photos.isEmpty {
                            if !isLoading {
                                Text("No photos shared today yet.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                            }
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(photos) { photo in
                                        AsyncImage(url: URL(string: "\(AuthService.shared.baseURL.replacingOccurrences(of: "/api", with: ""))\(photo.url)")) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .cornerRadius(12)
                                                .clipped()
                                        } placeholder: {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.1))
                                                .frame(width: 150, height: 150)
                                                .overlay(ProgressView())
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // Meals & Nutrition
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.green)
                            Text("Meals & Nutrition")
                                .font(.headline)
                        }
                        .padding()
                        
                        VStack(spacing: 0) {
                            if isLoading {
                                ProgressView().padding()
                            } else if meals.isEmpty {
                                Text("No meal records for today yet.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                let breakfast = meals.filter { $0.meal_type == "Breakfast" }.last
                                let lunch = meals.filter { $0.meal_type == "Lunch" }.last
                                let snack = meals.filter { $0.meal_type == "Snack" }.last
                                let dinner = meals.filter { $0.meal_type == "Dinner" }.last
                                
                                OverviewMealRow(
                                    title: "Breakfast",
                                    detail: breakfast?.food_item ?? "Not served yet",
                                    status: breakfast?.amount_eaten ?? "--"
                                )
                                Divider().padding(.horizontal)
                                OverviewMealRow(
                                    title: "Lunch",
                                    detail: lunch?.food_item ?? "Not served yet",
                                    status: lunch?.amount_eaten ?? "--"
                                )
                                Divider().padding(.horizontal)
                                OverviewMealRow(
                                    title: "Snack",
                                    detail: snack?.food_item ?? "Not served yet",
                                    status: snack?.amount_eaten ?? "--"
                                )
                                Divider().padding(.horizontal)
                                OverviewMealRow(
                                    title: "Dinner",
                                    detail: dinner?.food_item ?? "Not served yet",
                                    status: dinner?.amount_eaten ?? "--"
                                )
                            }
                        }
                    }
                    .background(AppTheme.surface)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                    
                    // Activities
                    VStack(spacing: 16) {
                        let filteredActivities = activities.reduce(into: [String: ActivityModel]()) { result, activity in
                            // For some types like 'Note', we might want to show all, but for Attendance/Mood/Nap/Game, 
                            // showing the latest is often cleaner in a summary report.
                            // We'll show all 'Note' and 'Photo', but deduplicate others.
                            if activity.activity_type == "Note" || activity.activity_type == "Photo" {
                                result["\(activity.activity_type)_\(activity.id)"] = activity
                            } else {
                                // For Nap, Game, etc., take the latest based on created_at
                                if let existing = result[activity.activity_type] {
                                    if activity.created_at > existing.created_at {
                                        result[activity.activity_type] = activity
                                    }
                                } else {
                                    result[activity.activity_type] = activity
                                }
                            }
                        }.values.sorted(by: { $0.created_at > $1.created_at })

                        ForEach(filteredActivities.filter({ $0.activity_type != "Mood" && $0.activity_type != "Attendance" }), id: \.id) { activity in
                            HStack {
                                Image(systemName: iconForType(activity.activity_type))
                                    .foregroundColor(colorForType(activity.activity_type))
                                    .padding(10)
                                    .background(colorForType(activity.activity_type).opacity(0.1))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(activity.activity_type)
                                        .font(.headline)
                                    
                                    if let notes = activity.notes {
                                        Text(notes)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                Spacer()
                                
                                Text(formatActivityTime(activity.created_at))
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .refreshable {
                loadData()
            }
            .onReceive(timer) { _ in
                loadData()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        Task {
            do {
                async let fetchedMeals = MealService.shared.fetchChildMeals(childId: childId)
                async let fetchedActivities = ActivityService.shared.fetchChildActivities(childId: childId)
                
                let (m, a) = try await (fetchedMeals, fetchedActivities)
                
                // Lenient "Today" filter: within the last 24 hours to handle UTC/Local cross-over
                let now = Date()
                let todayActivities = a.filter {
                    let date = self.parseDateTime($0.created_at)
                    return now.timeIntervalSince(date) < 24 * 3600
                }
                let todayMeals = m.filter {
                    let date = self.parseDateTime($0.created_at)
                    return now.timeIntervalSince(date) < 24 * 3600
                }
                
                await MainActor.run {
                    self.activities = todayActivities
                    self.meals = todayMeals
                    self.isLoading = false
                }
                
                // Fetch photos separately
                do {
                    let p = try await PhotoService.shared.fetchChildPhotos(childId: childId)
                    // Lenient "Today" filter: within the last 24 hours to handle UTC/Local cross-over
                    let todayPhotos = p.filter {
                         let date = self.parseDateTime($0.created_at)
                         return now.timeIntervalSince(date) < 24 * 3600
                    }
                    DispatchQueue.main.async {
                        self.photos = todayPhotos
                    }
                } catch {
                }
            } catch {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
    
    private func iconForType(_ type: String) -> String {
        switch type {
        case "Nap": return "moon.fill"
        case "Play": return "gamecontroller.fill"
        case "Learning": return "book.fill"
        case "Mood": return "face.smiling.fill"
        default: return "star.fill"
        }
    }
    
    private func colorForType(_ type: String) -> Color {
        switch type {
        case "Nap": return .blue
        case "Play": return .green
        case "Learning": return .purple
        case "Attendance": return .green
        case "Mood": return .orange
        default: return .indigo
        }
    }
    
    private func formatActivityTime(_ dateString: String) -> String {
        let date = parseDateTime(dateString)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    
    private func calculateDuration(checkIn: String?, checkOut: String?) -> String {
        guard let checkInStr = checkIn else { return "--" }
        let startDate = parseDateTime(checkInStr)
        let endDate = checkOut != nil ? parseDateTime(checkOut!) : Date()
        
        let diff = Int(endDate.timeIntervalSince(startDate))
        let hours = diff / 3600
        let minutes = (diff % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func parseDateTime(_ dateString: String) -> Date {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss"
        ]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) { return date }
        }
        return Date()
    }
}

struct MoodBadge: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(12)
    }
}

struct OverviewMealRow: View {
    let title: String
    let detail: String
    let status: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(detail)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Spacer()
            Text(status)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.05))
                .cornerRadius(4)
        }
        .padding()
    }
}
