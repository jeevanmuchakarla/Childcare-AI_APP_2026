import SwiftUI

// MARK: - Data Models
struct ProviderBooking: Identifiable, Decodable {
    let id: Int
    let parent_id: Int
    let provider_id: Int
    let child_id: Int?
    let child_name: String?
    let provider_name: String?
    let booking_date: String
    let start_time: String?
    let end_time: String?
    let total_amount: Double?
    let status: String
    let booking_type: String?
    let schedule_type: String?
    let parent_name: String?
    let parent_phone: String?
    let child_age_or_name: String?
    let notes: String?
}

// MARK: - ProviderBookingsView
public struct ProviderBookingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedFilter = 0
    @State private var bookings: [ProviderBooking] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private var providerId: Int { AuthService.shared.currentUser?.id ?? -1 }
    
    public init() {}
    
    private var filteredBookings: [ProviderBooking] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let today = Calendar.current.startOfDay(for: Date())
        
        switch selectedFilter {
        case 0:
            return bookings.filter {
                let date = formatter.date(from: $0.booking_date) ?? Date()
                let isPast = Calendar.current.startOfDay(for: date) < today
                return $0.status == "Confirmed" && !isPast
            }
        case 1:
            return bookings.filter {
                let date = formatter.date(from: $0.booking_date) ?? Date()
                let isPast = Calendar.current.startOfDay(for: date) < today
                return $0.status == "Pending" && !isPast
            }
        case 2:
            return bookings.filter {
                let date = formatter.date(from: $0.booking_date) ?? Date()
                let isPast = Calendar.current.startOfDay(for: date) < today
                return $0.status == "Completed" || $0.status == "Cancelled" || isPast
            }
        default: return bookings
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Bookings")
                    .font(.system(size: 32, weight: .bold))
                Spacer()
                Button(action: { Task { await loadBookings() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(themeManager.primaryColor)
                }
            }
            .padding()
            .padding(.top)
            
            // Segmented tabs
            HStack(spacing: 8) {
                FilterButton(title: "Confirmed", isSelected: selectedFilter == 0) { selectedFilter = 0 }
                FilterButton(title: "Pending", isSelected: selectedFilter == 1) { selectedFilter = 1 }
                FilterButton(title: "Past", isSelected: selectedFilter == 2) { selectedFilter = 2 }
            }
            .padding()
            .background(Color(hex: "#F1F4F9"))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            if isLoading {
                Spacer()
                ProgressView("Loading bookings...")
                    .foregroundColor(.gray)
                Spacer()
            } else if let error = errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    Button("Retry") { Task { await loadBookings() } }
                        .foregroundColor(themeManager.primaryColor)
                }
                .padding()
                Spacer()
            } else if filteredBookings.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 44))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No \(selectedFilter == 0 ? "confirmed" : selectedFilter == 1 ? "pending" : "past") bookings")
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(filteredBookings) { booking in
                            LiveRequestCard(booking: booking, onStatusChange: {
                                Task { await loadBookings() }
                            })
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .task { await loadBookings() }
    }
    
    private func loadBookings() async {
        guard providerId != -1 else { return }
        isLoading = true
        errorMessage = nil
        do {
            let url = URL(string: "\(AuthService.shared.baseURL)/bookings/provider/\(providerId)")!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    let serverError = String(data: data, encoding: .utf8) ?? "Unknown server error"
                    throw NSError(domain: "NetworkError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned \(httpResponse.statusCode): \(serverError)"])
                }
            }
            
            let decoded = try JSONDecoder().decode([ProviderBooking].self, from: data)
            await MainActor.run {
                self.bookings = decoded
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Could not load bookings: \(error.localizedDescription). Make sure the server at \(AuthService.shared.baseURL) is running and reachable."
                isLoading = false
            }
        }
    }
}

