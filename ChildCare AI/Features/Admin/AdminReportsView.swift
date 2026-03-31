import SwiftUI

public struct AdminReportsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var stats: PlatformStats?
    @State private var isLoading = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reports & Analytics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                            .padding(.top)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ReportStatBox(title: "Active Parents", value: "\(stats?.users.parents ?? 0)", icon: "person.2.fill", color: .blue)
                            ReportStatBox(title: "Active Providers", value: "\(stats?.users.centers ?? 0)", icon: "building.2.fill", color: themeManager.primaryColor)
                            
                            NavigationLink(destination: AdminBookingReportsView()) {
                                ReportStatBox(title: "Total Bookings", value: "\(stats?.bookings.total ?? 0)", icon: "calendar", color: .purple)
                            }
                            
                            NavigationLink(destination: AdminAIEfficiencyView()) {
                                ReportStatBox(title: "Match Success", value: stats?.metrics.match_success ?? "0%", icon: "sparkles", color: .orange)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Platform Growth Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Platform Growth")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                Text("Last 30 Days")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color(hex: "#F1F4F9"))
                                    .cornerRadius(8)
                            }
                            
                            GrowthChartView(data: [40, 60, 45, 80, 55, 90, 70, 85, 65, 95, 80, 100])
                                .frame(height: 120)
                        }
                        .padding(20)
                        .background(AppTheme.surface)
                        .cornerRadius(24)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                        .padding(.horizontal)
                        
                        Text("Recent Reports")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ReportRow(title: "Daily Statistics Update", date: "Today", size: "1.2 MB")
                            ReportRow(title: "Monthly Revenue Report", date: "Last Month", size: "2.4 MB")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
                .opacity(isLoading ? 0.6 : 1.0)
            }
        }
        .background(AppTheme.background.opacity(0.3))
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        isLoading = true
        Task {
            do {
                let s = try await AdminService.shared.fetchStats()
                await MainActor.run {
                    self.stats = s
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

struct ReportStatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
    }
}

struct ReportRow: View {
    let title: String
    let date: String
    let size: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(hex: "#F1F4F9"))
                    .frame(width: 44, height: 44)
                Image(systemName: "doc.text")
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                HStack(spacing: 4) {
                    Text(date)
                    Text("•")
                    Text(size)
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "arrow.down.to.line")
                .foregroundColor(themeManager.primaryColor)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
    }
}
