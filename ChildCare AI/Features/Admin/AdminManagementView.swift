import SwiftUI

public struct AdminManagementView: View {
    @State private var searchText = ""
    @Binding var selectedTab: Int
    @State private var innerSelectedTab = 0
    @State private var users: [AdminUser] = []
    @State private var pendingProviders: [PendingProvider] = []
    @State private var isLoading = false
    @State private var selectedUserId: Int? = nil
    @State private var showUserDetail = false
    @EnvironmentObject var themeManager: ThemeManager
    let tabs = ["Parents", "Preschools", "Daycares"]
    
    public init(selectedTab: Binding<Int>, initialTab: Int = 0) {
        self._selectedTab = selectedTab
        _innerSelectedTab = State(initialValue: initialTab)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Management", showBackButton: true, onBack: { selectedTab = 0 })
            // Tab Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Button(action: { innerSelectedTab = index }) {
                            Text(tabs[index])
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(innerSelectedTab == index ? themeManager.primaryColor : AppTheme.surface)
                                .foregroundColor(innerSelectedTab == index ? .white : .gray)
                                .cornerRadius(20)
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(innerSelectedTab == index ? Color.clear : Color.gray.opacity(0.1), lineWidth: 1))
                        }
                    }
                }
                .padding()
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search...", text: $searchText)
                    .font(.body)
            }
            .padding(14)
            .background(AppTheme.surface)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 16) {
                    if isLoading {
                        ProgressView().padding(.top, 40)
                    } else if innerSelectedTab == 0 {
                        // --- Parents Tab ---
                        let allParents = users.filter { $0.role.capitalized == "Parent" }
                        let pendingParents = allParents.filter { $0.is_approved == false }
                        let activeParents = allParents.filter { $0.is_approved != false }
                        let filtered = allParents.filter { searchText.isEmpty || $0.email.localizedCaseInsensitiveContains(searchText) }
                        
                        if !pendingParents.isEmpty {
                            AdminSectionHeader(title: "Pending Approval", count: pendingParents.count, color: .orange)
                        }
                        ForEach(pendingParents.filter { searchText.isEmpty || $0.email.localizedCaseInsensitiveContains(searchText) }) { user in
                            ManagementUserRow(
                                name: user.email.split(separator: "@").first.map(String.init)?.capitalized ?? "Parent",
                                email: user.email,
                                role: "Parent",
                                isPending: true,
                                color: .orange,
                                onTap: { selectedUserId = user.id; showUserDetail = true },
                                onApprove: { approveUser(user.id) }
                            )
                        }
                        if !pendingParents.isEmpty && !activeParents.isEmpty {
                            AdminSectionHeader(title: "Active Parents", count: activeParents.count, color: Color(hex: "#7D61FF"))
                        }
                        ForEach(activeParents.filter { searchText.isEmpty || $0.email.localizedCaseInsensitiveContains(searchText) }) { user in
                            ManagementUserRow(
                                name: user.email.split(separator: "@").first.map(String.init)?.capitalized ?? "Parent",
                                email: user.email,
                                role: "Parent",
                                status: "Active",
                                color: Color(hex: "#7D61FF"),
                                onTap: { selectedUserId = user.id; showUserDetail = true }
                            )
                        }
                        if filtered.isEmpty {
                            Text("No parents found.").foregroundColor(.gray).padding(.top, 40)
                        }
                        
                    } else if innerSelectedTab == 1 {
                        // --- Preschools Tab ---
                        let preschools = users.filter { $0.role.capitalized == "Preschool" }
                        ForEach(preschools.filter { searchText.isEmpty || $0.email.localizedCaseInsensitiveContains(searchText) }) { user in
                            ManagementUserRow(
                                name: user.email.split(separator: "@").first.map(String.init)?.capitalized ?? "Preschool",
                                email: user.email,
                                role: "Preschool",
                                status: (user.is_approved ?? false) ? "Active" : "Pending",
                                color: Color(hex: "#FF8C00"),
                                onTap: { selectedUserId = user.id; showUserDetail = true }
                            )
                        }
                    } else if innerSelectedTab == 2 {
                        // --- Daycares Tab ---
                        let daycares = users.filter { $0.role.capitalized == "Daycare" }
                        ForEach(daycares.filter { searchText.isEmpty || $0.email.localizedCaseInsensitiveContains(searchText) }) { user in
                            ManagementUserRow(
                                name: user.email.split(separator: "@").first.map(String.init)?.capitalized ?? "Daycare",
                                email: user.email,
                                role: "Daycare",
                                status: (user.is_approved ?? false) ? "Active" : "Pending",
                                color: Color(hex: "#00BC8C"),
                                onTap: { selectedUserId = user.id; showUserDetail = true }
                            )
                        }
                    } else {
                        Spacer()
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.background.opacity(0.3))
        .navigationBarHidden(true)
        .onAppear { loadData() }
        .sheet(isPresented: $showUserDetail) {
            if let uid = selectedUserId {
                AdminUserDetailSheet(userId: uid, onApprove: {
                    approveUser(uid)
                    showUserDetail = false
                })
                .environmentObject(themeManager)
            }
        }
    }
    
    private func loadData() {
        isLoading = true
        Task {
            do {
                let allUsers = try await AdminService.shared.fetchAllUsers()
                DispatchQueue.main.async {
                    self.users = allUsers
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async { self.isLoading = false }
            }
        }
    }
    
    private func approveUser(_ id: Int) {
        Task {
            do {
                let _ = try await AdminService.shared.approveUser(userId: id)
                DispatchQueue.main.async { loadData() }
            } catch {
            }
        }
    }
    
    private func approve(_ id: Int) {
        Task {
            if try await AdminService.shared.approveProvider(providerId: id) {
                loadData()
            }
        }
    }
    
    private func reject(_ id: Int) {
        Task {
            if try await AdminService.shared.rejectProvider(providerId: id) {
                loadData()
            }
        }
    }
}

