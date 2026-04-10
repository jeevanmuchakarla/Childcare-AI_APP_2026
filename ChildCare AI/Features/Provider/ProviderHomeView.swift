import SwiftUI

public struct ProviderDashboardView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var authService = AuthService.shared
    @State private var showingCheckIn = false
    @State private var showingDailyReport = false
    @State private var showingIncidentLog = false
    @State private var navigateToNotifications = false
    @State private var showingCenterProfile = false
    @State private var centerProfile: [String: Any]? = nil
    @State private var isLoading = false
    @State private var showingEmergencyAlert = false
    @State private var emergencyMessage = ""
    @State private var isSendingAlert = false
    @State private var providerSummary: ProviderSummaryRecord? = nil
    @State private var recentUpdates: [ProviderActivityUpdate] = []
    @State private var currentCenterStatus: String = "Open"
    
    struct ProviderActivityUpdate: Identifiable {
        let id: String
        let name: String
        let initial: String
        let description: String
        let time: String
        let date: Date
        let color: Color
    }
    
    // Static formatters for performance
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    private static let multiFormatters: [DateFormatter] = {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss"
        ]
        return formats.map { format in
            let f = DateFormatter()
            f.dateFormat = format
            f.locale = Locale(identifier: "en_US_POSIX")
            return f
        }
    }()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Section
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appRouter.currentRole == .preschool ? "Welcome to Preschool," : "Welcome to Daycare,")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    Text(centerDisplayName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                }
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { navigateToNotifications = true }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: Color.black.opacity(0.05), radius: 5)
                            
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.primaryColor)
                        }
                    }
                    
                    Button(action: { showingCenterProfile = true }) {
                        ZStack {
                            Circle()
                                .fill(themeManager.primaryColor.opacity(0.1))
                                .frame(width: 46, height: 46)
                            
                            AsyncImage(url: URL(string: "\(AuthService.shared.baseURL.replacingOccurrences(of: "/api", with: ""))/static/uploads/profile_\(AuthService.shared.currentUser?.id ?? 0).jpg?t=\(AuthService.shared.profileImageUpdateTrigger.uuidString)")) { phase in
                                switch phase {
                                case .empty:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(themeManager.primaryColor.opacity(0.3))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure(_):
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(themeManager.primaryColor.opacity(0.3))
                                @unknown default:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(themeManager.primaryColor.opacity(0.3))
                                }
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                            .id(AuthService.shared.profileImageUpdateTrigger)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 46, height: 46)
                        }
                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Top Stats Row
                    HStack(spacing: 12) {
                        DashboardStatChip(
                            title: "Active Classes",
                            value: "\(providerSummary?.classes_count ?? 12)",
                            color: Color(hex: "#7B61FF"),
                            icon: "graduationcap.fill"
                        )
                        DashboardStatChip(
                            title: "Capacity",
                            value: providerSummary?.capacity ?? "86%",
                            color: Color(hex: "#00BC8C"),
                            icon: "person.3.fill"
                        )
                        DashboardStatChip(
                            title: "Staff Ratio",
                            value: providerSummary?.staff_ratio ?? "1:8",
                            color: Color(hex: "#F6C23E"),
                            icon: "person.2.fill"
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Main Action Grid
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                        NavigationLink(destination: AIInsightsView()) {
                            BigActionCard(title: "Smart Insights", icon: "brain.headlight.fill", subtitle: "Recommendations", color: .red)
                        }
                        
                        NavigationLink(destination: CenterStatusView()) {
                            BigActionCard(title: "Center Status", icon: "building.columns.fill", subtitle: "Status: \(currentCenterStatus)", color: .green)
                        }
                        
                        NavigationLink(destination: ParentStatusView()) {
                            BigActionCard(title: "Parent Status", icon: "person.text.rectangle.fill", subtitle: "\(providerSummary?.parent_status_count ?? 0) Active Today", color: .blue)
                        }
                        
                        NavigationLink(destination: StaffStatusView()) {
                            BigActionCard(title: "Staff Status", icon: "person.2.badge.gearshape.fill", subtitle: "Management", color: .orange)
                        }
                        
                        NavigationLink(destination: DailyNotesView()) {
                            BigActionCard(title: "Daily Notes", icon: "doc.text.fill", subtitle: "Reports", color: .purple)
                        }
                        
                        Button(action: { showingEmergencyAlert = true }) {
                            BigActionCard(title: "Emergency", icon: "exclamationmark.triangle.fill", subtitle: "Alert Parents", color: .red)
                        }
                    }
                    .padding(.horizontal)
                    
                }
            }
            .opacity(isLoading ? 0.6 : 1.0)
            .animation(.easeIn(duration: 0.3), value: isLoading)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToNotifications) { NotificationsView() }
        .navigationDestination(isPresented: $showingCenterProfile) { ProfileView() }
        .onAppear {
            loadAllData()
        }
        .alert("Send Emergency Alert?", isPresented: $showingEmergencyAlert) {
            TextField("Emergency message...", text: $emergencyMessage)
            Button("Cancel", role: .cancel) { emergencyMessage = "" }
            Button("SEND NOW", role: .destructive) { sendAlert() }
        } message: {
            Text("This will send a high-priority notification to all parents with active bookings. Use only for real emergencies.")
        }
        .navigationDestination(for: String.self) { route in
            switch route {
            case "attendance": AttendanceView()
            case "expected_attendance": ExpectedAttendanceView()
            case "revenue": RevenueOverviewView()
            case "nap_schedule": NapScheduleView()
            case "log_activity": LogActivityView()
            case "activity_leo", "activity_emma": DailyTimelineView()
            case "activities": ActivitiesView()
            case "incidents": IncidentLogView()
            case "check_in_out": CheckInOutView()
            case "class_schedules": ClassSchedulesView()
            case "enrollment": PreschoolEnrollmentView()
            case "staff_management": StaffManagementView()
            default: EmptyView()
            }
        }
    }
    
    private func loadAllData() {
        guard !isLoading else { return }
        guard let userId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            do {
                async let profileTask = ProfileService.shared.getProfile(userId: userId)
                async let statusTask = ProviderStatsService.shared.fetchCenterStatus(providerId: userId)
                async let summaryTask = ProviderStatsService.shared.fetchProviderSummary(providerId: userId)
                async let activitiesTask = ActivityService.shared.fetchProviderActivities(providerId: userId)
                async let mealsTask = MealService.shared.fetchProviderMeals(providerId: userId)
                
                let (profile, statusData, summary, activities, meals) = (
                    try? await profileTask,
                    try? await statusTask,
                    try? await summaryTask,
                    (try? await activitiesTask) ?? [],
                    (try? await mealsTask) ?? []
                )
                
                await MainActor.run {
                    if let profile = profile { self.centerProfile = profile }
                    if let statusData = statusData { self.currentCenterStatus = statusData.current_status }
                    if let summary = summary {
                        if self.providerSummary?.classes_count != summary.classes_count || self.providerSummary?.capacity != summary.capacity {
                            self.providerSummary = summary 
                        }
                    }
                    
                    var updates: [ProviderActivityUpdate] = []
                    for a in activities.prefix(5) {
                        let date = parseDate(a.created_at)
                        updates.append(ProviderActivityUpdate(
                            id: "act_\(a.id)",
                            name: "Activity", 
                            initial: "A",
                            description: "\(a.activity_type): \(a.notes ?? "")",
                            time: formatTime(date),
                            date: date,
                            color: themeManager.primaryColor
                        ))
                    }
                    for m in meals.prefix(5) {
                        let date = parseDate(m.created_at)
                        updates.append(ProviderActivityUpdate(
                            id: "meal_\(m.id)",
                            name: "Meal",
                            initial: "M",
                            description: "\(m.meal_type): \(m.food_item)",
                            time: formatTime(date),
                            date: date,
                            color: .orange
                        ))
                    }
                    
                    let sorted = Array(updates.sorted(by: { $0.date > $1.date }).prefix(5))
                    if self.recentUpdates.count != sorted.count || self.recentUpdates.first?.id != sorted.first?.id {
                        self.recentUpdates = sorted 
                    }
                    
                    self.isLoading = false
                }
            }
        }
    }
    
    private func parseDate(_ dateString: String) -> Date {
        for formatter in Self.multiFormatters {
            if let date = formatter.date(from: dateString) { return date }
        }
        return Date.distantPast
    }
    
    private func formatTime(_ date: Date) -> String {
        return Self.timeFormatter.string(from: date)
    }
    
    private var centerDisplayName: String {
        if let name = AuthService.shared.currentUser?.full_name, !name.isEmpty {
            return name
        }
        if let email = AuthService.shared.currentUser?.email {
            return email.split(separator: "@").first?.capitalized ?? "Provider"
        }
        if let name = centerProfile?["center_name"] as? String {
            return name
        }
        switch appRouter.currentRole {
        case .preschool: return "My Preschool"
        case .daycare: return "My Daycare"
        default: return "Care Provider"
        }
    }
    
    private func sendAlert() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        let msg = emergencyMessage.isEmpty ? "There is an emergency at the center. Please contact us immediately." : emergencyMessage
        
        isSendingAlert = true
        Task {
            do {
                _ = try await NotificationService.shared.sendEmergencyAlert(providerId: providerId, message: msg)
                DispatchQueue.main.async {
                    isSendingAlert = false
                    emergencyMessage = ""
                }
            } catch {
                DispatchQueue.main.async {
                    isSendingAlert = false
                }
            }
        }
    }
}

