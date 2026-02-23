import SwiftUI

public struct AdminHomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var showingProfile = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Welcome & High level KPI
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Platform Overview")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Real-time metrics for ChildCare AI™")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.horizontal, AppTheme.padding)
                    .padding(.top, 10)
                    
                    HStack(spacing: 16) {
                        AdminKPICard(title: "Active Users", value: "12.4K", color: .blue)
                        AdminKPICard(title: "MRR", value: "$45.2K", color: .green)
                        AdminKPICard(title: "Pending Verifications", value: "32", color: .orange)
                    }
                    .padding(.horizontal, AppTheme.padding)
                    
                    // User Management Section
                    AdminSection(title: "User Management") {
                        VStack(spacing: 12) {
                            AdminNavRow(title: "Parents", icon: "person.2.fill", color: .blue, destination: AnyView(ParentManagementScreen()))
                            AdminNavRow(title: "Preschools", icon: "book.circle.fill", color: .indigo, destination: AnyView(PreschoolManagementScreen()))
                            AdminNavRow(title: "Daycare Centers", icon: "building.2.fill", color: .teal, destination: AnyView(DaycareManagementScreen()))
                            AdminNavRow(title: "Babysitters", icon: "figure.walk", color: .pink, destination: AnyView(BabysitterManagementScreen()))
                            AdminNavRow(title: "Approvals", icon: "checkmark.seal.fill", color: .orange, destination: AnyView(VerificationWorkflowScreen()))
                        }
                    }
                    
                    // Core Operations Section
                    AdminSection(title: "Core Operations") {
                        VStack(spacing: 12) {
                            AdminNavRow(title: "Revenue", icon: "dollarsign.circle.fill", color: .green, destination: AnyView(RevenueAnalyticsScreen()))
                            AdminNavRow(title: "Bookings", icon: "calendar.badge.clock", color: .cyan, destination: AnyView(BookingMonitoringScreen()))
                            AdminNavRow(title: "AI Performance", icon: "brain.head.profile", color: .purple, destination: AnyView(AIMetricsScreen()))
                        }
                    }
                    
                    // Admin Reports Section
                    AdminSection(title: "System Reports") {
                        VStack(spacing: 12) {
                            AdminNavRow(title: "Booking Reports", icon: "chart.bar.doc.horizontal", color: .gray, destination: AnyView(BookingReportScreen()))
                            AdminNavRow(title: "Revenue Reports", icon: "chart.pie.fill", color: .gray, destination: AnyView(AnalyticsReportScreen()))
                            AdminNavRow(title: "Usage Reports", icon: "waveform.path.ecg", color: .gray, destination: AnyView(MetricsReportScreen()))
                            AdminNavRow(title: "AI Insights", icon: "sparkles.rectangle.stack", color: .gray, destination: AnyView(AIInsightsScreen()))
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Admin Dashboard")
            .navigationBarItems(trailing:
                Menu {
                    Button(action: { showingProfile = true }) { Label("Admin Settings", systemImage: "gear") }
                    Button(role: .destructive, action: { appRouter.logout() }) { Label("Logout", systemImage: "rectangle.portrait.and.arrow.right") }
                } label: {
                    Image(systemName: "person.badge.key.fill")
                        .foregroundColor(.indigo)
                        .font(.title3)
                }
            )
            .background(
                NavigationLink(destination: Text("Admin Settings"), isActive: $showingProfile) { EmptyView() }
            )
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
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, AppTheme.padding)
            
            content()
                .padding(.horizontal, AppTheme.padding)
        }
        .padding(.top, 10)
    }
}

struct AdminNavRow: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
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
