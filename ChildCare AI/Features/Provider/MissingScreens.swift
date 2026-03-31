import SwiftUI

// MARK: - Attendance View
public struct AttendanceView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var children: [AttendanceItem] = []
    @State private var isLoading = false
    
    struct AttendanceItem: Identifiable {
        let id: Int
        let name: String
        let time: String
        let status: String
        let statusColor: Color
    }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Attendance")

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Summary Card
                    HStack(spacing: 16) {
                        AttendanceSummaryChip(value: "\(children.filter{ $0.status == "Present" }.count)", label: "Present", color: .green)
                        AttendanceSummaryChip(value: "\(children.filter{ $0.status == "Absent" }.count)", label: "Absent", color: .red)
                        AttendanceSummaryChip(value: "\(children.filter{ $0.status == "Late" }.count)", label: "Late", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Date Selector
                    HStack {
                        Text("Today's Attendance")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(themeManager.primaryColor)
                            Text("Oct 24, 2023")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Attendance List
                    VStack(spacing: 12) {
                        if isLoading {
                            ProgressView().padding()
                        } else if children.isEmpty {
                            Text("No bookings for today.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(children) { child in
                                AttendanceSummaryRow(
                                    name: child.name,
                                    time: child.time,
                                    status: child.status,
                                    statusColor: child.statusColor
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            loadAttendance()
        }
    }
    
    private func loadAttendance() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            do {
                let bookings = try await BookingService.shared.fetchProviderBookings(providerId: providerId)
                let items = bookings.map { booking -> AttendanceItem in
                    let status = booking.status == "Confirmed" ? "Present" : "Expected"
                    let statusColor: Color = booking.status == "Confirmed" ? .green : .blue
                    return AttendanceItem(
                        id: booking.id,
                        name: booking.child_name ?? "Unknown Child",
                        time: booking.start_time ?? "TBD",
                        status: status,
                        statusColor: statusColor
                    )
                }
                await MainActor.run {
                    self.children = items
                    self.isLoading = false
                }
            } catch {
                print("Error loading attendance: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

struct AttendanceSummaryChip: View {
    let value: String
    let label: String
    let color: Color
    
    public var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color, lineWidth: 1).opacity(0.2))
    }
}

struct AttendanceSummaryRow: View {
    let name: String
    let time: String
    let status: String
    let statusColor: Color
    
    public var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(statusColor)
                .opacity(0.1)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(name.prefix(1)))
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text("Check-in: \(time)")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(statusColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background { statusColor.opacity(0.1) }
                .cornerRadius(8)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5)
    }
}

// MARK: - Activities View
public struct ActivitiesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var activities: [ActivityItem] = []
    @State private var isLoading = false
    @State private var childNames: [Int: String] = [:]
    
    struct ActivityItem: Identifiable {
        let id: String
        let childName: String
        let activity: String
        let time: String
        let icon: String
        let color: Color
        let date: Date
    }
    
    public init() {}
    
    private func loadActivities() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            do {
                // Fetch children for name mapping
                let baseUrl = AuthService.shared.baseURL
                let childrenUrl = URL(string: "\(baseUrl)/bookings/provider/\(providerId)/children")!
                let (cData, _) = try await URLSession.shared.data(from: childrenUrl)
                let decodedChildren = try JSONDecoder().decode([ProviderChild].self, from: cData)
                var nameMap: [Int: String] = [:]
                for c in decodedChildren { nameMap[c.id] = c.name }
                
                let records = try await ActivityService.shared.fetchProviderActivities(providerId: providerId)
                let meals = try await MealService.shared.fetchProviderMeals(providerId: providerId)
                
                var items: [ActivityItem] = []
                
                for r in records {
                    let date = parseDate(r.created_at)
                    items.append(ActivityItem(
                        id: "act_\(r.id)",
                        childName: nameMap[r.child_id] ?? "Child",
                        activity: "\(r.activity_type): \(r.notes ?? "")",
                        time: formatTime(date),
                        icon: getIcon(for: r.activity_type),
                        color: getColor(for: r.activity_type),
                        date: date
                    ))
                }
                
                for m in meals {
                    let date = parseDate(m.created_at)
                    items.append(ActivityItem(
                        id: "meal_\(m.id)",
                        childName: nameMap[m.child_id] ?? "Child",
                        activity: "Meal: \(m.meal_type) - \(m.food_item)",
                        time: formatTime(date),
                        icon: "fork.knife",
                        color: .orange,
                        date: date
                    ))
                }
                
                let sorted = items.sorted(by: { $0.date > $1.date })
                
                await MainActor.run {
                    self.childNames = nameMap
                    self.activities = sorted
                    self.isLoading = false
                }
            } catch {
                print("Error loading activities: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func parseDate(_ dateString: String) -> Date {
        let formats = ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd HH:mm:ss"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) { return date }
        }
        return Date()
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func getIcon(for type: String) -> String {
        switch type.lowercased() {
        case "meal": return "fork.knife"
        case "nap": return "moon.fill"
        case "game": return "gamecontroller.fill"
        case "note": return "doc.text.fill"
        case "photo": return "camera.fill"
        default: return "star.fill"
        }
    }
    
    private func getColor(for type: String) -> Color {
        switch type.lowercased() {
        case "meal": return .orange
        case "nap": return .purple
        case "game": return .red
        case "photo": return .blue
        default: return .green
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Child Activities")

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if activities.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.3))
                    Text("No activities logged today")
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(activities) { activity in
                            ActivityCard(
                                time: activity.time,
                                title: activity.childName,
                                description: activity.activity,
                                icon: activity.icon,
                                color: activity.color
                                // Assuming ActivityCard has these parameters
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { loadActivities() }
    }
}

struct ActivityCard: View {
    let time: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    public var body: some View {
        HStack(spacing: 16) {
            VStack {
                Text(time)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .frame(width: 60)
            
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .opacity(0.12)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 18))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(description)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Spacer()
            }
            .padding(14)
            .background(AppTheme.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.02), radius: 5)
        }
        .padding(.horizontal)
    }
}

