import SwiftUI

// MARK: - AI Insights View
struct AIInsightsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var insights: [AIInsightRecord] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "AI Insights")
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // AI Themed Header
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.primaryGradient)
                                    .frame(width: 60, height: 60)
                                Image(systemName: "brain.headlight.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ChildCare AI")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.primaryColor)
                                Text("Smart Recommendations")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(AppTheme.surface)
                        .cornerRadius(20)
                        .shadow(color: themeManager.primaryColor.opacity(0.1), radius: 10, y: 5)
                        
                        ForEach(insights, id: \.id) { insight in
                            VStack(alignment: .leading, spacing: 14) {
                                HStack {
                                    Image(systemName: getIcon(for: insight.type))
                                        .foregroundColor(themeManager.primaryColor)
                                    Text(insight.title)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                }
                                
                                Text(insight.content)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.surface)
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(themeManager.primaryColor.opacity(0.1), lineWidth: 1)
                            )
                        }
                        
                        if insights.isEmpty {
                            Text("No insights available yet. Check back soon!")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { loadInsights() }
    }
    
    private func getIcon(for type: String) -> String {
        switch type {
        case "efficiency": return "chart.bar.fill"
        case "satisfaction": return "heart.fill"
        case "growth": return "trending.up.circle.fill"
        default: return "lightbulb.fill"
        }
    }
    
    private func loadInsights() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            do {
                let data = try await ProviderStatsService.shared.fetchInsights(providerId: providerId)
                await MainActor.run {
                    self.insights = data
                    self.isLoading = false
                }
            } catch {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
}

// MARK: - Center Status View
struct CenterStatusView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentStatus = "Open"
    @State private var statusMessage = ""
    @State private var isSaving = false
    
    let statusOptions: [(title: String, icon: String, color: Color, description: String)] = [
        ("Open", "door.left.hand.open", .green, "Currently accepting children"),
        ("Closed", "door.left.hand.closed", .red, "Not operating at this time"),
        ("Special Event", "star.fill", .orange, "Special schedule or event in progress")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Center Status")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Operational Status")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Update your center's availability for parents")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        ForEach(statusOptions, id: \.title) { option in
                            Button(action: { currentStatus = option.title }) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(currentStatus == option.title ? .white.opacity(0.2) : option.color.opacity(0.1))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: option.icon)
                                            .foregroundColor(currentStatus == option.title ? .white : option.color)
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(option.title)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        Text(option.description)
                                            .font(.caption)
                                            .opacity(0.8)
                                    }
                                    .foregroundColor(currentStatus == option.title ? .white : AppTheme.textPrimary)
                                    
                                    Spacer()
                                    
                                    if currentStatus == option.title {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                            .font(.title3)
                                    }
                                }
                                .padding(20)
                                .background(currentStatus == option.title ? themeManager.primaryColor : AppTheme.surface)
                                .cornerRadius(20)
                                .shadow(color: currentStatus == option.title ? themeManager.primaryColor.opacity(0.3) : Color.black.opacity(0.03), radius: 10, y: 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Status Message (Optional)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        TextField("e.g. Back to normal tomorrow", text: $statusMessage)
                            .padding(18)
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1)))
                    }
                    .padding(.horizontal)
                    
                    Button(action: saveStatus) {
                        HStack {
                            if isSaving { ProgressView().tint(.white) }
                            else { 
                                Label("Update Status", systemImage: "arrow.clockwise.circle.fill")
                                    .fontWeight(.bold)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(themeManager.primaryGradient)
                        .cornerRadius(20)
                        .shadow(color: themeManager.primaryColor.opacity(0.2), radius: 10, y: 5)
                    }
                    .padding(.horizontal)
                    .disabled(isSaving)
                }
                .padding(.vertical, 24)
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { loadStatus() }
    }
    
    private func loadStatus() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        Task {
            if let data = try? await ProviderStatsService.shared.fetchCenterStatus(providerId: providerId) {
                await MainActor.run {
                    self.currentStatus = data.current_status
                    self.statusMessage = data.status_message ?? ""
                }
            }
        }
    }
    
    private func saveStatus() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        isSaving = true
        Task {
            do {
                _ = try await ProviderStatsService.shared.updateCenterStatus(providerId: providerId, status: currentStatus, message: statusMessage)
                await MainActor.run { isSaving = false }
            } catch {
                await MainActor.run { isSaving = false }
            }
        }
    }
}

