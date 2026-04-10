import SwiftUI

public struct ParentBookingsView: View {
    @EnvironmentObject var bookingStore: BookingStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedFilter = 0 // 0 for Upcoming, 1 for Past
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "My Bookings", showBackButton: false)
            
            // Filter Tabs
            HStack(spacing: 0) {
                FilterTab(title: "Upcoming", isSelected: selectedFilter == 0) { selectedFilter = 0 }
                FilterTab(title: "Past", isSelected: selectedFilter == 1) { selectedFilter = 1 }
            }
            .padding(.horizontal, AppTheme.padding)
            .padding(.vertical, 12)
            
            ScrollView {
                VStack(spacing: 16) {
                    if selectedFilter == 0 {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Upcoming Bookings")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            if bookingStore.upcomingBookings.isEmpty {
                                Text("No upcoming bookings")
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            } else {
                                ForEach(bookingStore.upcomingBookings) { booking in
                                    BookingRedesignCard(
                                        name: booking.name,
                                        bookingId: "#\(booking.id.prefix(4))",
                                        date: booking.date.formatted(date: .abbreviated, time: .omitted),
                                        time: booking.time,
                                        address: booking.address,
                                        status: booking.status
                                    )
                                }
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Past Bookings")
                                .font(.headline)
                                .foregroundColor(AppTheme.textPrimary)
                            
                            if bookingStore.pastBookings.isEmpty {
                                Text("No past bookings")
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            } else {
                                ForEach(bookingStore.pastBookings) { booking in
                                    BookingRedesignCard(
                                        name: booking.name,
                                        bookingId: "#\(booking.id.prefix(4))",
                                        date: booking.date.formatted(date: .abbreviated, time: .omitted),
                                        time: booking.time,
                                        address: booking.address,
                                        status: booking.status
                                    )
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .navigationBarHidden(true)
        .onAppear {
            if let userId = AuthService.shared.currentUser?.id {
                Task {
                    await bookingStore.loadBookings(parentId: userId)
                }
            }
        }
    }
}

struct FilterTab: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundColor(isSelected ? themeManager.primaryColor : .gray)
                
                Rectangle()
                    .fill(isSelected ? themeManager.primaryColor : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct BookingRedesignCard: View {
    let name: String
    let bookingId: String
    let date: String
    let time: String
    let address: String
    let status: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Booking ID: \(bookingId)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text(status)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.05))
                    .cornerRadius(8)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                LabelItem(icon: "calendar", text: date)
                LabelItem(icon: "clock", text: time)
                LabelItem(icon: "mappin.and.ellipse", text: address)
            }
            
            NavigationLink(destination: BookingDetailView(name: name, bookingId: bookingId, date: date, time: time, address: address, status: status)) {
                Text("View Details")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct LabelItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeManager.primaryColor)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
struct BookingDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let name: String
    let bookingId: String
    let date: String
    let time: String
    let address: String
    let status: String
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Booking Details")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Booking ID: \(bookingId)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        StatusBadge(status: status)
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        DetailItem(icon: "calendar", title: "Date", value: date)
                        DetailItem(icon: "clock", title: "Time", value: time)
                        DetailItem(icon: "mappin.and.ellipse", title: "Address", value: address)
                    }
                    .padding()
                    .background(AppTheme.surface)
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Real-time Status")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            Circle()
                                .fill(status == "Confirmed" ? Color.green : Color.orange)
                                .frame(width: 8, height: 8)
                            Text(status == "Confirmed" ? "Booking Approved" : "Awaiting Approval")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surface)
                    .cornerRadius(16)
                    
                    if status == "Confirmed" {
                        NavigationLink(destination: ChatView(role: .parent, initialCategory: "Preschool")) {
                            HStack {
                                Image(systemName: "message.fill")
                                Text("Chat with Provider")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(themeManager.primaryColor)
                            .cornerRadius(16)
                            .shadow(color: themeManager.primaryColor.opacity(0.3), radius: 8, y: 4)
                        }
                    } else {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "lock.fill")
                                Text("Chat will enable after approval")
                            }
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.red.opacity(0.2), lineWidth: 1))
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct StatusBadge: View {
    let status: String
    var body: some View {
        Text(status)
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(status == "Completed" ? .gray : .green)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background((status == "Completed" ? Color.gray : Color.green).opacity(0.1))
            .cornerRadius(8)
    }
}

struct DetailItem: View {
    let icon: String
    let title: String
    let value: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(themeManager.primaryColor)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}