// MARK: - Subcomponents
struct DashboardStatChip: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color)
                    .opacity(0.1)
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(title)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5)
    }
}

struct RoutineStep: View {
    let title: String
    var isComplete: Bool = false
    var isCurrent: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(isCurrent ? Color(hex: "#008A3D") : AppTheme.textSecondary)
                .fontWeight(isCurrent ? .bold : .medium)
            
            Circle()
                .fill(isComplete || isCurrent ? Color(hex: "#008A3D") : Color.gray.opacity(0.2))
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .scaleEffect(isCurrent ? 2 : 1)
                        .opacity(isCurrent ? 0.3 : 0)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

struct ManageCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .opacity(0.12)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(14)
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.08), lineWidth: 1))
    }
}

struct DashboardMessageRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let name: String
    let message: String
    let time: String
    let isUnread: Bool
    let initial: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.surface)
                    .frame(width: 48, height: 48)
                Text(initial)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Text(time)
                        .font(.system(size: 10))
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
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
    }
}

struct ProfileSheetButton: View {
    let title: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isDestructive ? Color.white.opacity(0.2) : AppTheme.background)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .foregroundColor(isDestructive ? .white : AppTheme.textPrimary)
                        .font(.subheadline)
                }
                
                Text(title)
                    .foregroundColor(isDestructive ? .white : AppTheme.textPrimary)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(isDestructive ? .white.opacity(0.7) : AppTheme.textSecondary)
            }
            .padding()
            .background(isDestructive ? Color(hex: "#BA1A1A") : AppTheme.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isDestructive ? Color.clear : Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

struct HomeActivityRow: View {
    let name: String
    let description: String
    let timeOrStatus: String
    let statusColor: Color
    let initial: String
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color.gray.opacity(0.05))
                .frame(width: 45, height: 45)
                .overlay(Text(initial).fontWeight(.bold).foregroundColor(AppTheme.textSecondary))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(description)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Text(timeOrStatus)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background { statusColor.opacity(0.1) }
                .cornerRadius(6)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5)
    }
}

// Helper for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct BigActionCard: View {
    let title: String
    let icon: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(AppTheme.surface)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
    }
}

struct ProviderManagementCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color)
                    .opacity(0.12)
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.cardBackground)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
    }
}