// MARK: - Incident Log List View
public struct IncidentLogListView: View {
    public init() {}
    
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Incident Log")

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Summary
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("3")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("This Week")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        
                        VStack(spacing: 4) {
                            Text("0")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("High Priority")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Incident List
                    VStack(spacing: 12) {
                        IncidentRow(childName: "Leo Johnson", type: "Minor Bump", severity: "Low", time: "Today, 10:30 AM", color: .yellow)
                        IncidentRow(childName: "Emma Davis", type: "Scrape on Knee", severity: "Low", time: "Today, 2:15 PM", color: .yellow)
                        IncidentRow(childName: "Noah Brown", type: "Allergic Reaction", severity: "Medium", time: "Yesterday, 12:00 PM", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    // Report Button
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Log New Incident")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(hex: "#BA1A1A"))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct IncidentRow: View {
    let childName: String
    let type: String
    let severity: String
    let time: String
    let color: Color
    
    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color)
                    .opacity(0.15)
                    .frame(width: 44, height: 44)
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(childName)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(type)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Text(time)
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Text(severity)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color == .yellow ? .orange : color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background { color.opacity(0.1) }
                .cornerRadius(8)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5)
    }
}

// MARK: - Provider Messages View
public struct ProviderMessagesView: View {
    public init() {}
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var messageStore: MessageStore
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Messages")

            if messageStore.inbox.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "message.badge.filled.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.gray.opacity(0.2))
                    Text("No messages yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(messageStore.inbox) { item in
                            let name = item.full_name ?? item.email.components(separatedBy: "@").first?.capitalized ?? "Unknown"
                            let contact = ChatContact(
                                name: name,
                                initial: String(name.prefix(1)),
                                color: themeManager.primaryColor,
                                lastMessage: item.last_message,
                                time: item.timestamp,
                                unread: item.is_read ? 0 : 1,
                                userId: item.user_id
                            )
                            NavigationLink(destination: ChatConversationView(contact: contact)) {
                                MessageRowItem(
                                    name: contact.name,
                                    message: contact.lastMessage,
                                    time: contact.time,
                                    isUnread: contact.unread > 0,
                                    initial: contact.initial,
                                    color: contact.color
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            if let userId = AuthService.shared.currentUser?.id {
                messageStore.startInboxPolling(userId: userId)
            }
        }
    }
}

struct MessageRowItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let name: String
    let message: String
    let time: String
    let isUnread: Bool
    let initial: String
    let color: Color
    
    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color)
                    .opacity(0.1)
                    .frame(width: 50, height: 50)
                Text(initial)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Text(time)
                        .font(.caption2)
                        .foregroundColor(AppTheme.textSecondary)
                }
                
                Text(message)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
            }
            
            if isUnread {
                Circle()
                    .fill(themeManager.primaryColor)
                    .frame(width: 10, height: 10)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5)
    }
}