// MARK: - Section Header
struct AdminSectionHeader: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
            Spacer()
            Text("\(count)")
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(color.opacity(0.15))
                .foregroundColor(color)
                .cornerRadius(8)
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
    }
}

// MARK: - Admin User Detail Sheet
struct AdminUserDetailSheet: View {
    let userId: Int
    var onApprove: (() -> Void)? = nil
    @State private var details: AdminUserDetails? = nil
    @State private var isLoading = true
    @State private var isApproving = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity).padding(.top, 60)
                    } else if let d = details {
                        // Header
                        VStack(alignment: .center, spacing: 12) {
                            Circle()
                                .fill(roleColor(d.role).opacity(0.1))
                                .frame(width: 72, height: 72)
                                .overlay(
                                    Text(String((d.full_name ?? d.center_name ?? d.email).prefix(1)).uppercased())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(roleColor(d.role))
                                )
                            Text(d.full_name ?? d.center_name ?? "Unknown")
                                .font(.title2).fontWeight(.bold)
                            HStack(spacing: 8) {
                                Text(d.role.capitalized)
                                    .font(.caption).fontWeight(.bold)
                                    .padding(.horizontal, 10).padding(.vertical, 4)
                                    .background(roleColor(d.role).opacity(0.1))
                                    .foregroundColor(roleColor(d.role))
                                    .cornerRadius(8)
                                if !d.is_approved {
                                    Text("PENDING")
                                        .font(.caption).fontWeight(.bold)
                                        .padding(.horizontal, 10).padding(.vertical, 4)
                                        .background(Color.orange.opacity(0.15))
                                        .foregroundColor(.orange)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                        
                        Divider()
                        
                        // Details
                        AdminDetailRow(icon: "envelope.fill", label: "Email", value: d.email)
                        if let phone = d.phone { AdminDetailRow(icon: "phone.fill", label: "Phone", value: phone) }
                        if let contact = d.contact_person { AdminDetailRow(icon: "person.fill", label: "Contact Person", value: contact) }
                        if let license = d.license_number { AdminDetailRow(icon: "doc.badge.gearshape", label: "License Number", value: license) }
                        if let capacity = d.capacity { AdminDetailRow(icon: "person.3.fill", label: "Capacity", value: capacity) }
                        if let address = d.address { AdminDetailRow(icon: "map.fill", label: "Address", value: address) }
                        if let open = d.opening_time, let close = d.closing_time {
                            AdminDetailRow(icon: "clock.fill", label: "Hours", value: "\(open) – \(close)")
                        }
                        if let exp = d.years_experience { AdminDetailRow(icon: "star.fill", label: "Experience", value: "\(exp) years") }
                        AdminDetailRow(icon: "calendar", label: "Registered", value: String(d.created_at.prefix(10)))
                        
                        // Approve button
                        if !d.is_approved {
                            Button(action: { isApproving = true; onApprove?() }) {
                                HStack {
                                    if isApproving {
                                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Approve Account")
                                    }
                                }
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(14)
                            }
                            .padding(.top, 8)
                            .disabled(isApproving)
                        } else {
                            HStack {
                                Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                                Text("Account is Active").fontWeight(.semibold).foregroundColor(.green)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.08))
                            .cornerRadius(14)
                        }
                    } else {
                        Text("Could not load user details.").foregroundColor(.gray).padding(.top, 60).frame(maxWidth: .infinity)
                    }
                }
                .padding()
            }
            .navigationTitle("User Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear {
            Task {
                do {
                    let d = try await AdminService.shared.fetchUserDetails(userId: userId)
                    DispatchQueue.main.async { details = d; isLoading = false }
                } catch {
                    DispatchQueue.main.async { isLoading = false }
                }
            }
        }
    }
    
    private func roleColor(_ role: String) -> Color {
        switch role.lowercased() {
        case "parent": return Color(hex: "#7D61FF")
        case "preschool": return Color(hex: "#FF8C00")
        case "daycare": return Color(hex: "#00BC8C")
        default: return .gray
        }
    }
}

struct AdminDetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .frame(width: 22)
                .foregroundColor(.gray)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.caption).foregroundColor(.gray)
                Text(value).font(.subheadline).fontWeight(.medium)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ManagementUserRow: View {
    let name: String
    var email: String = ""
    let role: String
    var status: String? = nil
    var isPending: Bool = false
    let color: Color
    var onTap: (() -> Void)? = nil
    var onApprove: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: 16) {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(String(name.prefix(1)))
                            .fontWeight(.bold)
                            .foregroundColor(color)
                    )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(name)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.textPrimary)
                    Text(email.isEmpty ? role : email)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isPending {
                    // Quick approve button
                    Button(action: { onApprove?() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                            Text("Approve")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    
                    // Pending badge
                    Text("Pending")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(5)
                } else if let status = status {
                    Text(status)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding()
            .background(AppTheme.surface)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(isPending ? Color.orange.opacity(0.3) : Color(hex: "#F1F4F9"), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

