import SwiftUI

public struct ChildcareManagementView: View {
    @State private var searchText = ""
    @State private var selectedTab = 0
    @State private var providers: [AdminUser] = []
    @State private var isLoading = false
    @State private var selectedUserId: Int? = nil
    @State private var showUserDetail = false
    @EnvironmentObject var themeManager: ThemeManager
    let tabs = ["Preschools", "Daycares"]
    
    public init(initialTab: Int = 0) {
        _selectedTab = State(initialValue: initialTab)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            AppHeader(title: "Care Centers")
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search providers...", text: $searchText)
                    .font(.body)
            }
            .padding(14)
            .background(Color(hex: "#F1F4F9").opacity(0.3))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.05)))
            .padding()
            
            // Tabs
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    VStack(spacing: 8) {
                        Text(tabs[index])
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(selectedTab == index ? themeManager.primaryColor : .gray)
                        
                        Rectangle()
                            .fill(selectedTab == index ? themeManager.primaryColor : Color.clear)
                            .frame(height: 3)
                            .cornerRadius(1.5)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation { selectedTab = index }
                    }
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack(spacing: 12) {
                    if isLoading {
                        ProgressView().padding(.top, 40)
                    } else {
                        let roleFilter = selectedTab == 0 ? "Preschool" : "Daycare"
                        let roleColor = selectedTab == 0 ? Color(hex: "#FF8C00") : Color(hex: "#00BC8C")
                        let filtered = providers.filter {
                            $0.role.capitalized == roleFilter &&
                            (searchText.isEmpty || $0.email.localizedCaseInsensitiveContains(searchText))
                        }
                        let pending = filtered.filter { $0.is_approved == false }
                        let active = filtered.filter { $0.is_approved != false }
                        
                        if !pending.isEmpty {
                            AdminSectionHeader(title: "Pending Approval", count: pending.count, color: .orange)
                        }
                        ForEach(pending) { p in
                            ManagementUserRow(
                                name: p.email.split(separator: "@").first.map(String.init)?.capitalized ?? roleFilter,
                                email: p.email,
                                role: roleFilter,
                                isPending: true,
                                color: .orange,
                                onTap: { selectedUserId = p.id; showUserDetail = true },
                                onApprove: { approveUser(p.id) }
                            )
                        }
                        if !pending.isEmpty && !active.isEmpty {
                            AdminSectionHeader(title: "Active \(tabs[selectedTab])", count: active.count, color: roleColor)
                        }
                        ForEach(active) { p in
                            ManagementUserRow(
                                name: p.email.split(separator: "@").first.map(String.init)?.capitalized ?? roleFilter,
                                email: p.email,
                                role: roleFilter,
                                status: "Active",
                                color: roleColor,
                                onTap: { selectedUserId = p.id; showUserDetail = true }
                            )
                        }
                        if filtered.isEmpty {
                            Text("No \(tabs[selectedTab].lowercased()) found.").foregroundColor(.gray).padding(.top, 40)
                        }
                    }
                }
                .padding()
            }
        }
        .background(AppTheme.surface)
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
                    self.providers = allUsers.filter { ["preschool", "daycare"].contains($0.role.lowercased()) }
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
}

struct ManagementProviderCard: View {
    let name: String
    let status: String
    let verified: Bool
    let rating: String
    let joined: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(hex: "#F1F4F9"))
                    .frame(width: 48, height: 48)
                    .overlay(Text(String(name.prefix(1))).foregroundColor(.gray))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(name)
                            .font(.body)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    
                    HStack(spacing: 8) {
                        Text(status)
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(statusColor.opacity(0.1))
                            .foregroundColor(statusColor)
                            .cornerRadius(4)
                        
                        if verified {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 8))
                                Text("Verified")
                                    .font(.system(size: 8, weight: .bold))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(themeManager.primaryColor.opacity(0.1))
                            .foregroundColor(themeManager.primaryColor)
                            .cornerRadius(4)
                        }
                    }
                }
            }
            
            Divider()
                .background(Color(hex: "#F1F4F9"))
            
            HStack {
                HStack(spacing: 4) {
                    Text(rating)
                        .fontWeight(.bold)
                    Text("Rating")
                        .foregroundColor(.gray)
                }
                .font(.system(size: 10))
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Joined")
                        .foregroundColor(.gray)
                    Text(joined)
                        .fontWeight(.bold)
                }
                .font(.system(size: 10))
                
                Spacer()
                
                NavigationLink(destination: ProviderDetailView(
                    name: name,
                    type: "Service",
                    rating: Double(rating) ?? 4.5,
                    price: 1000,
                    experience: joined,
                    certifications: verified ? ["Verified Center"] : [],
                    amenities: ["Professional Care"],
                    description: "\(name) is a registered childcare provider managing excellence in care."
                )) {
                    Text("View Details")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(themeManager.primaryColor)
                }
            }
        }
        .padding()
        .background(AppTheme.surface)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(hex: "#F1F4F9"), lineWidth: 1))
    }
    
    private var statusColor: Color {
        switch status {
        case "active": return .green
        case "pending": return .orange
        case "inactive": return .gray
        default: return .gray
        }
    }
}