// MARK: - Emergency Alerts View
public struct EmergencyAlertsView: View {
    public init() {}
    
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Emergency Alerts")

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Active Alerts Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .opacity(0.1)
                                .frame(width: 64, height: 64)
                            Image(systemName: "checkmark.shield.fill")
                                .font(.title)
                                .foregroundColor(.green)
                        }
                        
                        Text("All Clear")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("No active emergency alerts")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.surface)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    // Emergency Contacts
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Emergency Contacts")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        EmergencyContactRow(name: "Primary Care Doctor", phone: "(555) 123-4567", icon: "heart.fill", color: .red)
                        EmergencyContactRow(name: "Sunshine Daycare", phone: "(555) 987-6543", icon: "building.2.fill", color: .blue)
                        EmergencyContactRow(name: "Emergency Services", phone: "911", icon: "phone.fill", color: .orange)
                    }
                    
                    // Medical Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Medical Information")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            MedicalInfoRow(label: "Blood Type", value: "A+")
                            Divider()
                            MedicalInfoRow(label: "Allergies", value: "Peanuts")
                            Divider()
                            MedicalInfoRow(label: "Medications", value: "None")
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                .padding(.bottom, 40)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct EmergencyContactRow: View {
    let name: String
    let phone: String
    let icon: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color)
                    .opacity(0.1)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(phone)
                    .font(.caption)
                    .foregroundColor(themeManager.primaryColor)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "phone.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct MedicalInfoRow: View {
    let label: String
    let value: String
    
    public var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}



