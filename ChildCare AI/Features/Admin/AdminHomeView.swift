import SwiftUI

public struct AdminHomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var authService = AuthService.shared
    @State private var showingProfile = false
    @State private var navigateToNotifications = false
    @State private var stats: PlatformStats?
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Spacer().frame(height: 10)
                        
                        // Standard Header
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Good morning,")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text(AuthService.shared.currentUser?.full_name ?? "Admin")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                            Spacer()
                            
                            // Notifications Bell
                            Button(action: { navigateToNotifications = true }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 44, height: 44)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5)
                                    
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(themeManager.primaryColor)
                                    
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 10, height: 10)
                                        .offset(x: 8, y: -8)
                                }
                            }
                            .buttonStyle(BounceButtonStyle())
                            
                            Menu {
                                Button(action: { showingProfile = true }) {
                                    Label("View Profile", systemImage: "person.crop.circle")
                                }
                                Button(role: .destructive, action: { appRouter.logout() }) {
                                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                                }
                            } label: {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .foregroundColor(themeManager.primaryColor)
                                    .background(Circle().fill(Color.white))
                                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                            }
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.top, 10)
                        
                        // Welcome & High level KPI
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Platform Overview")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Real-time metrics for ChildCare AI™")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.horizontal, AppTheme.padding)
                        .padding(.top, 4)
                        
                        HStack(spacing: 16) {
                            AdminKPICard(
                                title: "Active Users", 
                                value: "\(stats?.users.total ?? 0)", 
                                color: .blue
                            )
                            AdminKPICard(
                                title: "Total Revenue", 
                                value: "$\(String(format: "%.1f", (stats?.revenue.total_usd ?? 0)/1000))K", 
                                color: .green
                            )
                            AdminKPICard(
                                title: "Pending", 
                                value: "\(stats?.metrics.pending_verification ?? 0)",
                                color: .orange
                            )
                        }
                        .padding(.horizontal, AppTheme.padding)
                        
                        // User Management Section
                        AdminSection(title: "Management") {
                            VStack(spacing: 12) {
                                AdminNavRow(title: "Users", icon: "person.2.fill", color: .blue)
                                AdminNavRow(title: "Approvals", icon: "checkmark.seal.fill", color: .orange)
                                AdminNavRow(title: "Bookings", icon: "calendar.badge.clock", color: .cyan)
                            }
                        }
                        
                        // Core Operations Section
                        AdminSection(title: "Analytics") {
                            VStack(spacing: 12) {
                                AdminNavRow(title: "Revenue", icon: "dollarsign.circle.fill", color: .green)
                                AdminNavRow(title: "AI Performance", icon: "brain.head.profile", color: .purple)
                            }
                        }
                    }
                }
            }
            .task {
                do {
                    stats = try await AdminService.shared.fetchStats()
                } catch {
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $navigateToNotifications) {
                NotificationsView()
            }
            .navigationDestination(isPresented: $showingProfile) {
                ProfileView()
            }
            .navigationDestination(for: String.self) { title in
                adminDestination(for: title)
            }
        }
    }
    
    @ViewBuilder
    private func adminDestination(for title: String) -> some View {
        switch title {
        case "Users": AdminManagementView(initialTab: 0)
        case "Approvals": PendingUsersView()
        case "Bookings": AdminManagementView(initialTab: 2)
        case "Revenue": RevenueAnalyticsScreen()
        case "AI Performance": AIMetricsScreen()
        case "Booking Reports": BookingReportScreen()
        case "Revenue Reports": AnalyticsReportScreen()
        case "Usage Reports": MetricsReportScreen()
        case "AI Insights": AIInsightsScreen()
        default: EmptyView()
        }
    }
}

// MARK: - Admin Helper Views
struct AdminKPICard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct AdminSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.padding)
            
            content
                .padding(.horizontal, AppTheme.padding)
        }
        .padding(.top, 10)
    }
}

struct AdminNavRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        NavigationLink(value: title) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppTheme.textPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(AppTheme.cornerRadius)
            .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        }
    }
}
