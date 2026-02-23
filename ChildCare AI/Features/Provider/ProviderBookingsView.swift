import SwiftUI

public struct ProviderBookingsView: View {
    @State private var selectedFilter = 0 // 0: Requests, 1: Upcoming, 2: Past
    let role: UserRole
    
    public init(role: UserRole) {
        self.role = role
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom segmented control for filters
                HStack {
                    FilterTab(title: "Requests", isSelected: selectedFilter == 0) {
                        selectedFilter = 0
                    }
                    FilterTab(title: "Upcoming", isSelected: selectedFilter == 1) {
                        selectedFilter = 1
                    }
                    FilterTab(title: "Past", isSelected: selectedFilter == 2) {
                        selectedFilter = 2
                    }
                }
                .padding(.horizontal, AppTheme.padding)
                .padding(.bottom, 10)
                .background(AppTheme.surface)
                
                ScrollView {
                    VStack(spacing: 16) {
                        if selectedFilter == 0 {
                            // Booking Requests
                            ProviderBookingCard(
                                parentName: "Sarah Connor",
                                childName: "John (2 yrs)",
                                date: "Tomorrow, Oct 24",
                                time: "8:00 AM - 4:00 PM",
                                status: "New Request",
                                statusColor: AppTheme.primary,
                                showActions: true
                            )
                        } else if selectedFilter == 1 {
                            // Upcoming Bookings
                            ProviderBookingCard(
                                parentName: "Mike Smith",
                                childName: "Lily (4 yrs)",
                                date: "Thursday, Oct 26",
                                time: "9:00 AM - 1:00 PM",
                                status: "Confirmed",
                                statusColor: .green,
                                showActions: false
                            )
                        } else {
                            // Past Bookings
                            ProviderBookingCard(
                                parentName: "Emily Davis",
                                childName: "Noah (3 yrs)",
                                date: "Last Monday, Oct 17",
                                time: "Full Day",
                                status: "Completed",
                                statusColor: .gray,
                                showActions: false
                            )
                        }
                    }
                    .padding(AppTheme.padding)
                }
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Booking Schedule")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProviderBookingCard: View {
    let parentName: String
    let childName: String
    let date: String
    let time: String
    let status: String
    let statusColor: Color
    let showActions: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(parentName)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Child: \(childName)")
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
            }
            
            if showActions {
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Text("Decline")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {}) {
                        Text("Accept")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(AppTheme.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
