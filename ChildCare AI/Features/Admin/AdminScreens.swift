import SwiftUI

// MARK: - User Management Screens
public struct ParentManagementScreen: View {
    public var body: some View { AdminListScreen(title: "Parent Management", icon: "person.2.fill") }
}

public struct PreschoolManagementScreen: View {
    public var body: some View { AdminListScreen(title: "Preschools", icon: "book.circle.fill") }
}

public struct DaycareManagementScreen: View {
    public var body: some View { AdminListScreen(title: "Daycare Centers", icon: "building.2.fill") }
}



public struct VerificationWorkflowScreen: View {
    public var body: some View { AdminListScreen(title: "Pending Approvals", icon: "checkmark.seal.fill") }
}

// MARK: - Core Operations Screens
public struct RevenueAnalyticsScreen: View {
    public var body: some View { AdminDashboardScreen(title: "Revenue Analytics", icon: "dollarsign.circle.fill", dataPoints: ["MRR: $45.2K", "YTD: $310K", "Subscribers: 1,204"]) }
}

public struct BookingMonitoringScreen: View {
    public var body: some View { AdminListScreen(title: "Live Bookings", icon: "calendar.badge.clock") }
}

public struct SystemMetricsScreen: View {
    public var body: some View { AdminDashboardScreen(title: "Matching Performance", icon: "bolt.shield.fill", dataPoints: ["Match Success Rate: 94%", "Avg Request latency: 1.2s", "Top Factor: Distance Filter"]) }
}

// MARK: - Report Screens
public struct BookingReportScreen: View {
    public var body: some View { AdminReportScreen(title: "Monthly Booking Reports") }
}

public struct AnalyticsReportScreen: View {
    public var body: some View { AdminReportScreen(title: "Revenue Ledger") }
}

public struct MetricsReportScreen: View {
    public var body: some View { AdminReportScreen(title: "Platform Usage Metrics") }
}

public struct MatchingInsightsScreen: View {
    public var body: some View { AdminReportScreen(title: "Matching Logic Insights") }
}

// MARK: - Reusable Admin Screen Templates
struct AdminListScreen: View {
    let title: String
    let icon: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<5) { index in
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("User / Entity #\(index + 1)")
                                .font(.headline)
                            Text("ID: 104\(index) • Status: Active")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        Button("Manage") {}
                            .font(.footnote)
                            .foregroundColor(.indigo)
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(AppTheme.cornerRadius)
                    .shadow(color: Color.black.opacity(0.05), radius: 3)
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AdminDashboardScreen: View {
    let title: String
    let icon: String
    let dataPoints: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(.indigo)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    ForEach(dataPoints, id: \.self) { metric in
                        HStack {
                            Text(metric)
                                .font(.headline)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(AppTheme.cornerRadius)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AdminReportScreen: View {
    let title: String
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Report Generation")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Text("Compile data for \(title).")
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
            
            PrimaryButton(title: "Export to CSV") { }
                .padding(.top, 30)
                
            Spacer()
        }
        .padding()
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
