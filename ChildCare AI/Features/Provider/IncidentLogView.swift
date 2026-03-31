import SwiftUI

public struct IncidentLogView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var incidents: [IncidentRecord] = []
    @State private var isLoading = false
    @State private var childNames: [Int: String] = [:]
    
    struct IncidentRecord: Identifiable {
        let id: Int
        let type: String
        let childId: Int
        let description: String
        let date: String
        let time: String
        let status: String
        let statusColor: Color
        let statusBg: Color
    }
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Incident Log")
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Recent Reports Header
                        HStack {
                            Text("Recent Reports")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Button(action: {}) {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                    Text("New Report")
                                }
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(hex: "#EE675C"))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        if incidents.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.3))
                                Text("No incidents reported")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 20) {
                                ForEach(incidents) { incident in
                                    IncidentReportRow(
                                        type: incident.type,
                                        child: childNames[incident.childId] ?? "Child #\(incident.childId)",
                                        description: incident.description,
                                        date: incident.date,
                                        time: incident.time,
                                        status: incident.status,
                                        statusColor: incident.statusColor,
                                        statusBg: incident.statusBg
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .background(AppTheme.background.opacity(0.5))
        .navigationBarHidden(true)
        .onAppear { loadIncidents() }
    }
    
    private func loadIncidents() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            do {
                // First fetch children to map IDs to names
                let baseUrl = AuthService.shared.baseURL
                let childrenUrl = URL(string: "\(baseUrl)/bookings/provider/\(providerId)/children")!
                let (cData, _) = try await URLSession.shared.data(from: childrenUrl)
                let decodedChildren = try JSONDecoder().decode([ProviderChild].self, from: cData)
                var nameMap: [Int: String] = [:]
                for c in decodedChildren { nameMap[c.id] = c.name }
                
                // Then fetch activities
                let activities = try await ActivityService.shared.fetchProviderActivities(providerId: providerId)
                
                // Filter for incidents
                let filtered = activities.filter { 
                    $0.activity_type.lowercased().contains("incident") || 
                    $0.activity_type.lowercased().contains("injury") ||
                    $0.activity_type.lowercased().contains("behavior")
                }
                
                let mapped = filtered.map { a -> IncidentRecord in
                    let isResolved = (a.notes ?? "").lowercased().contains("resolved")
                    return IncidentRecord(
                        id: a.id,
                        type: a.activity_type,
                        childId: a.child_id,
                        description: a.notes ?? "No details provided",
                        date: formatDate(a.created_at),
                        time: formatTime(a.created_at),
                        status: isResolved ? "Resolved" : "Reported",
                        statusColor: isResolved ? Color(hex: "#008A3D") : Color(hex: "#EEA63A"),
                        statusBg: isResolved ? Color(hex: "#EEFBF4") : Color(hex: "#FDF4E7")
                    )
                }
                
                await MainActor.run {
                    self.childNames = nameMap
                    self.incidents = mapped
                    self.isLoading = false
                }
            } catch {
                print("Error loading incidents: \(error)")
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        // Simple day extraction for now
        if dateString.contains("T") {
            let parts = dateString.split(separator: "T")
            return String(parts[0])
        }
        return "Today"
    }
    
    private func formatTime(_ dateString: String) -> String {
        if dateString.contains("T") {
            let parts = dateString.split(separator: "T")
            if parts.count > 1 {
                let timeParts = parts[1].split(separator: ":")
                if timeParts.count > 1 {
                    return "\(timeParts[0]):\(timeParts[1])"
                }
            }
        }
        return "N/A"
    }
}

struct IncidentReportRow: View {
    let type: String
    let child: String
    let description: String
    let date: String
    let time: String
    let status: String
    let statusColor: Color
    let statusBg: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(Color(hex: "#EEA63A"))
                    Text(type)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Spacer()
                Text(status)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusBg)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 4) {
                    Text("Child:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    Text(child)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(date)
                }
                HStack(spacing: 4) {
                    Text(time)
                }
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.02), radius: 5)
    }
}
