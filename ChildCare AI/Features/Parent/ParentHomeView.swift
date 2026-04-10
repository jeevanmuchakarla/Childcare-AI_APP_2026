import SwiftUI
import Combine

public struct ParentHomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var authService = AuthService.shared
    @EnvironmentObject var messageStore: MessageStore
    @State private var showingAvatarMenu = false
    @State private var showingAIRecommendation = false
    
    @State private var preschoolCount: Int = 0
    @State private var daycareCount: Int = 0
    @State private var children: [ChildModel] = []
    
    @State private var navigateToFeatures = false
    @State private var navigateToReports = false
    @State private var navigateToProfile = false
    @State private var navigateToEmergency = false
    @State private var navigateToPayments = false
    @State private var navigateToCategory = false
    @State private var navigateToSearch = false
    @State private var navigateToChildren = false
    @State private var selectedCategory: String = "Preschools"
    @State private var navigateToBookings = false
    @State private var navigateToNotifications = false
    @State private var latestActivity: (childName: String, activity: String, time: String, icon: String)? = nil
    @State private var dailyReportNotification: NotificationModel? = nil
    @State private var navigateToDailyReport = false
    @State private var selectedChildForReport: ChildModel? = nil
    @State private var showingChildSelection = false
    @State private var timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    @State private var isLoadingLatestActivity = false
    @State private var isInitialLoad = true
    
    // Parenting Insights Data
    struct ParentingInsight: Identifiable {
        let id = UUID()
        let title: String
        let sub: String
        let content: String
        let icon: String
        let color: Color
        var action: (() -> Void)? = nil
    }
    
    @State private var selectedInsight: ParentingInsight? = nil
    @State private var navigateToInsightDetail = false
    
    private var insights: [ParentingInsight] {
        [
            ParentingInsight(
                title: "Early Learning",
                sub: "App features & growth paths.",
                content: "", // Opens App Features
                icon: "lightbulb.fill",
                color: .orange,
                action: { navigateToFeatures = true }
            ),
            ParentingInsight(
                title: "Healthy Habits",
                sub: "Top 5 nutritious snacks.",
                content: "Establishing healthy eating habits early sets the foundation for a lifetime of wellness. Focus on colorful vegetables, balanced proteins, and minimizing processed sugars. Involving children in meal prep can increase their willingness to try new nutritious foods.",
                icon: "leaf.fill",
                color: .green
            ),
            ParentingInsight(
                title: "Sleep Routines",
                sub: "Better rest for kids.",
                content: "A consistent bedtime routine helps children wind down and improves sleep quality. Try reading a book, a warm bath, or gentle music at the same time every night to signal to their body that it's time to rest.",
                icon: "moon.stars.fill",
                color: .indigo
            ),
            ParentingInsight(
                title: "Potty Training",
                sub: "Stress-free transition.",
                content: "Patience and positive reinforcement are key to successful potty training. Look for signs of readiness, such as staying dry for longer periods and showing interest in the bathroom, and celebrate every small success along the way.",
                icon: "figure.walk",
                color: .blue
            ),
            ParentingInsight(
                title: "Social Skills",
                sub: "Building friendships.",
                content: "Encourage sharing and empathy through playdates and group activities. Helping children identify and express their feelings is a crucial step in developing strong social connections and navigating world with kindness.",
                icon: "person.2.fill",
                color: .purple
            ),
            ParentingInsight(
                title: "Nutrition Tips",
                sub: "Healthy meal planning.",
                content: "Kids need a balance of proteins, healthy fats, and complex carbohydrates. Try to include a variety of colors on their plate and introduce new foods multiple times as it can take up to 10-15 exposures for a child to accept a new taste.",
                icon: "heart.text.square.fill",
                color: .red
            ),
            ParentingInsight(
                title: "Development",
                sub: "Key milestones guide.",
                content: "Track your child's physical, cognitive, and social milestones. Every child develops at their own pace, but early identification of developmental needs can lead to better outcomes through timely support and enrichment.",
                icon: "star.bubble.fill",
                color: .teal
            ),
            ParentingInsight(
                title: "Safety First",
                sub: "Childproofing 101.",
                content: "Protect your little ones by securing heavy furniture, covering electrical outlets, and keeping small objects out of reach. Regularly review safety guidelines for toys and outdoor equipment to ensure a secure environment for play.",
                icon: "checkmark.shield.fill",
                color: .green
            )
        ]
    }
    
    private static let relativeFormatter = RelativeDateTimeFormatter()
    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
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
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            GeometryReader { proxy in
                ZStack {
                    Circle()
                        .fill(themeManager.primaryColor)
                        .opacity(0.12)
                        .frame(width: 250)
                        .blur(radius: 20)
                        .offset(x: proxy.size.width - 100, y: -50)
                    
                    Circle()
                        .fill(Color(hex: "#FFD166"))
                        .opacity(0.1)
                        .frame(width: 200)
                        .blur(radius: 20)
                        .offset(x: -50, y: 150)
                }
            }
            .ignoresSafeArea()
            .padding(.top, -100)
            
                VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Header
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Good morning,")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(AuthService.shared.currentUser?.full_name ?? "Parent")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: { navigateToNotifications = true }) {
                                    ZStack {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 20))
                                        
                                        if messageStore.unreadNotificationCount > 0 {
                                            Circle()
                                                .fill(.red)
                                                .frame(width: 10, height: 10)
                                                .offset(x: 8, y: -8)
                                        }
                                    }
                                    .foregroundColor(themeManager.primaryColor)
                                    .padding(10)
                                    .background(Circle().fill(Color.white).shadow(radius: 2))
                                }
                                
                                Menu {
                                    Button(action: { navigateToProfile = true }) {
                                        Label("View Profile", systemImage: "person.crop.circle")
                                    }
                                    Button(role: .destructive, action: { appRouter.logout() }) {
                                        Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                                    }
                                } label: {
                                    AsyncImage(url: URL(string: "\(AuthService.shared.baseURL.replacingOccurrences(of: "/api", with: ""))/static/uploads/profile_\(AuthService.shared.currentUser?.id ?? 0).jpg?t=\(AuthService.shared.profileImageUpdateTrigger.uuidString)")) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 44, height: 44)
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 44, height: 44)
                                                .clipShape(Circle())
                                        case .failure(_):
                                            Image(systemName: "person.crop.circle.fill")
                                                .resizable()
                                                .frame(width: 44, height: 44)
                                                .foregroundColor(themeManager.primaryColor)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .background(Circle().fill(Color.white))
                                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                                    .id(AuthService.shared.profileImageUpdateTrigger)
                                }
                            }
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.top, 10)
                        
                        // AI recommendation card - Larger and more prominent
                        Button(action: { showingAIRecommendation = true }) {
                            HStack(spacing: 20) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 64, height: 64)
                                    .background(Color.white.opacity(0.25))
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Smart Matches")
                                        .font(.system(size: 24, weight: .black))
                                        .foregroundColor(.white)
                                    Text("Get instant matches & expert advice")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white.opacity(0.95))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 28)
                            .padding(.horizontal, 24)
                            .background(themeManager.isIndian ? Color(hex: "#FF9933") : themeManager.primaryColor)
                            .cornerRadius(24)
                            .shadow(color: (themeManager.isIndian ? Color(hex: "#FF9933") : themeManager.primaryColor).opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.bottom, 8)
                        
                        // Category Square Cards
                        HStack(spacing: 16) {
                            CategorySquareCard(title: "Preschools", count: preschoolCount, subtitle: "\(preschoolCount) Verified", icon: "book.fill", color: themeManager.isIndian ? .orange : .blue, isIndianTheme: themeManager.isIndian) {
                                selectedCategory = "Preschools"
                                navigateToCategory = true
                            }
                            CategorySquareCard(title: "Daycares", count: daycareCount, subtitle: "\(daycareCount) Verified", icon: "building.2.fill", color: themeManager.isIndian ? .green : .red, isIndianTheme: themeManager.isIndian) {
                                selectedCategory = "Daycares"
                                navigateToCategory = true
                            }
                        }
                        .padding(.horizontal, AppTheme.padding)
                        
                        // Children's Daily Update Button
                        Button(action: {
                            if children.count > 1 {
                                showingChildSelection = true
                            } else if let child = children.first {
                                selectedChildForReport = child
                                navigateToDailyReport = true
                            } else {
                                navigateToDailyReport = true // Show "No children" message
                            }
                        }) {
                            HStack(spacing: 20) {
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(.white)
                                    .frame(width: 54, height: 54)
                                    .background(Color.white.opacity(0.18))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Children's Daily Update")
                                        .font(.system(size: 19, weight: .bold))
                                        .foregroundColor(.white)
                                        
                                    if let lastReport = dailyReportNotification {
                                        Text(lastReport.message)
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.95))
                                            .lineLimit(2)
                                    } else {
                                        Text("Check today's activities & meals")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.95))
                                    }
                                }
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                            }
                            .padding(22)
                            .background(
                                themeManager.isIndian ? 
                                LinearGradient(gradient: Gradient(colors: [Color(hex: "#138808"), Color(hex: "#107007")]), startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(gradient: Gradient(colors: [Color(hex: "#7D61FF"), Color(hex: "#5A3FE0")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(24)
                            .shadow(color: (themeManager.isIndian ? Color(hex: "#138808") : Color(hex: "#7D61FF")).opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .sheet(isPresented: $showingChildSelection) {
                            ChildSelectionView(children: children) { child in
                                selectedChildForReport = child
                                navigateToDailyReport = true
                            }
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.top, 4)
                        
                        // Insights - Vertical Stack
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Parenting Insights")
                                .font(.system(size: 22, weight: .black))
                                .foregroundColor(AppTheme.textPrimary)
                                .padding(.horizontal, AppTheme.padding)
                            
                            VStack(spacing: 12) {
                                ForEach(insights) { insight in
                                    Button(action: {
                                        if let action = insight.action {
                                            action()
                                        } else {
                                            selectedInsight = insight
                                            navigateToInsightDetail = true
                                        }
                                    }) {
                                        InsightRow(title: insight.title, sub: insight.sub, icon: insight.icon, color: insight.color)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, AppTheme.padding)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingAIRecommendation) {
            AIRecommendationFlow()
        }
        .navigationDestination(isPresented: $navigateToFeatures) {
            AppFeaturesView()
        }
        .navigationDestination(isPresented: $navigateToCategory) {
            ProviderCategoryListView(categoryTitle: selectedCategory)
        }
        .navigationDestination(isPresented: $navigateToNotifications) {
            NotificationsView()
        }
        .navigationDestination(isPresented: $navigateToProfile) {
            ProfileView()
        }
        .navigationDestination(isPresented: $navigateToDailyReport) {
            if let child = selectedChildForReport {
                DailyReportOverviewView(childId: child.id, childName: child.name)
            } else if let child = children.first {
                 DailyReportOverviewView(childId: child.id, childName: child.name)
            } else {
                Text("No children added. Please add a child in the Children tab.")
            }
        }
        .navigationDestination(isPresented: $navigateToInsightDetail) {
            if let insight = selectedInsight {
                ParentingInsightDetailView(
                    title: insight.title,
                    content: insight.content,
                    icon: insight.icon,
                    color: insight.color
                )
            }
        }
        .onAppear {
            refreshAllData()
        }
        .onReceive(timer) { _ in
            refreshAllData()
        }
    }
    
    private func refreshAllData() {
        fetchCounts()
        fetchChildren()
        fetchNotifications()
    }
    
    private func fetchCounts() {
        Task {
            do {
                let counts = try await DiscoveryService.shared.fetchCounts()
                await MainActor.run {
                    self.preschoolCount = counts["Preschool"] ?? 0
                    self.daycareCount = counts["Daycare"] ?? 0
                }
            } catch {}
        }
    }
    
    private func fetchChildren() {
        guard let parentId = AuthService.shared.currentUser?.id else { return }
        Task {
            do {
                let fetchedChildren = try await ChildService.shared.fetchChildren(parentId: parentId)
                await MainActor.run {
                    self.children = fetchedChildren
                }
            } catch {}
        }
    }
    
    private func fetchNotifications() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        Task {
            await messageStore.refreshNotificationCount(userId: userId)
            
            do {
                let fetched = try await NotificationService.shared.fetchNotifications(userId: userId)
                let latestReport = fetched.first(where: { $0.title.contains("Daily Report") || $0.message.contains("daily report") })
                
                await MainActor.run {
                    self.dailyReportNotification = latestReport
                    
                    // Fallback to latest activity if notification is missing or generic
                    if latestReport == nil || latestReport?.message == "A new daily report has been shared for your child!" {
                        fetchLatestActivityFallback()
                    }
                }
            } catch {
                fetchLatestActivityFallback()
            }
        }
    }
    
    private func fetchLatestActivityFallback() {
        guard let parentId = AuthService.shared.currentUser?.id else { return }
        Task {
            do {
                let children = try await ChildService.shared.fetchChildren(parentId: parentId)
                let now = Date()
                
                var topActivity: ActivityModel? = nil
                
                for child in children {
                    let activities = try await ActivityService.shared.fetchChildActivities(childId: child.id)
                    let today = activities.filter {
                        if let date = self.parseDateTime($0.created_at) {
                            return now.timeIntervalSince(date) < 24 * 3600
                        }
                        return false
                    }
                    
                    // Priority: Report, then Mood, then newest activity
                    let report = today.filter { $0.activity_type == "Report" }.first
                    let mood = today.filter { $0.activity_type == "Mood" }.first
                    
                    let candidate = report ?? mood ?? today.first
                    if let c = candidate {
                        if topActivity == nil || c.created_at > topActivity!.created_at {
                            topActivity = c
                        }
                    }
                }
                
                if let best = topActivity {
                    await MainActor.run {
                        let msg = best.notes ?? "A new update for your child is ready!"
                        // Inject into a mock notification for the UI
                        self.dailyReportNotification = NotificationModel(
                            id: -1,
                            user_id: parentId,
                            title: "Daily Update",
                            message: msg,
                            type: "info",
                            child_id: best.child_id,
                            is_read: false,
                            created_at: best.created_at
                        )
                    }
                }
            } catch {}
        }
    }
    
    private func parseDateTime(_ dateString: String) -> Date? {
        if let date = Self.isoFormatter.date(from: dateString) {
            return date
        }
        for formatter in Self.multiFormatters {
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
    
    private func parseDate(_ dateString: String) -> Date { 
        parseDateTime(dateString) ?? Date()
    }
    private func iconForActivity(_ type: String) -> String { "star.fill" }
}

struct CategorySquareCard: View {
    let title: String
    let count: Int
    let subtitle: String?
    let icon: String
    let color: Color
    var isIndianTheme: Bool = false
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                VStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(subtitle ?? "\(count) Available")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(isIndianTheme ? 0.1 : 0.05), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isIndianTheme ? Color.gray.opacity(0.2) : Color.black.opacity(0.02), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InsightRow: View {
    let title: String
    let sub: String
    let icon: String
    let color: Color
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)
                Text(sub)
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(16)
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.divider.opacity(0.5), lineWidth: 1)
        )
    }
}
