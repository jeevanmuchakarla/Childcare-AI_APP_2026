import SwiftUI

struct AdminBookingDetail: Codable {
    let id: Int
    let child: ChildInfo
    let provider: ProviderInfo
    let parent: ParentInfo
    let booking_date: String
    let time: String
    let status: String
    let notes: String
    
    struct ChildInfo: Codable {
        let name: String
        let age: String
    }
    struct ProviderInfo: Codable {
        let name: String
        let type: String
        let address: String
    }
    struct ParentInfo: Codable {
        let name: String
        let email: String
        let phone: String
    }
}

struct AdminBookingDetailView: View {
    let bookingId: Int
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var booking: AdminBookingDetail?
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Booking Details")
                    .font(.headline.bold())
                Spacer()
                Button("Done") { dismiss() }
                    .foregroundColor(themeManager.primaryColor)
                    .font(.subheadline.bold())
            }
            .padding()
            .background(AppTheme.surface)
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let b = booking {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // User info
                        VStack(alignment: .leading, spacing: 12) {
                            DetailSectionHeader(title: "Child & Center")
                            BookingDetailRow(label: "Child", value: b.child.name)
                            BookingDetailRow(label: "Facility", value: b.provider.name)
                            BookingDetailRow(label: "Type", value: b.provider.type)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            DetailSectionHeader(title: "Schedule")
                            BookingDetailRow(label: "Date", value: b.booking_date)
                            BookingDetailRow(label: "Time", value: b.time)
                            BookingDetailRow(label: "Status", value: b.status, isStatus: true)
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            DetailSectionHeader(title: "Parent Information")
                            BookingDetailRow(label: "Name", value: b.parent.name)
                            BookingDetailRow(label: "Email", value: b.parent.email)
                            BookingDetailRow(label: "Phone", value: b.parent.phone)
                        }
                        
                        if !b.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                DetailSectionHeader(title: "Notes")
                                Text(b.notes)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.05))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            } else {
                Text("Error loading details").padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .onAppear { loadData() }
    }
    
    private func loadData() {
        Task {
            do {
                // Inline fetch for simplicity
                let url = URL(string: "http://localhost:8000/api/admin/bookings/\(bookingId)")!
                var request = URLRequest(url: url)
                if let token = UserDefaults.standard.string(forKey: "auth_token") {
                    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                
                let (data, _) = try await URLSession.shared.data(for: request)
                let decoded = try JSONDecoder().decode(AdminBookingDetail.self, from: data)
                await MainActor.run {
                    self.booking = decoded
                    self.isLoading = false
                }
            } catch {
                print("Error loading booking details: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

struct DetailSectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.caption2.bold())
            .foregroundColor(.gray)
            .tracking(1)
    }
}

struct BookingDetailRow: View {
    let label: String
    let value: String
    var isStatus: Bool = false
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(isStatus ? .blue : .primary)
        }
        .padding(.vertical, 4)
    }
}
