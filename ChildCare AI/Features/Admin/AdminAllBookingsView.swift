import SwiftUI

struct AdminAllBookingsView: View {
    @Binding var selectedTab: Int
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var bookings: [AdminLiveBooking] = []
    @State private var isLoading = false
    @State private var searchText = ""
    
    var filteredBookings: [AdminLiveBooking] {
        if searchText.isEmpty {
            return bookings
        } else {
            return bookings.filter { 
                $0.child_name.localizedCaseInsensitiveContains(searchText) || 
                $0.center_name.localizedCaseInsensitiveContains(searchText) 
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { selectedTab = 0 }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundColor(themeManager.primaryColor)
                }
                Spacer()
                Text("All Bookings")
                    .font(.headline.bold())
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(themeManager.primaryColor)
            }
            .padding()
            .background(AppTheme.surface)
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search child or center...", text: $searchText)
                    .font(.subheadline)
            }
            .padding()
            .background(AppTheme.background)
            .cornerRadius(12)
            .padding()

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        if filteredBookings.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("No bookings found.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 100)
                        } else {
                            ForEach(filteredBookings) { booking in
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(themeManager.primaryColor.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "calendar")
                                            .foregroundColor(themeManager.primaryColor)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(booking.child_name)
                                            .font(.headline)
                                        Text(booking.center_name)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(booking.time ?? booking.booking_date ?? "")
                                            .font(.caption.bold())
                                        
                                        let isExpired = booking.status.lowercased() == "pending" && (booking.booking_date ?? "") < "2026-03-27"
                                        Text(isExpired ? "Expired" : booking.status)
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(isExpired ? Color.gray.opacity(0.1) : getStatusColor(booking.status).opacity(0.1))
                                            .foregroundColor(isExpired ? .gray : getStatusColor(booking.status))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(AppTheme.surface)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.02), radius: 5, y: 2)
                                .onTapGesture {
                                    self.selectedBookingId = booking.id
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: Binding(
            get: { selectedBookingId != nil ? SelectedID(id: selectedBookingId!) : nil },
            set: { selectedBookingId = $0?.id }
        )) { item in
            AdminBookingDetailView(bookingId: item.id)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            loadData()
        }
    }
    
    @State private var selectedBookingId: Int? = nil
    
    struct SelectedID: Identifiable {
        let id: Int
    }
    
    private func getStatusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "confirmed": return .green
        case "completed": return .blue
        case "pending": return .orange
        default: return .gray
        }
    }
    
    private func loadData() {
        isLoading = true
        Task {
            do {
                let data = try await AdminService.shared.fetchAllBookings()
                await MainActor.run {
                    self.bookings = data
                    self.isLoading = false
                }
            } catch {
                print("Error loading bookings: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}