// MARK: - Live Request Card
struct LiveRequestCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let booking: ProviderBooking
    let onStatusChange: () -> Void
    @State private var isUpdating = false
    @State private var actionError: String?
    
    private var displayName: String {
        if let child = booking.child_name, !child.isEmpty {
            return "Booking for \(child)"
        }
        return booking.provider_name ?? "Booking #\(booking.id)"
    }
    
    private var timeDisplay: String {
        let start = booking.start_time ?? "N/A"
        let end = booking.end_time ?? ""
        return end.isEmpty ? start : "\(start) - \(end)"
    }
    
    private var statusColor: Color {
        switch booking.status {
        case "Confirmed": return Color(hex: "#43A047")
        case "Pending": return Color(hex: "#EEA63A")
        case "Cancelled": return Color(hex: "#BA1A1A")
        case "Completed": return .gray
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(themeManager.primaryColor.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Text(String(displayName.prefix(1)).uppercased())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.primaryColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    NavigationLink(destination: ChildProfileView(childId: booking.child_id ?? 0, name: booking.child_name ?? "Child", age: booking.child_age_or_name ?? "", role: AuthService.shared.currentUser?.role ?? .parent)) {
                        Text(displayName)
                            .font(.body).fontWeight(.bold)
                            .foregroundColor(themeManager.primaryColor)
                    }
                    Text(booking.status.lowercased())
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(statusColor.opacity(0.1))
                        .cornerRadius(6)
                }
                Spacer()
                if let amount = booking.total_amount {
                    Text("$\(String(format: "%.0f", amount))")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(themeManager.primaryColor)
                }
            }
            
            HStack(spacing: 16) {
                Label(booking.booking_date, systemImage: "calendar")
                Label(timeDisplay, systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.gray)
            
            if let age = booking.child_age_or_name, !age.isEmpty {
                Label("Age/Name: \(age)", systemImage: "person.circle")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if let pName = booking.parent_name, !pName.isEmpty {
                NavigationLink(destination: ParentProfileDetailView(parentId: booking.parent_id, parentName: pName)) {
                    Label("Parent: \(pName) \(booking.parent_phone.map { "- \($0)" } ?? "")", systemImage: "phone")
                        .font(.caption)
                        .foregroundColor(themeManager.primaryColor)
                }
            }
            
            if let notes = booking.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes:")
                        .font(.caption).fontWeight(.bold)
                    Text(notes)
                        .font(.caption)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            if let error = actionError {
                Text(error).font(.caption).foregroundColor(.red)
            }
            
            if booking.status == "Pending" {
                HStack(spacing: 12) {
                    Button(action: { Task { await updateStatus("Confirmed") } }) {
                        HStack(spacing: 6) {
                            if isUpdating { ProgressView().tint(.white).scaleEffect(0.8) }
                            else { Image(systemName: "checkmark.circle") }
                            Text("Accept")
                        }
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 46)
                        .background(themeManager.primaryColor)
                        .cornerRadius(12)
                    }
                    .disabled(isUpdating)
                    
                    Button(action: { Task { await updateStatus("Cancelled") } }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle")
                            Text("Decline")
                        }
                        .font(.subheadline).fontWeight(.bold)
                        .foregroundColor(Color(hex: "#BA1A1A"))
                        .frame(maxWidth: .infinity).frame(height: 46)
                        .background(AppTheme.surface)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#BA1A1A").opacity(0.3)))
                    }
                    .disabled(isUpdating)
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.08), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.03), radius: 4, y: 2)
    }
    
    private func updateStatus(_ newStatus: String) async {
        isUpdating = true
        actionError = nil
        do {
            var request = URLRequest(url: URL(string: "\(AuthService.shared.baseURL)/bookings/\(booking.id)/status")!)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(["status": newStatus])
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                await MainActor.run { onStatusChange() }
            } else {
                await MainActor.run { actionError = "Failed to update status." }
            }
        } catch {
            await MainActor.run { actionError = error.localizedDescription }
        }
        await MainActor.run { isUpdating = false }
    }
}

// MARK: - Reusable FilterButton
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? AppTheme.textPrimary : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.surface : Color.clear)
                .cornerRadius(8)
                .shadow(color: isSelected ? Color.black.opacity(0.05) : Color.clear, radius: 2)
        }
    }
}