// MARK: - Today's Schedule View
struct TodayScheduleView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var items: [ScheduleItemRecord] = []
    @State private var isLoading = false
    @State private var showingAddSheet = false
    @State private var newTime = "09:00 AM"
    @State private var newActivity = ""
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Today's Schedule")
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(items, id: \.id) { item in
                            HStack(spacing: 16) {
                                Text(item.time)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.primaryColor)
                                    .frame(width: 80, alignment: .leading)
                                
                                Text(item.activity)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.textPrimary)
                                
                                Spacer()
                                
                                if item.is_completed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.02), radius: 5)
                        }
                    }
                    .padding()
                    
                    Button(action: { showingAddSheet = true }) {
                        Label("Add Item", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(themeManager.primaryColor)
                            .cornerRadius(16)
                            .padding()
                    }
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { loadSchedule() }
        .sheet(isPresented: $showingAddSheet) {
            VStack(spacing: 24) {
                Text("New Schedule Item").font(.headline)
                
                TextField("Time (e.g. 10:00 AM)", text: $newTime)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                TextField("Activity Name", text: $newActivity)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                Button(action: saveItem) {
                    Text("Save Activity")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(themeManager.primaryColor)
                        .cornerRadius(16)
                }
            }
            .padding(32)
            .presentationDetents([.medium])
        }
    }
    
    private func loadSchedule() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            if let data = try? await ProviderStatsService.shared.fetchSchedule(providerId: providerId) {
                await MainActor.run {
                    self.items = data
                    self.isLoading = false
                }
            } else {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func saveItem() {
        guard let providerId = AuthService.shared.currentUser?.id, !newActivity.isEmpty else { return }
        let body: [String: Any] = ["time": newTime, "activity": newActivity, "is_completed": false]
        
        Task {
            do {
                let url = URL(string: "\(AuthService.shared.baseURL)/provider-stats/schedule/\(providerId)")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                _ = try await URLSession.shared.data(for: request)
                
                await MainActor.run {
                    showingAddSheet = false
                    newActivity = ""
                    loadSchedule()
                }
            } catch {
            }
        }
    }
}

// MARK: - Staff Status View
struct StaffStatusView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var staff: [StaffMemberRecord] = []
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Staff Status")
            
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(0..<staff.count, id: \.self) { index in
                            let member = staff[index]
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(themeManager.primaryColor.opacity(0.1))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Text(String(member.name.prefix(1)))
                                            .fontWeight(.bold)
                                            .foregroundColor(themeManager.primaryColor)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(member.name)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    Text(member.role)
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                                
                                Spacer()
                                
                                StatusChip(status: member.status)
                                    .onTapGesture {
                                        cycleStatus(for: index)
                                    }
                            }
                            .padding()
                            .background(AppTheme.surface)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.02), radius: 5)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { loadStaff() }
    }
    
    private func loadStaff() {
        guard let providerId = AuthService.shared.currentUser?.id else { return }
        isLoading = true
        Task {
            if let data = try? await ProviderStatsService.shared.fetchStaff(providerId: providerId) {
                await MainActor.run {
                    self.staff = data
                    self.isLoading = false
                }
            } else {
                await MainActor.run { self.isLoading = false }
            }
        }
    }
    
    private func cycleStatus(for index: Int) {
        let current = staff[index].status
        let next = current == "Present" ? "Away" : (current == "Away" ? "On Leave" : "Present")
        let staffId = staff[index].id
        
        Task {
            _ = try? await ProviderStatsService.shared.updateStaffStatus(staffId: staffId, status: next)
            await MainActor.run {
                // Update local state by creating a new array to trigger UI refresh
                var updatedStaff = staff
                let old = updatedStaff[index]
                updatedStaff[index] = StaffMemberRecord(id: old.id, name: old.name, role: old.role, status: next)
                staff = updatedStaff
            }
        }
    }
}

struct StatusChip: View {
    let status: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(status)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.08))
        .cornerRadius(30)
        .overlay(
            Capsule()
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
    
    var color: Color {
        switch status {
        case "Present": return .green
        case "Away": return .orange
        case "On Leave": return .red
        default: return .gray
        }
    }
}

// MARK: - Quick Actions View
struct ProviderQuickActionsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Quick Actions")
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    NavigationLink(destination: ProviderMessagesView()) {
                        QuickActionCard(title: "Broadcast", icon: "envelope.fill", color: .blue)
                    }
                    
                    NavigationLink(destination: EmergencyAlertsView()) {
                        QuickActionCard(title: "Emergency", icon: "exclamationmark.triangle.fill", color: .red)
                    }
                    
                    NavigationLink(destination: CenterProfileView()) {
                        QuickActionCard(title: "Center Profile", icon: "building.2.fill", color: .purple)
                    }
                    
                    NavigationLink(destination: AttendanceView()) {
                        QuickActionCard(title: "Directory", icon: "person.3.fill", color: .green)
                    }
                    
                    NavigationLink(destination: ProfileView()) {
                        QuickActionCard(title: "Documents", icon: "doc.badge.plus", color: .orange)
                    }
                    
                    NavigationLink(destination: ProfileView()) {
                        QuickActionCard(title: "Settings", icon: "gearshape.fill", color: .gray)
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(AppTheme.surface)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.03), radius: 8)
    }
}
