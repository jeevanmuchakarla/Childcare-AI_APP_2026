import SwiftUI

struct AdminLiveBookingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var bookings: [AdminLiveBooking] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                        .foregroundColor(themeManager.primaryColor)
                }
                Spacer()
                Text("Live Bookings Today")
                    .font(.headline.bold())
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(themeManager.primaryColor)
            }
            .padding()
            .background(AppTheme.surface)
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        if bookings.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("No live bookings for today yet.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 100)
                        } else {
                            ForEach(bookings) { booking in
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(themeManager.primaryColor.opacity(0.1))
                                            .frame(width: 50, height: 50)
                                        Image(systemName: "person.fill")
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
                                        Text(booking.time ?? "")
                                            .font(.caption.bold())
                                        Text(booking.status)
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(getStatusColor(booking.status).opacity(0.1))
                                            .foregroundColor(getStatusColor(booking.status))
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
                let data = try await AdminService.shared.fetchLiveBookings()
                await MainActor.run {
                    self.bookings = data
                    self.isLoading = false
                }
            } catch {
                print("Error loading live bookings: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}