// MARK: - Achievements View
public struct AchievementsView: View {
    public init() {}
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Achievements")
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<5) { i in
                        HStack(spacing: 16) {
                            Circle()
                                .fill(themeManager.primaryColor)
                                .opacity(0.1)
                                .frame(width: 60, height: 60)
                                .overlay(Image(systemName: "trophy.fill").foregroundColor(themeManager.primaryColor))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Milestone \(i + 1)")
                                    .font(.headline)
                                Text("Completed over \(10 * (i + 1)) successful sessions.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(16)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Payment Methods View
public struct PaymentMethodsView: View {
    public init() {}
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Payment Methods")
            ScrollView {
                VStack(spacing: 16) {
                    PaymentMethodRow(icon: "creditcard.fill", title: "Visa Primary", subtitle: "**** 4242", color: .blue)
                    PaymentMethodRow(icon: "apple.logo", title: "Apple Pay", subtitle: "Default", color: .black)
                    
                    Button(action: {}) {
                        Label("Add Payment Method", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.primaryColor)
                            .cornerRadius(16)
                    }
                    .padding(.top, 24)
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Child Profiles View
public struct ChildProfilesView: View {
    public init() {}
    @EnvironmentObject var themeManager: ThemeManager
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Child Profiles")
            VStack(spacing: 20) {
                Image(systemName: "person.2.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(themeManager.primaryColor.opacity(0.5))
                Text("Your Child Profiles")
                    .font(.title3)
                    .fontWeight(.bold)
                Text("Manage your children's information, allergies, and emergency contacts here.")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Button(action: {}) {
                    Text("+ Add Profile")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(themeManager.primaryColor)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 100)
            Spacer()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Availability View
public struct AvailabilityView: View {
    public init() {}
    @EnvironmentObject var themeManager: ThemeManager
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "My Availability")
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Set your active working hours")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        AvailabilityDayRow(day: "Monday", time: "09:00 AM - 05:00 PM", isOn: true)
                        AvailabilityDayRow(day: "Tuesday", time: "09:00 AM - 05:00 PM", isOn: true)
                        AvailabilityDayRow(day: "Wednesday", time: "09:00 AM - 05:00 PM", isOn: false)
                        AvailabilityDayRow(day: "Thursday", time: "10:00 AM - 04:00 PM", isOn: true)
                        AvailabilityDayRow(day: "Friday", time: "09:00 AM - 08:00 PM", isOn: true)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {}) {
                        Text("Save Schedule")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.primaryColor)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct AvailabilityDayRow: View {
    let day: String
    let time: String
    let isOn: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(day).font(.subheadline).fontWeight(.bold)
                Text(time).font(.caption).foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Toggle("", isOn: .constant(isOn)).labelsHidden()
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(12)
    }
}

// MARK: - Background Check Info View
public struct BackgroundCheckInfoView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Background Check")
            VStack(spacing: 32) {
                ZStack {
                    Circle()
                        .fill(Color.green)
                        .opacity(0.1)
                        .frame(width: 80, height: 80)
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 40)).foregroundColor(.green)
                }
                
                VStack(spacing: 8) {
                    Text("Verification Cleared").font(.title3).fontWeight(.bold)
                    Text("Last Checked: Oct 12, 2025").font(.caption).foregroundColor(AppTheme.textSecondary)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Verified Domains").font(.headline)
                    VStack(spacing: 12) {
                        VerificationItem(title: "Identity Verification", status: "Success")
                        VerificationItem(title: "Criminal Record Check", status: "Success")
                        VerificationItem(title: "Reference Check", status: "Success")
                    }
                }
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct VerificationItem: View {
    let title: String
    let status: String
    var body: some View {
        HStack {
            Text(title).font(.subheadline)
            Spacer()
            Text(status).font(.caption).fontWeight(.bold).foregroundColor(.green)
        }
    }
}

// MARK: - Admin Privileges View
public struct AdminPrivilegesView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Admin Privileges")
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Administrative Access").font(.headline)
                    VStack(spacing: 12) {
                        PrivilegeRow(title: "User Management", desc: "Add, remove, or ban users", hasAccess: true)
                        PrivilegeRow(title: "Financial Transfers", desc: "Approve and execute payouts", hasAccess: true)
                        PrivilegeRow(title: "System Configuration", desc: "Modify platform fees and settings", hasAccess: true)
                        PrivilegeRow(title: "Audit Logs", desc: "View all platform activities", hasAccess: true)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct PrivilegeRow: View {
    let title: String
    let desc: String
    let hasAccess: Bool
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: hasAccess ? "lock.open.fill" : "lock.fill")
                .foregroundColor(hasAccess ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline).fontWeight(.bold)
                Text(desc).font(.caption).foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(12)
    }
}

// MARK: - System Logs View
public struct SystemLogsView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "System Logs")
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(0..<15) { i in
                        HStack(spacing: 12) {
                            Circle().fill(i % 5 == 0 ? Color.red : Color.blue).frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(i % 5 == 0 ? "ERROR" : "INFO"): System Event \(i + 1024)")
                                    .font(.system(size: 12, design: .monospaced))
                                    .fontWeight(.bold)
                                Text("2026-03-05 22:30:12 - Action performed by ID: ADMIN-01")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Earnings View
public struct EarningsView: View {
    public init() {}
    @EnvironmentObject var themeManager: ThemeManager
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Earnings History")
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Card
                    VStack(spacing: 16) {
                        Text("Total Balance").font(.subheadline).foregroundColor(.white.opacity(0.8))
                        Text("$1,240.50").font(.system(size: 36, weight: .bold)).foregroundColor(.white)
                        HStack(spacing: 20) {
                            VStack {
                                Text("$450").fontWeight(.bold).foregroundColor(.white)
                                Text("This Week").font(.caption2).foregroundColor(.white.opacity(0.7))
                            }
                            Divider().background(Color.white.opacity(0.3))
                            VStack {
                                Text("12").fontWeight(.bold).foregroundColor(.white)
                                Text("Jobs").font(.caption2).foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .padding(32)
                    .background(themeManager.primaryColor)
                    .cornerRadius(24)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Transactions").font(.headline).padding(.horizontal)
                        VStack(spacing: 12) {
                            ForEach(0..<5) { i in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Babysitting - Sarah J.").font(.subheadline).fontWeight(.bold)
                                        Text("Oct 24, 2025").font(.caption).foregroundColor(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                    Text("+$80.00").fontWeight(.bold).foregroundColor(.green)
                                }
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

// MARK: - Admin Audit Logs View
public struct AdminAuditLogsView: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Security & Audit Logs")
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<10) { i in
                        HStack(spacing: 16) {
                            Image(systemName: "shield.lefthalf.filled")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Admin Action: Modified Platform Fee").font(.subheadline).fontWeight(.bold)
                                Text("User: admin_jane • 2 mins ago").font(.caption).foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}



// MARK: - Curriculum Offerings View
public struct CurriculumOfferingsView: View {
    public init() {}
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Curriculum Offerings")
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Our Educational Programs")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        CurriculumCard(title: "STEM Foundation", description: "Science, Technology, Engineering, and Math for early learners.", icon: "atom", color: .blue)
                        CurriculumCard(title: "Creative Arts", description: "Expressive arts, music, and dramatic play programs.", icon: "paintbrush.fill", color: .pink)
                        CurriculumCard(title: "Early Literacy", description: "Phonics, reading, and storytelling sessions.", icon: "book.fill", color: .green)
                        CurriculumCard(title: "Physical Education", description: "Motor skills development and active play.", icon: "figure.walk", color: .orange)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {}) {
                        Text("Add New Program")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.primaryColor)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct CurriculumCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1)))
    }
}

// MARK: - Class Schedules View
public struct ClassSchedulesView: View {
    public init() {}
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Class Schedules")
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Weekly Class Timetable")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ScheduleRow(title: "Starfish Room", time: "08:30 AM - 12:30 PM", teacher: "Ms. Wilson")
                        ScheduleRow(title: "Dolphin Room", time: "09:00 AM - 01:00 PM", teacher: "Mr. Smith")
                        ScheduleRow(title: "Whale Room", time: "08:00 AM - 02:00 PM", teacher: "Ms. Davis")
                        ScheduleRow(title: "After-care Class", time: "03:00 PM - 06:00 PM", teacher: "Ms. Miller")
                    }
                    .padding(.horizontal)
                    
                    Button(action: {}) {
                        Text("Modify Schedule")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.primaryColor)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct ScheduleRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let time: String
    let teacher: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(time)
                    .font(.caption)
                    .foregroundColor(themeManager.primaryColor)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Teacher")
                    .font(.caption2)
                    .foregroundColor(AppTheme.textSecondary)
                Text(teacher)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
    }
}

// MARK: - Expected Attendance View
public struct ExpectedAttendanceView: View {
    public init() {}
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Expected Attendance")
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Forecast")
                            .font(.headline)
                        Text("Total Expected: 24 children")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        ExpectedRow(name: "Oliver Smith", time: "08:30 AM", status: "Confirmed")
                        ExpectedRow(name: "Sophia Brown", time: "08:45 AM", status: "Running Late")
                        ExpectedRow(name: "Lucas Garcia", time: "09:00 AM", status: "Confirmed")
                        ExpectedRow(name: "Mia Johnson", time: "09:15 AM", status: "Confirmed")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct ExpectedRow: View {
    let name: String
    let time: String
    let status: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("ETA: \(time)")
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Text(status)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(status == "Running Late" ? .orange : .green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(status == "Running Late" ? Color.orange.opacity(0.1) : Color.green.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
    }
}

// MARK: - Revenue Overview View
public struct RevenueOverviewView: View {
    public init() {}
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Revenue Overview")
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weekly Earnings")
                            .font(.headline)
                        Text("$4,250.00")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.primaryColor)
                    }
                    .padding(.horizontal)
                    
                    GrowthChartView(data: [1200, 1500, 1100, 1800, 2100, 1900, 2400])
                        .frame(height: 200)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        RevenueItem(title: "Tuition Fees", amount: "$3,800.00", icon: "person.2.fill", color: .blue)
                        RevenueItem(title: "Registration", amount: "$350.00", icon: "doc.text.fill", color: .green)
                        RevenueItem(title: "Late Entry Fees", amount: "$100.00", icon: "clock.fill", color: .orange)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct RevenueItem: View {
    let title: String
    let amount: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
            }
            Text(title)
                .font(.subheadline)
            Spacer()
            Text(amount)
                .font(.subheadline)
                .fontWeight(.bold)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
    }
}

// MARK: - Preschool Enrollment View
public struct PreschoolEnrollmentView: View {
    public init() {}
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Preschool Enrollment")
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        EnrollmentStat(label: "Enrolled", value: "86", color: .blue)
                        EnrollmentStat(label: "Waitlist", value: "14", color: .orange)
                        EnrollmentStat(label: "Capacity", value: "100", color: .green)
                    }
                    .padding(.horizontal)
                    
                    Text("Class Breakdown")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ClassEnrollmentRow(name: "Pre-K 1", count: "18/20")
                        ClassEnrollmentRow(name: "Pre-K 2", count: "22/25")
                        ClassEnrollmentRow(name: "Early Learners", count: "15/15")
                        ClassEnrollmentRow(name: "Preschool A", count: "31/40")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct EnrollmentStat: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
    }
}

struct ClassEnrollmentRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let name: String
    let count: String
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Text(count)
                .font(.subheadline)
                .foregroundColor(themeManager.primaryColor)
                .fontWeight(.bold)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
    }
}

// MARK: - Staff Management View
public struct StaffManagementView: View {
    public init() {}
    @Environment(\.dismiss) var dismiss
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Staff Management")
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Ratio: 1:8")
                            .font(.headline)
                        Text("Staff on Duty: 12")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        StaffRow(name: "Sarah Johnson", role: "Lead Teacher", status: "On Duty")
                        StaffRow(name: "Michael Chen", role: "Assistant", status: "On Duty")
                        StaffRow(name: "Elena Rodriguez", role: "Specialist", status: "Scheduled")
                        StaffRow(name: "David Smith", role: "Lead Teacher", status: "On Duty")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct StaffRow: View {
    let name: String
    let role: String
    let status: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(role)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Text(status)
                .font(.caption)
                .foregroundColor(status == "On Duty" ? .green : .blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(status == "On Duty" ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.1)))
    }
}
