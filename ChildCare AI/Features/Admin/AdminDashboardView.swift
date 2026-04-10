import SwiftUI

public struct AdminDashboardView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var themeManager: ThemeManager
    @State private var navigateToNotifications = false
    @State private var showingProfile = false
    @State private var stats: PlatformStats?
    @State private var pendingCount = 0
    @State private var isLoading = false
    
    public init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            // Header Section
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("Admin Dashboard")
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
                    
                    Button(action: { showingProfile = true }) {
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
                                        .frame(width: 46, height: 46)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 46, height: 46)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                                case .failure(_):
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(themeManager.primaryColor.opacity(0.3))
                                        .frame(width: 46, height: 46)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                @unknown default:
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .foregroundColor(themeManager.primaryColor.opacity(0.3))
                                        .frame(width: 46, height: 46)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                }
                            }
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
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Main Stats Grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Overview Metrics")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                            NavigationLink(destination: AdminManagementView(selectedTab: $selectedTab)) {
                                StatCard(title: "Active Users", value: "\(stats?.users.total ?? 0)", icon: "person.2.fill", color: .blue, subtitle: "Total Accounts")
                            }
                            
                            NavigationLink(destination: AdminLiveBookingsView()) {
                                StatCard(title: "Live Bookings", value: "\(stats?.bookings.live_today ?? 0)", icon: "checkmark.seal.fill", color: .green, subtitle: "Today")
                            }
                            
                            NavigationLink(destination: PendingUsersView()) {
                                StatCard(title: "Pending Users", value: "\(stats?.metrics.pending_verification ?? 0)", icon: "clock.badge.checkmark.fill", color: .orange, subtitle: "Action Required")
                            }
                            
                            NavigationLink(destination: AdminSystemEfficiencyView()) {
                                StatCard(title: "Match Success", value: stats?.metrics.match_success ?? "0%", icon: "bolt.shield.fill", color: .purple, subtitle: "System Efficiency")
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Platform Reports - LARGE BUTTON
                    NavigationLink(destination: AdminReportsView()) {
                        HStack(spacing: 20) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.primaryColor.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "chart.bar.doc.horizontal.fill")
                                    .font(.title2)
                                    .foregroundColor(themeManager.primaryColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Platform Reports")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("View detailed analytics for parents, preschools, and daycares.")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(20)
                        .background(AppTheme.surface)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(AppTheme.divider, lineWidth: 1))
                    }
                    .padding(.horizontal)
                    
                    // AIPerformance Preview
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Matching Performance")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            NavigationLink(destination: AdminSystemEfficiencyView()) {
                                Text("Full Report")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.primaryColor)
                            }
                        }
                        .padding(.horizontal)
                        
                        AdminSystemEfficiencyView.CompactInsightCard()
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.top, 16)
            }
            .background(AppTheme.background)
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToNotifications) {
            NotificationsView()
        }
        .navigationDestination(isPresented: $showingProfile) {
            ProfileView()
        }
        .onAppear {
            loadDashboardData()
        }
    }
    
    private func loadDashboardData() {
        isLoading = true
        Task {
            do {
                async let statsTask = AdminService.shared.fetchStats()
                async let pendingTask = ProfileService.shared.fetchPendingUsers()
                
                let (fetchedStats, pending) = try await (statsTask, pendingTask)
                
                await MainActor.run {
                    self.stats = fetchedStats
                    self.pendingCount = pending.count
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

// MARK: - Subcomponents
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.textSecondary.opacity(0.7))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.divider, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}
