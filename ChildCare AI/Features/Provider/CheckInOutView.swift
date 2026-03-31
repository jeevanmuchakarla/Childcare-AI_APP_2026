import SwiftUI

public struct CheckInOutView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var children: [ProviderChild] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var errorMessage: String?
    
    private var providerId: Int { AuthService.shared.currentUser?.id ?? -1 }
    
    public init() {}
    
    var filteredChildren: [ProviderChild] {
        if searchText.isEmpty { return children }
        return children.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Attendance")
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search child...", text: $searchText)
            }
            .padding()
            .background(Color(hex: "#F1F4F9"))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.bottom, 24)
            
            ScrollView(showsIndicators: false) {
                if isLoading {
                    ProgressView("Loading children...").padding(.top, 40)
                } else if filteredChildren.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 48)).foregroundColor(.gray.opacity(0.3))
                        Text(searchText.isEmpty ? "No children in care" : "No results found")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                } else {
                    VStack(spacing: 16) {
                        ForEach(filteredChildren) { child in
                            AttendanceRow(child: child, providerId: providerId)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { Task { await loadChildren() } }
    }
    
    private func loadChildren() async {
        guard providerId != -1 else { return }
        isLoading = true
        do {
            let url = URL(string: "\(AuthService.shared.baseURL)/bookings/provider/\(providerId)/children")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([ProviderChild].self, from: data)
            await MainActor.run {
                children = decoded
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = "Could not load children."
                isLoading = false
            }
        }
    }
}

struct AttendanceRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let child: ProviderChild
    let providerId: Int
    @State private var isCheckedIn = false // This would normally come from an attendance status endpoint
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(themeManager.primaryColor.opacity(0.1))
                    .frame(width: 50, height: 50)
                Text(String(child.name.prefix(1)))
                    .font(.headline).fontWeight(.bold).foregroundColor(themeManager.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(child.name)
                    .font(.body).fontWeight(.bold)
                Text(child.parent_name)
                    .font(.caption).foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: toggleAttendance) {
                Text(isCheckedIn ? "Checked In" : "Check In")
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(isCheckedIn ? Color.green : .white)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(isCheckedIn ? Color.green.opacity(0.1) : themeManager.primaryColor)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.01), radius: 5)
    }
    
    private func toggleAttendance() {
        isCheckedIn.toggle()
        Task {
            do {
                let url = URL(string: "\(AuthService.shared.baseURL)/activities/")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: Any] = [
                    "child_id": child.id,
                    "provider_id": providerId,
                    "activity_type": "Attendance",
                    "notes": isCheckedIn ? "Checked In" : "Checked Out"
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                _ = try await URLSession.shared.data(for: request)
            } catch {
            }
        }
    }
}
