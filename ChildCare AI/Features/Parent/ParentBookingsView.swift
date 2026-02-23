import SwiftUI

public struct ParentBookingsView: View {
    @State private var selectedFilter = 0 // 0: Upcoming, 1: Past
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom segmented control for filters
                HStack {
                    FilterTab(title: "Upcoming", isSelected: selectedFilter == 0) {
                        selectedFilter = 0
                    }
                    FilterTab(title: "Past Bookings", isSelected: selectedFilter == 1) {
                        selectedFilter = 1
                    }
                }
                .padding(.horizontal, AppTheme.padding)
                .padding(.vertical, 10)
                .background(AppTheme.surface)
                
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedFilter == 0 { // Upcoming
                            BookingCard(
                                providerName: "Sunshine Daycare",
                                providerType: "Daycare Center",
                                date: "Tomorrow, Oct 24",
                                time: "8:00 AM - 4:00 PM",
                                status: "Confirmed",
                                statusColor: .green
                            )
                            
                            BookingCard(
                                providerName: "Sarah Babysitting",
                                providerType: "Babysitter",
                                date: "Friday, Oct 28",
                                time: "6:00 PM - 10:00 PM",
                                status: "Pending Approval",
                                statusColor: .orange
                            )
                        } else { // Past
                            BookingCard(
                                providerName: "Bright Beginnings",
                                providerType: "Preschool",
                                date: "Last Monday, Oct 17",
                                time: "9:00 AM - 3:00 PM",
                                status: "Completed",
                                statusColor: .gray
                            )
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("My Bookings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? AppTheme.primary : AppTheme.textSecondary)
                
                Rectangle()
                    .fill(isSelected ? AppTheme.primary : Color.clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct BookingCard: View {
    let providerName: String
    let providerType: String
    let date: String
    let time: String
    let status: String
    let statusColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(providerName)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(providerType)
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                Text(status)
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(AppTheme.primary)
                            .frame(width: 20)
                        Text(date)
                            .font(.subheadline)
                    }
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(AppTheme.primary)
                            .frame(width: 20)
                        Text(time)
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(AppTheme.primary)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
