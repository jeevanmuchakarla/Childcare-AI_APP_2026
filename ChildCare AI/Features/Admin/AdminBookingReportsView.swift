import SwiftUI

public struct AdminBookingReportsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(themeManager.primaryColor)
                }
                Text("Booking Reports")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(AppTheme.surface)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Summary Stats
                    HStack(spacing: 16) {
                        ReportStatCard(title: "Total", value: "1,240", color: .black)
                        ReportStatCard(title: "Completed", value: "985", color: Color(hex: "#00C853"))
                    }
                    .padding(.horizontal)
                    
                        // Booking Trends Card
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Booking Trends")
                                .font(.subheadline)
                                .fontWeight(.bold)
                            
                            GrowthChartView(data: [50, 70, 40, 85, 60, 95, 75, 90, 65, 100])
                                .frame(height: 100)
                        }
                        .padding(20)
                        .background(AppTheme.surface)
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
                        .padding(.horizontal)
                    
                    // Recent Bookings
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Bookings")
                            .font(.subheadline)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 12) {
                            AdminBookingRow(id: "202301", date: "Oct 23, 2023", status: "Completed")
                            AdminBookingRow(id: "202302", date: "Oct 22, 2023", status: "Completed")
                            AdminBookingRow(id: "202303", date: "Oct 21, 2023", status: "Completed")
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .background(AppTheme.background.opacity(0.1).ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct ReportStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
    }
}

struct AdminBookingRow: View {
    let id: String
    let date: String
    let status: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Booking # \(id)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#00C853").opacity(0.1))
                .foregroundColor(Color(hex: "#00C853"))
                .cornerRadius(8)
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
    }
}
